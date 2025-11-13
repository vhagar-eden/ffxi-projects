_addon.name = 'Spoils'
_addon.author = 'Vhagar'
_addon.version = '1.4'
_addon.commands = {'spoils'}

-- Lightweight Spoils addon (items-only display). Minimal and focused.
local texts = require('texts')
local res = require('resources')

-- Try to load settings (must exist: Spoils/settings/position.lua returning a table)
local ok, settings = pcall(require, 'settings.position')
if not ok or type(settings) ~= 'table' then
    settings = { window_position = { x = 50, y = 300 } }
end

-- Save settings (writes the Lua table back to same file)
local sep = package.config:sub(1,1)
local settings_path = windower.addon_path .. 'settings' .. sep .. 'position.lua'
local function save_settings()
    local f, err = io.open(settings_path, 'w')
    if not f then
        windower.add_to_chat(123, '[Spoils] Failed to save settings: ' .. tostring(err))
        return
    end
    f:write("return {\n")
    f:write(string.format("    window_position = { x = %d, y = %d },\n", settings.window_position.x, settings.window_position.y))
    f:write("}\n")
    f:close()
end

-- Core state
local treasure_pool = {}
local last_render_cache = ''
local pending_d2 = {}

-- Settings
local MAX_INDEX = 10
local PENDING_TIMEOUT = 12

-- On-screen display (draggable). Initialize at saved position.
local display = texts.new('', {
    pos = { x = settings.window_position.x or 50, y = settings.window_position.y or 300 },
    text = { size = 10, font = 'Consolas', stroke = { width = 2, alpha = 200 } },
    flags = { draggable = true },
    bg = { alpha = 120 }
})

-- ---------------------------
-- Packet / parsing helpers
-- ---------------------------
local function read_u16_le(data, offset)
    local b1, b2 = data:byte(offset + 1, offset + 2)
    if not b1 or not b2 then return nil end
    return b1 + b2 * 256
end

local function read_string(data, offset, length)
    local s = data:sub(offset + 1, offset + length)
    return s:match("^[^%z]*") or ''
end

local function normalize_index(src_idx)
    if not src_idx or type(src_idx) ~= 'number' then return nil end
    if src_idx >= 0 and src_idx <= (MAX_INDEX - 1) then return src_idx + 1 end
    if src_idx >= 1 and src_idx <= MAX_INDEX then return src_idx end
    return nil
end

local function parse_d2_fixed(data)
    local pkt_idx_raw = read_u16_le(data, 8)
    local itid = read_u16_le(data, 10)
    local pkt_idx = normalize_index(pkt_idx_raw)
    return pkt_idx_raw, pkt_idx, itid
end

-- ---------------------------
-- Display formatting (items only)
-- ---------------------------
local function pool_to_string()
    local lines = {'Treasure Pool:'}
    local keys = {}
    for k in pairs(treasure_pool) do table.insert(keys, k) end
    table.sort(keys)
    if #keys == 0 then
        table.insert(lines, '(Empty)')
        return table.concat(lines, '\n')
    end
    for display_idx = 1, #keys do
        local internal_idx = keys[display_idx]
        local e = treasure_pool[internal_idx]
        if e then
            table.insert(lines, string.format('%d: %s', display_idx, e.name or ('Item #'..(e.item_id or 0))))
        end
    end
    return table.concat(lines, '\n')
end

local function update_display_if_needed()
    local text = pool_to_string()
    if text ~= last_render_cache then
        display:text(text)
        display:visible(true)
        last_render_cache = text
    end
end

-- ---------------------------
-- Memory-reading (preferred source)
-- ---------------------------
local function refresh_from_memory()
    local ok, items = pcall(function() return windower.ffxi.get_items() end)
    if not ok or not items then return false end
    local pool_tbl = nil
    if type(items) == 'table' then
        pool_tbl = items.treasure or items.treasure_items or items.pool or nil
        if not pool_tbl then
            local numeric_entries = {}
            for k, v in pairs(items) do
                if type(k) == 'number' and (type(v) == 'table' or type(v) == 'number') then
                    numeric_entries[k] = v
                end
            end
            if next(numeric_entries) then pool_tbl = numeric_entries end
        end
    end
    if type(pool_tbl) == 'table' and next(pool_tbl) == nil then
        treasure_pool = {}
        return true
    end
    if not pool_tbl or (type(pool_tbl) == 'table' and next(pool_tbl) == nil) then return false end
    local min_key = nil
    for k, _ in pairs(pool_tbl) do
        if type(k) == 'number' then
            if not min_key or k < min_key then min_key = k end
        end
    end
    local offset = (min_key == 0) and 1 or 0
    local new_pool = {}
    for k, entry in pairs(pool_tbl) do
        if type(k) == 'number' then
            local display_idx = k + offset
            if display_idx >= 1 and display_idx <= MAX_INDEX then
                local item_id, name
                if type(entry) == 'table' then
                    item_id = entry.id or entry.item_id or entry.item
                    name = entry.name or (item_id and res.items[item_id] and res.items[item_id].name)
                elseif type(entry) == 'number' then
                    item_id = entry
                    name = res.items[item_id] and res.items[item_id].name
                end
                if item_id and item_id > 0 then
                    new_pool[display_idx] = {
                        item_id = item_id,
                        name = (name or (res.items[item_id] and res.items[item_id].name) or ('Item #'..item_id)),
                        lotters = {}
                    }
                end
            end
        end
    end
    if next(new_pool) then
        treasure_pool = new_pool
        return true
    else
        return false
    end
end

-- ---------------------------
-- Pending D2 reconciliation
-- ---------------------------
local function build_item_index_map()
    local map = {}
    for idx, e in pairs(treasure_pool) do
        if e and e.item_id then
            map[e.item_id] = map[e.item_id] or {}
            table.insert(map[e.item_id], idx)
        end
    end
    return map
end

local function reconcile_pending_d2()
    if #pending_d2 == 0 then return end
    local now = os.time()
    local mem_ok = refresh_from_memory()
    local map = build_item_index_map()
    local i = 1
    while i <= #pending_d2 do
        local p = pending_d2[i]
        if now - p.ts > PENDING_TIMEOUT then
            table.remove(pending_d2, i)
        else
            local assigned = false
            if mem_ok and map[p.item_id] and #map[p.item_id] > 0 then
                for _, idx in ipairs(map[p.item_id]) do
                    if not treasure_pool[idx] then
                        treasure_pool[idx] = {
                            item_id = p.item_id,
                            name = res.items[p.item_id] and res.items[p.item_id].name or ('Item #'..p.item_id),
                            lotters = {}
                        }
                        assigned = true
                        break
                    end
                end
            end
            if not assigned then
                local normalized = normalize_index(p.pkt_index_raw)
                if normalized and not treasure_pool[normalized] then
                    treasure_pool[normalized] = {
                        item_id = p.item_id,
                        name = res.items[p.item_id] and res.items[p.item_id].name or ('Item #'..p.item_id),
                        lotters = {}
                    }
                    assigned = true
                end
            end
            if assigned then
                table.remove(pending_d2, i)
            else
                i = i + 1
            end
        end
    end
end

-- ---------------------------
-- Packet handling (D2 only)
-- ---------------------------
windower.register_event('incoming chunk', function(id, data)
    if id == 0xD2 then
        local pkt_idx_raw, pkt_idx_norm, itid = parse_d2_fixed(data)
        if itid ~= nil then
            if itid > 0 then
                if pkt_idx_norm and not treasure_pool[pkt_idx_norm] then
                    treasure_pool[pkt_idx_norm] = {
                        item_id = itid,
                        name = res.items[itid] and res.items[itid].name or ('Item #'..itid),
                        lotters = {}
                    }
                    update_display_if_needed()
                else
                    table.insert(pending_d2, { item_id = itid, pkt_index_raw = pkt_idx_raw, ts = os.time() })
                end
            else
                if pkt_idx_norm and treasure_pool[pkt_idx_norm] then
                    treasure_pool[pkt_idx_norm] = nil
                    update_display_if_needed()
                else
                    local normalized = normalize_index(pkt_idx_raw)
                    if normalized and treasure_pool[normalized] then
                        treasure_pool[normalized] = nil
                        update_display_if_needed()
                    end
                end
            end
        end
    end
end)

-- ---------------------------
-- Prerender reconciliation (and position save)
-- ---------------------------
local tick = 0
windower.register_event('prerender', function()
    tick = tick + 1
    if tick % 10 ~= 0 then return end

    refresh_from_memory()
    reconcile_pending_d2()
    update_display_if_needed()

    -- position save: follow SleepTimers' simple pattern
    local x, y = display:pos()
    if x ~= settings.window_position.x or y ~= settings.window_position.y then
        settings.window_position.x = x
        settings.window_position.y = y
        save_settings()
    end
end)

-- ---------------------------
-- Addon commands
-- ---------------------------
windower.register_event('addon command', function(cmd, ...)
    cmd = cmd and cmd:lower() or ''
    if cmd == 'clear' then
        treasure_pool = {}
        pending_d2 = {}
        last_render_cache = ''
        update_display_if_needed()
        print('[Spoils] Cleared pool + pending queues')
    else
        print('Spoils commands:')
        print('//spoils clear         — clear pool and pending events')
    end
end)

-- ---------------------------
-- Zone change cleanup
-- ---------------------------
windower.register_event('zone change', function()
    treasure_pool = {}
    pending_d2 = {}
    last_render_cache = ''
    display:text('')
    display:visible(false)
end)

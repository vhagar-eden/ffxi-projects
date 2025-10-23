--[[Copyright © 2020, Kenshi
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of PartyBuffs nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL KENSHI BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.name = 'PartyBuffs'
_addon.author = 'Kenshi'
_addon.version = '3.7 - Vhagars Eden patch'
_addon.commands = {'pb', 'partybuffs'}

images  = require('images')
packets = require('packets')
config  = require('config')
require('pack')
require('tables')
require('filters')

-- Try to load external sorting file (optional)
local sorting = {}
local sorting_ok, sorting_mod = pcall(require, 'sorting')
if sorting_ok and type(sorting_mod) == 'table' then
    sorting = sorting_mod
else
    sorting.priority_left = {}   -- empty defaults if not provided
    sorting.priority_right = {}
end

-- ===================================================================
-- Settings
-- ===================================================================
defaults = {}
defaults.size = 20
defaults.mode = 'whitelist'
defaults.self_row = true   -- default ON
settings = config.load(defaults)

aliases = T{
    w='whitelist', wlist='whitelist', white='whitelist', whitelist='whitelist',
    b='blacklist', blist='blacklist', black='blacklist', blacklist='blacklist'
}
alias_strs = aliases:keyset()

local icon_size = (settings.size == 20 or defaults.size == 20) and 20 or 10
local party_buffs = {'p1', 'p2', 'p3', 'p4', 'p5'}

local x_pos = windower.get_windower_settings().ui_x_res - 150

-- Render objects for party members (unchanged)
do
    for k = 1, 5 do
        party_buffs[k] = T{}
        for i = 1, 32 do
            party_buffs[k][i] = images.new({
                color = { alpha = 255 },
                texture = { fit = false },
                draggable = false,
            })
        end
    end
end

-- ===================================================================
-- NEW: Self row (isolated)
-- ===================================================================
local self_images = T{}
for i = 1, 32 do
    self_images[i] = images.new({
        color = { alpha = 255 },
        texture = { fit = false },
        draggable = false,
    })
end

local self_vec = {}
for i = 1, 32 do self_vec[i] = 1000 end

-- ===================================================================
-- State (party logic unchanged)
-- ===================================================================
local member_name_by_index = T{ [1]=nil, [2]=nil, [3]=nil, [4]=nil, [5]=nil }
local member_id_by_name    = T{}
local buffs = T{ whitelist = {}, blacklist = {} }
local zoning_bool = false
local debug_enabled = false

-- Build y positions once (for party rows)
local party_buffs_y_pos = {}
do
    for i = 2, 6 do
        local y_pos = windower.get_windower_settings().ui_y_res - 5
        party_buffs_y_pos[i] = y_pos - 20 * i
    end
end

-- ===================================================================
-- Helpers
-- ===================================================================
local function debug(msg)
    if debug_enabled then windower.add_to_chat(207, '[PB] '..tostring(msg)) end
end

local function hide_self_row()
    for i = 1, 32 do
        self_images[i]:clear()
        self_images[i]:hide()
        self_images[i]:update()
    end
end

-- table utility: shallow contains for arrays
local function tbl_contains(arr, v)
    if not arr then return false end
    for _,x in ipairs(arr) do if x == v then return true end end
    return false
end

-- Build presence map from a vector (keep counts in case duplicates)
local function build_presence(vec)
    local pres = {}
    for _, v in ipairs(vec) do
        if v and v ~= 1000 then
            pres[v] = (pres[v] or 0) + 1
        end
    end
    return pres
end

-- The main priority sort function.
-- Input: vec (array of numbers, 1000 = blank)
-- Output: new array (length 32) ordered: left priorities, then middle (numeric), then right priorities.
local function sort_with_priority(vec)
    -- Build presence map (counts)
    local pres = build_presence(vec)

    local left_list = {}
    local middle_list = {}
    local right_list = {}

    -- Collect left by the order specified in sorting.priority_left
    if sorting.priority_left and #sorting.priority_left > 0 then
        for _, id in ipairs(sorting.priority_left) do
            while pres[id] and pres[id] > 0 do
                table.insert(left_list, id)
                pres[id] = pres[id] - 1
                if pres[id] == 0 then pres[id] = nil end
            end
        end
    end

    -- Collect right by the order in sorting.priority_right (we will append at the end)
    -- but store separately to append after middle.
    if sorting.priority_right and #sorting.priority_right > 0 then
        for _, id in ipairs(sorting.priority_right) do
            while pres[id] and pres[id] > 0 do
                table.insert(right_list, id)
                pres[id] = pres[id] - 1
                if pres[id] == 0 then pres[id] = nil end
            end
        end
    end

    -- Remaining ids -> middle; gather in numeric order
    local rem = {}
    for id, cnt in pairs(pres) do
        for n = 1, cnt do
            table.insert(rem, id)
        end
    end
    table.sort(rem, function(a,b) return a < b end)
    for _, id in ipairs(rem) do table.insert(middle_list, id) end

    -- Combine: visually left = priority_right, middle, visually right = priority_left
	local out = {}
	for _,v in ipairs(right_list)  do table.insert(out, v) end  -- priority_right goes left
	for _,v in ipairs(middle_list) do table.insert(out, v) end
	for _,v in ipairs(left_list)   do table.insert(out, v) end  -- priority_left goes right


    -- Pad to 32 with 1000
    while #out < 32 do table.insert(out, 1000) end

    return out
end

-- Rebuild our name/id maps using get_party()
local function rebuild_member_maps()
    local party = windower.ffxi.get_party()
    if not party then return false end

    local key_indices = {'p1','p2','p3','p4','p5'}
    local changed = false

    for idx = 1, 5 do
        local key = key_indices[idx]
        local m = party[key]
        local old_name = member_name_by_index[idx]
        local new_name, new_id = nil, nil

        if m and m.mob and not m.mob.is_npc then
            new_name = m.name
            new_id   = m.mob.id
        end

        if old_name ~= new_name or (new_name and member_id_by_name[new_name] ~= new_id) then
            changed = true
        end

        member_name_by_index[idx] = new_name

        if old_name and old_name ~= new_name then
            member_id_by_name[old_name] = nil
        end
        if new_name and new_id then
            member_id_by_name[new_name] = new_id
        end
    end

    if changed then
        debug('Party changed -> rebuilt name/id maps.')
    end
    return changed
end

local function parse_latest_buffs_if_any()
    local data = windower.packets.last_incoming(0x076)
    if data then
        parse_buffs(data)
        return true
    end
    return false
end

local function party_signature()
    local s = {}
    for i=1,5 do
        local n = member_name_by_index[i]
        local id = n and member_id_by_name[n] or 0
        s[#s+1] = (n or '-')..':'..tostring(id)
    end
    return table.concat(s,'|')
end

-- ===================================================================
-- Packet handlers
-- ===================================================================
windower.register_event('incoming chunk', function(id, data)
    if id == 0x0DD then
        local p = packets.parse('incoming', data)
        if p and p.Name and p.ID then
            for idx = 1,5 do
                if member_name_by_index[idx] == p.Name then
                    member_id_by_name[p.Name] = p.ID
                    debug('0x0DD updated '..p.Name..' -> '..tostring(p.ID))
                end
            end
            coroutine.schedule(buff_sort, 0.5)
        end
    end

    if id == 0x076 then
        parse_buffs(data)
    end

    if id == 0x0B then
        zoning_bool = true
        buff_sort()
    elseif id == 0x0A and zoning_bool then
        zoning_bool = false
        coroutine.schedule(buff_sort, 10)
    end
end)

-- ===================================================================
-- Buff parsing and drawing
-- ===================================================================
function parse_buffs(data)
    for k = 0, 4 do
        local id = data:unpack('I', k*48+5)
        buffs.whitelist[id] = buffs.whitelist[id] or {}
        buffs.blacklist[id] = buffs.blacklist[id] or {}

        if id ~= 0 then
            for i = 1, 32 do
                local buff = data:byte(k*48+5+16+i-1) + 256*( math.floor( data:byte(k*48+5+8+ math.floor((i-1)/4)) / 4^((i-1)%4) )%4)
                if buffs.whitelist[id][i] ~= buff then
                    buffs.whitelist[id][i] = buff
                end
                if buffs.blacklist[id][i] ~= buff then
                    buffs.blacklist[id][i] = buff
                end
            end
        end
    end
    buff_sort()
end

function buff_sort()
    local player = windower.ffxi.get_player()
    local party  = windower.ffxi.get_party()
    if not player or not party then return end

    for k = 1, 5 do
        local member = party['p'..k]
        for i = 1, 32 do
            if member then
                local id = member_id_by_name[member.name]
                if id and buffs[settings.mode][id] and buffs[settings.mode][id][i] then
                    if buffs[settings.mode][id][i] == 255 then
                        buffs[settings.mode][id][i] = 1000
                    elseif blacklist[player.name] and blacklist[player.name][player.main_job] and blacklist[player.name][player.main_job]:contains(buffs.blacklist[id][i]) then
                        buffs.blacklist[id][i] = 1000
                    elseif whitelist[player.name] and whitelist[player.name][player.main_job] and not whitelist[player.name][player.main_job]:contains(buffs.whitelist[id][i]) then
                        buffs.whitelist[id][i] = 1000
                    end
                end
            end
        end
        if member then
            local id = member_id_by_name[member.name]
            if id and buffs[settings.mode][id] then
                -- Create a full 32-vector from the possibly-sparse table and run priority sort
                local raw = {}
                for ii = 1, 32 do raw[ii] = buffs[settings.mode][id][ii] or 1000 end
                local sorted = sort_with_priority(raw)
                buffs[settings.mode][id] = sorted
            end
        end
    end

    -- Self row first (only if enabled)
    if settings.self_row then
        UpdateSelf()
    else
        hide_self_row()
    end

    -- Party rows next
    Update(buffs[settings.mode])
end

function Update(buff_table)
    local party_info = windower.ffxi.get_party_info()
    local zone = windower.ffxi.get_info().zone
    local party = windower.ffxi.get_party()
    if not party then return end

    local key_indices = {'p1','p2','p3','p4','p5'}

    for k = 1, 5 do
        local member = party[key_indices[k]]

        for image, i in party_buffs[k]:it() do
            if member then
                local id = member_id_by_name[member.name]
                if id and buff_table[id] and buff_table[id][i] then
                    if zoning_bool or member.zone ~= zone or buff_table[id][i] == 1000 then
                        buff_table[id][i] = 1000
                        image:clear(); image:hide()
                    elseif buff_table[id][i] == 255 or buff_table[id][i] == 0 then
                        buff_table[id][i] = 1000
                        image:clear(); image:hide()
                    else
                        image:path(windower.windower_path .. 'addons/PartyBuffs/icons/' .. buff_table[id][i] .. '.png')
                        image:transparency(0)
                        image:size(icon_size, icon_size)
                        if party_info and party_info.party1_count > 1 then
                            local pt_y_pos = party_buffs_y_pos[party_info.party1_count]
                            local x = (icon_size == 20 and x_pos - (i*20))
                                   or (i <= 16 and x_pos - (i*10))
                                   or x_pos - ((i-16)*10)
                            local y = (icon_size == 20 and pt_y_pos + ((k-1)*20))
                                   or (i <= 16 and pt_y_pos + ((k-1)*20))
                                   or pt_y_pos + (((k-1)*20)+10)
                            image:pos_x(x); image:pos_y(y)
                        end
                        if windower.ffxi.get_player().status ~= 4 then
                            image:show()
                        end
                    end
                end
            else
                image:clear(); image:hide()
            end
            image:update()
        end
    end
end

-- ===================================================================
-- Self row logic with solo fix (uses same sorting function)
-- ===================================================================
local function apply_filters_to_vec(vec)
    local player = windower.ffxi.get_player()
    if not player then return end

    for i = 1, 32 do
        local v = vec[i]
        if v == 255 or v == 0 or v == nil then
            vec[i] = 1000
        else
            if settings.mode == 'blacklist' then
                if blacklist[player.name] and blacklist[player.name][player.main_job] and blacklist[player.name][player.main_job]:contains(v) then
                    vec[i] = 1000
                end
            elseif settings.mode == 'whitelist' then
                if whitelist[player.name] and whitelist[player.name][player.main_job] and not whitelist[player.name][player.main_job]:contains(v) then
                    vec[i] = 1000
                end
            end
        end
    end
end

function UpdateSelf()
    local player = windower.ffxi.get_player()
    if not player then
        for i = 1, 32 do self_images[i]:clear(); self_images[i]:hide(); self_images[i]:update() end
        return
    end

    for i = 1, 32 do
        local b = player.buffs and player.buffs[i] or nil
        if b and b > 0 then
            self_vec[i] = b
        else
            self_vec[i] = 1000
        end
    end

    apply_filters_to_vec(self_vec)

    -- Use priority sorting (shared)
    local sorted = sort_with_priority(self_vec)
    -- replace self_vec with sorted (ensures 32 slots)
    for i = 1, 32 do self_vec[i] = sorted[i] end

    local party_info = windower.ffxi.get_party_info()
    local pt_count = (party_info and party_info.party1_count) or 1

    -- SOLO FIX: anchor self row at fixed offset if alone
    local base_y
    if pt_count == 1 then
        base_y = windower.get_windower_settings().ui_y_res - 45
    else
        local pt_y_pos = party_buffs_y_pos[pt_count] or (windower.get_windower_settings().ui_y_res - 5)
        base_y = pt_y_pos - 20
    end

    for i = 1, 32 do
        local id = self_vec[i]
        local img = self_images[i]
        if id and id ~= 1000 then
            img:path(windower.windower_path .. 'addons/PartyBuffs/icons/' .. id .. '.png')
            img:transparency(0)
            img:size(icon_size, icon_size)
            local x = (icon_size == 20 and x_pos - (i*20))
                   or (i <= 16 and x_pos - (i*10))
                   or x_pos - ((i-16)*10)
            img:pos_x(x); img:pos_y(base_y)
            if windower.ffxi.get_player().status ~= 4 then
                img:show()
            end
        else
            img:clear(); img:hide()
        end
        img:update()
    end
end

-- ===================================================================
-- Other events (self row respects settings.self_row)
-- ===================================================================
windower.register_event('status change', function(new_status_id)
    if new_status_id == 4 then -- cutscene/menu
        for k = 1, 5 do
            for image, _ in party_buffs[k]:it() do image:hide() end
        end
        hide_self_row()
    else
        Update(buffs[settings.mode])
        if settings.self_row then UpdateSelf() else hide_self_row() end
    end
end)

-- Delay init slightly to ensure player object is ready
windower.register_event('load', function()
    coroutine.schedule(function()
        if not windower.ffxi.get_info().logged_in then return end
        rebuild_member_maps()
        -- Try to seed from latest 0x076 so buffs appear without waiting
        if not parse_latest_buffs_if_any() then
            coroutine.schedule(buff_sort, 0.5)
        end
        if settings.self_row then UpdateSelf() else hide_self_row() end
    end, 3)
end)

windower.register_event('login', function()
    coroutine.schedule(function()
        rebuild_member_maps()
        parse_latest_buffs_if_any()
        buff_sort()
        if settings.self_row then UpdateSelf() else hide_self_row() end
    end, 3)
end)

windower.register_event('zone change', function()
    coroutine.schedule(function()
        rebuild_member_maps()
        parse_latest_buffs_if_any()
        buff_sort()
        if settings.self_row then UpdateSelf() else hide_self_row() end
    end, 5)
end)

-- ===================================================================
-- Prerender poller (every ~1s): detects party joins/leaves reliably
-- ===================================================================
do
    local last_sig = ''
    local last_tick = 0
    windower.register_event('prerender', function()
        local t = os.clock()
        if t - last_tick < 1.0 then return end
        last_tick = t

        local changed = rebuild_member_maps()
        local sig = party_signature()
        if changed or sig ~= last_sig then
            last_sig = sig
            debug('Detected party change -> refreshing (sig: '..sig..')')
            -- Grab freshest buff snapshot if available so icons show at once
            local got = parse_latest_buffs_if_any()
            if not got then
                coroutine.schedule(buff_sort, 0.2)
            end
        end

        if settings.self_row then UpdateSelf() else hide_self_row() end
    end)
end

-- ===================================================================
-- Commands (added 'self' handler)
-- ===================================================================
windower.register_event('addon command', function(...)
    local args = T{...}
    local command = args[1] and args[1]:lower()
    if not command then
        windower.add_to_chat(207,"First argument not specified, use size, mode, self, debug or help.")
        return
    end

    if command == 'size' then
        if not args[2] then
            windower.add_to_chat(207,"Size not specified.")
        elseif args[2] == '10' then
            if icon_size == 10 then windower.add_to_chat(207,"Size already 10.")
            else settings.size = 10; icon_size = 10; settings:save(); buff_sort()
                 windower.add_to_chat(207,'Icons size set to 10x10.') end
        elseif args[2] == '20' then
            if icon_size == 20 then windower.add_to_chat(207,"Size already 20.")
            else settings.size = 20; icon_size = 20; settings:save(); buff_sort()
                 windower.add_to_chat(207,'Icons size set to 20x20.') end
        else
            windower.add_to_chat(207,'Icons size has to be 10 or 20.')
        end

    elseif command == 'mode' then
        local mode = args[2] or 'status'
        if alias_strs:contains(mode) then
            if aliases[mode] == settings.mode then
                windower.add_to_chat(207,'Mode is already in ' .. settings.mode .. ' mode.')
            else
                settings.mode = aliases[mode]; settings:save(); buff_sort()
                windower.add_to_chat(207,'Mode switched to ' .. settings.mode .. '.')
            end
        elseif mode == 'status' then
            windower.add_to_chat(207,'Currently in ' .. settings.mode .. ' mode.')
        else
            windower.add_to_chat(207,'Invalid mode:', args[1]); return
        end

    elseif command == 'self' then
        local arg = (args[2] or ''):lower()
        if arg == 'on' then
            settings.self_row = true
            settings:save()
            windower.add_to_chat(207,'[PB] Self row ON')
            UpdateSelf()
        elseif arg == 'off' then
            settings.self_row = false
            settings:save()
            windower.add_to_chat(207,'[PB] Self row OFF')
            hide_self_row()
        else
            windower.add_to_chat(207,'Usage: //pb self on|off')
        end

    elseif command == 'debug' then
        local onoff = (args[2] or ''):lower()
        if onoff == 'on' then debug_enabled = true;  windower.add_to_chat(207,'[PB] debug ON')
        elseif onoff == 'off' then debug_enabled = false; windower.add_to_chat(207,'[PB] debug OFF')
        else windower.add_to_chat(207,'Use: //pb debug on|off') end

    elseif command == 'help' then
        windower.add_to_chat(207,"Partybuffs Commands:")
        windower.add_to_chat(207,"//pb|partybuffs size 10|20")
        windower.add_to_chat(207,"//pb|partybuffs mode w|whitelist | b|blacklist")
        windower.add_to_chat(207,"//pb|partybuffs self on|off")
        windower.add_to_chat(207,"//pb|partybuffs debug on|off")
    end
end)

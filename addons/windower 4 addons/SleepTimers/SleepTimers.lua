--[[
!!!Important!!! - This addon is made specifically for EdenXI Private Server.
This addon uses action packet values and spell IDs that are specific to Eden.
This addon will NOT work on other servers without correction to the values found in the following functions -

local sleep_spells
local damage_categories
local sleep_messages

You would also have to input the correct Spell IDs into the "damaging_spells.lua" file.

About the config file -

Position can be set manually, otherwise just click and drag the window where you want it and it will be saved automatically.
To get correct timers for bard's lullabies you have to manually toggle on the instrument they're using for lullaby.
Lullaby timers are set to 30s by default. 33s if "marys_horn" is set to true, and 36s if "nursemaids_harp" or "gjallarhorn" are set to true.
The triggers found under "your_bard" will change the timers for your bard only, the triggers found under "other_bard" will change timers for other bards only.
You can set these triggers manually by opening the config file and changing the values, saving, and then reloading the addon in game, or simply use the command system listed below in game after loading the addon.

Command System -

Type //sleeptimers or //st in game to show the command syntax -
//sleeptimers bard me|other none|mary|nurse|relic
//sleeptimers showconfig (this shows your current settings)

**Examples**
//st bard me mary - sets "marys_horn" to 'true' for "your_bard"
//st bard other relic - sets "gjallarhorn" to 'true' for "other_bard"
//sleeptimers bard other none - sets all conditions for "other_bard" to false and resets their lullaby timers to 30s

Once a command is entered, the correct timers will show for consecutive casts, no need to reload the addon or open the config file.
Settings changed by commands are saved to the config file and will remain the same until you change them again.
]]

_addon.name = 'SleepTimers'
_addon.version = '1.34'
_addon.author = 'Vhagar@Eden'
_addon.commands = {'sleeptimers','st'} 

texts = require('texts')
res = require('resources')

-- External list of damaging spells
local damaging_spells = require('damaging_spells')

-- Load settings
local settings = require('settings.config')

-- Save current settings to config.lua
local function save_settings()
    local path = windower.addon_path .. 'settings/config.lua'
    local f = io.open(path, 'w')
    if f then
        f:write("return {\n")
        f:write(string.format("    window_position = { x = %d, y = %d },\n", settings.window_position.x, settings.window_position.y))

        -- Save bard instrument configs
        local function write_bard_config(name, bard)
            f:write("    " .. name .. " = {\n")
            f:write("        marys_horn = " .. tostring(bard.marys_horn) .. ",\n")
            f:write("        nursemaids_harp = " .. tostring(bard.nursemaids_harp) .. ",\n")
            f:write("        gjallarhorn = " .. tostring(bard.gjallarhorn) .. ",\n")
            f:write("    },\n")
        end

        write_bard_config("your_bard", settings.your_bard)
        write_bard_config("other_bard", settings.other_bard)

        f:write("}\n")
        f:close()
    end
end

local player_id = 0
local window
local tracked = {}
local last_positions = {}
local MOVE_THRESHOLD = 0.5
local MOVEMENT_CHECK_INTERVAL = 30
local GRACE_PERIOD = 2.0
local prerender_count = 0

-- All sleep spells
local sleep_spells = {
    [273] = {name='Sleepga', duration=60},
    [274] = {name='Sleepga II', duration=90},
    [376] = {name='Horde Lullaby', duration=30},
    [253] = {name='Sleep', duration=60},
    [259] = {name='Sleep II', duration=90},
    [463] = {name='Foe Lullaby', duration=30},
    [98]  = {name='Repose', duration=90},
}

-- Overwrite rules
local overwrite_map = {
    ['Sleepga II']   = {'Sleepga', 'Horde Lullaby', 'Foe Lullaby', 'Sleep'},
    ['Sleepga']      = {},
    ['Sleep II']     = {'Sleep', 'Sleepga', 'Horde Lullaby', 'Foe Lullaby'},
    ['Sleep']        = {},
    ['Repose']       = {'Sleep', 'Sleepga', 'Horde Lullaby', 'Foe Lullaby'},
    ['Horde Lullaby']= {},
    ['Foe Lullaby']  = {},
}

-- Helpers
local function table_contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

-- Bard instrument duration logic
local function get_lullaby_duration(is_self_cast)
    local bard_settings = is_self_cast and settings.your_bard or settings.other_bard
    if not bard_settings then return 30 end

    if bard_settings.gjallarhorn or bard_settings.nursemaids_harp then
        return 36
    elseif bard_settings.marys_horn then
        return 33
    else
        return 30
    end
end

local function create_window()
    if window then return end
    window = texts.new('SleepTimers\n', {
        pos = { x = settings.window_position.x, y = settings.window_position.y },
        text = { font='Consolas', size=12 },
        bg = { alpha = 200 },
    })
    window:show()
end

local function clear_tracked(mob_id)
    tracked[mob_id] = nil
    last_positions[mob_id] = nil
end

local function moved_enough(oldpos, newpos, threshold)
    if not oldpos or not newpos then return false end
    local dx = newpos.x - oldpos.x
    local dy = newpos.y - oldpos.y
    local dz = newpos.z - oldpos.z
    local dist2 = dx*dx + dy*dy + dz*dz
    return dist2 >= (threshold * threshold)
end

local function update_window()
    local target = windower.ffxi.get_mob_by_target('t')
    local debuffs = target and tracked[target.id]

    if not debuffs or #debuffs == 0 then
        if window then window:hide() end
        return
    end

    local now = os.clock()
    local mob_name = target and target.name or "Unknown"

    local lines = {
        "Sleep Timers",
        string.format("\\cs(255,0,0)%s\\cr", mob_name),
    }

    local i = 1
    while i <= #debuffs do
        if debuffs[i].ends <= now then
            table.remove(debuffs, i)
        else
            i = i + 1
        end
    end

    for _, info in ipairs(debuffs) do
        local remaining = math.floor(info.ends - now)
        if remaining > 0 then
            local color = (info.actor == player_id) and "\\cs(0,255,0)" or "\\cs(255,255,0)"
            table.insert(lines, string.format("%s%s: %ds\\cr", color, info.name, remaining))
        end
    end

    if #lines > 2 then
        window:text(table.concat(lines, '\n'))
        window:show()
    else
        window:hide()
    end
end

local function handle_sleep_spell(actor, target_id, spell_id)
    local spell = sleep_spells[spell_id]
    if not spell then return end

    local is_self_cast = (actor == player_id)

    -- Adjust duration if it's a Lullaby
    local duration = spell.duration
    if spell.name == "Foe Lullaby" or spell.name == "Horde Lullaby" then
        duration = get_lullaby_duration(is_self_cast)
    end

    tracked[target_id] = tracked[target_id] or {}
    local existing = tracked[target_id][1]

    if not existing then
        tracked[target_id][1] = {
            name = spell.name,
            ends = os.clock() + duration,
            actor = actor,
            duration = duration,
            applied_at = os.clock(),
        }
        local mob = windower.ffxi.get_mob_by_id(target_id)
        if mob and mob.x and mob.y and mob.z then
            last_positions[target_id] = { x = mob.x, y = mob.y, z = mob.z }
        end
        return
    end

    local can_overwrite = overwrite_map[spell.name] and table_contains(overwrite_map[spell.name], existing.name)
    if can_overwrite then
        tracked[target_id][1] = {
            name = spell.name,
            ends = os.clock() + duration,
            actor = actor,
            duration = duration,
            applied_at = os.clock(),
        }
        local mob = windower.ffxi.get_mob_by_id(target_id)
        if mob and mob.x and mob.y and mob.z then
            last_positions[target_id] = { x = mob.x, y = mob.y, z = mob.z }
        end
    end
end

local damage_categories = { [1]=true, [2]=true, [3]=true, [6]=true }

-- Sleep effect “landed” messages (spells + bard songs)
local sleep_messages = {
    [236]=true, -- Sleep/Sleep II/Sleepga/Sleepga II/Repose targeted mob
    [277]=true, -- Sleepga and Sleepga II AoE targets
    [237]=true, -- Bard’s Lullaby single
    [278]=true, -- Bard’s Lullaby AoE
}

windower.register_event('action', function(act)
    if not act or type(act) ~= 'table' then return end

    if act.category == 4 and sleep_spells[act.param] then
        for _, target in ipairs(act.targets or {}) do
            for _, a in ipairs(target.actions or {}) do
                if sleep_messages[a.message] then
                    handle_sleep_spell(act.actor_id, target.id, act.param)
                end
            end
        end
        return
    end

    if act.actor_id and tracked[act.actor_id] then
        clear_tracked(act.actor_id)
        return
    end

    if damage_categories[act.category] then
        for _, target in ipairs(act.targets or {}) do
            local woke = false
            for _, a in ipairs(target.actions or {}) do
                local dmg = a.param or a.damage or a.amount or a.count
                if dmg and dmg >= 1 then
                    woke = true
                    break
                end
            end
            if woke then
                clear_tracked(target.id)
            end
        end
    end

    if damaging_spells and damaging_spells[act.param] then
        for _, target in ipairs(act.targets or {}) do
            local woke = false
            for _, a in ipairs(target.actions or {}) do
                local dmg = a.param or a.damage or a.amount or a.count
                if dmg and dmg >= 1 then
                    woke = true
                    break
                end
            end
            if woke then
                clear_tracked(target.id)
            end
        end
    end
end)

windower.register_event('status change', function(mob_id, new_status_id)
    if new_status_id ~= 3 and new_status_id ~= 4 then
        clear_tracked(mob_id)
    end
end)

local function check_movement()
    for mob_id, debuffs in pairs(tracked) do
        if not debuffs or #debuffs == 0 then
            tracked[mob_id] = nil
            last_positions[mob_id] = nil
        else
            local mob = windower.ffxi.get_mob_by_id(mob_id)
            if mob and mob.x and mob.y and mob.z then
                local last = last_positions[mob_id]
                local debuff = debuffs[1]
                local grace_ok = debuff and ((os.clock() - debuff.applied_at) >= GRACE_PERIOD)
                if last and moved_enough(last, mob, MOVE_THRESHOLD) and grace_ok then
                    clear_tracked(mob_id)
                else
                    last_positions[mob_id] = { x = mob.x, y = mob.y, z = mob.z }
                end
            else
                tracked[mob_id] = nil
                last_positions[mob_id] = nil
            end
        end
    end
end

windower.register_event('prerender', function()
    prerender_count = prerender_count + 1
    if prerender_count >= MOVEMENT_CHECK_INTERVAL then
        check_movement()
        prerender_count = 0
    end
    -- Detect if window moved
    if window then
        local x, y = window:pos()
        if x ~= settings.window_position.x or y ~= settings.window_position.y then
            settings.window_position.x = x
            settings.window_position.y = y
            save_settings()
        end
    end
    update_window()
end)

windower.register_event('load', function()
    local player = windower.ffxi.get_player()
    if player then
        player_id = player.id
    end
    create_window()
    windower.add_to_chat(207, '[SleepTimers] v' .. tostring(_addon.version) .. ' loaded. Type //sleeptimers help')
end)

windower.register_event('login', function()
    local player = windower.ffxi.get_player()
    if player then
        player_id = player.id
    end
end)

windower.register_event('logout', function()
    tracked = {}
    last_positions = {}
end)

windower.register_event('zone change', function()
    tracked = {}
    last_positions = {}
end)

-- =====================
-- Command System v1.34
-- =====================
local function print_help()
    windower.add_to_chat(207, '[SleepTimers] Commands:')
    windower.add_to_chat(207, '  //sleeptimers bard me|other none|mary|nurse|relic')
    windower.add_to_chat(207, '  //sleeptimers showconfig')
end

local function show_config()
    local y = settings.your_bard or {}
    local o = settings.other_bard or {}
    local function onoff(b) return b and 'ON' or 'off' end
    windower.add_to_chat(207, '[SleepTimers] your_bard: mary='..onoff(y.marys_horn)..', nurse='..onoff(y.nursemaids_harp)..', relic='..onoff(y.gjallarhorn))
    windower.add_to_chat(207, '[SleepTimers] other_bard: mary='..onoff(o.marys_horn)..', nurse='..onoff(o.nursemaids_harp)..', relic='..onoff(o.gjallarhorn))
end

windower.register_event('addon command', function(cmd, arg1, arg2)
    cmd = cmd and cmd:lower() or ''

    if cmd == '' or cmd == 'help' then
        print_help()
        return
    end

    if cmd == 'showconfig' then
        show_config()
        return
    end

    if cmd == 'bard' then
        local target = (arg1 and arg1:lower()) or ''
        local choice = (arg2 and arg2:lower()) or ''

        local section = nil
        if target == 'me' then
            section = settings.your_bard
        elseif target == 'other' then
            section = settings.other_bard
        end

        if not section then
            windower.add_to_chat(123, '[SleepTimers] Invalid target. Use: me/other')
            return
        end

        -- Reset all
        section.marys_horn = false
        section.nursemaids_harp = false
        section.gjallarhorn = false

        if choice == 'mary' then
            section.marys_horn = true
            windower.add_to_chat(207, '[SleepTimers] '..target..' bard set to Mary\'s Horn (33s)')
        elseif choice == 'nurse' then
            section.nursemaids_harp = true
            windower.add_to_chat(207, '[SleepTimers] '..target..' bard set to Nursemaid\'s Harp (36s)')
        elseif choice == 'relic' then
            section.gjallarhorn = true
            windower.add_to_chat(207, '[SleepTimers] '..target..' bard set to Gjallarhorn (36s)')
        elseif choice == 'none' then
            windower.add_to_chat(207, '[SleepTimers] '..target..' bard instrument cleared (30s)')
        else
            windower.add_to_chat(123, '[SleepTimers] Invalid instrument. Use: none/mary/nurse/relic')
            return
        end

        save_settings()
        return
    end

    -- Unknown command fallback
    windower.add_to_chat(123, '[SleepTimers] Unknown command. Type: //sleeptimers help')
end)

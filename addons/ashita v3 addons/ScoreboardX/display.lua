-- Display object
local texts = require('texts')

local Display = {
    visible = true,
    settings = nil,
    tb_name = 'scoreboard'
}

local valid_fonts = T{
    'fixedsys',
    'lucida console',
    'courier',
    'courier new',
    'ms mincho',
    'consolas',
    'dejavu sans mono'
}

local valid_fields = T{
    'name',
    'dps',
    'percent',
    'total',
    'mavg',
    'mrange',
    'critavg',
    'critrange',
    'ravg',
    'rrange',
    'rcritavg',
    'rcritrange',
    'acc',
    'racc',
    'crit',
    'rcrit',
    'wsavg'
}


function Display:set_position(posx, posy)
    self.text:pos(posx, posy)
end

function Display:new(settings, db)
    local repr = setmetatable({db = db}, self)
    self.settings = settings
    self.__index = self
    self.visible = settings.visible

    self.text = texts.new(settings.display, settings)

    if not valid_fonts:contains(self.settings.display.text.font:lower()) then
        error('Invalid font specified: ' .. self.settings.display.text.font)
        self.text:font(self.settings.display.text.font)
        self.text:size(self.settings.display.text.fontsize)
    else
        self.text:font(self.settings.display.text.font, 'consolas', 'courier new', 'monospace')
        self.text:size(self.settings.display.text.size)
    end

    self:visibility(self.visible)

    return repr
end


function Display:visibility(v)
    if v then
        self.text:show()
    else
        self.text:hide()
    end

    self.visible = v
    self.settings.visible = v
    self.settings:save()
end


function Display:report_filters()
    local mob_str
    local filters = self.db:get_filters()

    if filters:empty() then
        mob_str = "ScoreboardX filters: None (Displaying damage for all mobs)"
    else
        mob_str = "ScoreboardX filters: " .. filters:concat(', ')
    end
    windower.add_to_chat(55, mob_str)

end


-- Returns the string for the scoreboard header with updated info
-- about current mob filtering and whether or not time is currently
-- contributing to the DPS value.
function Display:build_scoreboard_header()
    local mob_filter_str
    local filters = self.db:get_filters()

    if filters:empty() then
        mob_filter_str = 'All'
    else
        mob_filter_str = table.concat(filters, ', ')
    end

    local labels
    if self.db:empty() then
        labels = '\n'
    else
        if not self.settings.display_mode or self.settings.display_mode == 'damage' then
            labels = ('%23s%7s%9s\n'):format('Tot', 'Pct', 'DPS')
        else
            local meta = Display.stat_summaries._all_stats[self.settings.display_mode]
            local stat_name = (meta and meta.name) or self.settings.display_mode:upper()
            labels = ('%23s%7s%9s    %-18s\n'):format('Tot', 'Pct', 'DPS', stat_name)
        end
    end

    local dps_status = dps_clock:is_active() and 'Active' or 'Paused'

    local dps_clock_str = ''
    if dps_clock:is_active() or dps_clock.clock > 1 then
        dps_clock_str = (' (%s)'):format(dps_clock:to_string())
    end

    local dps_chunk = ('DPS: %s%s'):format(dps_status, dps_clock_str)

    return ('%s%s\nMobs: %-9s\n%s'):format(
        dps_chunk,
        (' '):rep(29 - dps_chunk:len()) .. '/sbx help',
        mob_filter_str,
        labels
    )
end


-- Helper: match a pet-owner short suffix like "Chr" (from "(Chr.)") to a full player name in table
-- Returns matched full player name or nil
local function match_owner_by_prefix(player_totals, prefix)
    if not prefix then return nil end
    local prefix_l = prefix:lower()
    local best_match = nil
    local best_len = 0
    for name, _ in pairs(player_totals) do
        local name_l = name:lower()
        -- match starting prefix
        if name_l:sub(1, #prefix_l) == prefix_l then
            -- prefer longer prefixes (not strictly necessary for 3-char matching)
            if #name_l > best_len then
                best_len = #name_l
                best_match = name
            end
        end
    end
    return best_match
end

-- Helper: find the stat entry for a player name within a stat map returned by query_stat().
-- Stats map: stats[name] = { value, samples }
-- We attempt:
--  1) exact key match
--  2) case-insensitive match
--  3) prefix-match (player short name vs stat key)
local function lookup_stat_for_player(player_name, stats_map)
    if not player_name or not stats_map then return nil end

    -- exact
    if stats_map[player_name] then return stats_map[player_name] end

    -- case-insensitive exact
    local lname = player_name:lower()
    for k, v in pairs(stats_map) do
        if k:lower() == lname then return v end
    end

    -- prefix match (try short prefixes), prefer longer matches
    local best_k, best_v, best_len = nil, nil, 0
    for k, v in pairs(stats_map) do
        local k_l = k:lower()
        if k_l:sub(1, #lname) == lname or lname:sub(1, #k_l) == k_l then
            if #k_l > best_len then
                best_k, best_v, best_len = k, v, #k_l
            end
        end
    end

    return best_v -- may be nil
end


-- Returns following two element pair:
-- 1) table of sorted 2-tuples containing {player, totals_table}
--    where totals_table = { total=number, p=number, pet=number, sc=number }
-- 2) integer containing the total damage done
function Display:get_sorted_player_damage()
    if self.db:empty() then
        return {}, 0
    end

    local player_totals = T{}   -- map name -> { total=..., p=..., pet=..., sc=... }
    local sc_entries = {}       -- list of {actor_id = n, damage = d}
    local pet_entries = {}      -- list of {name = display_name, damage = d, owner_short = 'Abc'}
    local total_damage = 0

    -- Phase 1: collect entries
    for mob, players in self.db:iter() do
        for player_name, player in pairs(players) do
            -- SC entries stored as id_<actor_id>
            if type(player_name) == 'string' and player_name:match('^id_%d+$') then
                local actor_id = tonumber(player_name:sub(4))
                sc_entries[#sc_entries + 1] = { actor_id = actor_id, damage = player.damage }
            else
                -- Try to see if there is an explicit pet->owner mapping available
                local owner = nil
                if self.db.get_owner_for_pet then
                    owner = self.db:get_owner_for_pet(player_name)
                end

                if owner and self.settings.combinepets then
					local t = player_totals[owner] or { total = 0, p = 0, pet = 0, sc = 0 }
					t.pet = t.pet + player.damage
					t.total = t.total + player.damage
					player_totals[owner] = t
					total_damage = total_damage + player.damage
				else
					-- treat pet as standalone row
					local pname = player_name
					local t = player_totals[pname] or { total = 0, p = 0, pet = 0, sc = 0 }
					t.pet = t.pet + player.damage
					t.total = t.total + player.damage
					player_totals[pname] = t
					total_damage = total_damage + player.damage
				end
            end
        end
    end

    -- Phase 2: merge SC entries
    for _, e in ipairs(sc_entries) do
		local actor_name = nil
		if self.db.get_name_for_id then
			actor_name = self.db:get_name_for_id(e.actor_id)
		end

		if self.settings.combinesc and actor_name and actor_name ~= '' then
			local t = player_totals[actor_name] or { total = 0, p = 0, pet = 0, sc = 0 }
			t.sc = t.sc + e.damage
			t.total = t.total + e.damage
			player_totals[actor_name] = t
		else
			-- standalone SC row
			local row_name
			if actor_name and actor_name ~= '' then
				row_name = ('SC(%s)'):format(actor_name)
			else
				row_name = ('SC(%s)'):format(tostring(e.actor_id))
			end

			local t = player_totals[row_name] or { total = 0, p = 0, pet = 0, sc = 0 }
			t.sc = t.sc + e.damage
			t.total = t.total + e.damage
			player_totals[row_name] = t
		end
	end

    -- Phase 3: attribute pet entries using prefix matching (prefer names we already have)
	if self.settings.combinepets then
		for _, pe in ipairs(pet_entries) do
			local owner_short = pe.owner_short
			local matched_owner = match_owner_by_prefix(player_totals, owner_short)

			if matched_owner then
				local t = player_totals[matched_owner]
				t.pet = t.pet + pe.damage
				t.total = t.total + pe.damage
				player_totals[matched_owner] = t
			else
				-- fallback: search candidates across DB (non-id keys)
				local candidates = T{}
				for mob, players in self.db:iter() do
					for nm, _ in pairs(players) do
						if type(nm) == 'string' and not nm:match('^id_%d+$') then
							candidates[nm] = true
						end
					end
				end

				local fallback_match = nil
				for nm, _ in pairs(candidates) do
					if nm:lower():sub(1, #owner_short) == owner_short:lower() then
						fallback_match = nm
						break
					end
				end

				if fallback_match then
					local t = player_totals[fallback_match] or { total = 0, p = 0, pet = 0, sc = 0 }
					t.pet = t.pet + pe.damage
					t.total = t.total + pe.damage
					player_totals[fallback_match] = t
				else
					-- give up and keep the pet as its own display row (rare)
					local t = player_totals[pe.name] or { total = 0, p = 0, pet = 0, sc = 0 }
					t.pet = t.pet + pe.damage
					t.total = t.total + pe.damage
					player_totals[pe.name] = t
				end
			end
		end
	end
    -- Build sortable list
    local sortable = T{}
    for name, t in pairs(player_totals) do
        sortable:append({ name, t })
    end

    table.sort(sortable, function(a, b)
        return a[2].total > b[2].total
    end)

    return sortable, total_damage
end


-- Updates the main display with current filter/damage/dps status
function Display:update()
    if not self.visible then return end

    if self.db:empty() then
        self:reset()
        return
    end

    local damage_table, total_damage = self:get_sorted_player_damage()

    local display_table = T{}
    local player_lines = 0

    local stat_mode = (self.settings.display_mode and self.settings.display_mode ~= 'damage')
    local stat_map = nil
    local stat_meta = nil

    if stat_mode then
        stat_map = self.db:query_stat(self.settings.display_mode) or {}
        stat_meta = Display.stat_summaries._all_stats[self.settings.display_mode]
    end

    for _, entry in ipairs(damage_table) do
        local name = entry[1]
        local totals = entry[2]

        if player_lines < self.settings.numplayers then
            local dps
            if dps_clock.clock == 0 then
                dps = "N/A"
            else
                dps = ('%.2f'):format(math.round(totals.total / dps_clock.clock, 2))
            end

            local percent
            if total_damage > 0 then
                percent = ('(%.1f%%)'):format(100 * totals.total / total_damage)
            else
                percent = '(0%)'
            end

            local stat_str = ''

            if stat_mode then
                local stat_entry = stat_map[name]

                if not stat_entry then
                    -- try lowercase match
                    for k, v in pairs(stat_map) do
                        if k:lower() == name:lower() then
                            stat_entry = v
                            break
                        end
                    end
                end

                if stat_entry and stat_entry[2] > 0 then
                    local value = stat_entry[1]
                    local samples = stat_entry[2]

                    if stat_meta.category == 'range' then
                        stat_str = ('%10s'):format(('%d~%d'):format(value, samples))
                    elseif stat_meta.percent then
                        stat_str = ('%10s'):format(('%.1f%%'):format(value * 100))
                    else
                        stat_str = ('%10s'):format(tostring(value))
                    end
                else
                    stat_str = ('%10s'):format('N/A')
                end
            end

            if stat_mode then
                display_table:append(
                    ('%-16s%7d%8s %7s  %s'):format(
                        name,
                        totals.total,
                        percent,
                        dps,
                        stat_str
                    )
                )
            else
                display_table:append(
                    ('%-16s%7d%8s %7s'):format(
                        name,
                        totals.total,
                        percent,
                        dps
                    )
                )
            end
        end

        player_lines = player_lines + 1
    end

    self.text:text(self:build_scoreboard_header() .. table.concat(display_table, '\n'))
end



local function build_input_command(chatmode, tell_target)
    local input_cmd = 'input '
    if chatmode then
        input_cmd = input_cmd .. '/' .. chatmode .. ' '
        if tell_target then
            input_cmd = input_cmd .. tell_target .. ' '
        end
    end

    return input_cmd
end

-- Takes a table of elements to be wrapped across multiple lines and returns
-- a table of strings, each of which fits within one FFXI line.
local function wrap_elements(elements, header, sep)
    local max_line_length = 120 -- game constant
    if not sep then
        sep = ', '
    end

    local lines = T{}
    local current_line = nil
    local line_length

    local i = 1
    while i <= #elements do
        if not current_line then
            current_line = T{}
            line_length = header:len()
            lines:append(current_line)
        end

        local new_line_length = line_length + elements[i]:len() + sep:len()
        if new_line_length > max_line_length then
            current_line = T{}
            lines:append(current_line)
            new_line_length = elements[i]:len() + sep:len()
        end

        current_line:append(elements[i])
        line_length = new_line_length
        i = i + 1
    end

    local baked_lines = lines:map(function (ls) return ls:concat(sep) end)
    if header:len() > 0 and #baked_lines > 0 then
        baked_lines[1] = header .. baked_lines[1]
    end

    return baked_lines
end


local function slow_output(chatprefix, lines, limit)
    -- this is funky but if we don't wait like this, the lines will spew too fast and error
    windower.send_command(lines:map(function (l) return chatprefix .. l end):concat('; wait 1.2 ; '))
end


function Display:report_summary (...)
    local chatmode, tell_target = table.unpack({...})

    -- We'll compute breakdowns by scanning the DB directly:
    local direct = {}  -- direct player name -> damage
    local pettot = {}  -- owner name -> pet damage
    local sctot = {}   -- owner name -> skillchain damage
    local total_damage = 0

    -- iterate DB respecting filters
    for mob, players in self.db:iter() do
        for name, player in pairs(players) do
            -- Skillchain entries live under id_<actor_id>
            if type(name) == 'string' and name:match('^id_%d+$') then
                local actor_id = tonumber(name:sub(4))
                local owner_name = nil
                if self.db.get_name_for_id then
                    owner_name = self.db:get_name_for_id(actor_id)
                end
                if owner_name and owner_name ~= '' then
                    sctot[owner_name] = (sctot[owner_name] or 0) + player.damage
                    total_damage = total_damage + player.damage
                else
                    -- Unresolved SC: put into a generic "SC(id)" bucket (unlikely)
                    local key = ('SC(%s)'):format(tostring(actor_id))
                    sctot[key] = (sctot[key] or 0) + player.damage
                    total_damage = total_damage + player.damage
                end
            else
                -- Not an id_ entry. Could be a pet label or a real player
                local owner = nil
                if self.db.get_owner_for_pet then
                    owner = self.db:get_owner_for_pet(name)
                end

                if owner then
                    -- attribute to pet bucket for that owner
                    pettot[owner] = (pettot[owner] or 0) + player.damage
                    total_damage = total_damage + player.damage
                else
                    -- treat as direct player damage
                    direct[name] = (direct[name] or 0) + player.damage
                    total_damage = total_damage + player.damage
                end
            end
        end
    end

    -- Build the union of player names we will report on
    local players_set = T{}
    for name, _ in pairs(direct) do players_set[name] = true end
    for name, _ in pairs(pettot) do players_set[name] = true end
    for name, _ in pairs(sctot) do players_set[name] = true end

    -- Convert to sortable list by total (compute totals per player)
    local sortable = {}
    for pname, _ in pairs(players_set) do
        local p = direct[pname] or 0
        local pet = pettot[pname] or 0
        local sc = sctot[pname] or 0
        local tot = p + pet + sc
        table.insert(sortable, {name = pname, total = tot, p = p, pet = pet, sc = sc})
    end

    table.sort(sortable, function(a,b) return a.total > b.total end)

    -- Build lines: first the header line, then one line per player
    local lines = T{}
    lines:append('Total Damage Breakdown - (ScoreboardX)')

    for _, row in ipairs(sortable) do
        local pct = 0.0
        if total_damage > 0 then pct = 100.0 * row.total / total_damage end
        -- Format: Name Total (P:xx + Pet:xx + SC:xx) XX.X%
        local line = ('%s %d (P:%d + Pet:%d + SC:%d) %.1f%%'):format(
            row.name, row.total, row.p, row.pet, row.sc, math.round(pct, 1)
        )
        lines:append(line)
    end

    -- Send each line as its own chat line via slow_output
    slow_output(build_input_command(chatmode, tell_target), lines, #lines)
end


-- This is a table of the line aggregators and related utilities
Display.stat_summaries = {}


Display.stat_summaries._format_title = function (msg)
        local line_length = 40
        local msg_length  = msg:len()
        local border_len = math.floor(line_length / 2 - msg_length / 2)

        return (' '):rep(border_len) .. msg .. (' '):rep(border_len)
    end

    
Display.stat_summaries['range'] = function (stats, filters, options)
        
        local lines = T{}
        for name, pair in pairs(stats) do
            lines:append(('%-20s %d min   %d max'):format(name, pair[1], pair[2]))
        end

        if #lines > 0 and options and options.name then
            sb_output(Display.stat_summaries._format_title('-= '..options.name..' (' .. filters .. ') =-'))
            sb_output(lines)
        end
    end

    
Display.stat_summaries['average'] = function (stats, filters, options)
        
        local lines = T{}
        for name, pair in pairs(stats) do
            if options and options.percent then
                lines:append(('%-20s %.2f%% (%d sample%s)'):format(name, 100 * pair[1], pair[2],
                                                                      pair[2] == 1 and '' or 's'))
            else
                lines:append(('%-20s %d (%ds)'):format(name, pair[1], pair[2]))
            end
        end

        if #lines > 0 and options and options.name then
            sb_output(Display.stat_summaries._format_title('-= '..options.name..' (' .. filters .. ') =-'))
            sb_output(lines)
        end
    end

    
-- This is a closure around a hash-based dispatcher. Some conveniences are
-- defined for the actual stat display functions.
Display.show_stat = (function()
    return function (self, stat, player_filter)
        local stats = self.db:query_stat(stat, player_filter)
        local filters = self.db:get_filters()
        local filter_str

        if filters:empty() then
            filter_str = 'All mobs'
        else
            filter_str = filters:concat(', ')
        end
        
        Display.stat_summaries[Display.stat_summaries._all_stats[stat].category](stats, filter_str, Display.stat_summaries._all_stats[stat])
    end
end)()


-- TODO: This needs to be factored somehow to take better advantage of similar
--       code already written for reporting and stat queries.
Display.stat_summaries._all_stats = T{
    ['acc']        = {percent=true,  category="average", name='Accuracy'},
    ['racc']       = {percent=true,  category="average", name='Ranged Accuracy'},
    ['crit']       = {percent=true,  category="average", name='Melee Crit. Rate'},
    ['rcrit']      = {percent=true,  category="average", name='Ranged Crit. Rate'},
    ['wsavg']      = {percent=false, category="average", name='WS Average'}, 
    ['wsacc']      = {percent=true,  category="average", name='WS Accuracy'}, 
    ['mavg']       = {percent=false, category="average", name='Melee Non-Crit. Avg. Damage'},
    ['mrange']     = {percent=false, category="range",   name='Melee Non-Crit. Range'},
    ['critavg']    = {percent=false, category="average", name='Melee Crit. Avg. Damage'},
    ['critrange']  = {percent=false, category="range",   name='Melee Crit. Range'},
    ['ravg']       = {percent=false, category="average", name='Ranged Non-Crit. Avg. Damage'},
    ['rrange']     = {percent=false, category="range",   name='Ranged Non-Crit. Range'},
    ['rcritavg']   = {percent=false, category="average", name='Ranged Crit. Avg. Damage'},
    ['rcritrange'] = {percent=false, category="range",   name='Ranged Crit. Range'},}
function Display:report_stat(stat, args)
    if not Display.stat_summaries._all_stats:containskey(stat) then
        return
    end

    local stats = self.db:query_stat(stat, args.player)
    local meta  = Display.stat_summaries._all_stats[stat]
    if not meta then return end

    -- Build sortable array of {value, text}
    local elements = {}
    for name, stat_pair in pairs(stats) do
        if stat_pair[2] > 0 then
            local text
            if meta.category == 'range' then
                text = ('%s %d~%d'):format(name, stat_pair[1], stat_pair[2])
            elseif meta.percent then
                text = ('%s %.2f%% (%ds)'):format(name, stat_pair[1] * 100, stat_pair[2])
            else
                text = ('%s %d (%ds)'):format(name, stat_pair[1], stat_pair[2])
            end
            table.insert(elements, { stat_pair[1], text })
        end
    end

    -- sort by stat value descending
    table.sort(elements, function(a, b) return a[1] > b[1] end)

    -- prepare lines: header then each player line (respect numplayers)
    local lines = T{}
    local header = meta.name .. ':'
    lines:append(header)

    local limit = math.min(#elements, self.settings.numplayers or #elements)
    for i = 1, limit do
        lines:append(elements[i][2])
    end

    -- If user requested more than available, that's fine — we'll just send what's present.
    -- Send lines via slow_output (handles spacing/wait)
    slow_output(build_input_command(args.chatmode, args.telltarget), lines, #lines)
end



function Display:reset()
    -- the number of spaces here was counted to keep the table width
    -- consistent even when there's no data being displayed
    self.text:text(self:build_scoreboard_header() ..
                      'Waiting for results...' ..
                      (' '):rep(17))
end


return Display

--[[
Copyright � 2013-2014, Jerry Hebert
All rights reserved.

Modifications © 2025, Christopher Olson
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Scoreboard nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL JERRY HEBERT BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

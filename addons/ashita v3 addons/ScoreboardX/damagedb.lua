local Player = require 'player'
local MergedPlayer = require 'mergedplayer'

local DamageDB = {
    db = T{},
    filter = T{},
    id_map = T{},     -- maps actor_id -> full actor name (used for SC merging)
    id_reverse = T{}, -- maps actor_name -> actor_id (for lookups when only name is available)
    pet_owners = T{}  -- maps pet_display_name -> owner_full_name
}

DamageDB.player_stat_fields = T{
    'mavg', 'mrange', 'critavg', 'critrange',
    'ravg', 'rrange', 'rcritavg', 'rcritrange',
    'acc', 'racc', 'crit', 'rcrit',
    'wsavg', 'wsacc'
}

function DamageDB:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- ensure instance tables are fresh
    o.db = o.db or T{}
    o.filter = o.filter or T{}
    o.id_map = o.id_map or T{}
    o.id_reverse = o.id_reverse or T{}
    o.pet_owners = o.pet_owners or T{}
    
    return o
end


function DamageDB:iter()
    local k, v
    return function ()
        k, v = next(self.db, k)
        while k and not self:_filter_contains_mob(k) do
            k, v = next(self.db, k)
        end
        
        if k then
            return k, v
        end
    end
end


function DamageDB:get_filters()
    return self.filter
end


function DamageDB:_filter_contains_mob(mob_name)
    if self.filter:empty() then
        return true
    end
    
    for _, mob_pattern in ipairs(self.filter) do
        if mob_name:lower():find(mob_pattern:lower()) then
            return true
        end
    end
    return false
end


function DamageDB:clear_filters()
    self.filter = T{}
end


function DamageDB:add_filter(mob_pattern)
    if mob_pattern then self.filter:append(mob_pattern) end
end


-- Internal helper to create an internal key for actor IDs
local function id_key(actor_id)
    return string.format("id_%s", tostring(actor_id))
end

-- Internal helper to create an internal key for SC buckets (fallback only)
-- NOTE: we try to avoid using this; prefer id_key whenever possible.
local function sc_fallback_key(actor_name)
    return string.format("SC(%s)", tostring(actor_name))
end


-- Internal helper: try to merge two Player-like tables by summing numeric fields
-- and merging a .ws table if present. This is defensive (works with Player objects
-- that expose numeric fields and a .ws table).
local function merge_player_into(target, src)
    if not target or not src then return end
    for k, v in pairs(src) do
        if type(v) == 'number' then
            target[k] = (target[k] or 0) + v
        end
    end
    -- merge ws table (if present)
    if type(src.ws) == 'table' then
        target.ws = target.ws or {}
        for wsid, wsval in pairs(src.ws) do
            if type(wsval) == 'number' then
                target.ws[wsid] = (target.ws[wsid] or 0) + wsval
            end
        end
    end
end


-- Helper: resolve a short prefix (like 'Vha' or 'Vha.') to a likely player full name
-- Strategy: 1) check pet_owners values, 2) scan current DB keys (non-id, non-sc)
-- Returns matched full name or nil
function DamageDB:_find_owner_by_prefix(prefix)
    if not prefix or prefix == '' then return nil end
    local pref = prefix:lower():gsub('%.$','') -- remove trailing dot if present
    -- 1) check pet_owners values
    for _, owner in pairs(self.pet_owners) do
        if owner and owner:lower():sub(1, #pref) == pref then
            return owner
        end
    end
    -- 2) scan DB keys
    for _, players in self:iter() do
        for nm, _ in pairs(players) do
            if type(nm) == 'string' and not nm:match('^id_%d+$') and not nm:match('^SC%(') then
                if nm:lower():sub(1, #pref) == pref then
                    return nm
                end
            end
        end
    end
    return nil
end


-- Try to detect if a given player_key represents a pet and, if so, auto-register
-- its owner in self.pet_owners so subsequent lookups map the pet to the owner.
-- This uses Windower's mob API to inspect the mob's owner_id (if available).
function DamageDB:_ensure_pet_owner_for(player_key)
    if type(player_key) ~= 'string' then return end
    if self.pet_owners[player_key] then return end

    -- Ignore internal id_ keys or SC fallback keys
    if player_key:match('^id_%d+$') then return end
    if player_key:match('^SC%(') then return end

    -- If the key includes a suffix like " (Vis.)", strip it to get the base name
    local base = player_key:match('^(.+)%s+%([^)]+%)$') or player_key

    -- Try resolve mob by base name using windower. Defensive: only attempt if windower present.
    if type(windower) == 'table' and windower.ffxi and windower.ffxi.get_mob_by_name then
        local mob = windower.ffxi.get_mob_by_name(base)
        if mob and mob.owner_id and mob.owner_id > 0 then
            local owner_mob = windower.ffxi.get_mob_by_id(mob.owner_id)
            if owner_mob and owner_mob.name and owner_mob.name ~= '' then
                -- Register mapping using original player_key (preserves exact display used)
                self:set_pet_owner(player_key, owner_mob.name)
            end
        end
    end
end


-- IMPORTANT: Do NOT redirect pet display names to owner here — keep pet rows separate
-- so reports can compute P + Pet + SC breakdowns. (Display layer merges for UI as needed.)
function DamageDB:_get_player(mob, player_key, display_name)
    if not self.db[mob] then
        self.db[mob] = T{}
    end

    -- Try to auto-resolve pet owners (so first-time pet damage is mapped for later reporting)
    self:_ensure_pet_owner_for(player_key)

    if not self.db[mob][player_key] then
        -- Use display_name if supplied, otherwise use the player_key as name
        local name_for_player = display_name or player_key
        self.db[mob][player_key] = Player:new{name = name_for_player}
    end
    
    return self.db[mob][player_key]
end


-- Expose mapping lookup for display layer
function DamageDB:get_name_for_id(actor_id)
    return self.id_map[actor_id]
end

-- Reverse lookup: given a full actor name, return its ID (if known)
function DamageDB:get_id_for_name(actor_name)
    return self.id_reverse[actor_name]
end

-- Expose pet owner lookup (returns owner full name or nil)
function DamageDB:get_owner_for_pet(pet_display_name)
    return self.pet_owners[pet_display_name]
end


-- Register a pet -> owner mapping.
-- This version stores multiple mapping keys (exact display, base name, short forms)
-- but does NOT fold/delete existing pet entries so reports can compute breakdowns.
function DamageDB:set_pet_owner(pet_display_name, owner_full_name)
    if not pet_display_name or not owner_full_name then return end

    -- store mapping for exact key
    self.pet_owners[pet_display_name] = owner_full_name

    -- also store mapping for base name (strip suffix if present)
    local base = pet_display_name:match('^(.+)%s+%([^)]+%)$') or pet_display_name
    if not self.pet_owners[base] then
        self.pet_owners[base] = owner_full_name
    end

    -- also store the "(Xxx.)" short forms that create_mob_name() uses, to cover
    -- both 'Pets (Vis.)' and 'Ifrit (Vis.)' scenarios regardless of combinepets.
    local short = owner_full_name:sub(1, 3)
    if short and short ~= '' then
        local short_display = string.format('%s (%s.)', base, short)
        self.pet_owners[short_display] = owner_full_name
        local pets_short = string.format('Pets (%s.)', short)
        self.pet_owners[pets_short] = owner_full_name
    end

    -- NOTE: intentionally DO NOT fold existing pet rows into owner here.
    -- Folding/deleting would prevent us from producing a P: + Pet: + SC: breakdown later.
end


-- Allow explicitly setting a mapping name -> actor_id from outside (useful if action handler sees actor id)
function DamageDB:set_actor_id(actor_name, actor_id)
    if not actor_name or not actor_id then return end
    self.id_map[actor_id] = actor_name
    self.id_reverse[actor_name] = actor_id
end


-- Returns a table {player1 = stat1, player2 = stat2...}.
-- For WS queries, the stat value is a sub-table of {ws1 = ws_stat1, ws2 = ws_stat2}.
function DamageDB:query_stat(stat, player_name)
    local players = T{}
    
    if player_name and player_name:match('^[a-zA-Z]+$') then
        player_name = player_name:lower():ucfirst()
    end

    -- Gather a table mapping player names to all of the corresponding Player instances
    for mob, mob_players in self:iter() do
        for name, player in pairs(mob_players) do
            if player_name and player_name == name or
               not player_name and not player.is_sc then
                if players[name] then
                    players[name]:append(player)
                else
                    players[name] = T{player}
                end
            end
        end
    end
    
    -- Flatten player subtables into the merged stat we desire
    for name, instances in pairs(players) do
        local merged = MergedPlayer:new{players = instances}
        players[name] = MergedPlayer[stat](merged)
    end
    
    return players
end


function DamageDB:empty()
    return self.db:empty()
end


function DamageDB:reset()
    self.db = T{}
    self.id_map = T{}
    self.id_reverse = T{}
    self.pet_owners = T{}
end


--[[
The following player dispatchers all fetch the correct
instance of Player for a given mob and then dispatch the
method for data accumulation.
]]--
function DamageDB:add_m_hit(m, p, d)         self:_get_player(m, p):add_m_hit(d)         end
function DamageDB:add_m_crit(m, p, d)        self:_get_player(m, p):add_m_crit(d)        end
function DamageDB:add_r_hit(m, p, d)         self:_get_player(m, p):add_r_hit(d)        end
function DamageDB:add_r_crit(m, p, d)        self:_get_player(m, p):add_r_crit(d)        end
function DamageDB:incr_misses(m, p)          self:_get_player(m, p):incr_m_misses()      end
function DamageDB:incr_r_misses(m, p)        self:_get_player(m, p):incr_r_misses()      end
function DamageDB:incr_ws_misses(m, p)       self:_get_player(m, p):incr_ws_misses()     end


-- Override add_damage to attempt auto-mapping of pet -> owner on first sight
-- NOTE: we intentionally **do not** create name-based "sc_" keys here. We prefer actor IDs.
function DamageDB:add_damage(m, p, d)
    if type(p) ~= 'string' then
        self:_get_player(m, p):add_damage(d)
        return
    end

    -- If the name looks like Skillchain(...), do NOT create sc_<name> keys.
    -- Skillchain closing damage should ideally be recorded via add_sc_damage(actor_id,...)
    -- from the action handler (preferred). If we do get Skillchain(...) here *and*
    -- can resolve a full owner name -> id we will route it via add_sc_damage if possible,
    -- otherwise we will store the Skillchain(...) damage as a normal row (rare fallback).
    local sc_inner = p:match('^Skillchain%(%s*([^)]+)%s*%)')
    if sc_inner then
        local pref = sc_inner:match('^([%a%d]+)') or sc_inner
        pref = pref:gsub('%.$','')
        local owner = self:_find_owner_by_prefix(pref)
        if owner then
            local owner_id = self.id_reverse[owner]
            if owner_id then
                -- We have the actor id for the owner -> record as SC by id
                self:add_sc_damage(m, owner_id, owner, d)
                return
            else
                -- We have an owner name but no id -> fall back to storing under normal name
                self:_get_player(m, p):add_damage(d)
                return
            end
        else
            -- Unresolved: store as a normal row (fallback)
            self:_get_player(m, p):add_damage(d)
            return
        end
    end

    -- Auto-resolve common pet naming cases (if we can) so first-hit pet damage maps to owner mapping table
    if not self.pet_owners[p] then
        self:_ensure_pet_owner_for(p)
    end

    -- Store under the exact key (do NOT redirect to owner) so pet rows are preserved for breakdowns
    self:_get_player(m, p):add_damage(d)
end

-- Keep existing WS helper signature (delegates to _get_player which auto-resolves pet owners)
function DamageDB:add_ws_damage(m, p, d, id) self:_get_player(m, p):add_ws_damage(id, d) end


-- New: store skillchain damage keyed to actor ID (clean approach)
-- mob: target mob name
-- actor_id: numeric actor id (may be nil)
-- actor_name: readable full actor name (used for Player display_name)
-- d: damage amount
function DamageDB:add_sc_damage(m, actor_id, actor_name, d)
    -- If we have an actor_id, use the id_ key (this integrates with existing display merging)
    if actor_id and actor_id > 0 then
        -- register forward and reverse maps
        if actor_name and actor_name ~= '' then
            self.id_map[actor_id] = actor_name
            self.id_reverse[actor_name] = actor_id
        else
            self.id_map[actor_id] = self.id_map[actor_id] or tostring(actor_id)
        end

        local key = id_key(actor_id)
        local p = self:_get_player(m, key, actor_name)
        p.is_sc = true
        p:add_damage(d)
        return
    end

    -- If no actor_id is available, fall back to a non-id "SC(...)" key (rare).
    -- We intentionally avoid creating sc_<owner> style keys. Use SC(...) so display code
    -- can treat it as a fallback row (and not confuse it with id-based merging).
    if actor_name and actor_name ~= '' then
        local skey = sc_fallback_key(actor_name)
        local p = self:_get_player(m, skey, actor_name)
        p.is_sc = true
        p:add_damage(d)
    end
end


-- Optional: get all id->name mappings (useful for display merging)
function DamageDB:get_id_map()
    return self.id_map
end

return DamageDB

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
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

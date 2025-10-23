--[[
    The entire mergedplayer file exists to flatten individual stats in the db
    into two numbers (per name). So normally the db is:
    dps_db.dp[mob_name][player_name] = {stats}
    Mergedplayer iterates over mob_name and returns a table that's just:
    tab[player_name] = {CalculatedStatA,CalculatedStatB}
]]

--[[
    The entire mergedplayer file exists to flatten individual stats in the db
    into two numbers (per name). So normally the db is:
    dps_db.dp[mob_name][player_name] = {stats}
    Mergedplayer iterates over mob_name and returns a table that's just:
    tab[player_name] = {CalculatedStatA,CalculatedStatB}
    
    Changes made:
    - When computing per-hit / accuracy / ws stats, include both the player and
      their pet (if the Player object has a `.pet` table).
    - Provide a `damage()` helper that sums player damage + pet damage + any
      SC-instance damage (i.e. players in self.players with `is_sc == true`).
    - SC instances are included in the `damage()` total but are NOT treated as
      normal hits for per-hit averages (so averages remain meaningful).
]]--

local MergedPlayer = {}

function MergedPlayer:new (o)
    o = o or {}
    
    assert(o.players and #o.players > 0,
           "MergedPlayer constructor requires at least one Player instance.")

    setmetatable(o, self)
    self.__index = self
    
    return o
end

-- Helper: returns a flattened list of sources (players + their pets if present)
function MergedPlayer:_sources()
    local sources = {}
    for _, p in ipairs(self.players) do
        table.insert(sources, p)
        if p.pet and type(p.pet) == 'table' then
            table.insert(sources, p.pet)
        end
    end
    return sources
end

-- Helper: sum total combined damage (players + pets + SC instances)
function MergedPlayer:damage()
    local total = 0
    for _, p in ipairs(self.players) do
        total = total + (p.damage or 0)
        if p.pet and type(p.pet) == 'table' then
            total = total + (p.pet.damage or 0)
        end
        -- If this entry is an SC instance it already contributes via p.damage.
    end
    return total
end

--[[
    'wsmin', 'wsmax', 'wsavg'
]]

function MergedPlayer:mavg()
    local hits, hit_dmg = 0, 0
    local sources = self:_sources()
    
    for _, s in ipairs(sources) do
        -- don't include SC-only entries in per-hit averages
        if not s.is_sc then
            local s_hits = s.m_hits or 0
            local s_avg  = s.m_avg or 0
            hits    = hits + s_hits
            hit_dmg = hit_dmg + s_hits * s_avg
        end
    end
    
    if hits > 0 then
        return { hit_dmg / hits, hits}
    else
        return {0, 0}
    end
end


function MergedPlayer:mrange()
    local m_min, m_max = math.huge, 0
    local sources = self:_sources()
    
    for _, s in ipairs(sources) do
        if not s.is_sc then
            if s.m_min and s.m_min > 0 then m_min = math.min(m_min, s.m_min) end
            if s.m_max and s.m_max > 0 then m_max = math.max(m_max, s.m_max) end
        end
    end

    return {m_min~=math.huge and m_min or m_max, m_max}
end


function MergedPlayer:critavg()
    local crits, crit_dmg = 0, 0
    local sources = self:_sources()
    
    for _, s in ipairs(sources) do
        if not s.is_sc then
            local s_crits = s.m_crits or 0
            local s_cavg  = s.m_crit_avg or 0
            crits    = crits + s_crits
            crit_dmg = crit_dmg + s_crits * s_cavg
        end
    end
    
    if crits > 0 then
        return { crit_dmg / crits, crits}
    else
        return {0, 0}
    end
end


function MergedPlayer:critrange()
    local m_crit_min, m_crit_max = math.huge, 0
    local sources = self:_sources()
    
    for _, s in ipairs(sources) do
        if not s.is_sc then
            if s.m_crit_min and s.m_crit_min > 0 then m_crit_min = math.min(m_crit_min, s.m_crit_min) end
            if s.m_crit_max and s.m_crit_max > 0 then m_crit_max = math.max(m_crit_max, s.m_crit_max) end
        end
    end
    
    return {m_crit_min~=math.huge and m_crit_min or m_crit_max, m_crit_max}
end


function MergedPlayer:ravg()
    local r_hits, r_hit_dmg = 0, 0
    local sources = self:_sources()
    
    for _, s in ipairs(sources) do
        if not s.is_sc then
            local s_rhits = s.r_hits or 0
            local s_ravg  = s.r_avg or 0
            r_hits    = r_hits + s_rhits
            r_hit_dmg = r_hit_dmg + s_rhits * s_ravg
        end
    end
    
    if r_hits > 0 then
        return { r_hit_dmg / r_hits, r_hits}
    else
        return {0, 0}
    end
end


function MergedPlayer:rrange()
    local r_min, r_max = math.huge, 0
    local sources = self:_sources()
    
    for _, s in ipairs(sources) do
        if not s.is_sc then
            if s.r_min and s.r_min > 0 then r_min = math.min(r_min, s.r_min) end
            if s.r_max and s.r_max > 0 then r_max = math.max(r_max, s.r_max) end
        end
    end
    
    return {r_min~=math.huge and r_min or r_max, r_max}
end


function MergedPlayer:rcritavg()
    local r_crits, r_crit_dmg = 0, 0
    local sources = self:_sources()
    
    for _, s in ipairs(sources) do
        if not s.is_sc then
            local scrits = s.r_crits or 0
            local scravg = s.r_crit_avg or 0
            r_crits    = r_crits + scrits
            r_crit_dmg = r_crit_dmg + scrits * scravg
        end
    end
    
    if r_crits > 0 then
        return { r_crit_dmg / r_crits, r_crits}
    else
        return {0, 0}
    end
end


function MergedPlayer:rcritrange()
    local r_crit_min, r_crit_max = math.huge, 0
    local sources = self:_sources()
    
    for _, s in ipairs(sources) do
        if not s.is_sc then
            if s.r_crit_min and s.r_crit_min > 0 then r_crit_min = math.min(r_crit_min, s.r_crit_min) end
            if s.r_crit_max and s.r_crit_max > 0 then r_crit_max = math.max(r_crit_max, s.r_crit_max) end
        end
    end
    
    return {r_crit_min~=math.huge and r_crit_min or r_crit_max, r_crit_max}
end


function MergedPlayer:acc()
    local hits, crits, misses = 0, 0, 0
    local sources = self:_sources()
    
    for _, s in ipairs(sources) do
        if not s.is_sc then
            hits   = hits + (s.m_hits or 0)
            crits  = crits + (s.m_crits or 0)
            misses = misses + (s.m_misses or 0)
        end
    end
    
    local total = hits + crits + misses
    if total > 0 then
        return {(hits + crits) / total, total}
    else
        return {0, 0}
    end
end


function MergedPlayer:racc()
    local hits, crits, misses = 0, 0, 0
    local sources = self:_sources()
    
    for _, s in ipairs(sources) do
        if not s.is_sc then
            hits   = hits + (s.r_hits or 0)
            crits  = crits + (s.r_crits or 0)
            misses = misses + (s.r_misses or 0)
        end
    end
    
    local total = hits + crits + misses
    if total > 0 then
        return {(hits + crits) / total, total}
    else
        return {0, 0}
    end
end


function MergedPlayer:crit()
    local hits, crits = 0, 0
    local sources = self:_sources()
    
    for _, s in ipairs(sources) do
        if not s.is_sc then
            hits   = hits + (s.m_hits or 0)
            crits  = crits + (s.m_crits or 0)
        end
    end
    
    local total = hits + crits
    if total > 0 then
        return {crits / total, total}
    else
        return {0, 0}
    end
end


function MergedPlayer:rcrit()
    local hits, crits = 0, 0
    local sources = self:_sources()
    
    for _, s in ipairs(sources) do
        if not s.is_sc then
            hits   = hits + (s.r_hits or 0)
            crits  = crits + (s.r_crits or 0)
        end
    end
    
    local total = hits + crits
    if total > 0 then
        return {crits / total, total}
    else
        return {0, 0}
    end
end


function MergedPlayer:wsavg()
    local wsdmg   = 0
    local wscount = 0
    local sources = self:_sources()
    
    for _, s in ipairs(sources) do
        -- include WS damage from pets too if present
        if s.ws and type(s.ws) == 'table' then
            for _, dmg in pairs(s.ws) do
                wsdmg = wsdmg + (dmg or 0)
                wscount = wscount + 1
            end
        end
    end
    
    if wscount > 0 then
        return {wsdmg / wscount, wscount}
    else
        return {0, 0}
    end
end

function MergedPlayer:wsacc()
    local hits, misses = 0, 0
    local sources = self:_sources()
    
    for _, s in ipairs(sources) do
        if s.ws and type(s.ws) == 'table' then
            hits = hits + table.length(s.ws)
        end
        misses = misses + (s.ws_misses or 0)
    end
    
    local total = hits + misses
    if total > 0 then
        return {hits / total, total}
    else
        return {0, 0}
    end
end

-- Unused atm, but preserved with minimal pet/SC awareness
function MergedPlayer:merge(other)
    self.damage = (self.damage or 0) + (other.damage or 0)

    for ws_id, values in pairs(other.ws or {}) do
        if self.ws and self.ws[ws_id] then
            for _, value in ipairs(values) do
                self.ws[ws_id]:append(value)
            end
        else
            if not self.ws then self.ws = {} end
            self.ws[ws_id] = table.copy(values)
        end
    end
    
    self.m_hits   = (self.m_hits or 0) + (other.m_hits or 0)
    self.m_misses = (self.m_misses or 0) + (other.m_misses or 0)
    self.m_min    = math.min(self.m_min or math.huge, other.m_min or 0)
    self.m_max    = math.max(self.m_max or 0, other.m_max or 0)
    
    local total_m_hits = (self.m_hits or 0) + (other.m_hits or 0)
    if total_m_hits > 0 then
        self.m_avg    = (self.m_avg or 0)  * (self.m_hits or 0)/total_m_hits +
                        (other.m_avg or 0) * (other.m_hits or 0)/total_m_hits
    else
        self.m_avg = 0
    end
    
    self.m_crits   = (self.m_crits or 0) + (other.m_crits or 0)
    self.m_crit_min = math.min(self.m_crit_min or math.huge, other.m_crit_min or 0)
    self.m_crit_max = math.max(self.m_crit_max or 0, other.m_crit_max or 0)

    local total_m_crits  = (self.m_crits or 0) + (other.m_crits or 0)
    if total_m_crits > 0 then
        self.m_crit_avg = (self.m_crit_avg or 0)  * (self.m_crits or 0) / total_m_crits +
                          (other.m_crit_avg or 0) * (other.m_crits or 0) / total_m_crits
    else
        self.m_crit_avg = 0
    end
    
    self.r_hits   = (self.r_hits or 0) + (other.r_hits or 0)
    self.r_misses = (self.r_misses or 0) + (other.r_misses or 0)
    self.r_min    = math.min(self.r_min or math.huge, other.r_min or 0)
    self.r_max    = math.max(self.r_max or 0, other.r_max or 0)

    local total_r_hits = (self.r_hits or 0) + (other.r_hits or 0)
    if total_r_hits > 0 then
        self.r_avg    = (self.r_avg or 0)  * (self.r_hits or 0)/total_r_hits +
                        (other.r_avg or 0) * (other.r_hits or 0)/total_r_hits
    else
        self.r_avg = 0
    end
    
    self.r_crits    = (self.r_crits or 0) + (other.r_crits or 0)
    self.r_crit_min = math.min(self.r_crit_min or math.huge, other.r_crit_min or 0)
    self.r_crit_max = math.max(self.r_crit_max or 0, other.r_crit_max or 0)

    local total_r_crits  = (self.r_crits or 0) + (other.r_crits or 0)
    if total_r_crits > 0 then
        self.r_crit_avg = (self.r_crit_avg or 0)  * (self.r_crits or 0) / total_r_crits +
                          (other.r_crit_avg or 0) * (other.r_crits or 0) / total_r_crits
    else
        self.r_crit_avg = 0
    end
    
    self.jobabils = (self.jobabils or 0) + (other.jobabils or 0)
    self.spells   = (self.spells or 0) + (other.spells or 0)
end

return MergedPlayer


--[[
Copyright (c) 2013, Jerry Hebert
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


-- Object to encapsulate DPS Clock functionality

local DPSClock = {
    clock = 0,        -- accumulated seconds of active DPS time
    prev_time = 0,    -- last tick timestamp when advancing
    active = false,   -- whether the clock is currently running
    last_event = 0    -- timestamp of the last real damage event (os.time())
}

function DPSClock:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- ensure fields exist on new instance
    o.clock = o.clock or 0
    o.prev_time = o.prev_time or 0
    o.active = o.active or false
    o.last_event = o.last_event or 0

    return o
end

-- Mark a real damage event. This should be called by the action handler
-- whenever real non-zero damage (or a meaningful hit) is recorded.
-- Behavior:
--  - sets last_event to now
--  - if the clock is not active, starts it and seeds prev_time so the next advance has a correct base
function DPSClock:mark_event()
    local now = os.time()
    self.last_event = now

    if not self.active then
        self.active = true
        -- seed prev_time so the first advance has a proper delta
        self.prev_time = now
    end
end

-- Advance the clock by the elapsed time since the last tick, but only when active.
-- This function no longer implicitly "starts" the clock; it only accumulates time.
function DPSClock:advance()
    if not self.active then
        return
    end

    local now = os.time()

    if self.prev_time == 0 then
        -- seed prev_time but don't add time until we have a real delta
        self.prev_time = now
        return
    end

    local delta = now - self.prev_time
    if delta > 0 then
        self.clock = self.clock + delta
    end

    self.prev_time = now
end

-- Pause the clock (stop ticking). Does NOT clear last_event so external logic can still consult
-- last_event to decide whether to re-start within a grace window.
function DPSClock:pause()
    self.active = false
    self.prev_time = 0
end

function DPSClock:is_active()
    return self.active
end

-- Reset the clock entirely (used by //sbx reset). This clears last_event too so there's no immediate restart.
function DPSClock:reset()
    self.active = false
    self.clock = 0
    self.prev_time = 0
    self.last_event = 0
end

-- Convert integer seconds into a "HhMmSs" string
function DPSClock:to_string()
    local seconds = math.floor(self.clock)

    local hours = math.floor(seconds / 3600)
    seconds = seconds - hours * 3600

    local minutes = math.floor(seconds / 60)
    seconds = seconds - minutes * 60

    local hours_str    = hours > 0 and hours .. "h" or ""
    local minutes_str  = minutes > 0 and minutes .. "m" or ""
    local seconds_str  = seconds and seconds .. "s" or ""

    return hours_str .. minutes_str .. seconds_str
end

return DPSClock


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



-------------------------------------------------------------------------------------------------------
--  Samurai Gearswap Lua - EdenXI (75 Cap)
--  Author: Vhagar (EdenXI)
--  Version: 1.0
--
--  DESCRIPTION:
--      This is a custom Samurai GearSwap Lua designed specifically for Samurai on the EdenXI private
--      server. It includes deep support for level-syncing, Store TP modes, conditional food system, time/day
--      checks, and WS conditional overlays. This Lua was built for reliability even when zoning,
--      dying, or swapping weapons at low sync levels.
--
--  MAJOR FEATURES:
--      • Multiple Samurai Modes:
--          - sixhit
--          - fivehit
--          - polearm
--			- pdt
--
--      • Conditional Food System:
--          Toggle that cycles conditional foods per Samurai Mode.
--
--      • Level Sync Logic:
--          Gear sets rebuild dynamically whenever your main job level changes.
--
--      • Auto-Loading Job Keybinds:
--          Automatically executes Windower/scripts/name_of_file.txt
--
--      • Day/Time Elemental Checks:
--          Automatically equips Lightning Ring, Fire Ring, Fenrir's Earring, Vampire Earring, etc.,
--          based on day element or time of day.
--
--      • Death / Raise Handling:
--          Automatically prevents swaps when dead, and refreshes gear sets after being raised to prevent GearSwap lock-ups.
--
--      • Zoning Logic:
--          Automatically refreshes sets after zoning to avoid broken gear references.
--
--      • Sleep & Paralysis Handling:
--          Auto equips Berserker's Torque to wake you, and Flagellant's Rope while paralyzed.
--
--      • Samurai Roll Logic:
--          Automatically switches to power TP and power WS sets when Samurai Roll is active.
--
--      • Built-in HUD:
--          Displays current Samurai Mode + Conditional Food in real time using texts.lua.
--
--      • Idle / Engaged Decision Engine:
--          Includes safe-zone detection, mode-specific variants, weapon-first equip logic,
--          and overlays for day/time/buff checks.
--
--  COMMANDS:
--      Use via: Keybinds
--
--      • ALT+F1 = cycle_mode sixhit
--      • ALT+F2 = cycle_mode fivehit
--      • ALT+F3 = cycle_mode polearm
--          - First press switches to that mode.
--          - Pressing it again cycles the conditional food for that mode.
--		• ` = toggle PDT mode on/off (immediately switches in/out of defensive set)
--
--      Internal automated commands (you normally never trigger these manually):
--          • zone_refresh
--          • raise_refresh
--          • finish_pending_equip
--
--  IMPORTANT NOTES:
--      • All gear sets are organized by level brackets (40–75) for clean level sync behavior.
-------------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------------
--                                       SAM Mode HUD                                                --
--                       Track your current Samurai Mode and display it                              --
-------------------------------------------------------------------------------------------------------

-------============♣  Load Required files  ♣============------- [Preload]

texts = require('texts')
 
-------============♣  Samurai Modes  ♣============------- [Define Samurai Modes]
 
 -- Track engaged mode: 'fivehit', 'sixhit', 'polearm'
sam_mode = 'sixhit'
pdt_mode = false
pending_equip = nil

-- Food state per mode: 'none' | 'carbonara' | 'riceball'
food_state = {
	sixhit  = 'none',
    fivehit = 'none',
    polearm = 'none'
}
food_cycle = {'none','carbonara','riceball'} -- cycle order

 -------============♣  Samurai Mode HUD  ♣============------- [Define Samurai Modes]

-- Simple HUD for Samurai modes
hud = texts.new({
    pos = {x = 1525, y = 300},   -- adjust position on your screen
    text = {font = 'Arial', size = 12, stroke = {width = 2, alpha = 255}},
    bg = {alpha = 128},
    flags = {draggable = true}
})

function update_hud()
    local mode_text = ''

    -- Samurai Mode
    if sam_mode then
        mode_text = mode_text .. 'Samurai Mode: ' .. sam_mode .. '\n'
    end

    -- Food
    mode_text = mode_text .. 'Conditional Food: ' .. (food_state[sam_mode] or 'none') .. '\n'

    -- PDT Mode line with GREEN/RED color
    if pdt_mode then
        mode_text = mode_text .. 'PDT: \\cs(0,255,0)True\\cs(255,255,255)\n'
    else
        mode_text = mode_text .. 'PDT: \\cs(255,0,0)False\\cs(255,255,255)\n'
    end

    hud:text(mode_text)
    hud:show()
end


update_hud()

-------------------------------------------------------------------------------------------------------
--                                  Gear Sets Section                                                --
--                         Define your gear sets in this section.                                    --
--               Sets defined here will be called on in the functions section.                       --
--		  			 My Samurai gear sets are divided into level brackets							 --
-------------------------------------------------------------------------------------------------------

 function get_sets()
 
	-- leave these blank
	sets.ws = {}
	sets.ja = {}
	sets.idle = {}
	sets.engaged = {}
	sets.idle.fivehit = {}
	sets.idle.sixhit = {}
	sets.engaged.fivehit = {}
	sets.engaged.sixhit = {}
	sets.ws.fivehityuki = {}
	sets.ws.fivehitgekko = {}
	sets.ws.fivehitkasha = {}
	sets.ws.sixhityuki = {}
	sets.ws.sixhitgekko = {}
	sets.ws.sixhitkasha = {}
	sets.ws.penta = {}
	
	-- runs function to load job specific keybinds
	job_keybinds()
	
	-----------------------------------------------------------------------------------------------------------------------------------
	
	if	player.main_job_level >= 40 and		-- if job level is 40-49 use these gear sets
		player.main_job_level <= 49 then 
		sam_mode = 'sixhit'
	-----------------------------------------------------------------------------------------------------------------------------------
	
			sets.idle = {
			    main="Hosodachi",
				sub="Brass Grip +1",
				ammo="Olibanum Sachet",
				head="Emperor Hairpin",
				body="Jujitsu Gi",
				hands="Ochiudo's Kote",
				legs="Republic Subligar",
				feet="Fuma Kyahan",
				neck="Peacock Charm",
				waist="Brave Belt",
				left_ear="Beetle Earring +1",
				right_ear="Beetle Earring +1",
				left_ring="Rajas Ring",
				right_ring="Sniper's Ring +1",
				back="Resentment Cape",
			}
			sets.engaged = {
			    main="Hosodachi",
				sub="Brass Grip +1",
				ammo="Olibanum Sachet",
				head="Emperor Hairpin",
				body="Jujitsu Gi",
				hands="Ochiudo's Kote",
				legs="Republic Subligar",
				feet="Fuma Kyahan",
				neck="Peacock Charm",
				waist="Brave Belt",
				left_ear="Beetle Earring +1",
				right_ear="Beetle Earring +1",
				left_ring="Rajas Ring",
				right_ring="Sniper's Ring +1",
				back="Resentment Cape",
			}
			sets.ws.enpi = {
				feet="Federation kyahan",
			}
	end
	
	-----------------------------------------------------------------------------------------------------------------------------------
	
	if	player.main_job_level == 50 or		-- if job level is 50-51 then use these gear sets
		player.main_job_level == 51 then	-- Polearm mode required
		sam_mode = 'polearm'
	-----------------------------------------------------------------------------------------------------------------------------------
	
			sets.idle = {
			    main="R.K. Army Lance",
				sub="Brass Grip +1",
				ammo="Olibanum Sachet",
				head="Voyager Sallet",
				body="Shm. Hara-Ate",
				hands="Ochiudo's Kote",
				legs="Shm. Haidate",
				feet="Fuma Kyahan",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Beetle Earring +1",
				right_ear="Beetle Earring +1",
				left_ring="Rajas Ring",
				right_ring="Sniper's Ring +1",
				back="Jaguar Mantle",
			}
			sets.engaged.polearm = {
			    main="R.K. Army Lance",
				sub="Brass Grip +1",
				ammo="Olibanum Sachet",
				head="Voyager Sallet",
				body="Shm. Hara-Ate",
				hands="Ochiudo's Kote",
				legs="Shm. Haidate",
				feet="Fuma Kyahan",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Beetle Earring +1",
				right_ear="Beetle Earring +1",
				left_ring="Rajas Ring",
				right_ring="Sniper's Ring +1",
				back="Jaguar Mantle",
			}
			sets.ws.penta = {
			    main="R.K. Army Lance",
				sub="Brass Grip +1",
				ammo="Olibanum Sachet",
				head="Voyager Sallet",
				body="Jujitsu Gi",
				hands="Ochiudo's Kote",
				legs="Republic Subligar",
				feet="Fed. Kyahan",
				neck="Peacock Charm",
				waist="Life Belt",
				left_ear="Beetle Earring +1",
				right_ear="Beetle Earring +1",
				left_ring="Rajas Ring",
				right_ring="Sniper's Ring +1",
				back="Jaguar Mantle",
			}
	end
	
	-----------------------------------------------------------------------------------------------------------------------------------
	
	if	player.main_job_level >= 52 and		-- if job level is 52-54 use these gear sets
		player.main_job_level <= 54 then	-- polearm mode required
		sam_mode = 'polearm'
	-----------------------------------------------------------------------------------------------------------------------------------	
	
			sets.idle = {
			    main="Kamayari",
				sub="Brass Grip +1",
				ammo="Olibanum Sachet",
				head="Walkure Mask",
				body="Shm. Hara-Ate",
				hands="Ochiudo's Kote",
				legs="Shm. haidate",
				feet="Fuma Kyahan",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Sniper's Ring +1",
				back="Jaguar Mantle",
			}
			sets.engaged.polearm = {
			    main="Kamayari",
				sub="Brass Grip +1",
				ammo="Olibanum Sachet",
				head="Walkure Mask",
				body="Shm. Hara-Ate",
				hands="Ochiudo's Kote",
				legs="Shm. haidate",
				feet="Fuma Kyahan",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Sniper's Ring +1",
				back="Jaguar Mantle",
			}
			sets.ws.penta = {
				main="Kamayari",
				sub="Brass Grip +1",
				ammo="Olibanum Sachet",
				head="Walkure Mask",
				body="Shm. Hara-Ate",
				hands="Ochiudo's Kote",
				legs="Shm. haidate",
				feet="Fed. Kyahan",
				neck="Peacock Charm",
				waist="Swordbelt +1",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Sniper's Ring +1",
				back="Amemet Mantle +1",
			}
	end
	
	-----------------------------------------------------------------------------------------------------------------------------------
	
	if	player.main_job_level == 55 or		-- if level 55-56 use these gear sets
		player.main_job_level == 56 then	-- polearm mode required
		sam_mode = 'polearm'
	-----------------------------------------------------------------------------------------------------------------------------------
		
			sets.idle = {
			    main="Battle Fork",
				sub="Mythril Grip +1",
				ammo="Olibanum Sachet",
				head="Walkure Mask",
				body="Shm. Hara-Ate",
				hands="Ochiudo's Kote",
				legs="Shm. haidate",
				feet="Fuma Kyahan",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Sniper's Ring +1",
				back="Jaguar Mantle",
			}
			sets.engaged.polearm = {
			    main="Battle Fork",
				sub="Mythril Grip +1",
				ammo="Olibanum Sachet",
				head="Walkure Mask",
				body="Shm. Hara-Ate",
				hands="Ochiudo's Kote",
				legs="Shm. haidate",
				feet="Fuma Kyahan",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Sniper's Ring +1",
				back="Jaguar Mantle",
			}
			sets.ws.penta = {
				main="Battle Fork",
				sub="Mythril Grip +1",
				ammo="Olibanum Sachet",
				head="Walkure Mask",
				body="Jaridah Peti",
				hands="Ochiudo's Kote",
				legs="Ryl.Kgt. Breeches",
				feet="Fed. Kyahan",
				neck="Peacock Charm",
				waist="Swordbelt +1",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Sniper's Ring +1",
				back="Amemet Mantle +1",
			}
	end
	
	-----------------------------------------------------------------------------------------------------------------------------------
	
	if	player.main_job_level == 57 then	-- if level 57 use these gear sets -- polearm mode required
		sam_mode = 'polearm'
	-----------------------------------------------------------------------------------------------------------------------------------
	
			sets.idle = {
			    main="Partisan +1",
				sub="Mythril Grip +1",
				ammo="Olibanum Sachet",
				head="Walkure Mask",
				body="Scorpion Harness +1",
				hands="Ochiudo's Kote",
				legs="Ryl.Kgt. Breeches",
				feet="Fuma Kyahan",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Jaguar Mantle",
			}
			sets.engaged.polearm = {
			    main="Partisan +1",
				sub="Mythril Grip +1",
				ammo="Olibanum Sachet",
				head="Walkure Mask",
				body="Scorpion Harness +1",
				hands="Ochiudo's Kote",
				legs="Ryl.Kgt. Breeches",
				feet="Fuma Kyahan",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Jaguar Mantle",
			}
			sets.ws.penta = {
				main="Partisan +1",
				sub="Mythril Grip +1",
				ammo="Olibanum Sachet",
				head="Walkure Mask",
				body="Jaridah Peti",
				hands="Ochiudo's Kote",
				legs="Ryl.Kgt. Breeches",
				feet="Fed. Kyahan",
				neck="Peacock Charm",
				waist="Swordbelt +1",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Jaguar Mantle",
			}
	end
	
	-----------------------------------------------------------------------------------------------------------------------------------
	
	if	player.main_job_level == 58 then	-- if level 58 use these gear sets -- polearm mode required
		sam_mode = 'polearm'
	-----------------------------------------------------------------------------------------------------------------------------------
	
			sets.idle = {
			    main="Partisan +1",
				sub="Mythril Grip +1",
				ammo="Tiphia sting",
				head="Walkure Mask",
				body="Scorpion Harness +1",
				hands="Ochiudo's Kote",
				legs="Ryl.Kgt. Breeches",
				feet="Fuma Kyahan",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Jaguar Mantle",
			}
			sets.engaged.polearm = {
			    main="Partisan +1",
				sub="Mythril Grip +1",
				ammo="Tiphia sting",
				head="Walkure Mask",
				body="Scorpion Harness +1",
				hands="Ochiudo's Kote",
				legs="Ryl.Kgt. Breeches",
				feet="Fuma Kyahan",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Jaguar Mantle",
			}
			sets.ws.penta = {
				main="Partisan +1",
				sub="Mythril Grip +1",
				ammo="Tiphia sting",
				head="Walkure Mask",
				body="Jaridah Peti",
				hands="Ochiudo's Kote",
				legs="Ryl.Kgt. Breeches",
				feet="Fed. Kyahan",
				neck="Peacock Charm",
				waist="Swordbelt +1",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Jaguar Mantle",
			}
	end
	
	-----------------------------------------------------------------------------------------------------------------------------------
	
	if	player.main_job_level == 59 then	-- if level 59 use these gear sets -- polearm mode required
		sam_mode = 'polearm'
	-----------------------------------------------------------------------------------------------------------------------------------
	
			sets.idle = {
			    main="Partisan +1",
				sub="Mythril Grip +1",
				ammo="Tiphia sting",
				head="Walkure Mask",
				body="Haubergeon +1",
				hands="Ochiudo's Kote",
				legs="Shm. haidate",
				feet="Fuma Kyahan",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Jaguar Mantle",
			}
			sets.engaged.polearm = {
			    main="Partisan +1",
				sub="Mythril Grip +1",
				ammo="Tiphia sting",
				head="Walkure Mask",
				body="Haubergeon +1",
				hands="Ochiudo's Kote",
				legs="Shm. haidate",
				feet="Fuma Kyahan",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Jaguar Mantle",
			}
			sets.ws.penta = {
				main="Partisan +1",
				sub="Mythril Grip +1",
				ammo="Tiphia Sting",
				head="Walkure Mask",
				body="Haubergeon +1",
				hands="Ochiudo's Kote",
				legs="Ryl.Kgt. Breeches",
				feet="Fed. Kyahan",
				neck="Peacock Charm",
				waist="Swordbelt +1",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Jaguar Mantle",
			}
	end
	
	-----------------------------------------------------------------------------------------------------------------------------------
	
	if	player.main_job_level == 60 then	-- if level 60 use these gear sets -- polearm mode required
		sam_mode = 'polearm'
	-----------------------------------------------------------------------------------------------------------------------------------
	
			sets.idle = {
			    main="Couse",
				sub="Pole grip",
				ammo="Tiphia sting",
				head="Walkure Mask",
				body="Haubergeon +1",
				hands="Ochiudo's Kote",
				legs="Ryl.Kgt. Breeches",
				feet="Fuma Kyahan",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Jaguar Mantle",
			}
			sets.engaged.polearm = {
			    main="Couse",
				sub="Pole grip",
				ammo="Tiphia sting",
				head="Walkure Mask",
				body="Haubergeon +1",
				hands="Ochiudo's Kote",
				legs="Ryl.Kgt. Breeches",
				feet="Fuma Kyahan",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Jaguar Mantle",
			}
			sets.ws.penta = {
				main="Couse",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walkure Mask",
				body="Haubergeon +1",
				hands="Ochiudo's Kote",
				legs="Ryl.Kgt. Breeches",
				feet="Fed. Kyahan",
				neck="Peacock Charm",
				waist="Swordbelt +1",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Jaguar Mantle",
			}
	end
	
	-----------------------------------------------------------------------------------------------------------------------------------
	
	if	player.main_job_level == 61 or		-- if level 61-62 use these gear sets
		player.main_job_level == 62 then	-- polearm mode required
		sam_mode = 'polearm'
	-----------------------------------------------------------------------------------------------------------------------------------
		
			sets.idle = {
			    main="Couse",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Voyager sallet",
				body="Haubergeon +1",
				hands="Ochiudo's Kote",
				legs="Shm. Haidate",
				feet="Fuma Kyahan",
				neck="Chivalrous Chain",
				waist="Swift Belt",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Amemet Mantle +1",
			}
			sets.engaged.polearm = {
			    main="Couse",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walkure Mask",
				body="Haubergeon +1",
				hands="Ochiudo's Kote",
				legs="Shm. Haidate",
				feet="Fuma Kyahan",
				neck="Chivalrous Chain",
				waist="Swift Belt",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Amemet Mantle +1",
			}
			sets.ws.penta = {
				main="Couse",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walkure Mask",
				body="Haubergeon +1",
				hands="Ochiudo's Kote",
				legs="Ryl.Kgt. Breeches",
				feet="Fed. Kyahan",
				neck="Chivalrous Chain",
				waist="Swordbelt +1",
				left_ear="Spike Earring",
				right_ear="Spike Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Amemet Mantle +1",
			}
	end
	
	-----------------------------------------------------------------------------------------------------------------------------------
	
	if	player.main_job_level >= 63 and		-- if level 63-69 use these gear sets
		player.main_job_level <= 69 then	-- polearm mode required
		sam_mode = 'polearm'
	-----------------------------------------------------------------------------------------------------------------------------------
		
			sets.idle = {
				main="Couse",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walkure Mask",
				body="Haubergeon +1",
				hands="Ochiudo's Kote",
				legs="Ryl.Kgt. Breeches",
				feet="Fuma Kyahan",
			--	neck="Chivalrous Chain",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Merman's Earring",
				right_ear="Merman's Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Amemet Mantle +1",
			}
			sets.engaged.polearm = {
				main="Couse",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walkure Mask",
				body="Haubergeon +1",
				hands="Ochiudo's Kote",
				legs="Ryl.Kgt. Breeches",
				feet="Fuma Kyahan",
			--	neck="Chivalrous Chain",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Merman's Earring",
				right_ear="Merman's Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Amemet Mantle +1",
			}
			sets.ws.penta = {
				main="Couse",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walkure Mask",
				body="Haubergeon +1",
				hands="Ochiudo's Kote",
				legs="Ryl.Kgt. Breeches",
				feet="Fed. Kyahan",
			--	neck="Chivalrous Chain",
				neck="Peacock Charm",
				waist="Swordbelt +1",
				left_ear="Merman's Earring",
				right_ear="Merman's Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's ring",
				back="Amemet Mantle +1",
			}
	end
	
	-----------------------------------------------------------------------------------------------------------------------------------
	
	if	player.main_job_level == 75 then	-- if level 75 use these gear sets
	
	-----------------------------------------------------------------------------------------------------------------------------------
	
			sets.idle.fivehit = {					-- your idle set for your 5-hit GK mode -- Requirements: 480 delay Great Katana
				main="Pachipachio",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walahra Turban",
				body="Shm. Hara-Ate",
				hands="Ochiudo's Kote",
				legs="Byakko's Haidate",
				feet="Fuma Sune-Ate",
				neck="Orochi Nodowa",
				waist="Swift Belt",
				left_ear="Attila's Earring",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.idle.fivehit.carbonara = {			-- your idle set for your 5-hit GK mode when using Carbonara food (STP +6) -- Requirements: Carbonara food, 480 delay Great Katana
				main="Pachipachio",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walahra Turban",
				body="Shm. Hara-Ate",
				hands="Ochiudo's Kote",
				legs="Byakko's Haidate",
				feet="Fuma Sune-Ate",
				neck="Orochi Nodowa",
				waist="Swift Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.idle.sixhit = {					-- your idle set for your 6-hit mode -- Requirements: +11 Store TP, 450 delay Great Katana
				main="Hagun",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walahra Turban",
				body="Askar Korazin",
				hands="Seiryu's Kote",
				legs="Byakko's Haidate",
				feet="Fuma Sune-Ate",
				neck="Orochi Nodowa",
				waist="Swift Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.idle.sixhit.carbonara = {			-- your idle set for your 6-hit mode, when using Carbonara food (STP +6) -- Requirements: +5 Store TP, Carbonara food, 450 delay Great Katana
				main="Hagun",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walahra Turban",
				body="Askar Korazin",
				hands="Seiryu's Kote",
				legs="Byakko's Haidate",
				feet="Fuma Sune-Ate",
				neck="Orochi Nodowa",
				waist="Swift Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.idle.sixhit.riceball = {			-- your idle set for your 6-hit mode -- Requirements: +11 Store TP, 450 delay Great Katana
				main="Hagun",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walahra Turban",
				body="Askar Korazin",
				hands="Seiryu's Kote",
				legs="Byakko's Haidate",
				feet="Fuma Sune-Ate",
				neck="Orochi Nodowa",
				waist="Swift Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.idle.polearm = {					-- your idle set for your polearm modes
				main="Gondo-Shizunori",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walahra Turban",
				body="Shm. Hara-Ate",
				hands="Ochiudo's Kote",
				legs="Byakko's Haidate",
				feet="Nobushi Kyahan",
				neck="Orochi Nodowa",
				waist="Swift Belt",
				left_ear="Fenrir's Earring",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.engaged.fivehit = {				-- TP set for your 5-hit GK mode -- Requirements: +19 Store TP, 480 delay Great Katana
				main="Pachipachio",
				sub="Pole Grip",
				ammo="Tiphia sting",
				head="Walahra Turban",
				body="Shm. Hara-Ate",
				hands="Dusk Gloves",
				legs="Byakko's Haidate",
				feet="Fuma Sune-Ate",
				neck="Chivalrous Chain",
				waist="Swift Belt",
				left_ear="Attila's Earring",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.engaged.fivehit.carbonara = {		-- TP set for your 5-hit GK if using Carbonara food -- Requirements: +13 Store TP, 480 delay Great Katana
				main="Pachipachio",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walahra Turban",
				body="Askar Korazin",
				hands="Dusk Gloves",
				legs="Byakko's Haidate",
				feet="Fuma Sune-Ate",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.engaged.fivehit.riceball = {		-- TP set for your 5-hit GK if using Riceball food -- Requirements: +19 Store TP, 480 delay Great Katana
				main="Pachipachio",
				sub="Pole Grip",
				ammo="Tiphia sting",
				head="Walahra Turban",
				body="Shm. Hara-Ate",
				hands="Dusk Gloves",
				legs="Byakko's Haidate",
				feet="Fuma Sune-Ate",
				neck="Chivalrous Chain",
				waist="Swift Belt",
				left_ear="Attila's Earring",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.engaged.sixhit = {					-- TP set for your 6-hit GK mode -- Requirements: +11 Store TP, 450 delay Great Katana
				main="Hagun",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walahra Turban",
				body="Askar Korazin",
				hands="Dusk Gloves",
				legs="Byakko's Haidate",
				feet="Fuma Sune-Ate",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.engaged.sixhit.carbonara = {		-- TP set for your 6-hit GK mode when using Carbonara food -- Requirements: +5 Store TP, 450 delay Great Katana
				main="Hagun",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walahra Turban",
				body="Askar Korazin",
				hands="Dusk Gloves",
				legs="Byakko's Haidate",
				feet="Fuma Sune-Ate",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Sniper's Ring +1",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.engaged.sixhit.riceball = {		-- TP set for your 6-hit GK mode when using Riceball food -- Requirements: +11 Store TP, 450 delay Great Katana
				main="Hagun",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walahra Turban",
				body="Askar Korazin",
				hands="Dusk Gloves",
				legs="Byakko's Haidate",
				feet="Fuma Sune-Ate",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.engaged.polearm = {				-- TP set for your 5-hit polearm mode, requires +19 Store TP
				main="Gondo-Shizunori",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walahra Turban",
				body="Shm. Hara-Ate",
				hands="Dusk Gloves",
				legs="Byakko's Haidate",
				feet="Nobushi Kyahan",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Ethereal Earring",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.engaged.polearm.carbonara = {		-- TP set for your 5-hit polearm mode when using Carbonara food, requires +13 Store TP
				main="Gondo-Shizunori",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walahra Turban",
				body="Askar Korazin",
				hands="Dusk Gloves",
				legs="Byakko's Haidate",
				feet="Fuma Sune-Ate",
				neck="Chivalrous Chain",
				waist="Swift Belt",
				left_ear="Attila's Earring",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.engaged.polearm.riceball = {		-- TP set for your 5-hit polearm mode when using Riceball food, requires +19 Store TP
				main="Gondo-Shizunori",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Walahra Turban",
				body="Shm. Hara-Ate",
				hands="Dusk Gloves",
				legs="Byakko's Haidate",
				feet="Nobushi Kyahan",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Ethereal Earring",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.engaged.power = {					-- Power TP set to replace Store TP sets when "Samurai Roll" buff is active, do not include weapon
				ammo="Tiphia Sting",
				head="Walahra Turban",
				body="Askar Korazin",
				hands="Dusk Gloves",
				legs="Byakko's Haidate",
				feet="Fuma Sune-Ate",
				neck="Peacock Charm",
				waist="Swift Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Sniper's Ring +1",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.penta = {						-- Penta Thrust set for non riceball mode, no Store TP gear needed for Penta Thrust (test to make sure Penta gains 200+ tp with this set)
			    main="Gondo-Shizunori",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Shr.Znr.Kabuto",
				body="Askar Korazin",
				hands="Ochiudo's Kote",
				legs="Byakko's Haidate",
				feet="Saotome Sune-Ate",
				neck="Shadow gorget",
				waist="Potent Belt",
				left_ear="Merman's earring",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.penta.riceball = {				-- Penta Thrust set when using Riceball food, includes all 3 "Enhance effects from riceballs" pieces, no Store TP requirement
			    main="Gondo-Shizunori",
				sub="Pole Grip",
				ammo="Tiphia Sting",
				head="Roshi jinpachi",
				body="Askar Korazin",
				hands="Myochin kote",
				legs="Byakko's Haidate",
				feet="Nobushi Kyahan",
				neck="Shadow gorget",
				waist="Potent Belt",
				left_ear="Merman's earring",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.fivehityuki = {					-- 5-hit WS set for Tachi: Yukikaze + other WS's that use Breeze Gorget -- Requirements: +19 Store TP, 480 delay Great Katana
				main="Pachipachio",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Hachiman Domaru",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Breeze Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.fivehityuki.carbonara = {		-- 5-hit WS set for Tachi: Yukikaze + other WS's that use Breeze Gorget -- Requirements: Carbonara food, +13 Store TP, 480 delay Great Katana
				main="Pachipachio",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Kirin's Osode",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Breeze Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.fivehityuki.riceball = {		-- 5-hit WS set for Tachi: Yukikaze + other WS's that use Breeze Gorget -- Requirements: Riceball food, Riceball+ gear, +19 Store TP, 480 delay Great Katana
				main="Pachipachio",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Hachiman Domaru",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Nobushi Kyahan",
				neck="Breeze Gorget",
				waist="Warwolf Belt",
				left_ear="Attila's Earring",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.fivehitgekko = {				-- 5-hit WS set for Tachi: Gekko + other WS's that use Aqua Gorget -- Requirements: +19 Store TP, 480 delay Great Katana
				main="Pachipachio",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Hachiman Domaru",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Aqua Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.fivehitgekko.carbonara = {		-- 5-hit WS set for Tachi: Gekko + other WS's that use Aqua Gorget -- Requirements: Carbonara food, +13 Store TP, 480 delay Great Katana
				main="Pachipachio",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Kirin's Osode",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Aqua Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.fivehitgekko.riceball = {		-- 5-hit WS set for Tachi: Gekko + other WS's that use Aqua Gorget -- Requirements: Riceball food, Riceball+ gear, +19 Store TP, 480 delay Great Katana
				main="Pachipachio",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Hachiman Domaru",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Nobushi Kyahan",
				neck="Aqua Gorget",
				waist="Warwolf Belt",
				left_ear="Attila's Earring",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.fivehitkasha = {				-- 5-hit WS set for Tachi: Kasha + other WS's that use Shadow Gorget -- Requirements: +19 Store TP, 480 delay Great Katana
				main="Pachipachio",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				--body="Hachiman Domaru",
				body="Askar Korazin",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				--neck="Shadow Gorget",
				neck="Chivalrous Chain",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				--left_ear="Attila's Earring",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.fivehitkasha.carbonara = {		-- 5-hit WS set for Tachi: Kasha + other WS's that use Shadow Gorget -- Requirements: Carbonara food, +13 Store TP, 480 delay Great Katana
				main="Pachipachio",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Kirin's Osode",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Shadow Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.fivehitkasha.riceball = {		-- 5-hit WS set for Tachi: Kasha + other WS's that use Shadow Gorget -- Requirements: Riceball food, Riceball+ gear, +19 Store TP, 480 delay Great Katana
				main="Pachipachio",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Hachiman Domaru",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Nobushi Kyahan",
				neck="Shadow Gorget",
				waist="Warwolf Belt",
				left_ear="Attila's Earring",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.sixhityuki = {					-- 6-hit WS set for Tachi: Yukikaze + other WS's that use Breeze Gorget -- Requirements: +11 Store TP, 450 delay Great Katana
				main="Hagun",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Kirin's Osode",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Breeze Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.sixhityuki.carbonara = {		-- 6-hit WS set for Tachi: Yukikaze + other WS's that use Breeze Gorget -- Requirements: Carbonara food, +5 Store TP, 450 delay Great Katana
				main="Hagun",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Kirin's Osode",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Breeze Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.sixhityuki.riceball = {			-- 6-hit WS set for Tachi: Yukikaze + other WS's that use Breeze Gorget -- Requirements: Riceball food, Riceball+ gear, +11 Store TP, 450 delay Great Katana
				main="Hagun",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Kirin's Osode",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Breeze Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.sixhitgekko = {					-- 6-hit WS set for Tachi: Gekko + other WS's that use Aqua Gorget -- Requirements: +11 Store TP, 450 delay Great Katana
				main="Hagun",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Kirin's Osode",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Aqua Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.sixhitgekko.carbonara = {		-- 6-hit WS set for Tachi: Gekko + other WS's that use Aqua Gorget -- Requirements: Carbonara food, +5 Store TP, 450 delay Great Katana
				main="Hagun",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Kirin's Osode",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Aqua Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.sixhitgekko.riceball = {		-- 6-hit WS set for Tachi: Gekko + other WS's that use Aqua Gorget -- Requirements: Riceball food, Riceball+ gear, +11 Store TP, 450 delay Great Katana
				main="Hagun",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Kirin's Osode",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Aqua Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.sixhitkasha = {					-- 6-hit WS set for Tachi: Kasha + other WS's that use Shadow Gorget -- Requirements: +11 Store TP, 450 delay Great Katana
				main="Hagun",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Kirin's Osode",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Shadow Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.sixhitkasha.carbonara = {		-- 6-hit WS set for Tachi: Kasha + other WS's that use Shadow Gorget -- Requirements: Carbonara food, +5 Store TP, 450 delay Great Katana
				main="Hagun",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Kirin's Osode",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Shadow Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.sixhitkasha.riceball = {		 -- 6-hit WS set for Tachi: Kasha + other WS's that use Shadow Gorget -- Requirements: Riceball food, Riceball+ gear, +11 Store TP, 450 delay Great Katana
				main="Hagun",
				sub="Pole Grip",
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Kirin's Osode",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Shadow Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.poweryuki = {					-- Power WS set for Tachi: Yukikaze + other WS's that use Breeze Gorget, replaces Store TP+ sets when "Samurai Roll" buff is active, don't include weapon
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Kirin's Osode",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Breeze Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.powergekko = {					-- Power WS set for Tachi: Gekko + other WS's that use Aqua Gorget, replaces Store TP+ sets when "Samurai Roll" buff is active, don't include weapon
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Kirin's Osode",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Aqua Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.powerkasha = {					-- Power WS set for Tachi: Kasha + other WS's that use Shadow Gorget, replaces Store TP+ sets when "Samurai Roll" buff is active, don't include weapon
				ammo="Olibanum Sachet",
				head="Shr.Znr.Kabuto",
				body="Kirin's Osode",
				hands="Alkyoneus's Brc.",
				legs="Shura Haidate",
				feet="Hmn. Sune-Ate",
				neck="Shadow Gorget",
				waist="Warwolf Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Flame Ring",
				back="Cerb. Mantle +1",
			}
			sets.ws.sidewinder = {					-- Sidewinder WS set for SAM/RNG
				head="Optical Hat",
				body="Hachiman Domaru",
				hands="Seiryu's Kote",
				legs="Hachiman Hakama",
				feet="Hmn. Sune-Ate",
				neck="Breeze Gorget",
				waist="Warwolf Belt",
				left_ear="Drone Earring",
				right_ear="Drone Earring",
				left_ring="Behemoth Ring",
				right_ring="Behemoth Ring",
				back="Amemet Mantle +1",
			}
			sets.ranged = {							-- Swap to this set when you perform a ranged attack
				head="Optical Hat",
				body="Kirin's Osode",
				hands="Seiryu's Kote",
				legs="Republic Subligar",
				feet="Fed. Kyahan",
				neck="Peacock Charm",
				waist="Warwolf Belt",
				left_ear="Drone Earring",
				right_ear="Drone Earring",
				left_ring="Behemoth Ring",
				right_ring="Behemoth Ring",
				back="Amemet Mantle +1",
			}
			sets.ja.provoke = {						-- Swap to this set when you use Provoke, uses +Enmity 
				ammo="Olibanum Sachet",
				head="Aegishjalmr",
				body="Arhat's Gi +1",
				hands="Myochin Kote",
				legs="Saotome Haidate",
				feet="Myochin Sune-Ate",
				neck="Evasion Torque",
				waist="Warwolf Belt",
				left_ear="Elusive Earring",
				right_ear="Elusive Earring",
				left_ring="Phalanx Ring",
				right_ring="Jelly Ring",
				back="Cerb. Mantle +1",
			}
			sets.pdt = {							-- Minus Physical Damage Taken %, Emergency Defense Engaged Set, do not include main/sub
				ammo="Olibanum Sachet",
				head="Arh. Jinpachi +1",
				body="Arhat's Gi +1",
				hands="Rasetsu Tekko",
				legs="Gavial Cuisses",
				feet="Gavial Greaves",
				neck="Ritter Gorget",
				waist="Scouter's Rope",
				left_ear="Ethereal Earring",
				right_ear="Elusive Earring",
				left_ring="Jelly Ring",
				right_ring="Phalanx Ring",
				back="Boxer's Mantle",
			}
			sets.city = {							-- Prioritize this idle set when in a city or any defined "safe zone"
				ammo="Tiphia Sting",
				head="Arh. Jinpachi +1",
				body="Kirin's Osode",
				hands="Seiryu's Kote",
				legs="Byakko's Haidate",
				feet="Fuma Sune-Ate",
				neck="Orochi Nodowa",
				waist="Swift Belt",
				left_ear="Bushinomimi",
				right_ear="Brutal Earring",
				left_ring="Rajas Ring",
				right_ring="Toreador's Ring",
				back="Cerb. Mantle +1",
			}
			sets.meditate = {						-- Swap in these pieces when using meditate
				head="Myochin Kabuto",
				hands="Saotome kote"
			}
			sets.warding = {						-- Swap in your AF head for "Warding Circle"
				head="Myochin Kabuto"
			}
			sets.ws.vampearring = {					-- Conditional item that can be swapped in at night for +4 STR on WS's
				left_ear="Vampire earring"
			}
			sets.lightningring = {					-- Lightning ring can be swapped into certain sets during Lightningsday
				right_ring="Lightning Ring"
			}
			sets.firering = {						-- Fire ring can be swapped into certain sets during Firesday
				right_ring="Fire Ring"
			}
			sets.flagellant = {						-- flagellant overlay (waist) used when paralyzed
				waist = "Flagellant's Rope"
			}

    end
end
 
-------------------------------------------------------------------------------------------------------
--                                      Function Section                                             -- 
--             Define the conditions for swapping into and out of your defined gear sets             --
------------------------------------------------------------------------------------------------------- 

-------============♣  JOB-SPECIFIC KEYBINDS  ♣============------- [Load job keybinds]

function job_keybinds()
    -- Bind Samurai mode cycle keys directly here
    send_command('bind !f1 gs c cycle_mode sixhit')
    send_command('bind !f2 gs c cycle_mode fivehit')
    send_command('bind !f3 gs c cycle_mode polearm')
	send_command('bind ` gs c toggle_pdt')

    -- Load the rest of your job specific keybinds from the external txt file located in Windower/scripts/name_of_file.txt
    send_command('exec vhagar_sam_keybinds.txt')
end

-- Unload our samurai mode keybinds when we unload this file or switch to another job.
function file_unload()
    send_command('unbind !f1')
    send_command('unbind !f2')
    send_command('unbind !f3')
	send_command('unbind `')
end

-------============♣  PRERENDER LEVEL CHECK  ♣============------- [Rebuild sets when level changes]

current_level = player.main_job_level
last_check = os.clock()

windower.register_event('prerender', function()
    -- Check once every 5 seconds
    if os.clock() - last_check > 1 then
        last_check = os.clock()
        if player.main_job_level ~= current_level then
            current_level = player.main_job_level
			windower.add_to_chat(200, 'Level changed to ' .. current_level .. ', rebuilding sets...')
			get_sets()
			choose_set()
			update_hud()
        end
    end
end)

-------============♣  SAMURAI MODES  ♣============------- [Mode change command system]

-- helper for cycle_food_for_mode function
local function index_of(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then return i end
    end
    return nil
end

-- helper for our Samurai Mode command. we use this function to cycle our food for modes
local function cycle_food_for_mode(mode)
    local cur = food_state[mode] or 'none'
    local idx = index_of(food_cycle, cur) or 1
    local next_idx = idx % #food_cycle + 1
    food_state[mode] = food_cycle[next_idx]

    windower.add_to_chat(122, ('%s conditional food -> %s'):format(mode, food_state[mode]))

    -- re-equip if this mode is currently active
    if sam_mode == mode then
        if player.status == 'Engaged' then
            equip_engaged()
        else
            equip_idle()
        end
        update_hud()
    end
end

-- self commands, activated on command using //gs c string. I keybind commands for easy mode switching, you can also macro them.
function self_command(command)
    local cmd = command:lower()
	
	-- zone_refresh and raise_refresh commands are executed after a timed buffer, after zoning or being raised. This helps prevent Gearswap from breaking and needing to be reloaded.
	if command == 'zone_refresh' then
        get_sets()
        choose_set()
		update_hud()
    end
	if command == 'raise_refresh' then
        get_sets()
        choose_set()
		update_hud()
		windower.add_to_chat(200, 'Welcome back from the dead, refreshing your gear sets...')
    end
	-- finish pending equip command is used by our equip_idle() function. 
	-- when changing to an idle set that uses a different weapon than what we have equipped, we equip the weapon 1st, then the rest of the gear after a short delay.
	if command == 'finish_pending_equip' then
		if pending_equip then
			equip(pending_equip)
			pending_equip = nil
		end
	end
	-- PDT toggle command
	if cmd == 'toggle_pdt' then
		pdt_mode = not pdt_mode

		if pdt_mode then
			windower.add_to_chat(122, 'PDT Mode: ON')
		else
			windower.add_to_chat(122, 'PDT Mode: OFF')
		end
		choose_set()
		update_hud()
		return
	end

	
	-- Samurai Mode command
    local mode = cmd:match('^cycle_mode%s+(%w+)$')
    if not mode then return end

    -- if switching to a new mode
    if sam_mode ~= mode then
        sam_mode = mode
        windower.add_to_chat(122, ('Samurai mode -> %s'):format(sam_mode))
        if player.status == 'Engaged' then
            equip_engaged()
        else
            equip_idle()
        end
        update_hud()
    else
        -- already in this mode, cycle its food
        cycle_food_for_mode(mode)
    end
end

-------============♣  HELPER FUNCTIONS  ♣============------- [Conditional Checks]

-- Helper function to check if it's lightningsday
local function is_lightning_day()
    return world and world.day_element and tostring(world.day_element):lower() == 'lightning'
end

-- Helper function to check if it's firesday
local function is_fire_day()
    return world and world.day_element and tostring(world.day_element):lower() == 'fire'
end

-- List of safe zones where you don't need your defensive idle set
safe_zones = {
    ["Port Jeuno"] = true,
    ["Upper Jeuno"] = true,
    ["Lower Jeuno"] = true,
    ["Ru'Lude Gardens"] = true,
    ["Bastok Markets"] = true,
    ["Bastok Mines"] = true,
	["Port Bastok"] = true,
	["Metalworks"] = true,
    ["Windurst Waters"] = true,
    ["Windurst Walls"] = true,
	["Windurst Woods"] = true,
	["Heavens Tower"] = true,
	["Port Windurst"] = true,
    ["Southern San d'Oria"] = true,
	["Northern San d'Oria"] = true,
	["Port San d'Oria"] = true,
	["Chateau d'Oraguille"] = true,
    ["Nashmau"] = true,
    ["Aht Urhgan Whitegate"] = true,
	["Al Zahbi"] = true,
    ["Mhaura"] = true,
    ["Selbina"] = true,
	["Tavnazian Safehold"] = true,
	["Norg"] = true,
    -- Add more as needed
}

-- Helper function to check if you're in a safe zone
function is_safe_zone()
    return safe_zones[world.zone] or false
end

-- Function to handle zone changes
function zone_change(new_zone, old_zone)
    windower.send_command('wait 5; gs c zone_refresh')	-- 5 second buffer, then runs get_sets() and choose_set() from the self_command() function
end

-- Helper function to check if it's night time
function is_night()
    return world.time >= 1080 or world.time <= 360
end

-- Helper function to detect and handle status changes - idle/engaged/resting/dead
function status_change(new, old)
    -- Prevent GearSwap from attempting gearswaps while dead, or immediately after being raised.
	-- Should prevent GearSwap from breaking when you die, requiring a reload.
    if new == 'Dead' or old == 'Dead' or player.status == 'Dead' then
        return
    end
	-- If our status change is unrelated to death, then its safe to check for idle/engaged/resting and equip those sets
    choose_set()
end

-- Helper function to handle buff changes
function buff_change(buff, gain)
    buff = buff:lower()

    -- Weakness handling (after raise)
    if buff == "weakness" and gain then
        windower.send_command('wait 7; gs c raise_refresh')
        return
    end

    -- Sleep handling
    if buff == "sleep" then
        if gain then
            equip({ neck = "Berserker's Torque" })
        else
            choose_set()
        end
        return
    end

    -- Paralysis handling
    if buff == "paralysis" or buff == "paralyzed" then
        if gain then
            if player.status == 'Engaged' then
                equip_engaged()
            else
                choose_set()
            end
        else
            choose_set()
        end
        return
    end
end

-- Helper function to decide which set to choose based on player status - idle/engaged/resting
function choose_set()
  --Engaged
    if player.status == "Engaged" then
        equip_engaged()
  --Resting
	elseif player.status == "Resting" then
        equip(sets.rest)
    else 
  --Idle
		equip_idle()
    end
end

-------============♣  EQUIP IDLE  ♣============------- [Equip Function]

-- Equips our idle set
function equip_idle()
    -- If in a safe zone you use your casual/flashy city set (or equip your Aketon for speed)
    if is_safe_zone() then
        local set = sets.city or sets.idle
		-- Show off your lightning ring or fire ring if its the correct day and your level is high enough
        if player.main_job_level >= 65 and player.main_job_level <= 75 and is_lightning_day() then
            set = set_combine(set, {right_ring = "Lightning Ring"})
		elseif player.main_job_level >= 65 and player.main_job_level <= 75 and is_fire_day() then
            set = set_combine(set, {right_ring = "Fire Ring"})
        end
        equip(set)
		--return
    end
	
	-- Prioritize our emergency defensive set if PDT mode is on
	if pdt_mode == true then
		local set = set_combine(sets.idle[sam_mode], sets.pdt)
		equip(set)
		return
	end
	
    -- If we're not in a defined "Safe Zone" then - Prefer mode-specific idle variant, fallback to generic sets.idle
    local base_idle
    if sam_mode and sets.idle[sam_mode] then
        -- prefer per-mode food variant if present
        local food = food_state[sam_mode] or 'none'
        if food ~= 'none' and sets.idle[sam_mode][food] then
            base_idle = sets.idle[sam_mode][food]
        else
            base_idle = sets.idle[sam_mode]
        end
    else
        base_idle = sets.idle or sets.idle.normal
    end
	
	-- After we apply our sam mode gear, check level & day for conditional rings
	-- Level checks necessary to prevent errors when level syncing
	if player.main_job_level >= 65 and player.main_job_level <= 75 and is_lightning_day() then
        base_idle = set_combine(base_idle, {right_ring = "Lightning Ring"})
    elseif player.main_job_level >= 65 and player.main_job_level <= 75 and is_fire_day() then
        base_idle = set_combine(base_idle, {right_ring = "Fire Ring"})
    end
	
	-- Check if our new idle weapon is different from our current weapon. If it is, equip main first, then equip the rest of our gear after a 0.5 delay
	-- This fixes an error related to our sub requiring a main to be equipped when level syncing or changing SAM modes
	if base_idle and base_idle.main and base_idle.sub then
		local cur_main = player.equipment.main
		if cur_main ~= base_idle.main then
			equip({ main = base_idle.main })
			pending_equip = base_idle
			windower.send_command('wait 0.5; gs c finish_pending_equip')
			return
		end
	end

    equip(base_idle)
end

-------============♣  EQUIP ENGAGED  ♣============------- [Equip Function]

-- Handles what gear we wear while engaged.
function equip_engaged()
    local engaged_set
	
	-- if our PDT mode is active, prioritize our defense set
	if pdt_mode == true then
		engaged_set = set_combine(sets.engaged[sam_mode], sets.pdt)
	
	-- if we have samurai roll active, assume we have enough store TP and equip our power set
    elseif buffactive['Samurai Roll'] then
		engaged_set = sets.engaged.power or sets.engaged
	
	-- else check for store tp mode and use that set
	else
        local mode = sam_mode or 'sixhit'
        -- choose base engaged set
        local base = sets.engaged[mode] or sets.engaged.power or sets.engaged
        -- prefer per-mode food variant
        local food = food_state[mode] or 'none'
		
        if food ~= 'none' and base[food] then
            engaged_set = base[food]
        else
            engaged_set = base
        end
		
		----- OVERLAY SECTION -----
		
		-- if polearm mode and daytime, equip fenrir earring to left_ear
		if mode == 'polearm' and player.main_job_level >= 70 and player.main_job_level <= 75 and not is_night() then
			engaged_set = set_combine(engaged_set, {left_ear="Fenrir's Earring"})
		end
	
		-- Apply Lightning Ring overlay on Lightning day
		if player.main_job_level >= 65 and player.main_job_level <= 75 and is_lightning_day() then
			engaged_set = set_combine(engaged_set, {right_ring = "Lightning Ring"})
		end
		
		-- If paralyzed, overlay Flagellant's Rope (waist)
		if buffactive['Paralysis'] or buffactive['Paralyzed'] then
			engaged_set = set_combine(engaged_set, sets.flagellant or {waist = "Flagellant's Rope"})
		end
	end
    equip(engaged_set)
end

-------============♣  PRECASE SPELL  ♣============------- [Equip Function]

function precast(spell)
	-- check if sneak is already active upon casting, automatically cancel buff if it is
	if (spell.name == 'Sneak' or spell.name:contains('Monomi')) and spell.target.type == 'SELF' then
        if buffactive['Sneak'] then
            send_command('cancel Sneak')	-- uses the "cancel" addon to cancel my buff via command
        end
    end
	
	-- Tachi: Yukikaze (buff & mode-aware)
	if spell.name == "Tachi: Yukikaze" then
		local wsset = nil

		-- If Samurai Roll is active, use power WS set
		if buffactive['Samurai Roll'] then
			wsset = sets.ws.poweryuki
		else
			-- pick base WS set based on sam_mode
			if sam_mode == 'sixhit' then
				wsset = sets.ws.sixhityuki
			elseif sam_mode == 'fivehit' then
				wsset = sets.ws.fivehityuki
			end

			-- then apply food overlay if it exists
			local food = food_state[sam_mode]
			if food and food ~= 'none' and wsset[food] then
				wsset = wsset[food]
			end
		end
		
		-- If its nighttime, equip our Vampire Earring over our Bushinomimi
		if is_night() then
			wsset = set_combine(wsset, sets.ws.vampearring)
		end

		equip(wsset)
	end
	
	-- Tachi: Gekko (buff & mode-aware)
	if spell.name == "Tachi: Gekko" then
		local wsset = nil

		-- If Samurai Roll is active, use power WS set
		if buffactive['Samurai Roll'] then
			wsset = sets.ws.powergekko
		else
			-- pick base WS set based on sam_mode
			if sam_mode == 'sixhit' then
				wsset = sets.ws.sixhitgekko
			elseif sam_mode == 'fivehit' then
				wsset = sets.ws.fivehitgekko
			end

			-- then apply food overlay if it exists
			local food = food_state[sam_mode]
			if food and food ~= 'none' and wsset[food] then
				wsset = wsset[food]
			end
		end
		
		-- If its nighttime, equip our Vampire Earring over our Bushinomimi
		if is_night() then
			wsset = set_combine(wsset, sets.ws.vampearring)
		end

		equip(wsset)
	end
	
	-- Kasha / Rana / Jinpu - Shadow Gorget family (buff & mode-aware)
	if spell.name == "Tachi: Kasha" or
	   spell.name == "Tachi: Rana" or
	   spell.name == "Tachi: Jinpu" then
		local wsset = nil

		-- If Samurai Roll is active, use power WS set
		if buffactive['Samurai Roll'] then
			wsset = sets.ws.powerkasha
		else
			-- pick base WS set based on sam_mode
			if sam_mode == 'sixhit' then
				wsset = sets.ws.sixhitkasha
			elseif sam_mode == 'fivehit' then
				wsset = sets.ws.fivehitkasha
			end

			-- then apply food overlay if it exists
			local food = food_state[sam_mode]
			if food and food ~= 'none' and wsset[food] then
				wsset = wsset[food]
			end
		end

		-- If its nighttime, equip our Vampire Earring over our Bushinomimi
		if is_night() then
			wsset = set_combine(wsset, sets.ws.vampearring)
		end

		equip(wsset)
	end
	
	--Penta Thrust, checks for food mode, daytime check for fenrir earring, lightningday and firesday checks for rings
	if	spell.name == "Penta Thrust" or
		spell.name == "Impulse Drive" then
		local wsset = sets.ws.penta

		-- then apply food overlay if it exists
		local food = food_state[sam_mode]
		if food and food ~= 'none' and wsset[food] then
			wsset = wsset[food]
		end
		
		-- daytime Fenrir's Earring check
		if player.main_job_level >= 70 and player.main_job_level <= 75 and not is_night() then
			wsset = set_combine(wsset, {left_ear="Fenrir's Earring"})
		end
		-- Lightning day: add Lightning Ring to right_ring
		if player.main_job_level >= 65 and player.main_job_level <= 75 and is_lightning_day() then
			wsset = set_combine(wsset, {right_ring = "Lightning Ring"})
		-- Fires day: add Fire Ring to right_ring
		elseif player.main_job_level >= 65 and player.main_job_level <= 75 and is_fire_day() then
			wsset = set_combine(wsset, {right_ring = "Fire Ring"})
		end
		equip(wsset)
	end
	
	if 	spell.name == "Meditate" or
		spell.name == "Warding Circle" then
			equip(sets.meditate)
	end
	if	spell.name == "Sidewinder" then
			equip(sets.ws.sidewinder)
	end
	if	spell.name == "Tachi: Enpi" then
			equip(sets.ws.enpi)
	end
	if	spell.name == "Provoke" then
			equip(sets.ja.provoke)
	end
	if	spell.action_type == 'Ranged Attack' then
			equip(sets.ranged)
	end
end
 
-------============♣  MIDCAST SPELL  ♣============------- [Equip Function]
 
function midcast(spell)
end

-------============♣  AFTERCAST SPELL  ♣============------- [Equip Function]

function aftercast(spell)
     choose_set()
end

windower.register_event("zone change", zone_change)

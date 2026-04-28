-------------------------------------------------------------------------------------------------------
--                                  Gear Sets Section                                                --
--                         Define your gear sets in this section.                                    --
--               Sets defined here will be called on in the functions section.                       -- 
-------------------------------------------------------------------------------------------------------

-- Elemental Mode (1 = Potency, 2 = Accuracy, 3 = Max Accuracy)
elementalMode = 1

function get_sets()

	job_keybinds()

	--leave these empty
	sets.precast = {}
	sets.midcast = {}
	sets.midcast.stone = {}
	sets.midcast.water = {}
	sets.midcast.aero = {}
	sets.midcast.fire = {}
	sets.midcast.blizzard = {}
	sets.midcast.thunder = {}
	
	if player.main_job_level >= 30 and
	   player.main_job_level <= 39 then
		sets.idle = {
			main="Yew Wand +1",
			ammo="Morion Tathlum",
			head="Seer's Crown +1",
			body="Baron's Saio",
			hands="Seer's Mitts +1",
			legs="Seer's Slacks",
			feet="Custom F Boots",
			neck="Black Neckerchief",
			waist="Shaman's Belt",
			left_ear="Morion Earring",
			right_ear="Morion Earring",
			left_ring="Tamas Ring",
			right_ring="Eremite's Ring +1",
			back="Mist Silk Cape",
		}
		sets.rest = {
			main="Pilgrim's Wand",
			ammo="Morion Tathlum",
			head="Seer's Crown +1",
			body="Seer's Tunic",
			hands="Seer's Mitts +1",
			legs="Baron's Slops",
			feet="Custom F Boots",
			neck="Black Neckerchief",
			waist="Mohbwa Sash +1",
			left_ear="Morion Earring",
			right_ear="Morion Earring",
			left_ring="Tamas Ring",
			right_ring="Eremite's Ring +1",
			back="Mist Silk Cape",
		}
		sets.midcast.cure = {
			main="Yew Wand +1",
			ammo="Morion Tathlum",
			head="Traveler's Hat",
			body="Baron's Saio",
			hands="Devotee's Mitts",
			legs="Seer's Slacks",
			feet="Seer's Pumps",
			neck="Justice Badge",
			waist="Friar's Rope",
			left_ear="Morion Earring",
			right_ear="Morion Earring",
			left_ring="Tamas Ring",
			right_ring="Saintly Ring +1",
			back="Mist Silk Cape",
		}
	end
	if player.main_job_level >= 40 and
	   player.main_job_level <= 49 then
		sets.idle = {
			main="Solid Wand",
			ammo="Morion Tathlum",
			head="Seer's Crown +1",
			body="Baron's Saio",
			hands="Seer's Mitts +1",
			legs="Seer's Slacks",
			feet="Custom F Boots",
			neck="Mohbwa Scarf +1",
			waist="Shaman's Belt",
			left_ear="Morion Earring",
			right_ear="Morion Earring",
			left_ring="Tamas Ring",
			right_ring="Eremite's Ring +1",
			back="Black Cape +1",
		}
		sets.rest = {
			main="Pilgrim's Wand",
			ammo="Morion Tathlum",
			head="Seer's Crown +1",
			body="Seer's Tunic",
			hands="Seer's Mitts +1",
			legs="Baron's Slops",
			feet="Custom F Boots",
			neck="Mohbwa Scarf +1",
			waist="Qiqirn Sash +1",
			left_ear="Morion Earring",
			right_ear="Morion Earring",
			left_ring="Tamas Ring",
			right_ring="Eremite's Ring +1",
			back="Black Cape +1",
		}
		sets.midcast.cure = {
			main="Solid Wand",
			ammo="Morion Tathlum",
			head="Traveler's Hat",
			body="Bishop's Robe",
			hands="Devotee's Mitts",
			legs="Custom Pants",
			feet="Seer's Pumps",
			neck="Justice Badge",
			waist="Friar's Rope",
			left_ear="Morion Earring",
			right_ear="Morion Earring",
			left_ring="Tamas Ring",
			right_ring="Saintly Ring +1",
			back="White Cape +1",
		}
	end
	
	if player.main_job_level >= 50 and
	   player.main_job_level <= 59 then
		sets.idle = {
			main="Solid Wand",
			ammo="Morion Tathlum",
			head="Seer's Crown +1",
			body="Baron's Saio",
			hands="Seer's Mitts +1",
			legs="Seer's Slacks",
			feet="Custom F Boots",
			neck="Mohbwa Scarf +1",
			waist="Shaman's Belt",
			left_ear="Morion Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Eremite's Ring +1",
			back="Red Cape +1",
		}
		sets.rest = {
			main="Pilgrim's Wand",
			ammo="Morion Tathlum",
			head="Seer's Crown +1",
			body="Seer's Tunic",
			hands="Seer's Mitts +1",
			legs="Baron's Slops",
			feet="Custom F Boots",
			neck="Beak Necklace +1",
			waist="Qiqirn Sash +1",
			left_ear="Antivenom Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Eremite's Ring +1",
			back="Red Cape +1",
		}
		sets.midcast.cure = {
			main="Solid Wand",
			ammo="Morion Tathlum",
			head="Traveler's Hat",
			body="Bishop's Robe",
			hands="Devotee's Mitts",
			legs="Custom Pants",
			feet="Seer's Pumps",
			neck="Justice Badge",
			waist="Friar's Rope",
			left_ear="Morion Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Saintly Ring +1",
			back="Red Cape +1",
		}
		sets.midcast.skulkers = {
				back="Skulker's cape"
			}
	end
	
	if player.main_job_level >= 60 and
	   player.main_job_level <= 74 then
		sets.idle = {
			main="Terra's Staff",
			sub="Bugard Strap +1",
			ammo="Morion Tathlum",
			--ammo="Phtm. Tathlum",
			body="Vermillion Cloak",
			--body="Demon's Cloak",
			hands="Wizard's Gloves",
			legs="Wizard's Tonban",
			--legs="Mahatma Slops",
			feet="Custom F Boots",
			neck="Mohbwa Scarf +1",
			--neck="Philomath Stole",
			waist="Penitent's Rope",
			left_ear="Morion Earring",
			--left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			--left_ring="Eremite's Ring +1",
			right_ring="Eremite's Ring +1",
			left_ring="Tamas Ring",
			--right_ring="Snow ring",
			back="Red Cape +1",
			--back="Prism Cape",
		}
		sets.rest = {
			main="Pluto's Staff",
			body="Vermillion Cloak",
			--body="Demon's Cloak",
			--body="Errant Hpl.",
			legs="Baron's Slops",
			neck="Beak Necklace +1",
			waist="Qiqirn Sash +1",
			left_ear="Antivenom Earring",
			right_ear="Relaxing Earring",
			back="Invigorating Cape",
		}
		sets.midcast.cure = {
			main="Apollo's Staff",
			sub="Raptor Strap +1",
			ammo="Morion Tathlum",
			--ammo="Phtm. Tathlum",
			body="Vermillion Cloak",
			--body="Demon's Cloak",
			hands="Devotee's Mitts",
			legs="Custom Pants",
			--legs="Mahatma Slops",
			feet="Seer's Pumps",
			--feet="Mahatma Pigaches",
			neck="Justice Badge",
			waist="Penitent's Rope",
			left_ear="Morion Earring",
			right_ear="Morion Earring",
			--left_ring="Saintly Ring +1",
			right_ring="Saintly Ring +1",
			left_ring="Tamas Ring",
			--right_ring="Sapphire Ring",
			back="Red Cape +1",
			--back="Prism Cape",
		}
		sets.midcast.stone = {
			main="Terra's Staff",
			sub="Bugard Strap +1",
			ammo="Morion Tathlum",
			--ammo="Phtm. Tathlum",
			body="Shaman's Cloak",
			hands="Wizard's Gloves",
			legs="Seer's Slacks",
			--legs="Mahatma Slops",
			feet="Custom F Boots",
			neck="Mohbwa Scarf +1",
			--neck="Philomath Stole",
			waist="Penitent's Rope",
			left_ear="Morion Earring",
			--left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			--left_ring="Eremite's Ring +1",
			right_ring="Eremite's Ring +1",
			left_ring="Tamas Ring",
			--right_ring="Snow ring",
			back="Red Cape +1",
			--back="Prism Cape",
		}
		sets.midcast.water = {
			main="Neptune's Staff",
			sub="Bugard Strap +1",
			ammo="Morion Tathlum",
			--ammo="Phtm. Tathlum",
			body="Shaman's Cloak",
			hands="Wizard's Gloves",
			legs="Seer's Slacks",
			--legs="Mahatma Slops",
			feet="Custom F Boots",
			neck="Mohbwa Scarf +1",
			--neck="Philomath Stole",
			waist="Penitent's Rope",
			left_ear="Morion Earring",
			--left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			--left_ring="Eremite's Ring +1",
			right_ring="Eremite's Ring +1",
			left_ring="Tamas Ring",
			--right_ring="Snow ring",
			back="Red Cape +1",
			--back="Prism Cape",
		}
		sets.midcast.aero = {
			main="Auster's Staff",
			sub="Bugard Strap +1",
			ammo="Morion Tathlum",
			--ammo="Phtm. Tathlum",
			body="Shaman's Cloak",
			hands="Wizard's Gloves",
			legs="Seer's Slacks",
			--legs="Mahatma Slops",
			feet="Custom F Boots",
			neck="Mohbwa Scarf +1",
			--neck="Philomath Stole",
			waist="Penitent's Rope",
			left_ear="Morion Earring",
			--left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			--left_ring="Eremite's Ring +1",
			right_ring="Eremite's Ring +1",
			left_ring="Tamas Ring",
			--right_ring="Snow ring",
			back="Red Cape +1",
			--back="Prism Cape",
		}
		sets.midcast.fire = {
			main="Vulcan's Staff",
			sub="Bugard Strap +1",
			ammo="Morion Tathlum",
			--ammo="Phtm. Tathlum",
			body="Shaman's Cloak",
			hands="Wizard's Gloves",
			legs="Seer's Slacks",
			--legs="Mahatma Slops",
			feet="Custom F Boots",
			neck="Mohbwa Scarf +1",
			--neck="Philomath Stole",
			waist="Penitent's Rope",
			left_ear="Morion Earring",
			--left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			--left_ring="Eremite's Ring +1",
			right_ring="Eremite's Ring +1",
			left_ring="Tamas Ring",
			--right_ring="Snow ring",
			back="Red Cape +1",
			--back="Prism Cape",
		}
		sets.midcast.blizzard = {
			main="Aquilo's Staff",
			sub="Bugard Strap +1",
			ammo="Morion Tathlum",
			--ammo="Phtm. Tathlum",
			body="Shaman's Cloak",
			hands="Wizard's Gloves",
			legs="Seer's Slacks",
			--legs="Mahatma Slops",
			feet="Custom F Boots",
			neck="Mohbwa Scarf +1",
			--neck="Philomath Stole",
			waist="Penitent's Rope",
			left_ear="Morion Earring",
			--left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			--left_ring="Eremite's Ring +1",
			right_ring="Eremite's Ring +1",
			left_ring="Tamas Ring",
			--right_ring="Snow ring",
			back="Red Cape +1",
			--back="Prism Cape",
		}
		sets.midcast.thunder = {
			main="Jupiter's Staff",
			sub="Bugard Strap +1",
			ammo="Morion Tathlum",
			--ammo="Phtm. Tathlum",
			body="Shaman's Cloak",
			hands="Wizard's Gloves",
			legs="Seer's Slacks",
			--legs="Mahatma Slops",
			feet="Custom F Boots",
			neck="Mohbwa Scarf +1",
			--neck="Philomath Stole",
			waist="Penitent's Rope",
			left_ear="Morion Earring",
			--left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			--left_ring="Eremite's Ring +1",
			right_ring="Eremite's Ring +1",
			left_ring="Tamas Ring",
			--right_ring="Snow ring",
			back="Red Cape +1",
			--back="Prism Cape",
		}
		sets.midcast.darkenf = {
			main="Pluto's Staff",
			sub="Bugard Strap +1",
			ammo="Morion Tathlum",
			--ammo="Phtm. Tathlum",
			head="Wizard's Petasos",
			--head="Igqira tiara",
			body="Wizard's Coat +1",
			hands="Seer's Mitts +1",
			--hands="Errant Cuffs",
			legs="Seer's Slacks",
			--legs="Mahatma Slops",
			--legs="Igqira lappas",
			feet="Custom F Boots",
			neck="Mohbwa Scarf +1",
			--neck="Enfeebling Torque",
			waist="Penitent's Rope",
			left_ear="Morion Earring",
			--left_ear="Abyssal Earring",
			right_ear="Morion Earring",
			left_ring="Tamas Ring",
			right_ring="Eremite's Ring +1",
			back="Red Cape +1",
			--back="Prism Cape",
		}
		sets.midcast.darkmag = {
			main="Pluto's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			body="Shaman's Cloak",
			--body="Demon's Cloak",
			body="Errant Hpl.",
			hands="Seer's Mitts +1",
			--hands="Errant Cuffs",
			legs="Wizard's Tonban",
			feet="Custom F Boots",
			neck="Mohbwa Scarf +1",
			--neck="Philomath Stole",
			waist="Penitent's Rope",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Eremite's Ring +1",
			--right_ring="Snow ring",
			back="Red Cape +1",
			--back="Prism Cape",
		}
		sets.midcast.stoneskin = {
			main="Terra's Staff",
			sub="Raptor Strap +1",
			ammo="Phtm. Tathlum",
			head="Errant Hat",
			body="Bishop's Robe",
			--body="Errant Hpl.",
			hands="Devotee's Mitts",
			legs="Custom Pants",
			--legs="Mahatma Slops",
			feet="Seer's Pumps",
			--feet="Mahatma pigaches",
			neck="Mohbwa Scarf +1",
			waist="Penitent's Rope",
			left_ear="Morion Earring",
			right_ear="Morion Earring",
			left_ring="Tamas Ring",
			right_ring="Saintly Ring +1",
			--right_ring="Aqua Ring",
			back="Red Cape +1",
			--back="Prism Cape",
		}
		sets.midcast.gravity = {
			main="Auster's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Wizard's Petasos",
			--head="Igqira tiara",
			body="Wizard's Coat +1",
			hands="Seer's Mitts +1",
			--hands="Errant Cuffs",
			legs="Seer's Slacks",
			--legs="Mahatma Slops",
			--legs="Igqira lappas",
			feet="Custom F Boots",
			neck="Mohbwa Scarf +1",
			--neck="Philomath Stole",
			--neck="Enfeebling Torque",
			waist="Penitent's Rope",
			left_ear="Morion Earring",
			right_ear="Morion Earring",
			left_ring="Tamas Ring",
			right_ring="Eremite's Ring +1",
			--right_ring="Snow ring",
			back="Red Cape +1",
			--back="Prism Cape",
		}
		sets.midcast.bind = {
			main="Aquilo's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Wizard's Petasos",
			--head="Igqira tiara",
			body="Wizard's Coat +1",
			hands="Seer's Mitts +1",
			--hands="Errant Cuffs",
			legs="Seer's Slacks",
			--legs="Mahatma Slops",
			--legs="Igqira lappas",
			feet="Custom F Boots",
			neck="Mohbwa Scarf +1",
			--neck="Philomath Stole",
			--neck="Enfeebling Torque",
			waist="Penitent's Rope",
			left_ear="Morion Earring",
			right_ear="Morion Earring",
			left_ring="Tamas Ring",
			right_ring="Eremite's Ring +1",
			--right_ring="Snow ring",
			back="Red Cape +1",
			--back="Prism Cape",
		}
		sets.midcast.silence = {
			main="Auster's Staff",
			sub="Raptor Strap +1",
			ammo="Phtm. Tathlum",
			head="Errant Hat",
			--head="Igqira tiara",
			body="Wizard's Coat +1",
			hands="Devotee's Mitts",
			legs="Custom Pants",
			--legs="Mahatma Slops",
			--legs="Igqira lappas",
			feet="Seer's Pumps",
			neck="Mohbwa Scarf +1",
			--neck="Enfeebling Torque",
			waist="Penitent's Rope",
			left_ear="Moldavite Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Saintly Ring +1",
			--right_ring="Aqua Ring",
			back="Red Cape +1",
			--back="Prism Cape",
		}
		sets.midcast.skulkers = {
				back="Skulker's cape"
			}
	end
	
	if player.main_job_level == 75 then
		sets.precast.fc = {left_ear="Loquacious earring", feet="Rostrum pumps"}
		sets.precast.convertmp = {
			main="Pluto's Staff",
			sub="Thunder Grip",
			ammo="Phtm. Tathlum",
			head="Zenith Crown",
			body="Dalmatica",
			hands="Zenith Mitts",
			legs="Zenith Slacks",
			feet="Rostrum pumps",
			neck="Morgana's Choker",
			waist="Sorcerer's Belt",
			left_ear="Loquac. Earring",
			right_ear="Moldavite Earring",
			left_ring="Serket Ring",
			right_ring="Sorcerer's Ring",
			back="Blue Cape +1",
		}
		sets.idle = {
			main="Terra's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Sorcerer's Petas.",
			body="Dalmatica",
			hands="Zenith Mitts",
			legs="Goliard Trews",
			feet="Herald's Gaiters",
			neck="Uggalepih Pendant",
			waist="Sorcerer's Belt",
			left_ear="Loquac. Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Jelly Ring",
			back="Umbra Cape",
		}
		sets.home = {
			main="Terra's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Sorcerer's Petas.",
			body="Dalmatica",
			hands="Zenith Mitts",
			legs="Goliard Trews",
			feet="Herald's Gaiters",
			neck="Uggalepih Pendant",
			waist="Sorcerer's Belt",
			left_ear="Loquac. Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Jelly Ring",
			back="Umbra Cape",
			}
		sets.rest = {
			main="Rsv.Cpt. Mace",
			sub="Legion Scutum",
			ammo="Phtm. Tathlum",
			head="Oracle's Cap",
			body="Oracle's Robe",
			hands="Zenith Mitts",
			legs="Yigit Seraweels",
			feet="Goliard Clogs",
			neck="Beak Necklace +1",
			waist="Qiqirn Sash +1",
			left_ear="Antivenom Earring",
			right_ear="Relaxing Earring",
			left_ring="Tamas Ring",
			right_ring="Serket Ring",
			back="Invigorating Cape",
		}
		sets.midcast.cure = {
			main="Apollo's Staff",
			sub="Raptor Strap +1",
			ammo="Hedgehog Bomb",
			head="Errant Hat",
			body="Errant Hpl.",
			hands="Nashira Gages",
			legs="Mahatma Slops",
			feet="Rostrum Pumps",
			neck="Promise Badge",
			waist="Penitent's Rope",
			left_ear="Loquac. Earring",
			right_ear="Cmn. Earring",
			left_ring="Tamas Ring",
			right_ring="Aqua Ring",
			back="Prism Cape",
		}
		sets.midcast.stone.potency = {
			main="Terra's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Wzd. Petasos +1",
			body="Igqira Weskit",
			hands="Zenith mitts",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Philomath Stole",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Sorcerer's Ring",
			back="Prism Cape",
		}
		sets.midcast.stone.acc = {
			main="Terra's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Sorcerer's petasos",
			body="Igqira Weskit",
			hands="Zenith mitts",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Elemental torque",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Sorcerer's Ring",
			back="Prism Cape",
		}
		sets.midcast.stone.maxacc = {
			main="Terra's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Sorcerer's petasos",
			body="Igqira Weskit",
			hands="Wizard's Gloves",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Elemental Torque",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Omega Ring",
			back="Prism Cape",
		}
		sets.midcast.water.potency = {
			main="Neptune's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Wzd. Petasos +1",
			body="Igqira Weskit",
			hands="Zenith mitts",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Philomath Stole",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Sorcerer's Ring",
			back="Prism Cape",
		}
		sets.midcast.water.acc = {
			main="Neptune's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Sorcerer's petasos",
			body="Igqira Weskit",
			hands="Zenith mitts",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Elemental torque",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Sorcerer's Ring",
			back="Prism Cape",
		}
		sets.midcast.water.maxacc = {
			main="Neptune's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Sorcerer's petasos",
			body="Igqira Weskit",
			hands="Wizard's Gloves",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Elemental Torque",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Omega Ring",
			back="Prism Cape",
		}
		sets.midcast.aero.potency = {
			main="Auster's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Wzd. Petasos +1",
			body="Igqira Weskit",
			hands="Zenith mitts",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Philomath Stole",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Sorcerer's Ring",
			back="Prism Cape",
		}
		sets.midcast.aero.acc = {
			main="Auster's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Sorcerer's petasos",
			body="Igqira Weskit",
			hands="Zenith mitts",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Elemental torque",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Sorcerer's Ring",
			back="Prism Cape",
		}
		sets.midcast.aero.maxacc = {
			main="Auster's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Sorcerer's petasos",
			body="Igqira Weskit",
			hands="Wizard's Gloves",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Elemental Torque",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Omega Ring",
			back="Prism Cape",
		}
		sets.midcast.fire.potency = {
			main="Vulcan's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Wzd. Petasos +1",
			body="Igqira Weskit",
			hands="Zenith mitts",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Philomath Stole",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Sorcerer's Ring",
			back="Prism Cape",
		}
		sets.midcast.fire.acc = {
			main="Vulcan's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Sorcerer's petasos",
			body="Igqira Weskit",
			hands="Zenith mitts",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Elemental torque",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Sorcerer's Ring",
			back="Prism Cape",
		}
		sets.midcast.fire.maxacc = {
			main="Vulcan's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Sorcerer's petasos",
			body="Igqira Weskit",
			hands="Wizard's Gloves",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Elemental Torque",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Omega Ring",
			back="Prism Cape",
		}
		sets.midcast.blizzard.potency = {
			main="Aquilo's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Wzd. Petasos +1",
			body="Igqira Weskit",
			hands="Zenith mitts",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Philomath Stole",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Sorcerer's Ring",
			back="Prism Cape",
		}
		sets.midcast.blizzard.acc = {
			main="Aquilo's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Sorcerer's petasos",
			body="Igqira Weskit",
			hands="Zenith mitts",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Elemental torque",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Sorcerer's Ring",
			back="Prism Cape",
		}
		sets.midcast.blizzard.maxacc = {
			main="Aquilo's Staff",
			sub="Ice Grip",
			ammo="Phtm. Tathlum",
			head="Sorcerer's petasos",
			body="Igqira Weskit",
			hands="Wizard's Gloves",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Elemental Torque",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Omega Ring",
			back="Prism Cape",
		}
		sets.midcast.thunder.potency = {
			main="Jupiter's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Wzd. Petasos +1",
			body="Igqira Weskit",
			hands="Zenith mitts",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Philomath Stole",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Sorcerer's Ring",
			back="Prism Cape",
		}
		sets.midcast.thunder.acc = {
			main="Jupiter's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Sorcerer's petasos",
			body="Igqira Weskit",
			hands="Zenith mitts",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Elemental torque",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Sorcerer's Ring",
			back="Prism Cape",
		}
		sets.midcast.thunder.maxacc = {
			main="Jupiter's Staff",
			sub="Thunder Grip",
			ammo="Phtm. Tathlum",
			head="Sorcerer's petasos",
			body="Igqira Weskit",
			hands="Wizard's Gloves",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Elemental Torque",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Moldavite Earring",
			left_ring="Tamas Ring",
			right_ring="Omega Ring",
			back="Prism Cape",
		}
		sets.midcast.darkenf = {
			main="Pluto's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Igqira Tiara",
			body="Wizard's Coat +1",
			hands="Goliard Cuffs",
			legs="Igqira Lappas",
			feet="Avocat Pigaches",
			neck="Enfeebling Torque",
			waist="Sorcerer's Belt",
			left_ear="Loquac. Earring",
			right_ear="Abyssal Earring",
			left_ring="Tamas Ring",
			right_ring="Omega Ring",
			back="Prism Cape",
		}
		sets.midcast.darkmag = {
			main="Pluto's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Wzd. Petasos +1",
			body="Nashira Manteel",
			hands="Sorcerer's Gloves",
			legs="Wizard's Tonban",
			feet="Goliard Clogs",
			neck="Dark Torque",
			waist="Sorcerer's Belt",
			left_ear="Abyssal Earring",
			right_ear="Morion Earring",
			left_ring="Balrahn's Ring",
			right_ring="Omega Ring",
			back="Prism Cape",
		}
		sets.midcast.stoneskin = {
			main="Kirin's Pole",
			sub="Raptor Strap +1",
			ammo="Phtm. Tathlum",
			head="Zenith Crown",
			body="Errant Hpl.",
			hands="Devotee's Mitts",
			legs="Mahatma Slops",
			feet="Rostrum Pumps",
			neck="Promise Badge",
			waist="Penitent's Rope",
			left_ear="Cmn. Earring",
			right_ear="Cmn. Earring",
			left_ring="Tamas Ring",
			right_ring="Aqua Ring",
			back="Prism Cape",
		}
		sets.midcast.gravity = {
			main="Auster's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Igqira Tiara",
			body="Wizard's Coat +1",
			hands="Goliard Cuffs",
			legs="Igqira Lappas",
			feet="Avocat Pigaches",
			neck="Enfeebling Torque",
			waist="Sorcerer's Belt",
			left_ear="Loquac. Earring",
			right_ear="Morion Earring",
			left_ring="Tamas Ring",
			right_ring="Omega Ring",
			back="Prism Cape",
		}
		sets.midcast.bind = {
			main="Aquilo's Staff",
			sub="Bugard Strap +1",
			ammo="Phtm. Tathlum",
			head="Igqira Tiara",
			body="Wizard's Coat +1",
			hands="Goliard Cuffs",
			legs="Igqira Lappas",
			feet="Avocat Pigaches",
			neck="Enfeebling Torque",
			waist="Sorcerer's Belt",
			left_ear="Loquac. Earring",
			right_ear="Morion Earring",
			left_ring="Tamas Ring",
			right_ring="Omega Ring",
			back="Prism Cape",
		}
		sets.midcast.silence = {			-- this is my set for Silence. (MND + Enfeebling (priority) + Wind Staff)
			main="Auster's Staff",
			sub="Raptor Strap +1",
			ammo="Phtm. Tathlum",
			head="Igqira Tiara",
			body="Wizard's Coat +1",
			hands="Goliard Cuffs",
			legs="Igqira Lappas",
			feet="Goliard Clogs",
			neck="Enfeebling Torque",
			waist="Penitent's Rope",
			left_ear="Cmn. Earring",
			right_ear="Cmn. Earring",
			left_ring="Tamas Ring",
			right_ring="Omega Ring",
			back="Prism Cape",
		}
		sets.midcast.paralyze = {         -- this is my set for Paralyze. (MND + Enfeebling + Ice Staff)
			main="Aquilo's Staff",
			sub="Raptor Strap +1",
			ammo="Hedgehog Bomb",
			head="Igqira Tiara",
			body="Errant Hpl.",
			hands="Devotee's Mitts",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Enfeebling Torque",
			waist="Penitent's Rope",
			left_ear="Cmn. Earring",
			right_ear="Cmn. Earring",
			left_ring="Tamas Ring",
			right_ring="Omega Ring",
			back="Prism Cape",
		}
		sets.midcast.slow = {              -- this is my set for Slow spells. (MND + Enfeebling + Earth Staff)
			main="Terra's Staff",
			sub="Raptor Strap +1",
			ammo="Hedgehog Bomb",
			head="Igqira Tiara",
			body="Errant Hpl.",
			hands="Devotee's Mitts",
			legs="Mahatma Slops",
			feet="Goliard Clogs",
			neck="Enfeebling Torque",
			waist="Penitent's Rope",
			left_ear="Cmn. Earring",
			right_ear="Cmn. Earring",
			left_ring="Tamas Ring",
			right_ring="Omega Ring",
			back="Prism Cape",
		}
		sets.midcast.skulkers = {back="Skulker's cape"}
		-- Conditional items
		sets.midcast.tonban = {legs="Sorcerer's Tonban"}
		sets.midcast.iceobi = {waist="Hyorin obi"}
		sets.midcast.thunderobi = {waist="Rairin obi"}
		sets.midcast.fireobi = {waist="Karin obi"}
		sets.midcast.earthobi = {waist="Dorin obi"}
		sets.midcast.waterobi = {waist="Suirin obi"}
		sets.midcast.windobi = {waist="Furin obi"}
		sets.midcast.darkobi = {waist="Anrin obi"}
		sets.midcast.uggpendant = {neck="Uggalepih pendant"}
		sets.midcast.diabolospole = {main="Diabolos's Pole"}
		sets.midcast.diabolosring = {right_ring="Diabolos's Ring"}
	end
end

-------------------------------------------------------------------------------------------------------
--                                      Function Section                                             -- 
--             Define the conditions for swapping into and out of your defined gear sets             --
------------------------------------------------------------------------------------------------------- 

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
            idle()
        end
    end
end)

function job_keybinds()
    send_command('exec visenya_blm_keybinds.txt')
end

-- Handle manual mode switching:
-- elementalMode: 1 = Potency, 2 = Accuracy, 3 = Max Accuracy
function self_command(cmd)
    if not cmd then return end
    local c = cmd:lower()
    if c == 'setmode potency' then
        elementalMode = 1
        windower.add_to_chat(122, 'Elemental Mode: Potency')
        return
    elseif c == 'setmode acc' then
        elementalMode = 2
        windower.add_to_chat(122, 'Elemental Mode: Accuracy')
        return
    elseif c == 'setmode maxacc' then
        elementalMode = 3
        windower.add_to_chat(122, 'Elemental Mode: Max Accuracy')
        return
    end
    if command == 'zone_refresh' then
        get_sets()
        choose_set()
		windower.add_to_chat(200, 'Zone change detected, refreshing your gear sets...')
    end
	if command == 'raise_refresh' then
        get_sets()
        choose_set()
		windower.add_to_chat(200, 'Welcome back from the dead, refreshing your gear sets...')
    end
end

-- convenience helper to pick the correct variant for an element
local function select_elemental_variant(base_set)
    if not base_set then return nil end
    if elementalMode == 1 and base_set.potency then
        return base_set.potency
    elseif elementalMode == 2 and base_set.acc then
        return base_set.acc
    elseif elementalMode == 3 and base_set.maxacc then
        return base_set.maxacc
    end
    -- fallback to the base set (could be a plain table)
    return base_set
end

-- helper function to check if we're in potency or acc mode, used to determine if we should convert hp > mp for sorc ring
function sorc_ring_allowed()
	return elementalMode == 1 or elementalMode == 2
end

function precast(spell,action)
	--if we cast a magic spell of any kind, equip our fast cast set before we start casting
	if  spell.type:contains('Magic') then
		if spell.skill == 'Elemental Magic' and sorc_ring_allowed() then
			equip(sets.precast.convertmp)
		else
		equip(sets.precast.fc)
		end
	end
	--if we cast sneak or monomi on ourselves, automatically cancel our current sneak buff using the cancel addon
	if (spell.name == 'Sneak' or spell.name:contains('Monomi')) and spell.target.type == 'SELF' then
        if buffactive['Sneak'] then
            send_command('cancel Sneak')
        end
    end
	--if we start to cast stoneskin on ourselves and we already have stoneskin on - cancel our current stoneskin using the cancel addon.
	if spell.name == 'Stoneskin' and spell.target.type == 'SELF' then
        if buffactive['Stoneskin'] then
            send_command('cancel Stoneskin')
        end
    end
end

function midcast(spell,action)
	if											
		spell.name:match('Cure') or 
		spell.name:match('Curaga') then   
			equip(sets.midcast.cure)
	end
	if											
		spell.name == "Dispel" or
		spell.name == "Blind" or
		spell.name:match('Sleep') or
		spell.name:match('Poison') or
		spell.name:match('Bio') then
			equip(sets.midcast.darkenf)
	end
	if										
		spell.name == "Drain" or
		spell.name == "Aspir" then
		--define a variable and store our default dark magic gearset inside it
		local darkset = sets.midcast.darkmag
		--check if it's both darksday and dark weather, if so, combine our dark obi, diabolos pole, and diabolos ring with our default dark magic set
		if spell.element == world.weather_element and spell.element == world.day_element then
		darkset = set_combine(darkset, sets.midcast.darkobi, sets.midcast.diabolospole, sets.midcast.diabolosring)
		--if not both, check if it's dark weather and if so, combine our dark obi and diabolos pole with our default dark magic set
		elseif spell.element == world.weather_element then
		darkset = set_combine(darkset, sets.midcast.darkobi, sets.midcast.diabolospole)
		--else if it's not dark weather but it is darksday, then combine our dark obi and diabolos ring with our gearset
		elseif spell.element == world.day_element then
        darkset = set_combine(darkset, sets.midcast.darkobi, sets.midcast.diabolosring)
		end
		--now equip our darkset
		equip(darkset)
	end
	if										
		spell.name == "Stun" then
		--define a variable and store our default dark magic gearset inside it
		local darkset = sets.midcast.darkmag
		if spell.element == world.day_element then
        darkset = set_combine(darkset, sets.midcast.diabolosring)
		end
		equip(darkset)
	end
	if	--If casting an Earth Elemental Spell	
		spell.name == "Stone" or
		spell.name == "Stone II" or
		spell.name == "Stone III" or
		spell.name == "Stone IV" or
		spell.name:match('Stonega') or
		spell.name == "Rasp" or
		spell.name:match('Quake') then
		
		--define a couple variables - "base" = sets.midcast.element, then apply the current mode to the end to call the correct set - sets.midcast.element.potency/acc/maxxacc and save it as "gearset"
		local base = sets.midcast.stone
		local gearset = select_elemental_variant(base)

		--If the spells element matches the day, then combine our "gearset" with our Sorc pants and Elemental Obi
		--else if the spells element matches the current weather, then combine our "gearset" with the Elemental Obi
		if spell.element == world.day_element then
        gearset = set_combine(gearset, sets.midcast.tonban, sets.midcast.earthobi)
		elseif spell.element == world.weather_element then
        gearset = set_combine(gearset, sets.midcast.earthobi)
		end
		--if your MP is currently less than or equal to 51% of your max, then combine "gearset" with Uggalepih Pendant
		if player.mp / player.max_mp <= 0.51 then
        gearset = set_combine(gearset, sets.midcast.uggpendant)
		end
		--now that you've selected the correct base set and applied all the variable gear to it, its time to equip it
		equip(gearset)
		return
	end
	
	if	--If casting a Water Elemental Spell
		spell.name:match('Water') or
		spell.name:match('Waterga') or
		spell.name == "Drown" or
		spell.name:match('Flood') then
		
		--define a couple variables - "base" = sets.midcast.element, then apply the current mode to the end to call the correct set - sets.midcast.element.potency/acc/maxxacc and save it as "gearset"
		local base = sets.midcast.water
		local gearset = select_elemental_variant(base)

		--If the spells element matches the day, then combine our "gearset" with our Sorc pants and Elemental Obi
		--else if the spells element matches the current weather, then combine our "gearset" with the Elemental Obi
		if spell.element == world.day_element then
        gearset = set_combine(gearset, sets.midcast.tonban, sets.midcast.waterobi)
		elseif spell.element == world.weather_element then
        gearset = set_combine(gearset, sets.midcast.waterobi)
		end
		--if your MP is currently less than or equal to 51% of your max, then combine "gearset" with Uggalepih Pendant
		if player.mp / player.max_mp <= 0.51 then
        gearset = set_combine(gearset, sets.midcast.uggpendant)
		end
		--now that you've selected the correct base set and applied all the variable gear to it, its time to equip it
		equip(gearset)
		return
	end
	
	if	--If casting a Wind Elemental Spell
		spell.name:match('Aero') or
		spell.name:match('Aeroga') or
		spell.name:match('Tornado') or
		spell.name == "Choke" then
		
		--define a couple variables - "base" = sets.midcast.element, then apply the current mode to the end to call the correct set - sets.midcast.element.potency/acc/maxxacc and save it as "gearset"
		local base = sets.midcast.aero
		local gearset = select_elemental_variant(base)

		--If the spells element matches the day, then combine our "gearset" with our Sorc pants and Elemental Obi
		--else if the spells element matches the current weather, then combine our "gearset" with the Elemental Obi
		if spell.element == world.day_element then
        gearset = set_combine(gearset, sets.midcast.tonban, sets.midcast.windobi)
		elseif spell.element == world.weather_element then
		gearset = set_combine(gearset, sets.midcast.windobi)
		end
		--if your MP is currently less than or equal to 51% of your max, then combine "gearset" with Uggalepih Pendant
		if player.mp / player.max_mp <= 0.51 then
        gearset = set_combine(gearset, sets.midcast.uggpendant)
		end
		--now that you've selected the correct base set and applied all the variable gear to it, its time to equip it
		equip(gearset)
		return
	end
	
	if	--If casting a Fire Elemental Spell
		spell.name:match('Fire') or
		spell.name:match('Firaga') or
		spell.name:match('Flare') or
		spell.name == "Burn" then
		
		--define a couple variables - "base" = sets.midcast.element, then apply the current mode to the end to call the correct set - sets.midcast.element.potency/acc/maxxacc and save it as "gearset"
		local base = sets.midcast.fire
		local gearset = select_elemental_variant(base)

		--If the spells element matches the day, then combine our "gearset" with our Sorc pants and Elemental Obi
		--else if the spells element matches the current weather, then combine our "gearset" with the Elemental Obi
		if spell.element == world.day_element then
        gearset = set_combine(gearset, sets.midcast.tonban, sets.midcast.fireobi)
		elseif spell.element == world.weather_element then
        gearset = set_combine(gearset, sets.midcast.fireobi)
		end
		--if your MP is currently less than or equal to 51% of your max, then combine "gearset" with Uggalepih Pendant
		if player.mp / player.max_mp <= 0.51 then
        gearset = set_combine(gearset, sets.midcast.uggpendant)
		end
		--now that you've selected the correct base set and applied all the variable gear to it, its time to equip it
		equip(gearset)
		return
	end
	
	if	--If casting an Ice Elemental Spell
		spell.name:match('Blizzard') or
		spell.name:match('Blizzaga') or
		spell.name == "Frost" or
		spell.name == "Freeze" or
		spell.name == "Freeze II" then
		
		--define a couple variables - "base" = sets.midcast.element, then apply the current mode to the end to call the correct set - sets.midcast.element.potency/acc/maxxacc and save it as "gearset"
		local base = sets.midcast.blizzard
		local gearset = select_elemental_variant(base)

		--If the spells element matches the day, then combine our "gearset" with our Sorc pants and Elemental Obi
		--else if the spells element matches the current weather, then combine our "gearset" with the Elemental Obi
		if spell.element == world.day_element then
        gearset = set_combine(gearset, sets.midcast.tonban, sets.midcast.iceobi)
		elseif spell.element == world.weather_element then
        gearset = set_combine(gearset, sets.midcast.iceobi)
		end
		--if your MP is currently less than or equal to 51% of your max, then combine "gearset" with Uggalepih Pendant
		if player.mp / player.max_mp <= 0.51 then
        gearset = set_combine(gearset, sets.midcast.uggpendant)
		end
		--now that you've selected the correct base set and applied all the variable gear to it, its time to equip it
		equip(gearset)
		return
	end
	
	if	--If casting a Thunder Elemental Spell
		spell.name:match('Thunder') or
		spell.name:match('Thundaga') or
		spell.name == "Burst" or
		spell.name == "Burst II" or
		spell.name == "Shock" then
		
		--define a couple variables - "base" = sets.midcast.element, then apply the current mode to the end to call the correct set - sets.midcast.element.potency/acc/maxxacc and save it as "gearset"
		local base = sets.midcast.thunder
		local gearset = select_elemental_variant(base)

		--If the spells element matches the day, then combine our "gearset" with our Sorc pants and Elemental Obi
		--else if the spells element matches the current weather, then combine our "gearset" with the Elemental Obi
		if spell.element == world.day_element then
        gearset = set_combine(gearset, sets.midcast.tonban, sets.midcast.thunderobi)
		elseif spell.element == world.weather_element then
        gearset = set_combine(gearset, sets.midcast.thunderobi)
		end
		--if your MP is currently less than or equal to 51% of your max, then combine "gearset" with Uggalepih Pendant
		if player.mp / player.max_mp <= 0.51 then
        gearset = set_combine(gearset, sets.midcast.uggpendant)
		end
		--now that you've selected the correct base set and applied all the variable gear to it, its time to equip it
		equip(gearset)
		return
	end
	
	if											
		spell.name == "Stoneskin" then
			equip(sets.midcast.stoneskin)
	end
	if											
		spell.name == "Gravity" then
			equip(sets.midcast.gravity)
	end
	if											
		spell.name == "Bind" then
			equip(sets.midcast.bind)
	end
	if
		spell.name == "Silence" then
			equip(sets.midcast.silence)
	end
	if
		spell.name == "Paralyze" then
			equip(sets.midcast.paralyze)
	end
	if	
		spell.name == "Slow" then
			equip(sets.midcast.slow)
	end
	if
		spell.name == "Sneak" or
		spell.name == "Invisible" then
			equip(sets.midcast.skulkers)
	end
end

-- Equip idle gear, but check if in San d'Oria zones for home set
function aftercast(spell,action)
	if aketon_zone[world.zone] then
		equip(sets.home)
	else
		equip(sets.idle)
	end
end

function idle()
	if aketon_zone[world.zone] then
		equip(sets.home)
	else
		equip(sets.idle)
	end
end

-- Function to handle zone changes
function zone_change(new_zone, old_zone)
	windower.send_command('wait 5; gs c zone_refresh')	-- 5 second buffer, then runs get_sets() and choose_set() from the self_command() function
end

function engaged()
end

function rest()
	equip(sets.rest)
end
 
--status change checks if we just got raised, to prevent Gearswap from breaking on death.
function status_change(new,old)
    if new == 'Dead' or new == 'KO' then return end
    if old == 'Dead' or old == 'KO' then
        -- we were dead and now not -> rebuild sets
        windower.send_command('wait 7; gs c raise_refresh')	-- 7 second buffer after getting raised, then runs get_sets and choose_set functions from self_command
        return
    end
    -- normal behavior
    choose_set()
end

function choose_set()
  --Engaged
    if player.status == "Engaged" then
        equip_engaged()
  --Resting
	elseif player.status == "Resting" then
        equip(sets.rest)
    else 
  --Idle
		idle()
    end
end

-- List of zones that I want to equip my Aketon
aketon_zone = {
    ["Southern San d'Oria"] = true,
	["Northern San d'Oria"] = true,
	["Port San d'Oria"] = true,
	["Chateau d'Oraguille"] = true,
    -- Add more as needed
}

-- Register zone change event to re-equip idle gear
windower.register_event("zone change", zone_change)

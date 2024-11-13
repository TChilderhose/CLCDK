local _, CLCDK = ...

local spellLookup = {
	["Anti-Magic Shell"] = 48707,
	["Anti-Magic Zone"] = 51052,
	["Death and Decay"] = 43265,
	["Chains of Ice"] = 45524,
	["Control Undead"] = 111673,
	["Dark Command"] = 56222,
	["Death Coil"] = 47541,
	["Death Grip"] = 49576,
	["Death Strike"] = 49998,
	["Death's Advance"] = 48265,
	["Icebound Fortitude"] = 48792,
	["Lichborne"] = 49039,
	["Obliteration"] = 207256,
	["Sacrificial Pact"] = 327574,
	["Mind Freeze"] = 47528,
	["Path of Frost"] = 3714,
	["Raise Ally"] = 61999,
	["Raise Dead"] = 46584,		
	["Unholy Strength"] = 53365,
	
	
	--Unholy Only
	["Apocalypse"] = 220143,	
	["Army of the Dead"] = 42650,
	["Dark Transformation"] = 63560,
	["Epidemic"] = 207317,
	["Festering Strike"] = 85948,
	["Festering Wound"] = 194310,
	["Outbreak"] = 77575,
	["Raise Abomination"] = 455395,
	["Runic Corruption"] = 51460,
	["Scourge Strike"] = 55090,
	["Soul Reaper"] = 343294,
	["Sudden Doom"] = 81340,
	["Unholy Blight"] = 115989,
	["Virulent Plague"] = 191587,
	["Wraith Walk"] = 212552,
	
	
	--Blood Only
	["Blood Boil"] = 50842,
	["Blood Plague"] = 55078,
	["Bone Shield"] = 195181,
	["Dancing Rune Weapon"] = 49028,
	["Heart Strike"] = 206930,
	["Marrowrend"] = 195182,
	["Rune Tap"] = 194679,
	["Vampiric Blood"] = 55233,
	
	
	--Frost Only
	["Breath of Sindragosa"] = 152279,
	["Empower Rune Weapon"] = 47568,
	["Frost Fever"] = 55095,
	["Frost Strike"] = 49143,
	["Gathering Storm"] = 194912,
	["Howling Blast"] = 49184,
	["Icy Talons"] = 194878,
	["Killing Machine"] = 51124,
	["Obliterate"] = 49020,
	["Pillar of Frost"] = 51271,
	["Remorseless Winter"] = 196770,
	["Rime"] = 59057,
	["Unleashed Frenzy"] = 376905,
	

	--Racials
	["Human"] = 59752,--Every Man for Himself
	["Dwarf"] = 20594,--Stoneform
	["NightElf"] = 58984,--Shadowmeld
	["Gnome"] = 20589,--Escape Artist
	["Draenei"] = 28880,--Gift of the Naaru
	["Worgen"] = 68992,--Darkflight

	["Orc"] = 33697,--Blood Fury
	["Scourge"] = 7744,--Will of the Forsaken
	["Tauren"] = 20549,--War Stomp
	["Troll"] = 26297,--Berserking
	["BloodElf"] = 28730,--Arcane Torrent
	["Goblin"] = 69070,--Rocket Jump

}

function CLCDK.LoadSpells()
	CLCDK.PrintDebug("CLCDK.LoadSpells")
	if CLCDK.Spells then
		wipe(CLCDK.Spells)
	end
	CLCDK.Spells = {}

	local info
	for name, id in pairs(spellLookup) do
		info = C_Spell.GetSpellInfo(id).name
		if (info == nil) then
			CLCDK.PrintDebug("Spell " .. name .. " is null")
		else
			CLCDK.Spells[name] = info
		end
	end
	CLCDK.PrintDebug("Spells Loaded")
end

function CLCDK.LoadCooldowns()
	CLCDK.PrintDebug("CLCDK.LoadCooldowns")
	if CLCDK.Cooldowns then
		wipe(CLCDK.Cooldowns)
	end
	CLCDK.Cooldowns = {
		NormCDs = {--CDs that all DKs get		
			CLCDK.Spells["Anti-Magic Shell"],
			CLCDK.Spells["Anti-Magic Zone"],
			CLCDK.Spells["Death and Decay"],
			CLCDK.Spells["Dark Command"],
			CLCDK.Spells["Death Grip"],
			CLCDK.Spells["Icebound Fortitude"],
			CLCDK.Spells["Lichborne"],
			CLCDK.Spells["Mind Freeze"],
			CLCDK.Spells["Raise Ally"],
			CLCDK.Spells["Raise Dead"],
			CLCDK.Spells["Unholy Strength"],
		},
		UnholyCDs = {
			CLCDK.Spells["Army of the Dead"],
			CLCDK.Spells["Apocalypse"],
			CLCDK.Spells["Dark Transformation"],
			CLCDK.Spells["Festering Wound"],
			CLCDK.Spells["Outbreak"],
			CLCDK.Spells["Raise Abomination"],
			CLCDK.Spells["Runic Corruption"],
			CLCDK.Spells["Soul Reaper"],
			CLCDK.Spells["Sudden Doom"],
			CLCDK.Spells["Unholy Blight"],
			CLCDK.Spells["Wraith Walk"],
		},
		FrostCDs = {
			CLCDK.Spells["Breath of Sindragosa"],
			CLCDK.Spells["Empower Rune Weapon"],
			CLCDK.Spells["Icy Talons"],
			CLCDK.Spells["Killing Machine"],
			CLCDK.Spells["Pillar of Frost"],
			CLCDK.Spells["Remorseless Winter"],
			CLCDK.Spells["Rime"],
			CLCDK.Spells["Unleashed Frenzy"],
		},
		BloodCDs = {
			CLCDK.Spells["Blood Boil"],
			CLCDK.Spells["Bone Shield"],
			CLCDK.Spells["Crimson Scourge"],
			CLCDK.Spells["Dancing Rune Weapon"],
			CLCDK.Spells["Hemostasis"],
			CLCDK.Spells["Rune Tap"],
			CLCDK.Spells["Vampiric Blood"],
		},
		Buffs = {--List of Buffs
			--- How to use {who gets buff,  Is it also a CD?}
			--normal
			[CLCDK.Spells["Anti-Magic Shell"]] = {"player", true},
			[CLCDK.Spells["Death and Decay"]] = {"player", true},
			[CLCDK.Spells["Icebound Fortitude"]] = {"player", true},
			[CLCDK.Spells["Obliteration"]] = {"player", false},
			[CLCDK.Spells["Unholy Strength"]] = {"player", false},

			--unholy
			[CLCDK.Spells["Dark Transformation"]] = {"pet", true},
			[CLCDK.Spells["Festering Wound"]] = {"target", false},
			[CLCDK.Spells["Runic Corruption"]] = {"player", false},
			[CLCDK.Spells["Soul Reaper"]] = {"target", true},
			[CLCDK.Spells["Sudden Doom"]] = {"player", false},
			[CLCDK.Spells["Virulent Plague"]] = {"target", false},
			[CLCDK.Spells["Unholy Blight"]] = {"player", true},
			[CLCDK.Spells["Wraith Walk"]] = {"player", true},

			--frost
			[CLCDK.Spells["Breath of Sindragosa"]] = {"player", true},
			[CLCDK.Spells["Empower Rune Weapon"]] = {"player", true},
			[CLCDK.Spells["Pillar of Frost"]] = {"player", true},
			[CLCDK.Spells["Icy Talons"]] = {"player", false},
			[CLCDK.Spells["Lichborne"]] = {"player", true},
			[CLCDK.Spells["Killing Machine"]] = {"player", false},
			[CLCDK.Spells["Remorseless Winter"]] = {"player", true},
			[CLCDK.Spells["Rime"]] = {"player", false},
			[CLCDK.Spells["Unleashed Frenzy"]] = {"player", false},

			--blood
			[CLCDK.Spells["Bone Shield"]] = {"player", true},
			[CLCDK.Spells["Dancing Rune Weapon"]] = {"player", true},
			[CLCDK.Spells["Rune Tap"]] = {"player", true},
			[CLCDK.Spells["Vampiric Blood"]] = {"player", true},

			--racials
			[CLCDK.Spells["Orc"]] = {"player", true},
		},
		Moves = {--List of Moves that can be watched when availible
			CLCDK.Spells["Blood Boil"],
			CLCDK.Spells["Death Coil"],
			CLCDK.Spells["Death Strike"],
			CLCDK.Spells["Festering Strike"],
			CLCDK.Spells["Frost Strike"],
			CLCDK.Spells["Heart Strike"],
			CLCDK.Spells["Howling Blast"],
			CLCDK.Spells["Icy Touch"],
			CLCDK.Spells["Necrotic Strike"],
			CLCDK.Spells["Obliterate"],
			CLCDK.Spells["Pestilence"],
			CLCDK.Spells["Plague Strike"],
			CLCDK.Spells["Scourge Strike"],
		},
		LowDuration = { --by default cds that are under 10 seconds are ignored because of rune CDs, but there are some that are acutally under 10 seconds
			CLCDK.Spells["Soul Reaper"],
		}
	}
	CLCDK.PrintDebug("Cooldowns Loaded")
	return;
end
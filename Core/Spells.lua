local _, CLCDK = ...

CLCDK.SPELL_LOOKUP = {
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


	--Covenant
	["Fleshcraft"] = 324631,
	["Abomination Limb"] = 315443,
}

CLCDK.Spells = {}

function CLCDK.LoadSpells()
	CLCDK.PrintDebug("CLCDK.LoadSpells")
	if CLCDK.Spells ~= nil then
		wipe(CLCDK.Spells)
	end
	CLCDK.Spells = {}

	local info
	for name, id in pairs (CLCDK.SPELL_LOOKUP) do
		info = C_Spell.GetSpellInfo(id).name
		if (info == nil) then
			CLCDK.PrintDebug("Spell " .. name .. " is null")
		else
			CLCDK.Spells[name] = info
		end
	end
	CLCDK.PrintDebug("Spells Loaded")
end
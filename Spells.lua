local _, CLCDK = ...

CLCDK.SPELL_LOOKUP = {
	["Anti-Magic Shell"] = 48707,
	["Army of the Dead"] = 42650,
	["Blood Plague"] = 55078,
	["Blood Strike"] = 45902,
	["Dark Command"] = 56222,
	["Dark Simulacrum"] = 77606, --Cata
	["Dark Succor"] = 101568,
	["Death and Decay"] = 43265,
	["Death Coil"] = 47541,
	["Death Grip"] = 49576,
	["Death Pact"] = 48743,
	["Death Strike"] = 49998,
	["Empower Rune Weapon"] = 47568,
	["Festering Strike"] = 85948,	--Cata
	["Frost Fever"] = 55095,
	["Horn of Winter"] = 57330,
	["Icebound Fortitude"] = 48792,
	["Lichborne"] = 49039,
	["Mind Freeze"] = 47528,
	["Necrotic Strike"] = 73975, --Cata
	["Obliterate"] = 49020,
	["Outbreak"] = 77575, --Cata
	["Pestilence"] = 50842,
	["Raise Ally"] = 61999,
	["Raise Dead"] = 46584,
	["Rune Strike"] = 210764,
	["Rune Tap"] = 194679,
	["Strangulate"] = 47476,
	["Unholy Strength"] = 53365,
	["Unholy Frenzy"] = 207289,

	--Blood Only
	["Bone Shield"] = 195181,
	["Blood Boil"] = 50842,
	["Dancing Rune Weapon"] = 49028,
	["Vampiric Blood"] = 55233,
	["Marrowrend"] = 195182,
	["Blooddrinker"] = 206931,
	["Heart Strike"] = 206930,
	["Crimson Scourge"] = 81136,
	["Hemostasis"] = 273946,

	--Frost Only
	["Freezing Fog"] = 59052,
	["Frost Strike"] = 49143,
	["Howling Blast"] = 49184,
	["Killing Machine"] = 51124,
	["Pillar of Frost"] = 51271,
	["Rime"] = 59057,
	["Razorice"] = 51714,
	["Sindragosa's Fury"] = 190778,
	["Gathering Storm"] = 194912,
	["Remorseless Winter"] = 196770,

	--Unholy Only
	["Anti-Magic Zone"] = 51052,
	["Dark Transformation"] = 63560,
	["Desolation"] = 63583,
	["Epidemic"] = 207317,
	["Gnaw"] =  91800,
	["Runic Corruption"] = 51460,
	["Scourge Strike"] = 55090,
	["Sudden Doom"] = 81340,
	["Summon Gargoyle"] = 49206,
	["Virulent Plague"] = 191587,--Legion
	["Festering Wound"] = 194310,--Legion
	["Apocalypse"] = 220143,--Legion
	["Scourge of Worlds"] = 191748,--Legion
	["Soul Reaper"] = 343294,
	["Unholy Blight"] = 115989,

	--Tier Sets

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
		info = GetSpellInfo(id)
		if (info == nil) then
			CLCDK.PrintDebug("Spell " .. name .. " is null")
		else
			CLCDK.Spells[name] = info
		end
	end
	CLCDK.PrintDebug("Spells Loaded")
end
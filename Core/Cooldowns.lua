local _, CLCDK = ...

CLCDK.Cooldowns = {}

function CLCDK.LoadCooldowns()
	if CLCDK.Cooldowns~= nil then
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
		
		--by default cds that are under 10 seconds are ignored because of rune CDs, but there are some that are acutally under 10 seconds
		LowDuration = {
			CLCDK.Spells["Soul Reaper"],
		},
		
		SpecialStackCount = {
			CLCDK.Spells["Anti-Magic Shell"],
		}
	}
	CLCDK.PrintDebug("Cooldowns Loaded")
	return;
end
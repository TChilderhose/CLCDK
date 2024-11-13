local _, CLCDK = ...

function CLCDK.GetNextMove(frame)
	if (CLCDK.CURRENT_SPEC == CLCDK.SPEC_UNHOLY) then
		return UnholyMove(frame)
	elseif (CLCDK.CURRENT_SPEC == CLCDK.SPEC_FROST) then
		return FrostMove(frame)
	elseif (CLCDK.CURRENT_SPEC == CLCDK.SPEC_BLOOD) then
		return BloodMove(frame)
	else
		return BlankMove(frame)
	end
end

local function UnholyMove(frame)
	--https://www.method.gg/guides/unholy-death-knight/playstyle-and-rotation

	--Rune Info
	local numRunes = CLCDK.RuneCDs()
	local runicPower = UnitPower("player");
	local aoeSet = false

	-- Raise Abomination
	if (numRunes >= 1 and runicPower >= 10 and CLCDK.IsSpellNameOffCD("Raise Abomination")) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Raise Abomination"])
	end

	-- Dark Transformation
	if (UnitExists("pet") and CLCDK.IsSpellNameOffCD("Dark Transformation")) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Dark Transformation"])
	end

	local numFestWounds = CLCDK.GetPlayerBuff("Festering Wound").applications or 0

	-- Apocalypse - at 4+ stacks of Festering Wound
	if (numFestWounds >= 4 and CLCDK.IsSpellNameOffCD("Apocalypse")) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Apocalypse"])
	end
	
	-- Soul Reaper when in execute range
	if (numRunes >= 1 and runicPower >= 10 and CLCDK.GetUnitHealthPct("target") < 35 and CLCDK.IsSpellNameOffCD("Soul Reaper")) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Soul Reaper"])
	end	

	-- Death Coil - when you have a Sudden Doom proc
	if (runicPower >= 20 and CLCDK.GetPlayerBuff("Sudden Doom")) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Death Coil"])
	end	

	-- Abomination Limb - On cooldown if there is no incoming grips or multi-target damage needed
	if (CLCDK.IsSpellNameOffCD("Abomination Limb")) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Abomination Limb"])
	end

	-- Death Coil - If you have 85+ Runic Power or have 0 runes
	if (runicPower >= 85 or numRunes = 0) then
		if (not aoeSet and frame.AOE ~= nil) then
			CLCDK.SetRangeandIcon(frame.AOE.Icon, CLCDK.Spells["Epidemic"])
			aoeSet = true
		end
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Death Coil"])
	end	
		
	-- Outbreak - When Virulent Plague has 3 seconds remaining and Dark Transformation has more than 12 seconds left on its cooldown.
	if (numRunes >= 1 and runicPower >= 10 and CLCDK.GetSpecDiseaseRemaining() <= 3 and CLCDK.GetSpellNameCDRemaining("Dark Transformation") > 12) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Outbreak"])
	end
	
	-- Festering Strike - If your target has 3 or less Festering Wound.
	if (runicPower >= 20 and numRunes >= 2 and numFestWounds <= 3) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Festering Strike"])
	end

	-- Scourge Strike - If your target has at least 1 Festering Wound or you do not have Plaguebringer (if talented) active.	
	if (runicPower >= 10 and numRunes >= 1 and numFestWounds >= 1) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Scourge Strike"])
	end

	-- Death Coil
	if (runicPower >= 30) then
		if (not aoeSet and frame.AOE ~= nil) then
			CLCDK.SetRangeandIcon(frame.AOE.Icon, CLCDK.Spells["Epidemic"])
			aoeSet = true
		end
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Death Coil"])
	end	

	-- If nothing else can be done
	return frame.Icon:SetTexture(nil)
end

local function FrostMove(frame)
	--https://www.method.gg/guides/frost-death-knight/playstyle-and-rotation

	--Rune Info
	local numRunes = CLCDK.RuneCDs()
	local runicPower = UnitPower("player")
	local aoeSet = false

	-- Death and Decay - if no Death and Decay is active
	if (not aoeSet and frame.AOE and numRunes >= 1 and runicPower >= 10 and not CLCDK.GetPlayerBuff("Death and Decay") and CLCDK.IsSpellNameOffCD("Death and Decay")) then
		CLCDK.SetRangeandIcon(frame.AOE.Icon, CLCDK.Spells["Death and Decay"])
		aoeSet = true
	end

	-- Obliterate - if you have Killing Machine
	if (numRunes >= 2 and CLCDK.GetPlayerBuff("Killing Machine")) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Obliterate"])
	end

	-- Frost Strike - If you are about to lose Icy Talons
	if (runicPower >= 30) then
		local icyTalons = CLCDK.GetPlayerBuff("Icy Talons")
		if (icyTalons == nil or icyTalons.applications < 3 ) then
			return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Frost Strike"])
		end
	end

	-- Obliteration Mode
	if (CLCDK.GetPlayerBuff("Obliteration")) then

		-- Frost Strike - if you have =< 1 Rune
		if (numRunes <= 1 and runicPower >= 30) then
			return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Frost Strike"])
		end

		-- Howling Blast - if you have a Rime proc to trigger Killing Machine
		if (runicPower >= 10 and CLCDK.GetPlayerBuff("Rime")) then
			return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Howling Blast"])
		end

		-- Frost Strike - to trigger Killing Machine
		if (runicPower >= 30) then
			return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Frost Strike"])
		end

		-- Obliterate
		if (numRunes >= 2) then
			return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Obliterate"])
		end

	else

		-- Soul Reaper when in execute range
		if (numRunes >= 1 and runicPower >= 10 and CLCDK.GetUnitHealthPct("target") < 35 and CLCDK.IsSpellNameOffCD("Soul Reaper")) then
			return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Soul Reaper"])
		end	

		-- Remorseless Winter out of Obliteration Mode
		if (numRunes >= 1 and runicPower >= 10 and CLCDK.IsSpellNameOffCD("Remorseless Winter")) then
			return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Remorseless Winter"])
		end

		-- Frost Strike - if you have =< 1 Rune
		if (numRunes <= 1 and runicPower >= 30) then
			return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Frost Strike"])
		end

		-- Howling Blast - if you have a Rime proc
		if (runicPower >= 10 and CLCDK.GetPlayerBuff("Rime")) then
			return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Howling Blast"])
		end	
	
		-- Frost Strike - if you have 75+ Runic Power
		if (runicPower >= 75) then
			return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Frost Strike"])
		end
	
		-- Obliterate
		if (numRunes >= 2) then
			return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Obliterate"])
		end
	
		-- Frost Strike
		if (runicPower >= 30) then
			return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Frost Strike"])
		end

	end

	return frame.Icon:SetTexture(nil)
end

local function BloodMove(frame)
	
	return frame.Icon:SetTexture(nil)
end

local function BlankMove(frame)
	
	return frame.Icon:SetTexture(nil)
end
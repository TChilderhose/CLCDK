local _, CLCDK = ...

function CLCDK.GetNextMove(frame)
	--Call correct function based on spec
	if (CLCDK.CURRENT_SPEC == CLCDK.SPEC_UNHOLY) then
		return CLCDK.UnholyMove(frame)
	elseif (CLCDK.CURRENT_SPEC == CLCDK.SPEC_FROST) then
		return CLCDK.FrostMove(frame)
	elseif (CLCDK.CURRENT_SPEC == CLCDK.SPEC_BLOOD) then
		return CLCDK.BloodMove(frame)
	else
		return CLCDK.BlankMove(frame)
	end
end

function CLCDK.UnholyMove(frame)
	--[[
		Virulent Plague (Maintain on target [refresh using Outbreak])
		Cast Dark Transformation Icon Dark Transformation off cooldown.
		Cast Apocalypse Icon Apocalypse when you have 4 stacks of Festering Wound Icon Festering Wounds
		Death Coil (With Sudden Doom procs or when >80 Runic Power)
		Scourge Strike (When 1 or more Festering Wound)
		Festering Strike
		Death Coil
	]]--

	--Rune Info
	local numRunes = CLCDK.RuneCDs()
	local runicPower = UnitPower("player");

	-- Virulent Plague (Maintain on target [refresh using Outbreak])
	if CLCDK.GetDiseaseRemaining() < 2 and numRunes >= 1 then
		if (frame.AOE ~= nil and (CLCDK.IsOffCD(GetSpellCooldown(CLCDK.Spells["Unholy Blight"])))) then
			CLCDK.SetRangeandIcon(frame.AOE.Icon, CLCDK.Spells["Unholy Blight"])
		end
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Outbreak"])
	end

	-- Cast Dark Transformation Icon Dark Transformation off cooldown.
	if (CLCDK.IsOffCD(GetSpellCooldown(CLCDK.Spells["Dark Transformation"]))) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Dark Transformation"])
	end

	local numFestWounds = select(3, CLCDK.FindTargetDebuff(CLCDK.Spells["Festering Wound"]))
	if numFestWounds == nil then numFestWounds = 0 end

	-- Cast Apocalypse Icon Apocalypse when you have 4 stacks of Festering Wound Icon Festering Wounds
	if (numFestWounds >= 4 and CLCDK.IsOffCD(GetSpellCooldown(CLCDK.Spells["Apocalypse"]))) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Apocalypse"])
	end

	-- Death Coil (With Sudden Doom procs or when >80 Runic Power)
	if (CLCDK.FindPlayerBuff(CLCDK.Spells["Sudden Doom"]) ~= nil or runicPower >= 80) then
		if (frame.AOE ~= nil) then
			CLCDK.SetRangeandIcon(frame.AOE.Icon, CLCDK.Spells["Epidemic"])
		end
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Death Coil"])
	end

	if (frame.AOE ~= nil and (CLCDK.IsOffCD(GetSpellCooldown(CLCDK.Spells["Death and Decay"])))) then
		CLCDK.SetRangeandIcon(frame.AOE.Icon, CLCDK.Spells["Death and Decay"])
	end

	-- Scourge Strike (When 1 or more Festering Wound)
	if (numRunes >= 1 and numFestWounds >= 1) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Scourge Strike"])
	end

	-- Festering Strike
	if (numRunes >= 2) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Festering Strike"])
	end

	-- Death Coil
	if (UnitPower("player") >= 40) then
		if (frame.AOE ~= nil) then
			CLCDK.SetRangeandIcon(frame.AOE.Icon, CLCDK.Spells["Epidemic"])
		end
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Death Coil"])
	end

	-- If nothing else can be done
	return frame.Icon:SetTexture(nil)
end

function CLCDK.FrostMove(frame)
	--[[
	Use Icon Sindragosa's Fury (with Pillar of Frost Icon Pillar of Frost, the proc from Rune of the Fallen Crusader Icon Rune of the Fallen Crusader, and 5 stacks of Razorice).
	Use Remorseless Winter Icon Remorseless Winter on cooldown (for Gathering Storm Icon Gathering Storm).
	Use Howling Blast Icon Howling Blast, only if you have a Rime Icon Rime proc.
	Use Obliterate Icon Obliterate to avoid capping runes, or if you have a Killing Machine Icon Killing Machine proc.
	Use Frost Strike Icon Frost Strike when you are about to cap Runic Power.
	Use Obliterate Icon Obliterate.
	Use Frost Strike Icon Frost Strike.
	]]

	--Rune Info
	local numRunes = CLCDK.RuneCDs()
	local runicPower = UnitPower("player");

	if (UnitBuff("PLAYER",CLCDK.Spells["Pillar of Frost"]) ~= nil and
		UnitBuff("PLAYER",CLCDK.Spells["Unholy Strength"]) ~= nil	and
		UnitBuff("PLAYER",CLCDK.Spells["Razorice"]) ~= nil and
		select(4, UnitBuff("PLAYER",CLCDK.Spells["Razorice"])) == 5) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Sindragosa's Fury"])
	end

	if (numRunes >= 1 and CLCDK.IsOffCD(GetSpellCooldown(CLCDK.Spells["Remorseless Winter"]))) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Remorseless Winter"])
	end

	if (UnitBuff("PLAYER", CLCDK.Spells["Rime"]) ~= nil) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Howling Blast"])
	end

	if (UnitBuff("PLAYER",CLCDK.Spells["Killing Machine"]) ~= nil or numRunes > 4) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Obliterate"])
	end

	if (runicPower >= 80) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Frost Strike"])
	end

	if (numRunes >= 2) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Obliterate"])
	end

	if (runicPower >= 25) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Frost Strike"])
	end

	return frame.Icon:SetTexture(nil)
end

function CLCDK.BloodMove(frame)
	--[[
	Before engaging anything, use Rune Tap a second before you get meleed for the first time.
	Use Marrowrend if your Bone Shield is about to expire.
	Use Death Strike if your health is low, or to avoid capping Runic Power.
	Use Blood Boil if any nearby enemies do not have your Blood Plague disease, or you have 2 charges of Blood Boil.
	Use Marrowrend if you have 6 or fewer stacks of Bone Shield.
	Use Heart Strike if you have 3 or more Runes.
	Use Death and Decay if you have a Crimson Scourge proc.
	Use Blood Boil.
	]]--

	--Rune Info
	local numRunes = CLCDK.RuneCDs()
	local runicPower = UnitPower("player");
	local curh, maxh = UnitHealth("player"), UnitHealthMax("player")
	local perch
	if maxh == 0 then
		perch = -1
	else
		perch= (curh/maxh)*100
	end

	local _, _, bs_count, _, bs_duration = CLCDK.FindPlayerBuff(CLCDK.Spells["Bone Shield"])

	-- Use Marrowrend if your Bone Shield is about to expire.
	if ((bs_duration == nil or bs_duration < 3) and numRunes >= 2) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Marrowrend"])
	end

	-- Use Death Strike if your health is low, or to avoid capping Runic Power.
	if ((perch < 33 or runicPower > 80) and runicPower >= 45) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Death Strike"])
	end

	-- Use Blood Boil if any nearby enemies do not have your Blood Plague disease, or you have 2 charges of Blood Boil.
	if (CLCDK.GetDiseaseRemaining() < 2 and GetSpellCharges(CLCDK.Spells["Blood Boil"]) >= 1) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Blood Boil"])
	end

	-- Use Marrowrend if you have 6 or fewer stacks of Bone Shield.
	if ((bs_count == nil or bs_count < 6) and numRunes >= 2) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Marrowrend"])
	end

	-- Use Heart Strike if you have 3 or more Runes.
	if (numRunes >= 3) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Heart Strike"])
	end

	-- Use Death and Decay if you have a Crimson Scourge proc.
	if (CLCDK.FindPlayerBuff(CLCDK.Spells["Crimson Scourge"]) ~= nil) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Death and Decay"])
	end

	-- Use Blood Boil.
	if (GetSpellCharges(CLCDK.Spells["Blood Boil"]) >= 1) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Blood Boil"])
	end

	return frame.Icon:SetTexture(nil)
end

function CLCDK.BlankMove(frame)
	local numRunes = CLCDK.RuneCDs()
	local runicPower = UnitPower("player");

	if (runicPower >= 90) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Death Coil"])
	end

	if (numRunes >= 1) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Rune Strike"])
	end

	if (runicPower >= 40) then
		return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Death Coil"])
	end
	
	return frame.Icon:SetTexture(nil)
end
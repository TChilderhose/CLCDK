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
	return frame.Icon:SetTexture(nil)
end

local function FrostMove(frame)
	--https://www.method.gg/guides/frost-death-knight/playstyle-and-rotation

	--Rune Info
	local numRunes = CLCDK.RuneCDs()
	local runicPower = UnitPower("player");

	-- Death and Decay - if no Death and Decay is active
	if (frame.AOE and numRunes >= 1 and not CLCDK.GetPlayerBuff("Death and Decay") and CLCDK.IsSpellNameOffCD("Death and Decay")) then
		CLCDK.SetRangeandIcon(frame.AOE.Icon, CLCDK.Spells["Death and Decay"])
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
		if (CLCDK.GetPlayerBuff("Rime")) then
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
		if (numRunes >= 1 and CLCDK.GetUnitHealthPct("target") <= 35 and CLCDK.IsSpellNameOffCD("Soul Reaper")) then
			return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Soul Reaper"])
		end	

		-- Remorseless Winter out of Obliteration Mode
		if (numRunes >= 1 and CLCDK.IsSpellNameOffCD("Remorseless Winter")) then
			return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Remorseless Winter"])
		end

		-- Frost Strike - if you have =< 1 Rune
		if (numRunes <= 1 and runicPower >= 30) then
			return CLCDK.SetRangeandIcon(frame.Icon, CLCDK.Spells["Frost Strike"])
		end

		-- Howling Blast - if you have a Rime proc
		if (CLCDK.GetPlayerBuff("Rime")) then
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
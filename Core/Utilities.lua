local _, CLCDK = ...

function CLCDK.PrintDebug(text)
	if CLCDK.DEBUG then
		print("CLCDK: " .. text)
	end
end

local DAY, HOUR, MINUTE = 86400, 3600, 60
function CLCDK.GetTimeText(seconds)
	if seconds > DAY then
		return format("%dd", seconds/DAY)
	elseif seconds > MINUTE*100 then
		return format("%dh", (seconds/HOUR + 1))
	elseif seconds > MINUTE*5 then
		return format("%dm", (seconds/MINUTE + 1))
	elseif seconds > MINUTE then
		return format("%d:%2.2d", seconds/MINUTE, (seconds%MINUTE))
	elseif seconds > 5 then
		return format("%d", seconds%MINUTE)
	elseif seconds > 0 then
		return format("%0.1f", seconds%MINUTE)
	else
		return ""
	end
end

function CLCDK.IsInTable(tabl, key)
	for i = 1, #tabl do
		if tabl[i] == key then
			return true
		end
	end
	return false
end

function CLCDK.GetCDTime(start, dur)
	if (dur == nil or dur == 0) then
		return 0
	end
	return dur + start - CLCDK.CURRENT_TIME
end

function CLCDK.IsOffCD(spellCooldownInfo)
	return ((CLCDK.GetCDTime(spellCooldownInfo.startTime, spellCooldownInfo.duration) - CLCDK.GCD) <= 0)
end

function CLCDK.RuneCDs()
	local numRunesReady = 0
	for i = 1, 6 do
		local start, dur, runeReady = GetRuneCooldown(i)
		if (runeReady or (CLCDK.GetCDTime(start, dur) - CLCDK.GCD) <= 0) then
			numRunesReady = numRunesReady + 1
		end
	end
	return numRunesReady;
end

function CLCDK.CheckSpec()
	CLCDK.CURRENT_SPEC = GetSpecialization()
	CLCDK.MAX_RP = UnitPowerMax("Player")

	CLCDK.PrintDebug("Spec: "..CLCDK.CURRENT_SPEC)
	CLCDK.OptionsRefresh()
end

function CLCDK.GetSpecDisease()
	if (CLCDK.CURRENT_SPEC == CLCDK.SPEC_UNHOLY) then
		return CLCDK.Spells["Virulent Plague"]
	elseif (CLCDK.CURRENT_SPEC == CLCDK.SPEC_FROST) then
		return CLCDK.Spells["Frost Fever"]
	elseif (CLCDK.CURRENT_SPEC == CLCDK.SPEC_BLOOD) then
		return CLCDK.Spells["Blood Plague"]
	end
end

function CLCDK.GetSpecDiseaseRemaining()
	local aura = CLCDK.FindTargetDebuff(CLCDK.GetSpecDisease(CLCDK.CURRENT_SPEC))
	if aura == nil then 
		return 0 			
	end
	return (aura.expirationTime - CLCDK.CURRENT_TIME)
end

function CLCDK.FindPlayerBuff(spell)
	return CLCDK.FindBuff(spell, "player")
end

function CLCDK.FindBuff(spell, unit)
	if (spell == nil) then return end
	for i = 1, 40 do	
		local aura = C_UnitAuras.GetBuffDataByIndex(unit, i);
		if (aura ~= nil and aura.name == spell) then
			return aura
		end
	end
end

function CLCDK.FindTargetDebuff(spell)
	for i = 1, 40 do
		local aura = C_UnitAuras.GetDebuffDataByIndex("TARGET", i, "PLAYER");
		if (aura ~= nil and aura.name == spell) then
			return aura
		end
	end
end

function CLCDK.GetUnitHealthPct(unit)
	local curh, maxh = UnitHealth(unit), UnitHealthMax(unit)
	if maxh == 0 then
		return -1
	else
		return (curh/maxh)*100
	end
end
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

function CLCDK.NumFormat(num)
	if num >= 1000000000 then
		num = format("%.2fb", num / 1000000000)
	elseif num >= 1000000 then
		num = format("%.2fm", num / 1000000)
	elseif num >= 100000 then		
		num = format("%.2fk", num / 1000)
	end		
	return num
end

function CLCDK.IsInTable(tbl, key)
	for i = 1, #tbl do
		if tbl[i] == key then
			return true
		end
	end
	return false
end

function CLCDK.IsSpellNameOffCD(spellName)
	return CLCDK.IsSpellInfoOffCD(C_Spell.GetSpellCooldown(CLCDK.Spells[spellName]))
end

function CLCDK.IsSpellInfoOffCD(spellCooldownInfo)
	if spellCooldownInfo == nil then
		return false
	end
	return CLCDK.IsOffCD(spellCooldownInfo.startTime, spellCooldownInfo.duration)
end

function CLCDK.IsOffCD(startTime, duration)
	return CLCDK.GetCDTimeWithGCD(startTime, duration) <= 0
end

function CLCDK.GetCDTimeWithGCD(startTime, duration)
	return CLCDK.GetCDTime(startTime, duration) - CLCDK.GCD
end

function CLCDK.GetCDTime(start, dur)
	if (dur == nil or dur == 0) then
		return 0
	end
	return dur + start - CLCDK.CURRENT_TIME
end

function CLCDK.RuneCDs()
	local numRunesReady = 0
	local start, dur, runeReady
	for i = 1, 6 do
		start, dur, runeReady = GetRuneCooldown(i)
		if (runeReady or CLCDK.IsOffCD(start, dur)) then
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

function CLCDK.FindPlayerBuff(spellName)
	return CLCDK.FindBuff(CLCDK.Spells[spellName], "player")
end

function CLCDK.PlayerHasBuff(spellName)
	return CLCDK.FindPlayerBuff(spellName)
end

function CLCDK.FindBuff(spellName, unit)
	if (spellName == nil) then 
		return nil
	end
	local aura
	for i = 1, 99 do	
		aura = C_UnitAuras.GetBuffDataByIndex(unit, i);
		if aura == nil then
			return nil
		elseif aura.name == spellName then
			return aura
		end
	end
end

function CLCDK.FindTargetDebuff(spellName)
	if (spellName == nil) then 
		return nil
	end
	local aura
	for i = 1, 99 do
		aura = C_UnitAuras.GetDebuffDataByIndex("TARGET", i, "PLAYER");
		if aura == nil then
			return nil
		elseif aura.name == spellName then
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
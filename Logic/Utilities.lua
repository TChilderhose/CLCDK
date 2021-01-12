local _, CLCDK = ...

function CLCDK.PrintDebug(text)
	if CLCDK.DEBUG then
		print("CLCDK: " .. text)
	end
end

local DAY, HOUR, MINUTE = 86400, 3600, 60
function CLCDK.GetTimeText(seconds)
	if seconds > DAY then
		return format("%dd", seconds/DAY), HOUR
	elseif seconds > MINUTE*100 then
		return format("%dh", (seconds/HOUR + 1)), MINUTE
	elseif seconds > MINUTE*5 then
		return format("%dm", (seconds/MINUTE + 1)), 1
	elseif seconds > MINUTE then
		return format("%d:%2.2d", seconds/MINUTE, (seconds%MINUTE)), 0.5
	elseif seconds > 5 then
		return format("%d", seconds%MINUTE), 0.25
	elseif seconds > 0 then
		return format("%0.1f", seconds%MINUTE), 0.1
	else
		return "", 1
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

function CLCDK.IsOffCD(start, dur)
	if (dur == nil) then dur = 0 end
	return (dur + start - CLCDK.CURRENT_TIME - CLCDK.GCD <= 0)
end

function CLCDK.RuneCDs()
	local numCool = 0
	for i = 1, 6 do
		local start, dur, cool = GetRuneCooldown(i)
		local tempTime = (dur - (CLCDK.CURRENT_TIME - start + CLCDK.GCD))
		if (cool or tempTime < 0) then
			numCool = numCool + 1
		end
	end
	return numCool;
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

function CLCDK.GetDisease(icon)
	local expires = select(6, AuraUtil.FindAuraByName(CLCDK.GetSpecDisease(CLCDK.CURRENT_SPEC), "TARGET", "PLAYER"))
	if  expires ~= nil then	
		expires = expires - CLCDK.CURRENT_TIME 
	end
	return (expires == nil or expires < 2)
end

function CLCDK.FindPlayerBuff(spellName)
	for i=1,40 do
		local name, icon, count, debuffType, duration, expirationTime = UnitBuff("PLAYER", i);
		if (name == spellName) then
			return name, icon, count, debuffType, duration, expirationTime
		end
	end
end

function CLCDK.FindTargetDebuff(spellName)
	for i=1,40 do
		local name, icon, count, debuffType, duration, expirationTime = UnitDebuff("TARGET", i, "PLAYER");
		if (name == spellName) then
			return name, icon, count, debuffType, duration, expirationTime
		end
	end
end
local _, CLCDK = ...

local cachedDisease = ""
local playerSpells = {}

local GetBuffDataByIndex, GetDebuffDataByIndex = C_UnitAuras.GetBuffDataByIndex, C_UnitAuras.GetDebuffDataByIndex
local GetSpellCooldown, GetSpellIDForSpellIdentifier = C_Spell.GetSpellCooldown, C_Spell.GetSpellIDForSpellIdentifier

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

local function PlayerHasSpell(spellName)
	if (playerSpells[spellName] == nil) then
		local spellId = GetSpellIDForSpellIdentifier(spellName)

		if not spellId then
			playerSpells[spellName] = false
		else
			playerSpells[spellName] = IsPlayerSpell(spellId)
		end
	end
	return playerSpells[spellName]
end

local function GetCDTimeWithGCD(startTime, duration)
	return CLCDK.GetCDTime(startTime, duration) - CLCDK.GCD
end

local function GetSpellInfoCDRemaining(spellCooldownInfo)
	if spellCooldownInfo == nil then
		return false
	end
	return GetCDTimeWithGCD(spellCooldownInfo.startTime, spellCooldownInfo.duration)
end

function CLCDK.GetSpellNameCDRemaining(spellName)
	return GetSpellInfoCDRemaining(GetSpellCooldown(CLCDK.Spells[spellName]))
end

function CLCDK.IsSpellNameOffCD(spellName)
	if (not PlayerHasSpell(spellName)) then
		CLCDK.PrintDebug("Player Doesnt Have Spell: " .. spellName)
		return false
	end
	return CLCDK.GetSpellNameCDRemaining(spellName) <= 0
end

function CLCDK.GetCDTime(startTime, duration)
	if (duration == nil or duration == 0) then
		return 0
	end
	return duration + startTime - CLCDK.CURRENT_TIME
end

function CLCDK.RuneCDs()
	local numRunesReady = 0
	local startTime, duration, runeReady
	for i = 1, 6 do
		startTime, duration, runeReady = GetRuneCooldown(i)
		if (runeReady or GetCDTimeWithGCD(startTime, duration) <= 0) then
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

	cachedDisease = ""
	playerSpells = {}
end

local function GetSpecDisease()
	if (cachedDisease == "") then
		if (CLCDK.CURRENT_SPEC == CLCDK.SPEC_UNHOLY) then
			cachedDisease = CLCDK.Spells["Virulent Plague"]
		elseif (CLCDK.CURRENT_SPEC == CLCDK.SPEC_FROST) then
			cachedDisease = CLCDK.Spells["Frost Fever"]
		elseif (CLCDK.CURRENT_SPEC == CLCDK.SPEC_BLOOD) then
			cachedDisease = CLCDK.Spells["Blood Plague"]
		end
	end

	return cachedDisease
end

function CLCDK.GetSpecDiseaseRemaining()
	local aura = CLCDK.FindTargetDebuff(GetSpecDisease())
	if aura == nil then
		return 0
	end
	return (aura.expirationTime - CLCDK.CURRENT_TIME)
end

function CLCDK.GetPlayerBuff(spellName)
	return CLCDK.FindBuff(CLCDK.Spells[spellName], "player")
end

function CLCDK.FindBuff(spellName, unit)
	if (spellName == nil) then
		return nil
	end

	for i = 1, 40 do
		local aura = GetBuffDataByIndex(unit, i);
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

	for i = 1, 40 do
		local aura = GetDebuffDataByIndex("TARGET", i, "PLAYER");
		if aura == nil then
			return nil
		elseif aura.name == spellName then
			return aura
		end
	end
end

function CLCDK.CanShowExecute(unit)
	local minHealth = 1000000
	local curh, maxh = UnitHealth(unit), UnitHealthMax(unit)
	if maxh > minHealth or UnitIsPlayer(unit) then
		return (curh/maxh) < 0.35
	end
	return false
end
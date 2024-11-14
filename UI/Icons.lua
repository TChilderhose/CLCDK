local _, CLCDK = ...

local GetSpellTexture, IsSpellInRange, GetSpellCooldown, GetSpellCharges = C_Spell.GetSpellTexture, C_Spell.IsSpellInRange,  C_Spell.GetSpellCooldown, C_Spell.GetSpellCharges

function CLCDK.CreateIcon(name, parent, size)
	local frame = CreateFrame('Button', name, parent, BackdropTemplateMixin and "BackdropTemplate")
	frame:SetWidth(size)
	frame:SetHeight(size)
	frame:SetFrameStrata("BACKGROUND")

	frame.c = CreateFrame('Cooldown', name .. ".c", frame, "CooldownFrameTemplate")
	frame.c:SetAllPoints(frame)
	frame.c:SetDrawEdge(false)
	frame.c:SetDrawBling(false)
	frame.c:SetFrameStrata("BACKGROUND")

	frame.Icon = frame:CreateTexture("$parentIcon", "ARTWORK")
	frame.Icon:SetAllPoints()
	frame.Icon:SetTexture(nil)

	frame.Time = frame:CreateFontString(nil, 'OVERLAY')
	frame.Time:SetPoint("CENTER", frame, 1, 0)
	frame.Time:SetJustifyH("CENTER")
	frame.Time:SetFont(CLCDK.FONT, CLCDK.FONT_SIZE_M, "THICKOUTLINE")

	frame.Stack = frame:CreateFontString(nil, 'OVERLAY')
	frame.Stack:SetPoint("BOTTOMRIGHT", frame, 4, 1)
	frame.Stack:SetJustifyH("CENTER")
	frame.Stack:SetFont(CLCDK.FONT, CLCDK.FONT_SIZE_S, "THICKOUTLINE")

	frame.start = 0
	frame.dur = 0

	frame:EnableMouse(false)

	return frame
end

function CLCDK.SetIconCooldown(frame, start, dur)
	if (start ~= frame.start or dur ~= frame.dur) then
		frame.c:SetCooldown(start, dur)
		frame.start = start
		frame.dur = dur
	end
end

function CLCDK.SetRangeandIcon(icon, move)
	if move then
		--CLCDK.PrintDebug(move)
		icon:SetTexture(GetSpellTexture(move))
		if CLCDK_Settings.Range and IsSpellInRange(move, "target") == 0 then
			icon:SetVertexColor(196/255, 30/255, 58/255, 1) --DK Red
		else
			icon:SetVertexColor(1, 1, 1, 1)
		end
	else
		icon:SetTexture(nil)
	end
end

function CLCDK.SetIconData(frame, icon, duration, stackCount, iconType)
	frame.Icon:SetTexture(icon)

	if duration > 0 then
		local color = nil
		if (iconType == CLCDK.IS_BUFF) then
			color = CLCDK.COLOR_GREEN

		elseif (iconType == CLCDK.IS_CD) then
			if (duration < 5) then
				color = CLCDK.COLOR_RED
			else
				color = CLCDK.COLOR_WHITE
			end
		end

		frame.Time:SetText(color .. CLCDK.GetTimeText(duration) .. "|r")
	else
		frame.Time:SetText("")
		CLCDK.SetIconCooldown(frame, 0, 0)
	end

	if stackCount and stackCount > 1 then
		frame.Stack:SetText(stackCount)
	else
		frame.Stack:SetText("")
	end
end

function CLCDK.HandlePriority(frame)
	if (frame.AOE) then
		frame.AOE.Icon:SetTexture(nil)
	end

	if (UnitCanAttack("player", "target") and (not UnitIsDead("target"))) then
		CLCDK.GetNextMove(frame)
	else
		frame.Icon:SetTexture(nil)
	end
end

function CLCDK.HandleBuff(frame, action, target)
	local aura

	if target == "target" then
		aura = CLCDK.FindTargetDebuff(action)
	else
		aura = CLCDK.FindBuff(action, target)
	end

	if aura and (aura.expirationTime - CLCDK.CURRENT_TIME) > 0 then
		CLCDK.SetIconData(frame, aura.icon, (aura.expirationTime - CLCDK.CURRENT_TIME), aura.applications, CLCDK.IS_BUFF)
		return true
	end

	frame.Icon:SetTexture(nil)
	return false
end

function CLCDK.HandleCooldown(frame, action)
	local spellCooldownInfo = GetSpellCooldown(action)
	local chargeInfo = GetSpellCharges(action)
	local count = chargeInfo and chargeInfo.maxCharges >= 1 and chargeInfo.currentCharges or 0

	CLCDK.SetIconData(frame, GetSpellTexture(action), 0, count, CLCDK.IS_CD)

	--by default cds that are under 10 seconds are ignored because of rune CDs, but there are some that are acutally under 10 seconds
	if (spellCooldownInfo and (spellCooldownInfo.duration > CLCDK.CD_DURATION_THRESHOLD or (spellCooldownInfo.duration > 1.5 and CLCDK.IsInTable(CLCDK.Cooldowns.LowDuration, action)))) then
		CLCDK.SetIconCooldown(frame, spellCooldownInfo.startTime, spellCooldownInfo.duration)
	end
end

function CLCDK.HandleAbility(frame, action)
	CLCDK.HandleCooldown(frame, action)
	CLCDK.SetRangeandIcon(frame.Icon, action)
end
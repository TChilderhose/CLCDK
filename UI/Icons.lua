local _, CLCDK = ...

function CLCDK.CreateIcon(name, parent, size)
	frame = CreateFrame('Button', name, parent, BackdropTemplateMixin and "BackdropTemplate")
	frame:SetWidth(size)
	frame:SetHeight(size)
	frame:SetFrameStrata("BACKGROUND")

	frame.c = CreateFrame('Cooldown', name .. ".c", frame, "CooldownFrameTemplate")
	frame.c:SetAllPoints(frame)
	frame.c:SetDrawEdge(false)
	frame.c:SetDrawBling(false)
	frame.c:SetFrameStrata("BACKGROUND")

	frame.Icon = frame:CreateTexture("$parentIcon", "DIALOG")
	frame.Icon:SetAllPoints()
	frame.Icon:SetTexture(nil)
	
	frame.Time = frame.c:CreateFontString(nil, 'OVERLAY')
	frame.Time:SetPoint("CENTER",frame, 1, 0)
	frame.Time:SetJustifyH("CENTER")
	frame.Time:SetFont(CLCDK.FONT, CLCDK.FONT_SIZE_M, "OUTLINE")

	frame.Stack = frame.c:CreateFontString(nil, 'OVERLAY')
	frame.Stack:SetPoint("BOTTOMRIGHT",frame, 3, 1)
	frame.Stack:SetJustifyH("CENTER")
	frame.Stack:SetFont(CLCDK.FONT, CLCDK.FONT_SIZE_S, "OUTLINE")
	
	frame.start = 0
	frame.dur = 0
	
	frame:EnableMouse(false)

	return frame
end

function CLCDK.SetCooldown(frame, start, dur)
	if (start ~= frame.start or dur ~= frame.dur) then
		frame.c:SetCooldown(start, dur)
		frame.start = start
		frame.dur = dur
	end
end

function CLCDK.SetRangeandIcon(icon, move)
	if move ~= nil then
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
		CLCDK.SetCooldown(frame, 0, 0)
	end

	if stackCount ~= null and stackCount > 1 then
		frame.Stack:SetText(stackCount)
	else
		frame.Stack:SetText("")
	end
end

function CLCDK.HandlePriority(frame)
	if (frame.AOE ~= nil) then
		frame.AOE.Icon:SetTexture(nil)
	end

	if (UnitCanAttack("player", "target") and (not UnitIsDead("target"))) then
		CLCDK.GetNextMove(frame)
	else
		frame.Icon:SetTexture(nil)
	end
end

function CLCDK.HandleBuff(frame, action, target)
	local icon, count, expirationTime

	if target == "target" then
		_, icon, count, _, _, expirationTime = CLCDK.FindTargetDebuff(action)
	else
		_, icon, count, _, _, expirationTime = CLCDK.FindBuff(action, target)
	end

	if expirationTime ~= nil and (expirationTime - CLCDK.CURRENT_TIME) > 0 then
		CLCDK.SetIconData(frame, icon, (expirationTime - CLCDK.CURRENT_TIME), count, CLCDK.IS_BUFF)
		return true
	end

	frame.Icon:SetTexture(nil)
	return false
end

function CLCDK.HandleCooldown(frame, action)
	local start, dur = GetSpellCooldown(action)
	local chargeCount, chargeMax = GetSpellCharges(action)
	local count = chargeMax ~= nil and chargeMax >= 1 and chargeCount or 0

	--by default cds that are under 10 seconds are ignored because of rune CDs, but there are some that are acutally under 10 seconds
	local remaining = 0	
	if (dur ~= nil and (dur > CLCDK.CD_DURATION_THRESHOLD or (dur > 1.5 and CLCDK.IsInTable(CLCDK.Cooldowns.LowDuration, action)))) then
		if (CLCDK_Settings.CDS) then
			CLCDK.SetCooldown(frame, start, dur)
		end
		remaining = CLCDK.GetCDTime(start, dur)
	end	
		
	CLCDK.SetIconData(frame, GetSpellTexture(action), remaining, count, CLCDK.IS_CD)
end

function CLCDK.HandleAbility(frame, action)
	CLCDK.HandleCooldown(frame, action)
	CLCDK.SetRangeandIcon(frame.Icon, action)
end
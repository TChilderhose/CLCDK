local _, CLCDK = ...

function CLCDK.CreateIcon(name, parent, spellname, size)
	frame = CreateFrame('Button', name, parent, BackdropTemplateMixin and "BackdropTemplate")
	frame:SetWidth(size)
	frame:SetHeight(size)
	frame:SetFrameStrata("BACKGROUND")

	frame.c = CreateFrame('Cooldown', nil, frame, "CooldownFrameTemplate")
	frame.c:SetAllPoints(frame)
	frame.c:SetDrawEdge(false)

	frame.Icon = frame:CreateTexture("$parentIcon", "DIALOG")
	frame.Icon:SetAllPoints()
	frame.Icon:SetTexture(GetSpellTexture(spellname))

	frame.Time = frame:CreateFontString(nil, 'OVERLAY')
	frame.Time:SetPoint("CENTER",frame, 1, 0)
	frame.Time:SetJustifyH("CENTER")
	frame.Time:SetFont(CLCDK.FONT, 14, "OUTLINE")

	frame.Stack = frame:CreateFontString(nil, 'OVERLAY')
	frame.Stack:SetPoint("BOTTOMRIGHT",frame, 3, 1)
	frame.Stack:SetJustifyH("CENTER")
	frame.Stack:SetFont(CLCDK.FONT, 10, "OUTLINE")

	frame:EnableMouse(false)

	return frame
end

--Determines if player is in range with spell and sets colour and icon accordingly
--In: icon: icon in which to change the vertex colour of   move: spellID of spell to be cast next
--Out: returns the texture of the icon (probably unessesary since icon is now being passed in, will look into it more)
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
		frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
		
		local color = nil
		if iconType == CLCDK.IS_BUFF then
			color = CLCDK.COLOR_GREEN
		else
			color = duration < 5 and CLCDK.COLOR_RED or CLCDK.COLOR_WHITE
		end
		
		frame.Time:SetText(color .. CLCDK.GetTimeText(duration) .. "|r")
	else
		frame.Icon:SetVertexColor(1, 1, 1, 1)
		frame.Time:SetText("")
	end

	if stackCount > 1 then
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
	local icon, count, dur, expirationTime
	
	if target == "target" then
		_, icon, count, _, dur, expirationTime = CLCDK.FindTargetDebuff(action)
	else
		_, icon, count, _, dur, expirationTime = AuraUtil.FindAuraByName(action, target)
	end
	
	if expirationTime ~= nil and (expirationTime - CLCDK.CURRENT_TIME) > 0 then
		CLCDK.SetIconData(frame, icon, (expirationTime - CLCDK.CURRENT_TIME), count, CLCDK.IS_BUFF)
		return true
	end
	
	frame.Icon:SetTexture(nil)
	return false
end

function CLCDK.HandleCooldown(frame, action)
	local icon = GetSpellTexture(action)	
	local start, dur, _ =  GetSpellCooldown(action)
	local chargeCount, chargeMax = GetSpellCharges(action)

	local remaining = dur > CLCDK.CD_DURATION_THRESHOLD and (start + dur - CLCDK.CURRENT_TIME) or 0
	local count =  chargeMax ~= nil and chargeMax >= 1 and chargeCount or 0
	
	if CLCDK_Settings.CDS and dur > CLCDK.CD_DURATION_THRESHOLD then 
		frame.c:SetCooldown(start, dur) 
	end	
	CLCDK.SetIconData(frame, icon, remaining, count, CLCDK.IS_CD)
end

function CLCDK.HandleAbility(frame, action)
	CLCDK.HandleCooldown(frame, action)
	CLCDK.SetRangeandIcon(frame.Icon, action)
end
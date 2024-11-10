local name, CLCDK = ...

function CLCDK.CreateCDs()
	CLCDK.CD = {}

	--Create two frames in which 2 icons will placed in each
	for i = 1, 4 do
		CLCDK.CD[i] = CreateFrame("Button", "CLCDK.CD"..i, CLCDK.MainFrame, BackdropTemplateMixin and "BackdropTemplate")
		CLCDK.CD[i]:SetWidth(34)
		CLCDK.CD[i]:SetHeight(68)
		CLCDK.CD[i]:SetFrameStrata("BACKGROUND")
		CLCDK.CD[i]:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = -1, right = -1, top = -1, bottom = -1},}
		CLCDK.CD[i]:SetBackdropColor(0, 0, 0, 0.5)
		CLCDK.SetupMoveFunction(CLCDK.CD[i])
	end

	--List of CD frame names, using the name of dropdown menu to allow easy saving and fetching
	CDDisplayList = {
		"CLCDK_CDRPanel_DD_CD1_One",
		"CLCDK_CDRPanel_DD_CD1_Two",
		"CLCDK_CDRPanel_DD_CD2_One",
		"CLCDK_CDRPanel_DD_CD2_Two",
		"CLCDK_CDRPanel_DD_CD3_One",
		"CLCDK_CDRPanel_DD_CD3_Two",
		"CLCDK_CDRPanel_DD_CD4_One",
		"CLCDK_CDRPanel_DD_CD4_Two",
	}

	--Create the Icons with desired paramaters
	for i = 1, #CDDisplayList do
		CLCDK.CD[CDDisplayList[i]] = CLCDK.CreateIcon(CDDisplayList[i].."Butt", CLCDK.MainFrame, 32)
		CLCDK.CD[CDDisplayList[i]]:SetParent(CLCDK.CD[ceil(i/2)])
		CLCDK.CD[CDDisplayList[i]]:EnableMouse(false)
	end

	--Give Icons their position based on parent
	CLCDK.CD[CDDisplayList[1]]:SetPoint("TOPLEFT", CLCDK.CD[1], "TOPLEFT", 1, -1)
	CLCDK.CD[CDDisplayList[2]]:SetPoint("TOPLEFT", CLCDK.CD[CDDisplayList[1]], "BOTTOMLEFT", 0, -2)
	CLCDK.CD[CDDisplayList[3]]:SetPoint("TOPRIGHT", CLCDK.CD[2], "TOPRIGHT", -1, -1)
	CLCDK.CD[CDDisplayList[4]]:SetPoint("TOPLEFT", CLCDK.CD[CDDisplayList[3]], "BOTTOMLEFT", 0, -2)
	CLCDK.CD[CDDisplayList[5]]:SetPoint("TOPRIGHT", CLCDK.CD[3], "TOPRIGHT", -1, -1)
	CLCDK.CD[CDDisplayList[6]]:SetPoint("TOPLEFT", CLCDK.CD[CDDisplayList[5]], "BOTTOMLEFT", 0, -2)
	CLCDK.CD[CDDisplayList[7]]:SetPoint("TOPRIGHT", CLCDK.CD[4], "TOPRIGHT", -1, -1)
	CLCDK.CD[CDDisplayList[8]]:SetPoint("TOPLEFT", CLCDK.CD[CDDisplayList[7]], "BOTTOMLEFT", 0, -2)
	CLCDK.PrintDebug("Cooldowns Created")
end

function CLCDK.UpdateCD(location, frame)
	--Reset Icon
	frame.Time:SetText("")
	frame.Stack:SetText("")

	--If the option is not set to nothing
	if 	CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][location] ~= nil and 
		CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][location][1] ~= nil and
		CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][location][1] ~= CLCDK_OPTIONS_FRAME_VIEW_NONE then

		local action = CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][location][1]		
		frame:SetAlpha(1)
		if action == CLCDK_OPTIONS_CDR_CD_PRIORITY then --Priority
			CLCDK.HandlePriority(frame)

		elseif CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][location][CLCDK.IS_BUFF] and 
				CLCDK.Cooldowns.Buffs[action] ~= nil and 
				not CLCDK.Cooldowns.Buffs[action][2] then --Buff/DeBuff
			CLCDK.HandleBuff(frame, action, CLCDK.Cooldowns.Buffs[action][1])
			CLCDK.SetCooldown(frame, -1, -1)

		elseif CLCDK.IsInTable(CLCDK.Cooldowns.Moves, action) then --Move
			CLCDK.HandleAbility(frame, action)

		else --Cooldown or Racial
			if action == CLCDK_OPTIONS_CDR_RACIAL then
				action = CLCDK.Spells[CLCDK.PLAYER_RACE]
			end

			if CLCDK.Cooldowns.Buffs[action] ~= nil and CLCDK.HandleBuff(frame, action, CLCDK.Cooldowns.Buffs[action][1]) then
				CLCDK.SetCooldown(frame, -1, -1)
				return
			end
			CLCDK.HandleCooldown(frame, action)

		end
		
		--if the icon is nil, then just hide the frame
		if frame.Icon:GetTexture() == nil then
			frame:SetAlpha(0)
		end
	else		
		CLCDK.PrintDebug("Nothing Set for ", CLCDK.CURRENT_SPEC, location)
		CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][location][1] = CLCDK_OPTIONS_FRAME_VIEW_NONE
		frame:SetAlpha(0)
	end
end
		
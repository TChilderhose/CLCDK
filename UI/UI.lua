local name, CLCDK = ...

function CLCDK.CreateUI()
	CLCDK.SetupMoveFunction(CLCDK.MainFrame)

	CLCDK.RuneBar = CreateFrame("Button", "CLCDK.RuneBar", CLCDK.MainFrame, BackdropTemplateMixin and "BackdropTemplate")
	CLCDK.RuneBar:SetHeight(23)
	CLCDK.RuneBar:SetWidth(94)
	CLCDK.RuneBar:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
	CLCDK.RuneBar:SetBackdropColor(0, 0, 0, 0.5)
	CLCDK.RuneBar.Text = CLCDK.RuneBar:CreateFontString(nil, 'OVERLAY')
	CLCDK.RuneBar.Text:SetPoint("TOP", CLCDK.RuneBar, "TOP", 0, -2)
	CLCDK.RuneBar.Text:SetJustifyH("CENTER")
	CLCDK.RuneBar.Text:SetFont(CLCDK.FONT_MONO, CLCDK.FONT_SIZE_L, "OUTLINE")
	CLCDK.SetupMoveFunction(CLCDK.RuneBar)

	CLCDK.RunicPower = CreateFrame("Button", "CLCDK.RunicPower", CLCDK.MainFrame, BackdropTemplateMixin and "BackdropTemplate")
	CLCDK.RunicPower:SetHeight(23)
	CLCDK.RunicPower:SetWidth(47)
	CLCDK.RunicPower:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
	CLCDK.RunicPower:SetBackdropColor(0, 0, 0, 0.5)
	CLCDK.RunicPower.Text = CLCDK.RunicPower:CreateFontString(nil, 'OVERLAY')
	CLCDK.RunicPower.Text:SetPoint("TOP", CLCDK.RunicPower, "TOP", 0, -2)
	CLCDK.RunicPower.Text:SetJustifyH("CENTER")
	CLCDK.RunicPower.Text:SetFont(CLCDK.FONT_MONO, CLCDK.FONT_SIZE_L, "OUTLINE")
	CLCDK.SetupMoveFunction(CLCDK.RunicPower)

	CLCDK.Disease = CreateFrame("Button", "CLCDK.Disease", CLCDK.MainFrame, BackdropTemplateMixin and "BackdropTemplate")
	CLCDK.Disease:SetHeight(24)
	CLCDK.Disease:SetWidth(47)
	CLCDK.Disease:SetFrameStrata("BACKGROUND")
	CLCDK.Disease:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
	CLCDK.Disease:SetBackdropColor(0, 0, 0, 0.5)
	CLCDK.Disease.Text = CLCDK.Disease:CreateFontString(nil, 'OVERLAY')
	CLCDK.Disease.Text:SetPoint("TOP", CLCDK.Disease, "TOP", 0, -2)
	CLCDK.Disease.Text:SetJustifyH("CENTER")
	CLCDK.Disease.Text:SetFont(CLCDK.FONT_MONO, CLCDK.FONT_SIZE_L, "OUTLINE")
	CLCDK.SetupMoveFunction(CLCDK.Disease)

	CLCDK.Move = CLCDK.CreateIcon('CLCDK.Move', CLCDK.MainFrame, 47)
	CLCDK.SetupMoveFunction(CLCDK.Move)
	
	CLCDK.Move.AOE = CLCDK.CreateIcon('CLCDK.Move.AOE', CLCDK.Move, 47)
	CLCDK.Move.AOE:SetAllPoints(CLCDK.Move)
	CLCDK.Move.AOE.Icon:SetMask("Interface\\AddOns\\CLCDK\\Media\\Mask")

	CLCDK.MoveBackdrop = CreateFrame('Frame', nil, CLCDK.MainFrame, BackdropTemplateMixin and "BackdropTemplate")
	CLCDK.MoveBackdrop:SetHeight(47)
	CLCDK.MoveBackdrop:SetWidth(47)
	CLCDK.MoveBackdrop:SetFrameStrata("BACKGROUND")
	CLCDK.MoveBackdrop:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
	CLCDK.MoveBackdrop:SetBackdropColor(0, 0, 0, 0.5)
	CLCDK.MoveBackdrop:SetAllPoints(CLCDK.Move)

	CLCDK.PrintDebug("UI Created")
end

function CLCDK.UpdateUI()
	if (UnitCanAttack("player", "target") and (not UnitIsDead("target"))) then
		CLCDK.MainFrame:SetAlpha(CLCDK_Settings.NormTrans)
	else
		CLCDK.MainFrame:SetAlpha(CLCDK_Settings.CombatTrans)
	end

	--GCD
	local spellCooldownInfo = C_Spell.GetSpellCooldown(CLCDK.GCD_SPELL_ID)
	if spellCooldownInfo and spellCooldownInfo.duration ~= 0 and spellCooldownInfo.startTime then
		CLCDK.GCD = CLCDK.GetCDTime(spellCooldownInfo.startTime, spellCooldownInfo.duration) + CLCDK.UPDATE_INTERVAL
		if CLCDK_Settings.GCD then
			CLCDK.Move.AOE.c:SetCooldown(spellCooldownInfo.startTime, spellCooldownInfo.duration)
		end
	else
		CLCDK.GCD = 0
	end

	--Runes
	if CLCDK_Settings.Rune then
		local RuneBar, cdtime = "", ""
		for i = 1, 6 do
			local start, dur, runeReady = GetRuneCooldown(i)
			if (runeReady) then
				cdtime = "*"			
			else
				cdtime = math.ceil(CLCDK.GetCDTime(start, dur))
				if cdtime >= 10 then
					cdtime = "X"
				end
			end
			RuneBar = RuneBar .. cdtime
		end

		CLCDK.RuneBar:SetAlpha(1)
		CLCDK.RuneBar.Text:SetText(CLCDK.COLOR_RUNES .. RuneBar .. "|r")
	else
		CLCDK.RuneBar:SetAlpha(0)
	end

	--RunicPower
	if CLCDK_Settings.RP then
		CLCDK.RunicPower:SetAlpha(1)
		CLCDK.RunicPower.Text:SetText(string.format(CLCDK.COLOR_RUNIC_POWER.."%.3d|r", UnitPower("player")))
	else
		CLCDK.RunicPower:SetAlpha(0)
	end

	--Diseases
	if CLCDK_Settings.Disease then
		CLCDK.Disease:SetAlpha(1)
		if UnitCanAttack("player", "target") and (not UnitIsDead("target")) and (CLCDK.CURRENT_SPEC ~= CLCDK.SPEC_UNKNOWN) then
			CLCDK.Disease.Text:SetText(string.format(CLCDK.COLOR_GREEN .. "%.2d|r", CLCDK.GetSpecDiseaseRemaining()))
		else
			CLCDK.Disease.Text:SetText(string.format(CLCDK.COLOR_GREEN .. "%.2d|r", 0))
		end
	else
		CLCDK.Disease:SetAlpha(0)
	end

	--Priority Icon
	if CLCDK_Settings.CD[CLCDK.CURRENT_SPEC]["CLCDK_Options_DD_Priority"][1] ~= CLCDK_OPTIONS_FRAME_VIEW_NONE then
		CLCDK.Move:SetAlpha(1)
		CLCDK.MoveBackdrop:SetAlpha(1)
		CLCDK.UpdateCD("CLCDK_Options_DD_Priority", CLCDK.Move)
	else
		CLCDK.Move:SetAlpha(0)
		CLCDK.MoveBackdrop:SetAlpha(0)
	end

	--CDs
	for i = 1, #CDDisplayList do
		if CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][ceil(i/2)] then
			CLCDK.CD[ceil(i/2)]:SetAlpha(1)
			CLCDK.UpdateCD(CDDisplayList[i], CLCDK.CD[CDDisplayList[i]])
		else
			CLCDK.CD[ceil(i/2)]:SetAlpha(0)
		end
	end
end

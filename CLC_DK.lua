local _, CLCDK = ...

if CLCDK.PLAYER_CLASS == "DEATHKNIGHT" then
	CLCDK.PrintDebug("Is DK. Starting...")

	-----Create Main Frame-----
	CLCDK.MainFrame = CreateFrame("Button", "CLCDK", UIParent, BackdropTemplateMixin and "BackdropTemplate")
	CLCDK.MainFrame:SetWidth(94)
	CLCDK.MainFrame:SetHeight(68)
	CLCDK.MainFrame:SetFrameStrata("BACKGROUND")

	--Variables
	local loaded, mutex = false, false
	local mousex, mousey
	local GetTime = GetTime
	local launchtime = 0
	local updatetimer = 0
	local resize = nil

	function CLCDK.LoadTrinkets()
		local loaded = true

		local function AddTrinket(name, info) --BuffID, Is on use?, (ItemID or ICD), start, cd flag, alternative buff
			if name == nil then
				loaded = false
				CLCDK.PrintDebug("Trinket Not Found - Buff: "..info[1])
			else
				CLCDK.Cooldowns.Trinkets[name] = info
			end
		end
		CLCDK.Cooldowns.Trinkets = {}

		--Test trinket that doesnt exist
		--AddTrinket(select(1, GetItemInfo(1)), {"Test Trinket"})

		CLCDK.PrintDebug("Trinkets Loaded")
		return loaded
	end

	--Sets up required information for each element that can be moved
	function CLCDK.SetupMoveFunction(frame)
		frame.Drag = CreateFrame("Button", "ResizeGrip", frame) -- Grip Buttons from Omen2
		frame.Drag:SetFrameLevel(frame:GetFrameLevel() + 100)
		frame.Drag:SetNormalTexture("Interface\\AddOns\\CLC_DK\\Media\\ResizeGrip")
		frame.Drag:SetHighlightTexture("Interface\\AddOns\\CLC_DK\\Media\\ResizeGrip")
		frame.Drag:SetWidth(26)
		frame.Drag:SetHeight(26)
		frame.Drag:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 7, -7)
		frame.Drag:EnableMouse(true)
		frame.Drag:Show()
		frame.Drag:SetScript("OnMouseDown", function(self,button)
			if (not CLCDK_Settings.Locked) and button == "LeftButton" then
				mousex, mousey = GetCursorPosition()
				resize = self:GetParent()
			end
		end)

		frame.Drag:SetScript("OnMouseUp", function(self,button)
			if (not CLCDK_Settings.Locked) and button == "LeftButton" then
				self:StopMovingOrSizing()
				CLCDK_Settings.Location[(self:GetParent()):GetName()].Scale = (self:GetParent()):GetScale()
				resize, mousex, mousey = nil, nil, nil
			end
		end)

		frame:EnableMouse(false)
		frame:SetMovable(true)

		--When mouse held, move
		frame:SetScript("OnMouseDown", function(self, button)
			CLCDK.PrintDebug("Mouse Down "..self:GetName())
			CloseDropDownMenus()
		--	self.x1, self.y1 = select(4, self:GetPoint())
			self:StartMoving()
		--	self.x2, self.y2 = select(4, self:GetPoint())
		end)

		--When mouse released, save position
		frame:SetScript("OnMouseUp", function(self, button)
			CLCDK.PrintDebug("Mouse Up "..self:GetName())
		--	self.x3, self.y3 = select(4, self:GetPoint())
		--	print("Delta "..(self.x3-self.x2)+self.x1.." "..(self.y3-self.y2)+self.y1)
		--	CLCDK_Settings.Location[self:GetName()].X, CLCDK_Settings.Location[self:GetName()].Y = (self.x3-self.x2)+self.x1, (self.y3-self.y2)+self.y1
			self:StopMovingOrSizing()
			CLCDK_Settings.Location[self:GetName()].Point, CLCDK_Settings.Location[self:GetName()].Rel, CLCDK_Settings.Location[self:GetName()].RelPoint, CLCDK_Settings.Location[self:GetName()].X, CLCDK_Settings.Location[self:GetName()].Y = self:GetPoint()
		end)
	end

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
			CLCDK.CD[CDDisplayList[i]] = CLCDK.CreateIcon(CDDisplayList[i].."Butt", CLCDK.MainFrame, CLCDK.Spells["Horn of Winter"], 32)
			CLCDK.CD[CDDisplayList[i]].Time:SetFont(CLCDK.FONT, 13, "OUTLINE")
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

	function CLCDK.CreateUI()
		CLCDK.SetupMoveFunction(CLCDK.MainFrame)

		--Create Rune bar frame
		CLCDK.RuneBar = CreateFrame("Button", "CLCDK.RuneBar", CLCDK.MainFrame, BackdropTemplateMixin and "BackdropTemplate")
		CLCDK.RuneBar:SetHeight(23)
		CLCDK.RuneBar:SetWidth(94)
		CLCDK.RuneBar:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
		CLCDK.RuneBar:SetBackdropColor(0, 0, 0, 0.5)
		CLCDK.RuneBar.Text = CLCDK.RuneBar:CreateFontString(nil, 'OVERLAY')
		CLCDK.RuneBar.Text:SetPoint("TOP", CLCDK.RuneBar, "TOP", 0, -2)
		CLCDK.RuneBar.Text:SetJustifyH("CENTER")
		CLCDK.RuneBar.Text:SetFont(CLCDK.FONT, 18, "OUTLINE")
		CLCDK.SetupMoveFunction(CLCDK.RuneBar)

		CLCDK.RuneBarHolder = CreateFrame("Button", "CLCDK.RuneBarHolder", CLCDK.MainFrame, BackdropTemplateMixin and "BackdropTemplate")
		CLCDK.RuneBarHolder:SetHeight(100)
		CLCDK.RuneBarHolder:SetWidth(110)
		CLCDK.RuneBarHolder:SetFrameStrata("BACKGROUND")
		CLCDK.RuneBarHolder:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
		CLCDK.RuneBarHolder:SetBackdropColor(0, 0, 0, 0.5)

		--Create Runic Power frame
		CLCDK.RunicPower = CreateFrame("Button", "CLCDK.RunicPower", CLCDK.MainFrame, BackdropTemplateMixin and "BackdropTemplate")
		CLCDK.RunicPower:SetHeight(23)
		CLCDK.RunicPower:SetWidth(47)
		CLCDK.RunicPower:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
		CLCDK.RunicPower:SetBackdropColor(0, 0, 0, 0.5)
		CLCDK.RunicPower.Text = CLCDK.RunicPower:CreateFontString(nil, 'OVERLAY')
		CLCDK.RunicPower.Text:SetPoint("TOP", CLCDK.RunicPower, "TOP", 0, -2)
		CLCDK.RunicPower.Text:SetJustifyH("CENTER")
		CLCDK.RunicPower.Text:SetFont(CLCDK.FONT, 18, "OUTLINE")
		CLCDK.SetupMoveFunction(CLCDK.RunicPower)

		--Create frome for Diseases with 2 icons for their respective disease
		CLCDK.Disease = CreateFrame("Button", "CLCDK.Disease", CLCDK.MainFrame, BackdropTemplateMixin and "BackdropTemplate")
		CLCDK.Disease:SetHeight(24)
		CLCDK.Disease:SetWidth(47)
		CLCDK.Disease:SetFrameStrata("BACKGROUND")
		CLCDK.Disease:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
		CLCDK.Disease:SetBackdropColor(0, 0, 0, 0.5)
		CLCDK.Disease.Text = CLCDK.Disease:CreateFontString(nil, 'OVERLAY')
		CLCDK.Disease.Text:SetPoint("TOP", CLCDK.Disease, "TOP", 0, -2)
		CLCDK.Disease.Text:SetJustifyH("CENTER")
		CLCDK.Disease.Text:SetFont(CLCDK.FONT, 18, "OUTLINE")
		CLCDK.SetupMoveFunction(CLCDK.Disease)

		--Create the Frame and Icon for the large main Priority Icon
		CLCDK.Move = CLCDK.CreateIcon('CLCDK.Move', CLCDK.MainFrame, CLCDK.Spells["Death Coil"], 47)
		CLCDK.Move.Time:SetFont(CLCDK.FONT, 16, "OUTLINE")
		CLCDK.Move.Stack:SetFont(CLCDK.FONT, 15, "OUTLINE")
		CLCDK.SetupMoveFunction(CLCDK.Move)

		--Create backdrop for move
		CLCDK.MoveBackdrop = CreateFrame('Frame', nil, CLCDK.MainFrame, BackdropTemplateMixin and "BackdropTemplate")
		CLCDK.MoveBackdrop:SetHeight(47)
		CLCDK.MoveBackdrop:SetWidth(47)
		CLCDK.MoveBackdrop:SetFrameStrata("BACKGROUND")
		CLCDK.MoveBackdrop:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
		CLCDK.MoveBackdrop:SetBackdropColor(0, 0, 0, 0.5)
		CLCDK.MoveBackdrop:SetAllPoints(CLCDK.Move)

		--AOE icon to be placed with the Priority Icon
		CLCDK.Move.AOE = CLCDK.CreateIcon('CLCDK.AOE', CLCDK.Move, CLCDK.Spells["Death Coil"], 47)
		CLCDK.Move.AOE:SetAllPoints(CLCDK.Move)
		CLCDK.Move.AOE.Icon:SetMask("Interface\\AddOns\\CLC_DK\\Media\\Mask")

		CLCDK.PrintDebug("UI Created")
	end

	------Update Frames------
	--In:location - name or location of the settings for specific CD   frame- frame in which to set the icon for
	--Out:: N/A (does not return but does set icon settings
	function CLCDK.UpdateCD(location, frame)
		--Reset Icon
		frame.Time:SetText("")
		frame.Stack:SetText("")

		--If the option is not set to nothing
		if CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][location] ~= nil and CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][location][1] ~= nil and
			CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][location][1] ~= CLCDK_OPTIONS_FRAME_VIEW_NONE then

			local action = CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][location][1]

			frame:SetAlpha(1)
			if action == CLCDK_OPTIONS_CDR_CD_PRIORITY then --Priority
				CLCDK.HandlePriority(frame)

			elseif CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][location][CLCDK.IS_BUFF] and not CLCDK.Cooldowns.Buffs[action][2] then --Buff/DeBuff
				CLCDK.HandleBuff(frame, action, CLCDK.Cooldowns.Buffs[action][1])

			elseif CLCDK.IsInTable(CLCDK.Cooldowns.Moves, action) then --Move
				CLCDK.HandleAbility(frame, action)

			elseif action == CLCDK_OPTIONS_CDR_CD_TRINKETS_SLOT1 or
				action == CLCDK_OPTIONS_CDR_CD_TRINKETS_SLOT2 then --Trinkets

				local id
				if action == CLCDK_OPTIONS_CDR_CD_TRINKETS_SLOT1 then
					id = GetInventoryItemID("player", 13)
				else
					id = GetInventoryItemID("player", 14)
				end
				local trink
				if id ~= nil then
					trink = CLCDK.Cooldowns.Trinkets[select(1,GetItemInfo(id))]
				end

				if trink ~= nil then
					local altbuff = false

					--Buff
					_, _, icon, count, _, dur, expirationTime = UnitBuff("player",trink[1])
					if icon == nil and trink[6] ~= nil then
						_, _, icon, count, _, dur, expirationTime = UnitBuff("player",trink[6])
						altbuff = true
					end
					if icon ~= nil then
						CLCDK.SetIconData(frame, icon, (expirationTime - CLCDK.CURRENT_TIME), count, CLCDK.IS_CD)
						if (not altbuff) and (not trink[5]) then trink[5] = true; trink[4] = CLCDK.CURRENT_TIME end

					--ICD or Use CD
					else
						local start, dur, active
						frame.Icon:SetTexture(GetItemIcon(id))
						if trink[2] then --On-Use
							start, dur, active = GetItemCooldown(trink[3])
						else --ICD
							trink[5] = false
							dur, start = trink[3], trink[4]
							active = 1
						end
						t = (start + dur - CLCDK.CURRENT_TIME)
						CLCDK.SetIconData(frame, action, t, count, CLCDK.IS_CD)
					end
				else
					frame.Icon:SetTexture(nil)
				end

			else --Cooldown or Racial
				if action == CLCDK_OPTIONS_CDR_RACIAL then
					action = CLCDK.Spells[CLCDK.PLAYER_RACE]
				end		
			
				if CLCDK.Cooldowns.Buffs[action] ~= nil and CLCDK.HandleBuff(frame, action, CLCDK.Cooldowns.Buffs[action][1]) then
					return
				end
				CLCDK.HandleCooldown(frame, action)
				
			end
			--if the icon is nil, then just hide the frame
			if frame.Icon:GetTexture() == nil then
				frame:SetAlpha(0)
			end
		else
			CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][location][1] = CLCDK_OPTIONS_FRAME_VIEW_NONE
			frame:SetAlpha(0)
		end
	end

	--Used to move individual frames where they are suppose to be displayed, also enables and disables mouse depending on settings
	function CLCDK.MoveFrame(self)
		self:ClearAllPoints()
		self:SetPoint(CLCDK_Settings.Location[self:GetName()].Point, CLCDK_Settings.Location[self:GetName()].Rel, CLCDK_Settings.Location[self:GetName()].RelPoint, CLCDK_Settings.Location[self:GetName()].X, CLCDK_Settings.Location[self:GetName()].Y)
		self:SetBackdropColor(0, 0, 0, CLCDK_Settings.Trans)
		self:EnableMouse((not CLCDK_Settings.Locked) and ((not CLCDK_Settings.LockedPieces) or (CLCDK_Settings.Location[self:GetName()].Rel == nil)))
		if CLCDK_Settings.Locked then
			self.Drag:SetAlpha(0)
			self.Drag:EnableMouse(0)
		else
			self.Drag:SetAlpha(1)
			self.Drag:EnableMouse(1)
		end

		if CLCDK_Settings.Location[self:GetName()].Scale ~= nil then
			self:SetScale(CLCDK_Settings.Location[self:GetName()].Scale)
		else
			CLCDK_Settings.Location[self:GetName()].Scale = 1
		end
	end

	--Called to update all the frames positions and scales
	function CLCDK.UpdatePosition()
		CLCDK.MoveFrame(CLCDK.MainFrame)
		CLCDK.MoveFrame(CLCDK.CD[1])
		CLCDK.MoveFrame(CLCDK.CD[2])
		CLCDK.MoveFrame(CLCDK.CD[3])
		CLCDK.MoveFrame(CLCDK.CD[4])
		CLCDK.MoveFrame(CLCDK.RuneBar)
		CLCDK.MoveFrame(CLCDK.RunicPower)
		CLCDK.MoveFrame(CLCDK.Move)
		CLCDK.MoveBackdrop:SetBackdropColor(0, 0, 0, CLCDK_Settings.Trans)
		CLCDK.MoveFrame(CLCDK.Disease)

		CLCDK.MainFrame:SetScale(CLCDK_Settings.Scale)
		CLCDK.PrintDebug("UpdatePosition")
	end

	--Main function for updating all information
	function CLCDK.UpdateUI()
		if (UnitCanAttack("player", "target") and (not UnitIsDead("target"))) then
			CLCDK.MainFrame:SetAlpha(CLCDK_Settings.NormTrans)
		else
			CLCDK.MainFrame:SetAlpha(CLCDK_Settings.CombatTrans)
		end

		--GCD
		local start, dur = GetSpellCooldown(CLCDK.Spells["Death Coil"])
		if dur ~= 0 and start ~= nil then
			CLCDK.GCD =  dur - (CLCDK.CURRENT_TIME - start) + 0.1
			if CLCDK_Settings.GCD then
				CLCDK.Move.c:SetCooldown(start, dur)
			end
		else
			CLCDK.GCD = 0
		end

		--Runes
		CLCDK.RuneBar:SetAlpha((CLCDK_Settings.Rune and 1) or 0)
		if CLCDK_Settings.Rune then
			local RuneBar = ""
			local place = 1
			for i = 1, 6 do
				local start, cooldown = GetRuneCooldown(i)
				local cdtime = start + cooldown - CLCDK.CURRENT_TIME

				cdtime = math.ceil(cdtime)
				if cdtime >= cooldown or cdtime >= 10 then
					cdtime = "X"
				elseif cdtime <= 0 then
					cdtime = "*"
				end
				RuneBar = RuneBar .. string.format("|cff808080%s|r", cdtime)
			end

			CLCDK.RuneBar.Text:SetText(RuneBar)
		end

		--RunicPower
		if CLCDK_Settings.RP then
			CLCDK.RunicPower:SetAlpha(1)
			CLCDK.RunicPower.Text:SetText(string.format("|cFF00D1FF%.3d|r", UnitPower("player")))
		else
			CLCDK.RunicPower:SetAlpha(0)
		end

		--Diseases
		if CLCDK_Settings.Disease then
			CLCDK.Disease:SetAlpha(1)
			local diseaseTime = 0;
			if UnitCanAttack("player", "target") and (not UnitIsDead("target")) and (CLCDK.CURRENT_SPEC ~= CLCDK.SPEC_UNKNOWN) then
				local expires = select(6, AuraUtil.FindAuraByName(CLCDK.GetSpecDisease(), "TARGET", "PLAYER"))
				if  expires ~= nil and (expires - CLCDK.CURRENT_TIME) > 0 then
					diseaseTime = expires - CLCDK.CURRENT_TIME
				end
			end

			CLCDK.Disease.Text:SetText(string.format("|cff54BD47%.2d|r", diseaseTime))
		else
			CLCDK.Disease:SetAlpha(0)
		end

		--Priority Icon
		if CLCDK_Settings.CD[CLCDK.CURRENT_SPEC]["CLCDK_CDRPanel_DD_Priority"][1] ~= CLCDK_OPTIONS_FRAME_VIEW_NONE then
			CLCDK.Move:SetAlpha(1)
			CLCDK.MoveBackdrop:SetAlpha(1)
			CLCDK.UpdateCD("CLCDK_CDRPanel_DD_Priority", CLCDK.Move)
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

		--GCD
		if CLCDK_Settings.GCD then
			local start, dur = GetSpellCooldown(CLCDK.Spells["Death Coil"])
			if dur ~= 0 and start ~= nil then
				CLCDK.Move.c:SetCooldown(start, dur)
			end
		end
	end
		
	--Function to check spec and gylphs and adjust settings accordingly
	function CLCDK.CheckSpec()
		--Set all settings to default
		CLCDK.CURRENT_SPEC = GetSpecialization()

		CLCDK.PrintDebug("Spec: "..CLCDK.CURRENT_SPEC)
		CLCDK.OptionsRefresh()
	end

	function CLCDK.Initialize()
		CLCDK.PrintDebug("Initialize")
		mutex = true

		CLCDK.LoadSpells()
		CLCDK.LoadCooldowns()
		if not CLCDK.LoadTrinkets() and (CLCDK.CURRENT_TIME - launchtime < CLCDK.ITEM_LOAD_THRESHOLD)then
			CLCDK.PrintDebug("Initialize - Failed");
			mutex = false;
			return;
		end

		if (CLCDK.CURRENT_TIME - launchtime >= CLCDK.ITEM_LOAD_THRESHOLD) then
			CLCDK.PrintDebug("Initialize - Threshold Met")
		end

		CLCDK.CheckSettings()
		CLCDK.PrintDebug("Initialize - Version "..CLCDK_Settings.Version)

		CLCDK.MainFrame:SetAlpha(0)
		CLCDK.CreateCDs()
		CLCDK.CreateUI()
		CLCDK.CheckSpec()
		
		CLCDK.InitializeOptions()

		mutex = nil
		loaded = true

		collectgarbage()
	end

	CLCDK.PrintDebug("Functions Done")

	-----Events-----
	--Register Events
	CLCDK.MainFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	CLCDK.MainFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	CLCDK.MainFrame:SetScript("OnEvent", function(...)
		if loaded then
			CLCDK.CheckSpec()
			CLCDK.MAX_RP = UnitPowerMax("Player")
		end
	end)

	--Main function to run addon
	CLCDK.MainFrame:SetScript("OnUpdate", function()
		CLCDK.CURRENT_TIME = GetTime()
		
		if (CLCDK.CURRENT_TIME - updatetimer >= CLCDK.UPDATE_INTERVAL) then
			updatetimer = CLCDK.CURRENT_TIME

			if (not loaded) and (not mutex) then
				if launchtime == 0 then
					launchtime = CLCDK.CURRENT_TIME;
					CLCDK.PrintDebug("Launchtime Set")
				end
				CLCDK.Initialize()
				
			elseif loaded then
				--Check if visibility conditions are met, if so update the information in the addon
				if (not UnitHasVehicleUI("player")) and
						((InCombatLockdown() and CLCDK_Settings.VScheme == CLCDK_OPTIONS_FRAME_VIEW_NORM) or
						(CLCDK_Settings.VScheme == CLCDK_OPTIONS_FRAME_VIEW_SHOW) or
						(not CLCDK_Settings.Locked) or
						(CLCDK_Settings.VScheme ~= CLCDK_OPTIONS_FRAME_VIEW_HIDE and UnitCanAttack("player", "target") and (not UnitIsDead("target")))) then
					CLCDK.UpdateUI()
					if CLCDK_Settings.Locked then
						if IsAltKeyDown() then CLCDK.MainFrame:EnableMouse(true)
						else CLCDK.MainFrame:EnableMouse(false) end
					end

				else
					CLCDK.MainFrame:SetAlpha(0)
				end

				if resize ~= nil then
					x, y = GetCursorPosition()
					sizex = (x - mousex + resize:GetWidth())/resize:GetWidth()
					sizey = (mousey - y + resize:GetHeight())/resize:GetHeight()
					if sizex < sizey then
						if sizex > 1 then
							resize:SetScale(sizex)
						end
					else
						if sizey > 1 then
							resize:SetScale(sizey)
						end
					end
				end
			end
		end
	end)
else
	CLCDK.PrintDebug("Not a DK")
	CLCDK = nil
	CLCDK_Options = nil
	CLCDK_FramePanel = nil
	CLCDK_CDRPanel = nil
	CLCDK_CDPanel = nil
	CLCDK_ABOUTPanel = nil
end
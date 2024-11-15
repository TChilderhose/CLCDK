local _, CLCDK = ...

local GetSpellTexture = C_Spell.GetSpellTexture

function CLCDK.InitializeOptions()
	CLCDK.PrintDebug("InitializeOptions Start")

	local category = Settings.RegisterCanvasLayoutCategory(CLCDK_Options, CLCDK_Options.name, CLCDK_Options.name);
	category.ID = CLCDK_Options.name;
	Settings.RegisterAddOnCategory(category);

	--Initalize all dropdowns
	UIDropDownMenu_Initialize(CLCDK_Options_DD_Priority, CLCDK_Options_DD_OnLoad)
	for i = 1, #CDDisplayList do
		UIDropDownMenu_Initialize(_G[CDDisplayList[i]], CLCDK_Options_DD_OnLoad)
	end
	UIDropDownMenu_Initialize(CLCDK_Options_ViewDD, CLCDK_Options_ViewDD_OnLoad)

	CLCDK.PrintDebug("InitializeOptions Done")
end

--function to handle the View dropdown box
function CLCDK_Options_ViewDD_OnLoad()
	info            = {}
	info.text       = CLCDK_OPTIONS_FRAME_VIEW_NORM
	info.value      = CLCDK_OPTIONS_FRAME_VIEW_NORM
	info.func       = function() CLCDK_Settings.VScheme = CLCDK_OPTIONS_FRAME_VIEW_NORM;UIDropDownMenu_SetSelectedValue(CLCDK_Options_ViewDD, CLCDK_Settings.VScheme); end
	UIDropDownMenu_AddButton(info)

	info            = {}
	info.text       = CLCDK_OPTIONS_FRAME_VIEW_TARGET
	info.value      = CLCDK_OPTIONS_FRAME_VIEW_TARGET
	info.func       = function() CLCDK_Settings.VScheme = CLCDK_OPTIONS_FRAME_VIEW_TARGET;UIDropDownMenu_SetSelectedValue(CLCDK_Options_ViewDD, CLCDK_Settings.VScheme); end
	UIDropDownMenu_AddButton(info)

	info            = {}
	info.text       = CLCDK_OPTIONS_FRAME_VIEW_SHOW
	info.value      = CLCDK_OPTIONS_FRAME_VIEW_SHOW
	info.func       = function() CLCDK_Settings.VScheme = CLCDK_OPTIONS_FRAME_VIEW_SHOW;UIDropDownMenu_SetSelectedValue(CLCDK_Options_ViewDD, CLCDK_Settings.VScheme); end
	UIDropDownMenu_AddButton(info)

	info            = {}
	info.text       = CLCDK_OPTIONS_FRAME_VIEW_HIDE
	info.value      = CLCDK_OPTIONS_FRAME_VIEW_HIDE
	info.func       = function() CLCDK_Settings.VScheme = CLCDK_OPTIONS_FRAME_VIEW_HIDE;UIDropDownMenu_SetSelectedValue(CLCDK_Options_ViewDD, CLCDK_Settings.VScheme); end
	UIDropDownMenu_AddButton(info)
end

function CLCDK_Options_DD_OnLoad(self, level)
	--If specified level, or base
	level = level or 1

	--Template for an item in the dropdown box
	local function CLCDK_Options_DD_Item(panel, spell)
		info = {}
		info.text = spell
		info.value = spell
		info.func = function()
			CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][panel:GetName()] = spell
			UIDropDownMenu_SetSelectedValue(panel, spell)
			CloseDropDownMenus()
		end
		return info
	end

	--Function to add specs specific CDs
	local function AddSpecCDs(Spec)
		for i = 1, #Spec do
			UIDropDownMenu_AddButton(CLCDK_Options_DD_Item(self, Spec[i]), 2)
		end
	end

	--If base level
	if level == 1 then
		--Add unique items to dropdown
		UIDropDownMenu_AddButton(CLCDK_Options_DD_Item(self, CLCDK_OPTIONS_CDR_CD_PRIORITY), 1)
		UIDropDownMenu_AddButton(CLCDK_Options_DD_Item(self, CLCDK_OPTIONS_FRAME_VIEW_NONE), 1)
		UIDropDownMenu_AddButton(CLCDK_Options_DD_Item(self, CLCDK_OPTIONS_CDR_RACIAL), 1)

		--Setup nested dropdowns
		info.hasArrow = true
		info.notCheckable = 1

		--Spec Specific CDs
		info.text = CLCDK_OPTIONS_CDR_CD_SPEC
		info.value = {["Level1_Key"] = "Spec";}
		UIDropDownMenu_AddButton(info)

		--Normal CDs
		info.text = CLCDK_OPTIONS_CDR_CD_NORMAL
		info.value = {["Level1_Key"] = "Normal";}
		UIDropDownMenu_AddButton(info)

		--Moves
		info.text = CLCDK_OPTIONS_CDR_CD_MOVES
		info.value = {["Level1_Key"] = "Moves";}
		UIDropDownMenu_AddButton(info)

		--Tier Buffs
		-- info.text = CLCDK_OPTIONS_CDR_CD_TIER
		-- info.value = {["Level1_Key"] = "Tier";}
		-- UIDropDownMenu_AddButton(info)

	--If nested menu
	elseif level == 2 then
		--Check what the "parent" is
		local key = UIDROPDOWNMENU_MENU_VALUE["Level1_Key"]

		if key == "Spec" then
			if (CLCDK.CURRENT_SPEC == CLCDK.SPEC_UNHOLY) then
				AddSpecCDs(CLCDK.Cooldowns.UnholyCDs)
			elseif (CLCDK.CURRENT_SPEC == CLCDK.SPEC_FROST) then
				AddSpecCDs(CLCDK.Cooldowns.FrostCDs)
			elseif (CLCDK.CURRENT_SPEC == CLCDK.SPEC_BLOOD) then
				AddSpecCDs(CLCDK.Cooldowns.BloodCDs)
			end

		elseif key == "Normal" then
			AddSpecCDs(CLCDK.Cooldowns.NormCDs)

		elseif key == "Moves" then
			for i = 1, #CLCDK.Cooldowns.Moves do
				if CLCDK.Cooldowns.Moves[i] and GetSpellTexture(CLCDK.Cooldowns.Moves[i]) then
					UIDropDownMenu_AddButton(CLCDK_Options_DD_Item(self, CLCDK.Cooldowns.Moves[i]), 2)
				end
			end

		end
	end
end


-----Validation/Checks-----
--Update the Blizzard interface Options with settings
function CLCDK_OptionsRefresh()
	CLCDK.OptionsRefresh()
end
function CLCDK.OptionsRefresh()
	if CLCDK_Settings and CLCDK_Settings.Version and CLCDK_Settings.Version == CLCDK.VERSION then
		--Frame
		CLCDK_Options_GCD:SetChecked(CLCDK_Settings.GCD)
		CLCDK_Options_Range:SetChecked(CLCDK_Settings.Range)
		CLCDK_Options_Rune:SetChecked(CLCDK_Settings.Rune)
		CLCDK_Options_RP:SetChecked(CLCDK_Settings.RP)
		CLCDK_Options_Disease:SetChecked(CLCDK_Settings.Disease)
		CLCDK_Options_Locked:SetChecked(CLCDK_Settings.Locked)
		CLCDK_Options_LockedPieces:SetChecked(CLCDK_Settings.LockedPieces)
		CLCDK_Options_Scale:SetNumber(CLCDK_Settings.Scale)
		CLCDK_Options_Scale:SetCursorPosition(0)
		CLCDK_Options_Trans:SetNumber(CLCDK_Settings.Trans)
		CLCDK_Options_Trans:SetCursorPosition(0)
		CLCDK_Options_CombatTrans:SetNumber(CLCDK_Settings.CombatTrans)
		CLCDK_Options_CombatTrans:SetCursorPosition(0)
		CLCDK_Options_NormalTrans:SetNumber(CLCDK_Settings.NormTrans)
		CLCDK_Options_NormalTrans:SetCursorPosition(0)

		--View Dropdown
		UIDropDownMenu_SetSelectedValue(CLCDK_Options_ViewDD, CLCDK_Settings.VScheme)
		UIDropDownMenu_SetText(CLCDK_Options_ViewDD, CLCDK_Settings.VScheme)

		CLCDK_Options_DD_CD1:SetChecked(CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][1])
		CLCDK_Options_DD_CD2:SetChecked(CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][2])
		CLCDK_Options_DD_CD3:SetChecked(CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][3])
		CLCDK_Options_DD_CD4:SetChecked(CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][4])

		--Priority Dropdown
		if CLCDK_Settings.CD[CLCDK.CURRENT_SPEC]["CLCDK_Options_DD_Priority"] then
			UIDropDownMenu_SetSelectedValue(CLCDK_Options_DD_Priority, CLCDK_Settings.CD[CLCDK.CURRENT_SPEC]["CLCDK_Options_DD_Priority"])
			UIDropDownMenu_SetText(CLCDK_Options_DD_Priority, CLCDK_Settings.CD[CLCDK.CURRENT_SPEC]["CLCDK_Options_DD_Priority"])
		end

		--Cooldown Dropdown
		for i = 1, #CDDisplayList do
			if _G[CDDisplayList[i]] and CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][CDDisplayList[i]] then
				UIDropDownMenu_SetSelectedValue(_G[CDDisplayList[i]], CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][CDDisplayList[i]])
				UIDropDownMenu_SetText(_G[CDDisplayList[i]], CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][CDDisplayList[i]])
			end
		end

		CLCDK.PrintDebug("OptionsRefresh")
		CLCDK.UpdatePosition()
	else
		CLCDK.PrintDebug("ERROR OptionsRefresh - "..(CLCDK_Settings == nil and "Settings are nil") or (CLCDK_Settings.Version == nil and "Version is nil") or ("Invalid Version"..CLCDK_Settings.Version ))
	end
end

--Check if options are valid and save them to settings if so
function CLCDK_OptionsOkay()
	CLCDK.OptionsOkay()
end
function CLCDK.OptionsOkay()
	if CLCDK_Settings and (CLCDK_Settings.Version and CLCDK_Settings.Version == CLCDK.VERSION) then
		--Frame
		CLCDK_Settings.GCD = CLCDK_Options_GCD:GetChecked()
		CLCDK_Settings.Range = CLCDK_Options_Range:GetChecked()
		CLCDK_Settings.Rune = CLCDK_Options_Rune:GetChecked()
		CLCDK_Settings.RP = CLCDK_Options_RP:GetChecked()
		CLCDK_Settings.Disease = CLCDK_Options_Disease:GetChecked()
		CLCDK_Settings.Locked = CLCDK_Options_Locked:GetChecked()
		CLCDK_Settings.LockedPieces = CLCDK_Options_LockedPieces:GetChecked()

		--Scale
		if CLCDK_Options_Scale:GetNumber() >= 0.5 and CLCDK_Options_Scale:GetNumber() <= 5 then
			CLCDK_Settings.Scale = CLCDK_Options_Scale:GetNumber()
		else
			CLCDK_Options_Scale:SetNumber(CLCDK_Settings.Scale)
		end

		--Transparency
		if CLCDK_Options_Trans:GetNumber() >= 0 and CLCDK_Options_Trans:GetNumber() <= 1 then
			CLCDK_Settings.Trans = CLCDK_Options_Trans:GetNumber()
		else
			CLCDK_Options_Trans:SetNumber(CLCDK_Settings.Trans)
		end
		if CLCDK_Options_CombatTrans:GetNumber() >= 0 and CLCDK_Options_CombatTrans:GetNumber() <= 1 then
			CLCDK_Settings.CombatTrans = CLCDK_Options_CombatTrans:GetNumber()
		else
			CLCDK_Options_CombatTrans:SetNumber(CLCDK_Settings.CombatTrans)
		end
		if CLCDK_Options_NormalTrans:GetNumber() >= 0 and CLCDK_Options_NormalTrans:GetNumber() <= 1 then
			CLCDK_Settings.NormTrans = CLCDK_Options_NormalTrans:GetNumber()
		else
			CLCDK_Options_NormalTrans:SetNumber(CLCDK_Settings.NormTrans)
		end

		--CD/R
		CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][1] = (CLCDK_Options_DD_CD1:GetChecked())
		CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][2] = (CLCDK_Options_DD_CD2:GetChecked())
		CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][3] = (CLCDK_Options_DD_CD3:GetChecked())
		CLCDK_Settings.CD[CLCDK.CURRENT_SPEC][4] = (CLCDK_Options_DD_CD4:GetChecked())


		CLCDK.PrintDebug("OptionsOkay")
		CLCDK.OptionsRefresh()
	else
		CLCDK.PrintDebug("ERROR OptionsOkay - "..(CLCDK_Settings == nil and "Settings are nil") or (CLCDK_Settings.Version == nil and "Version is nil") or ("Invalid Version"..CLCDK_Settings.Version))
	end
end

--Checks to make sure that none of the settings are nil, which will lead to the addon not working properly
function CLCDK.CheckSettings()
	CLCDK.PrintDebug("Check Settings Start")

	local specs = {CLCDK.SPEC_UNKNOWN, CLCDK.SPEC_BLOOD, CLCDK.SPEC_FROST, CLCDK.SPEC_UNHOLY}
	local spots = {"Priority", "CD1_One", "CD1_Two", "CD2_One", "CD2_Two", "CD3_One", "CD3_Two", "CD4_One", "CD4_Two"}

	--Defaults
	if CLCDK_Settings == nil then
		CLCDK.PrintDebug("No Settings Found")
		CLCDK_Settings = {}
		CLCDK_Settings.Locked = true
		CLCDK_Settings.LockedPieces = true
		CLCDK_Settings.Range = true
		CLCDK_Settings.GCD = true
		CLCDK_Settings.Rune = true
		CLCDK_Settings.RP = true
		CLCDK_Settings.Disease = true
		CLCDK_Settings.CD = {}
		CLCDK.CooldownDefaults()
	end

	--General Settings
	if CLCDK_Settings.Scale == nil then CLCDK_Settings.Scale = 1.0 end
	if CLCDK_Settings.Trans == nil then CLCDK_Settings.Trans = 0.5 end
	if CLCDK_Settings.CombatTrans == nil then CLCDK_Settings.CombatTrans = 1.0 end
	if CLCDK_Settings.NormTrans == nil then CLCDK_Settings.NormTrans = 1.0 end
	if CLCDK_Settings.VScheme == nil then CLCDK_Settings.VScheme = CLCDK_OPTIONS_FRAME_VIEW_NORM end

	--CDs
	if CLCDK_Settings.CD == nil then
		CLCDK.PrintDebug("No CD Settings Found")
		CLCDK_Settings.CD = {}
		CLCDK.CooldownDefaults()
	end
	for i=1,#specs do
		if CLCDK_Settings.CD[specs[i]] == nil then CLCDK_Settings.CD[specs[i]] = {}	end
		for j=1,#spots do
			if CLCDK_Settings.CD[specs[i]]["CLCDK_Options_DD_"..spots[j]] == nil then
				CLCDK_Settings.CD[specs[i]]["CLCDK_Options_DD_"..spots[j]] = {CLCDK_OPTIONS_FRAME_VIEW_NONE, nil}
			end
		end
	end

	--Frame Location
	if CLCDK_Settings.Location == nil then CLCDK_Settings.Location = {} end
	if CLCDK_Settings.Location["CLCDK"] == nil then	CLCDK_Settings.Location["CLCDK"] = {Point = "Center", Rel = nil, RelPoint = "CENTER", X = 0, Y = -140, Scale = 1} end
	if CLCDK_Settings.Location["CLCDK.CD1"] == nil then	CLCDK_Settings.Location["CLCDK.CD1"] = {Point = "TOPRIGHT",Rel = "CLCDK",RelPoint = "TOPLEFT", X = -1, Y = -3, Scale = 1} end
	if CLCDK_Settings.Location["CLCDK.CD2"] == nil then	CLCDK_Settings.Location["CLCDK.CD2"] = {Point = "TOPLEFT",Rel = "CLCDK",RelPoint = "TOPRIGHT",X = 1,Y = -3, Scale = 1}	end
	if CLCDK_Settings.Location["CLCDK.CD3"] == nil then	CLCDK_Settings.Location["CLCDK.CD3"] = {Point = "TOPRIGHT",Rel = "CLCDK.CD1",RelPoint = "TOPLEFT", X = -2, Y = 0, Scale = 1} end
	if CLCDK_Settings.Location["CLCDK.CD4"] == nil then	CLCDK_Settings.Location["CLCDK.CD4"] = {Point = "TOPLEFT",Rel = "CLCDK.CD2",RelPoint = "TOPRIGHT",X = 2,Y = 0, Scale = 1} end
	if CLCDK_Settings.Location["CLCDK.RuneBar"] == nil then	CLCDK_Settings.Location["CLCDK.RuneBar"] = {Point = "Top",Rel = "CLCDK",RelPoint = "Top",X = 0,Y = -2, Scale = 1} end
	if CLCDK_Settings.Location["CLCDK.RunicPower"] == nil then CLCDK_Settings.Location["CLCDK.RunicPower"] = {Point = "TOPRIGHT",Rel = "CLCDK.RuneBar",RelPoint = "BOTTOMRIGHT",X = 0,Y = 0, Scale = 1} end
	if CLCDK_Settings.Location["CLCDK.Move"] == nil then CLCDK_Settings.Location["CLCDK.Move"] = {Point = "TOPLEFT",Rel = "CLCDK.RuneBar",RelPoint = "BOTTOMLEFT",X = 0,Y = 0, Scale = 1} end
	if CLCDK_Settings.Location["CLCDK.Disease"] == nil then CLCDK_Settings.Location["CLCDK.Disease"]= {Point = "TOPRIGHT",Rel = "CLCDK.RunicPower",RelPoint = "BOTTOMRIGHT",X = 0,Y = 0, Scale = 1} end

	CLCDK_Settings.Version = CLCDK.VERSION

	wipe(specs)
	wipe(spots)
	collectgarbage()
	CLCDK.PrintDebug("Check Settings Complete")
end


-----Reset/Defaults-----
function CLCDK_SetDefaults()
	CLCDK.SetDefaults()
end
function CLCDK.SetDefaults()
	if CLCDK_Settings then
		wipe(CLCDK_Settings);
		CLCDK_Settings = nil
	end
	CLCDK.CheckSettings()

	CLCDK.OptionsRefresh()
	CLCDK.PrintDebug("SetDefaults Done")
end

function CLCDK_SetLocationDefault()
	CLCDK.SetLocationDefault()
end
function CLCDK.SetLocationDefault()
	if CLCDK_Settings.Location then
		wipe(CLCDK_Settings.Location);
		CLCDK_Settings.Location = nil
	end
	CLCDK.CheckSettings()

	CLCDK.OptionsRefresh()
	CLCDK.PrintDebug("SetLocationDefault Done")
end

function CLCDK_CooldownDefaults()
	CLCDK.CooldownDefaults()
end
function CLCDK.CooldownDefaults()
	if CLCDK_Settings.CD then
		wipe(CLCDK_Settings.CD)
	end

	CLCDK_Settings.CD = {
		[CLCDK.SPEC_UNHOLY] = {
			["CLCDK_Options_DD_Priority"] = CLCDK_OPTIONS_CDR_CD_PRIORITY,

			[1] = true,
			["CLCDK_Options_DD_CD1_One"] = CLCDK.Spells["Apocalypse"],
			["CLCDK_Options_DD_CD1_Two"] = CLCDK.Spells["Dark Transformation"],

			[2] = true,
			["CLCDK_Options_DD_CD2_One"] = CLCDK.Spells["Plaguebringer"],
			["CLCDK_Options_DD_CD2_Two"] = CLCDK.Spells["Festering Wound"],

			[3] = true,
			["CLCDK_Options_DD_CD3_One"] = CLCDK.Spells["Unholy Assault"],
			["CLCDK_Options_DD_CD3_Two"] = CLCDK.Spells["Army of the Dead"],

			[4] = true,
			["CLCDK_Options_DD_CD4_One"] = CLCDK.Spells["Icy Talons"],
			["CLCDK_Options_DD_CD4_Two"] = CLCDK.Spells["Death Rot"],
		},

		[CLCDK.SPEC_FROST] = {
			["CLCDK_Options_DD_Priority"] = CLCDK_OPTIONS_CDR_CD_PRIORITY,

			[1] = true,
			["CLCDK_Options_DD_CD1_One"] = CLCDK.Spells["Pillar of Frost"],
			["CLCDK_Options_DD_CD1_Two"] = CLCDK.Spells["Remorseless Winter"],

			[2] = true,
			["CLCDK_Options_DD_CD2_One"] = CLCDK.Spells["Killing Machine"],
			["CLCDK_Options_DD_CD2_Two"] = CLCDK.Spells["Rime"],

			[3] = false,
			["CLCDK_Options_DD_CD3_One"] = CLCDK_OPTIONS_FRAME_VIEW_NONE,
			["CLCDK_Options_DD_CD3_Two"] = CLCDK_OPTIONS_FRAME_VIEW_NONE,

			[4] = true,
			["CLCDK_Options_DD_CD4_One"] = CLCDK.Spells["Icy Talons"],
			["CLCDK_Options_DD_CD4_Two"] = CLCDK.Spells["Unleashed Frenzy"],
		},

		[CLCDK.SPEC_BLOOD] = {
			["CLCDK_Options_DD_Priority"] = CLCDK_OPTIONS_CDR_CD_PRIORITY,

			[1] = true,
			["CLCDK_Options_DD_CD1_One"] = CLCDK.Spells["Bone Shield"],
			["CLCDK_Options_DD_CD1_Two"] = CLCDK.Spells["Vampiric Blood"],

			[2] = true,
			["CLCDK_Options_DD_CD2_One"] = CLCDK.Spells["Rune Tap"],
			["CLCDK_Options_DD_CD2_Two"] = CLCDK.Spells["Scarlet Fever"],

			[3] = false,
			["CLCDK_Options_DD_CD3_One"] = CLCDK.Spells["Horn of Winter"],
			["CLCDK_Options_DD_CD3_Two"] = CLCDK.Spells["Blood Charge"],

			[4] = false,
			["CLCDK_Options_DD_CD4_One"] = CLCDK_OPTIONS_FRAME_VIEW_NONE,
			["CLCDK_Options_DD_CD4_Two"] = CLCDK_OPTIONS_FRAME_VIEW_NONE,
		},

		[CLCDK.SPEC_UNKNOWN] = {
			["CLCDK_Options_DD_Priority"] = CLCDK_OPTIONS_CDR_CD_PRIORITY,

			[1] = true,
			["CLCDK_Options_DD_CD1_One"] = CLCDK.Spells["Horn of Winter"],
			["CLCDK_Options_DD_CD1_Two"] = CLCDK.Spells["Blood Charge"],

			[2] = true,
			["CLCDK_Options_DD_CD2_One"] = CLCDK.Spells["Raise Dead"],
			["CLCDK_Options_DD_CD2_Two"] = CLCDK.Spells["Army of the Dead"],

			[3] = false,
			["CLCDK_Options_DD_CD3_One"] = CLCDK.Spells["Horn of Winter"],
			["CLCDK_Options_DD_CD3_Two"] = CLCDK.Spells["Blood Tap"],

			[4] = false,
			["CLCDK_Options_DD_CD4_One"] = CLCDK_OPTIONS_FRAME_VIEW_NONE,
			["CLCDK_Options_DD_CD4_Two"] = CLCDK_OPTIONS_FRAME_VIEW_NONE,
		},
	}
end


-----Slash Command-----
SLASH_CLCDK1 = '/clcdk'
SlashCmdList["CLCDK"] = function()
	CLCDK.PrintDebug("Slash Command Used")
	Settings.OpenToCategory("CLCDK")
end
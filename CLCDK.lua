local _, CLCDK = ...

if CLCDK.PLAYER_CLASS == "DEATHKNIGHT" then
	CLCDK.PrintDebug("Is DK. Starting...")
	
	--Create Main Frame
	CLCDK.MainFrame = CreateFrame("Button", "CLCDK", UIParent, BackdropTemplateMixin and "BackdropTemplate")
	CLCDK.MainFrame:SetWidth(94)
	CLCDK.MainFrame:SetHeight(68)
	CLCDK.MainFrame:SetFrameStrata("BACKGROUND")
	CLCDK.MainFrame:SetAlpha(0)

	local GetTime = GetTime
	local mutex = false
	local timeSinceLastUpdate = 0	

	CLCDK.MainFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	CLCDK.MainFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	CLCDK.MainFrame:SetScript("OnEvent", function()
		if CLCDK.LOADED then
			CLCDK.CheckSpec()
		end
	end)

	CLCDK.MainFrame:SetScript("OnUpdate", function(_, elapsed)
		timeSinceLastUpdate = timeSinceLastUpdate + elapsed
		if (not mutex and timeSinceLastUpdate > CLCDK.UPDATE_INTERVAL) then
			mutex = true
			timeSinceLastUpdate = 0
			
			if CLCDK.LOADED then
				--Check if visibility conditions are met, if so update the information in the addon
				if (not UnitHasVehicleUI("player")) and (
						(CLCDK_Settings.VScheme == CLCDK_OPTIONS_FRAME_VIEW_NORM and InCombatLockdown()) or
						(CLCDK_Settings.VScheme == CLCDK_OPTIONS_FRAME_VIEW_SHOW) or
						(CLCDK_Settings.VScheme ~= CLCDK_OPTIONS_FRAME_VIEW_HIDE and UnitCanAttack("player", "target") and (not UnitIsDead("target"))) or
						(not CLCDK_Settings.Locked)) then
					CLCDK.CURRENT_TIME = GetTime()
					CLCDK.UpdateUI()
				else
					CLCDK.MainFrame:SetAlpha(0)
				end
				
			elseif (not CLCDK.LOADED) then
				CLCDK.PrintDebug("Initialize")

				CLCDK.LoadSpells()
				CLCDK.LoadCooldowns()

				CLCDK.CheckSettings()

				CLCDK.CreateCDs()
				CLCDK.CreateUI()
				CLCDK.CheckSpec()

				CLCDK.InitializeOptions()

				CLCDK.LOADED = true

				collectgarbage()
			end
			
			mutex = false
		end
	end)

else
	CLCDK.PrintDebug("Not a DK")
	wipe(CLCDK)
	CLCDK = nil
	CLCDK_Options = nil
	CLCDK_FramePanel = nil
	CLCDK_CDRPanel = nil
	CLCDK_CDPanel = nil
	CLCDK_ABOUTPanel = nil
	collectgarbage()
end
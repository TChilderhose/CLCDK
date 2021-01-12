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
	local mousex, mousey
	local resize = nil	

	CLCDK.MainFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	CLCDK.MainFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	CLCDK.MainFrame:SetScript("OnEvent", function()
		if CLCDK.LOADED then
			CLCDK.CheckSpec()
		end
	end)

	CLCDK.MainFrame:SetScript("OnUpdate", function(_, elapsed)
		timeSinceLastUpdate = timeSinceLastUpdate + elapsed
		if (timeSinceLastUpdate > CLCDK.UPDATE_INTERVAL) then
			CLCDK.CURRENT_TIME = GetTime()

			if CLCDK.LOADED then
				--Check if visibility conditions are met, if so update the information in the addon
				if (not UnitHasVehicleUI("player")) and
						((InCombatLockdown() and CLCDK_Settings.VScheme == CLCDK_OPTIONS_FRAME_VIEW_NORM) or
						(CLCDK_Settings.VScheme == CLCDK_OPTIONS_FRAME_VIEW_SHOW) or
						(not CLCDK_Settings.Locked) or
						(CLCDK_Settings.VScheme ~= CLCDK_OPTIONS_FRAME_VIEW_HIDE and UnitCanAttack("player", "target") and (not UnitIsDead("target")))) then
					CLCDK.UpdateUI()
				else
					CLCDK.MainFrame:SetAlpha(0)
				end

				if resize ~= nil then
					local x, y = GetCursorPosition()
					local sizex = (x - mousex + resize:GetWidth())/resize:GetWidth()
					local sizey = (mousey - y + resize:GetHeight())/resize:GetHeight()
					if sizex < sizey then
						if sizex > 1 then
							resize:SetScale(sizex)
						end
					elseif sizey > 1 then
						resize:SetScale(sizey)
					end
				end
				
			elseif (not CLCDK.LOADED) and (not mutex) then
				CLCDK.PrintDebug("Initialize")
				mutex = true

				CLCDK.LoadSpells()
				CLCDK.LoadCooldowns()

				CLCDK.CheckSettings()

				CLCDK.CreateCDs()
				CLCDK.CreateUI()
				CLCDK.CheckSpec()

				CLCDK.InitializeOptions()

				mutex = nil
				CLCDK.LOADED = true

				collectgarbage()
			end
			
			timeSinceLastUpdate = 0
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
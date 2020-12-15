local debugg = true
if select(2, UnitClass("player")) == "DEATHKNIGHT" then	
	if debugg then print("CLCDK:Starting")end	
	CLCDK_VERSION = 9.02
	
	-----Create Main Frame-----
	local CLCDK = CreateFrame("Button", "CLCDK", UIParent, BackdropTemplateMixin and "BackdropTemplate")
	CLCDK:SetWidth(94)
	CLCDK:SetHeight(68)
	CLCDK:SetFrameStrata("BACKGROUND")	

	-----Locals-----
	--Constants
	local PLAYER_NAME, PLAYER_RACE = UnitName("player"), select(2, UnitRace("player"))
	local SPEC_UNKNOWN, SPEC_BLOOD, SPEC_FROST, SPEC_UNHOLY = 5, 1, 2, 3
	local IS_BUFF = 2
	local ITEM_LOAD_THRESHOLD = .5
		
	--Variables
	local loaded, mutex = false, false
	local mousex, mousey
	local font = 'Interface\\AddOns\\CLC_DK\\Font.ttf'
	local GetTime = GetTime
	local darksim = {0, 0}
	local simtime = 0
	local bsamount = 0
	local GCD, curtime, launchtime = 0, 0, 0
	local Current_Spec = SPEC_UNKNOWN
	local updatetimer = 0
	local maxPower = 100

	if debugg then print("CLCDK:Locals Done")end
	
	local spellLookup = {
		["Anti-Magic Shell"] = 48707,
		["Army of the Dead"] = 42650,
		["Blood Plague"] = 55078,
		["Blood Strike"] = 45902,
		["Dark Command"] = 56222,
		["Dark Simulacrum"] = 77606, --Cata
		["Dark Succor"] = 101568,
		["Death and Decay"] = 43265,	
		["Death Coil"] = 47541,
		["Death Grip"] = 49576,	
		["Death Pact"] = 48743,
		["Death Strike"] = 49998,		
		["Empower Rune Weapon"] = 47568,	
		["Festering Strike"] = 85948,	--Cata
		["Frost Fever"] = 55095,
		["Horn of Winter"] = 57330,		
		["Icebound Fortitude"] = 48792,
		["Lichborne"] = 49039,
		["Mind Freeze"] = 47528,
		["Necrotic Strike"] = 73975, --Cata		
		["Obliterate"] = 49020,		
		["Outbreak"] = 77575, --Cata
		["Pestilence"] = 50842,			
		["Raise Ally"] = 61999,
		["Raise Dead"] = 46584,	
		["Rune Strike"] = 210764,	
		["Strangulate"] = 47476,	
		["Unholy Strength"] = 53365,
		["Unholy Frenzy"] = 207289,
		
		--Blood Only
		["Blood Shield"] = 77535,	
		["Dancing Rune Weapon"] = 49028,	
		["Vampiric Blood"] = 55233,
		["Marrowrend"] = 195182,
		["Blooddrinker"] = 206931,
		["Heart Strike"] = 206930,
		
		--Frost Only
		["Freezing Fog"] = 59052,
		["Frost Strike"] = 49143,		
		["Howling Blast"] = 49184,	
		["Killing Machine"] = 51124,
		["Pillar of Frost"] = 51271,	
		["Rime"] = 59057,	
		["Razorice"] = 51714,
		["Sindragosa's Fury"] = 190778,	
		["Gathering Storm"] = 194912,	
		["Remorseless Winter"] = 196770,
								
		--Unholy Only
		["Anti-Magic Zone"] = 51052,
		["Dark Transformation"] = 63560,
		["Desolation"] = 63583,
		["Gnaw"] =  91800,
		["Runic Corruption"] = 51460,
		["Scourge Strike"] = 55090,	
		["Sudden Doom"] = 81340,
		["Summon Gargoyle"] = 49206,
		["Virulent Plague"] = 191587,--Legion
		["Festering Wound"] = 194310,--Legion
		["Apocalypse"] = 220143,--Legion
		["Scourge of Worlds"] = 191748,--Legion

		--Tier Sets
		
		--Racials
		["Human"] = 59752,--Every Man for Himself
		["Dwarf"] = 20594,--Stoneform
		["NightElf"] = 58984,--Shadowmeld
		["Gnome"] = 20589,--Escape Artist 
		["Draenei"] = 28880,--Gift of the Naaru
		["Worgen"] = 68992,--Darkflight
		
		["Orc"] = 33697,--Blood Fury
		["Scourge"] = 7744,--Will of the Forsaken 
		["Tauren"] = 20549,--War Stomp
		["Troll"] = 26297,--Berserking
		["BloodElf"] = 28730,--Arcane Torrent
		["Goblin"] = 69070,--Rocket Jump
	}
	
	local spells
	function CLCDK:LoadSpells()
		if debugg then print("CLCDK:LoadSpells")end
		if spells ~= nil then wipe(spells) end
		spells = {}
		
		local info
		for name, id in pairs (spellLookup) do
			info = GetSpellInfo(id)
			if (info == nil) then
				if debugg then print("Spell " .. name .. " is null")end
			else
				spells[name] = info
			end
		end		
		if debugg then print("CLCDK:Spells Loaded")end
	end
			
	local Cooldowns
	function CLCDK:LoadCooldowns()
		if Cooldowns~= nil then wipe(Cooldowns) end
		Cooldowns = {}
		Cooldowns = {
			NormCDs = {--CDs that all DKs get
				spells["Anti-Magic Shell"],
				spells["Apocalypse"],
				spells["Army of the Dead"],	
				spells["Dark Command"],
				spells["Dark Simulacrum"],
				spells["Dark Succor"],
				spells["Death and Decay"],
				spells["Death Grip"],
				spells["Death Pact"],
				spells["Empower Rune Weapon"],
				spells["Horn of Winter"],
				spells["Icebound Fortitude"],				
				spells["Lichborne"],
				spells["Mind Freeze"],
				spells["Necrotic Strike"],
				spells["Outbreak"],
				spells["Raise Ally"],
				spells["Raise Dead"],
				spells["Strangulate"],
				spells["Unholy Strength"],
			},
			UnholyCDs = {
				spells["Anti-Magic Zone"],
				spells["Dark Transformation"],
				spells["Gnaw"],
				spells["Festering Wound"],
				spells["Runic Corruption"],
				spells["Scourge of Worlds"],
				spells["Summon Gargoyle"],	
				spells["Sudden Doom"],
				spells["Unholy Strength"],
			},
			FrostCDs = {
				spells["Chilblains"],
				spells["Freezing Fog"],
				spells["Killing Machine"],
				spells["Pillar of Frost"],			
			},
			BloodCDs = {
				spells["Blood Shield"],
				spells["Bone Shield"],	
				spells["Crimson Scourge"],
				spells["Dancing Rune Weapon"],
				spells["Rune Tap"],	
				spells["Scarlet Fever"],
				spells["Lichborne"],
				spells["Vampiric Blood"],
			},
			Buffs = {--List of Buffs
				--- How to use {who gets buff,  Is it also a CD?}
				--normal
				[spells["Anti-Magic Shell"]] = {"player", true},
				[spells["Dark Simulacrum"]] = {"target", true},	
				[spells["Dark Succor"]] = {"player", false},	
				[spells["Festering Wound"]] = {"target", false},	
				[spells["Icebound Fortitude"]] = {"player", true},
				[spells["Necrotic Strike"]] = {"target", false},
				[spells["Strangulate"]] = {"target", true},	
				[spells["Scourge of Worlds"]] = {"target", false},	
				[spells["Unholy Strength"]] = {"player", false},					
						
				--unholy
				[spells["Dark Transformation"]] = {"pet", true},
				[spells["Unholy Frenzy"]] = {"player", false},
				[spells["Runic Corruption"]] = {"player", false},
				[spells["Sudden Doom"]] = {"player", false},
				[spells["Virulent Plague"]] = {"target", false},
				
				--frost
				[spells["Pillar of Frost"]] = {"player", true},
				[spells["Lichborne"]] = {"player", true},
				[spells["Freezing Fog"]] = {"player", false},
				[spells["Killing Machine"]] = {"player", false},
				
				--blood
				[spells["Blood Shield"]] = {"player", false},	
				--[spells["Bone Shield"]] = {"player", true},	
				[spells["Dancing Rune Weapon"]] = {"player", true},
				[spells["Vampiric Blood"]] = {"player", true},								
			},
			Moves = {--List of Moves that can be watched when availible
				spells["Blood Boil"],
				spells["Blood Strike"],
				spells["Death Coil"],
				spells["Death Strike"],
				spells["Festering Strike"],
				spells["Frost Strike"],
				spells["Heart Strike"],
				spells["Howling Blast"],
				spells["Icy Touch"],
				spells["Necrotic Strike"],
				spells["Obliterate"],
				spells["Pestilence"],
				spells["Plague Strike"],
				spells["Scourge Strike"],
			},				
		}
		if debugg then print("CLCDK:Cooldowns Loaded")end
		return;
	end	
	
	function CLCDK:LoadTrinkets()
		local loaded = true
		
		local function AddTrinket(name, info) --BuffID, Is on use?, (ItemID or ICD), start, cd flag, alternative buff	
			if name == nil then 
				loaded = false
				if debugg then print("CLCDK:Trinket Not Found - Buff: "..info[1])end
			else 
				Cooldowns.Trinkets[name] = info
			end
		end
		Cooldowns.Trinkets = {}	
		
		--Test trinket that doesnt exist
		--AddTrinket(select(1, GetItemInfo(1)), {"Test Trinket"})
		
		--On-Use		
		--Impatience of Youth
		spells["Thrill of Victory"] = GetSpellInfo(91828)
		AddTrinket(select(1, GetItemInfo(62469)), {spells["Thrill of Victory"], true, 62469})
		
		-- Vial of Stolen Memories
		spells["Memory of Invincibility"] = GetSpellInfo(92213)
		AddTrinket(select(1, GetItemInfo(59515)), {spells["Memory of Invincibility"], true, 59515})
		
		-- Figurine - King of Boars
		spells["King of Boars"] = GetSpellInfo(73522)
		AddTrinket(select(1, GetItemInfo(52351)), {spells["King of Boars"], true, 52351})
		
		-- Figurine - Earthen Guardian
		spells["Earthen Guardian"] = GetSpellInfo(73550)
		AddTrinket(select(1, GetItemInfo(52352)), {spells["Earthen Guardian"], true, 52352})
		
		-- Might of the Ocean
		spells["Typhoon"] = GetSpellInfo(91340)
		AddTrinket(select(1, GetItemInfo(56285)), {spells["Typhoon"], true, 56285})
		
		-- Magnetite Mirror
		spells["Polarization"] = GetSpellInfo(91351)
		AddTrinket(select(1, GetItemInfo(55814)), {spells["Polarization"], true, 55814})
		
		-- Mirror of Broken Images
		spells["Image of Immortality"] = GetSpellInfo(92222)
		AddTrinket(select(1, GetItemInfo(62466)), {spells["Image of Immortality"], true, 62466})
		
		--Essence of the Eternal Flame
		spells["Essence of the Eternal Flame"] = GetSpellInfo(97010)
		AddTrinket(select(1, GetItemInfo(69002)), {spells["Essence of the Eternal Flame"], true, 69002})
		
		--Moonwell Phial
		spells["Summon Splashing Waters"] = GetSpellInfo(101492)
		AddTrinket(select(1, GetItemInfo(70143)), {spells["Summon Splashing Waters"], true, 70143})
		
		-- Scales of Life
		spells["Weight of a Feather"] = GetSpellInfo(97117)
		AddTrinket(select(1, GetItemInfo(69109)), {spells["Weight of a Feather"], true, 69109})
				
		-- Rotting Skull
		spells["Titanic Strength"] = GetSpellInfo(109746)
		AddTrinket(select(1, GetItemInfo(77116)), {spells["Titanic Strength"], true, 77116})
		
		--Badge of Victory
		spells["Call of Victory"] = GetSpellInfo(92224)
		AddTrinket(select(1, GetItemInfo(64689)), {spells["Call of Victory"], true, 64689})--Bloodthirsty Gladiator's		
		AddTrinket(select(1, GetItemInfo(61034)), {spells["Call of Victory"], true, 61034})--Vicious Gladiator's s9
		AddTrinket(select(1, GetItemInfo(70519)), {spells["Call of Victory"], true, 70519})--Vicious Gladiator's s10
		AddTrinket(select(1, GetItemInfo(70400)), {spells["Call of Victory"], true, 70400})--Ruthless Gladiator's s10
		AddTrinket(select(1, GetItemInfo(72450)), {spells["Call of Victory"], true, 72450})--Ruthless Gladiator's s11
		AddTrinket(select(1, GetItemInfo(73496)), {spells["Call of Victory"], true, 73496})--Cataclysmic Gladiator's s11
		
		--PvP Trinkets
		spells["PvP Trinket"] = GetSpellInfo(42292)
		AddTrinket(select(1, GetItemInfo(64794)), {spells["PvP Trinket"], true, 64794})--Bloodthirsty
		AddTrinket(select(1, GetItemInfo(60807)), {spells["PvP Trinket"], true, 60807})--Vicious s9
		AddTrinket(select(1, GetItemInfo(70607)), {spells["PvP Trinket"], true, 70607})--Vicious s10
		AddTrinket(select(1, GetItemInfo(70395)), {spells["PvP Trinket"], true, 70395})--Ruthless s10
		AddTrinket(select(1, GetItemInfo(72413)), {spells["PvP Trinket"], true, 72413})--Ruthless s11
		AddTrinket(select(1, GetItemInfo(73537)), {spells["PvP Trinket"], true, 73537})--Cataclysmic s11
		
		AddTrinket(select(1, GetItemInfo(60795)), {spells["PvP Trinket"], true, 60795})
		AddTrinket(select(1, GetItemInfo(60796)), {spells["PvP Trinket"], true, 60796})
		AddTrinket(select(1, GetItemInfo(60797)), {spells["PvP Trinket"], true, 60797})
		AddTrinket(select(1, GetItemInfo(60798)), {spells["PvP Trinket"], true, 60798})
		
		AddTrinket(select(1, GetItemInfo(51378)), {spells["PvP Trinket"], true, 51378})		
		AddTrinket(select(1, GetItemInfo(51377)), {spells["PvP Trinket"], true, 51377})
		
		
		--Stacking Buff	
		--"License to Slay
		spells["Slayer"] = GetSpellInfo(91810)
		AddTrinket(select(1, GetItemInfo(58180)), {spells["Slayer"], false, 0, 0, false})
		
		-- Fury of Angerforge
		spells["Forged Fury"] = GetSpellInfo(91836)
		spells["Raw Fury"] = GetSpellInfo(91832)
		AddTrinket(select(1, GetItemInfo(59461)), {spells["Forged Fury"], false, 120, 0, false, spells["Raw Fury"]})
		
		--Apparatus of Khaz'goroth
		spells["Titanic Power"] = GetSpellInfo(96923)
		spells["Blessing of Khaz'goroth"] = GetSpellInfo(97127)
		AddTrinket(select(1, GetItemInfo(69113)), {spells["Blessing of Khaz'goroth"], false, 120, 0, false, spells["Titanic Power"]})

		--Vessel of Acceleration
		spells["Accelerated"] = GetSpellInfo(96980)
		AddTrinket(select(1, GetItemInfo(68995)), {spells["Accelerated"], false, 0, 0, false})
		
		--Eye of Unmaking
		spells["Titanic Strength"] = GetSpellInfo(109748)
		AddTrinket(select(1, GetItemInfo(77977)), {spells["Titanic Strength"], false, 0, 0, false})
		
		--Resolve of Undying
		spells["Preternatural Evasion"] = GetSpellInfo(109782)
		AddTrinket(select(1, GetItemInfo(77998)), {spells["Preternatural Evasion"], false, 0, 0, false})
		
		
		--ICD
		-- Heart of Rage
		spells["Rageheart"] = GetSpellInfo(92345)
		AddTrinket(select(1, GetItemInfo(65072)), {spells["Rageheart"], false, 20*5, 0, false})
		
		-- Heart of Solace
		spells["Heartened"] = GetSpellInfo(91363)
		AddTrinket(select(1, GetItemInfo(55868)), {spells["Heartened"], false, 20*5, 0, false})	
		
		-- Crushing Weight
		spells["Race Against Death"] = GetSpellInfo(92342)
		AddTrinket(select(1, GetItemInfo(59506)), {spells["Race Against Death"], false, 15*5, 0, false})
		
		-- Symbiotic Worm
		spells["Turn of the Worm"] = GetSpellInfo(92235)
		AddTrinket(select(1, GetItemInfo(59332)), {spells["Turn of the Worm"], false, 30, 0, false})
		
		-- Bedrock Talisman
		spells["Tectonic Shift"] = GetSpellInfo(92233)
		AddTrinket(select(1, GetItemInfo(58182)), {spells["Tectonic Shift"], false, 30, 0, false})
		
		-- Porcelain Crab
		spells["Hardened Shell"] = GetSpellInfo(92174)
		AddTrinket(select(1, GetItemInfo(56280)), {spells["Hardened Shell"], false, 20*5, 0, false})
		
		-- Right Eye of Rajh
		spells["Eye of Doom"] = GetSpellInfo(91368)
		AddTrinket(select(1, GetItemInfo(56431)), {spells["Eye of Doom"], false, 10*5, 0, false})
		
		-- Rosary of Light
		spells["Rosary of Light"] = GetSpellInfo(102660)
		AddTrinket(select(1, GetItemInfo(72901)), {spells["Rosary of Light"], false, 20*5, 0, false})	
		
		-- Creche of the Final Dragon
		spells["Find Weakness"] = GetSpellInfo(109744)
		AddTrinket(select(1, GetItemInfo(77992)), {spells["Find Weakness"], false, 20*5, 0, false})
		
		-- Indomitable Pride
		spells["Indomitable"] = GetSpellInfo(109786)
		AddTrinket(select(1, GetItemInfo(78003)), {spells["Indomitable"], false, 60, 0, false})
		
		-- Soulshifter Vortex
		spells["Haste"] = GetSpellInfo(109777)
		AddTrinket(select(1, GetItemInfo(77990)), {spells["Haste"], false, 20*5, 0, false})
		
		-- Veil of Lies
		spells["Veil of Lies"] = GetSpellInfo(102666)
		AddTrinket(select(1, GetItemInfo(72900)), {spells["Veil of Lies"], false, 20*5, 0, false})
		
		--Spidersilk Spindle
		spells["Loom of Fate"] = GetSpellInfo(97130)
		AddTrinket(select(1, GetItemInfo(69138)), {spells["Loom of Fate"], false, 60, 0, false})
		
		--Master Pit Fighter
		spells["Master Pit Fighter"] = GetSpellInfo(109996)
		AddTrinket(select(1, GetItemInfo(74035)), {spells["Master Pit Fighter"], false, 20*5, 0, false})
      
		--Varo'then's Brooch
		spells["Varo'then's Brooch"] = GetSpellInfo(102664)
		AddTrinket(select(1, GetItemInfo(72899)), {spells["Varo'then's Brooch"], false, 20*5, 0, false})

		if debugg then print("CLCDK:Trinkets Loaded")end
		return loaded
	end
	
	--In: timeleft - seconds
	--Out: formated string of hours, minutes and seconds
	local function formatTime(timeleft)
		if timeleft > 3600 then
			return format("%dh:%dm", timeleft/3600, ((timeleft%3600)/60))
		elseif timeleft > 600 then 
			return format("%dm", timeleft/60)
		elseif timeleft > 60 then 
			return format("%d:%2.2d", timeleft/60, timeleft%60)
		end	
		return timeleft
	end		
	
	--In: start- when the spell cd started  dur- duration of the cd
	--Out: returns if the spell is or will be off cd in the next GCD
	local function isOffCD(start, dur)
		if (dur == nil) then dur = 0 end
		return (dur + start - curtime - GCD <= 0)
	end
	
	--In:tabl - table to check if key is in it  key- key you are looking for
	--Out: returns true if key is in table
	local function inTable(tabl, key)
		for i = 1, #tabl do
			if tabl[i] == key then return true end
		end
		return false
	end
	
	local resize = nil
	--Sets up required information for each element that can be moved
	function CLCDK:SetupMoveFunction(frame)
		frame.Drag = CreateFrame("Button", "ResizeGrip", frame) -- Grip Buttons from Omen2
		frame.Drag:SetFrameLevel(frame:GetFrameLevel() + 100)
		frame.Drag:SetNormalTexture("Interface\\AddOns\\CLC_DK\\ResizeGrip")
		frame.Drag:SetHighlightTexture("Interface\\AddOns\\CLC_DK\\ResizeGrip")
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
			if debugg then print("CLCDK:Mouse Down "..self:GetName())end
			CloseDropDownMenus()
		--	self.x1, self.y1 = select(4, self:GetPoint())
			self:StartMoving()
		--	self.x2, self.y2 = select(4, self:GetPoint())
		end)

		--When mouse released, save position
		frame:SetScript("OnMouseUp", function(self, button)			
			if debugg then print("CLCDK:Mouse Up "..self:GetName())end
		--	self.x3, self.y3 = select(4, self:GetPoint())
		--	print("Delta "..(self.x3-self.x2)+self.x1.." "..(self.y3-self.y2)+self.y1)
		--	CLCDK_Settings.Location[self:GetName()].X, CLCDK_Settings.Location[self:GetName()].Y = (self.x3-self.x2)+self.x1, (self.y3-self.y2)+self.y1
			self:StopMovingOrSizing()
			CLCDK_Settings.Location[self:GetName()].Point, CLCDK_Settings.Location[self:GetName()].Rel, CLCDK_Settings.Location[self:GetName()].RelPoint, CLCDK_Settings.Location[self:GetName()].X, CLCDK_Settings.Location[self:GetName()].Y = self:GetPoint()
		end)
	end

	--Icon template
	--In: name: the name of the icon frame   parent: the icons parent   spellname: the spell the icon will first display   size:height and width in pixels
	--Out: returns the icon create by parameters
	function CLCDK:CreateIcon(name, parent, spellname, size)
		frame = CreateFrame('Button', name, parent, BackdropTemplateMixin and "BackdropTemplate")
		frame:SetWidth(size)
		frame:SetHeight(size)
		frame:SetFrameStrata("BACKGROUND")
		frame.Spell = spellname
		frame.c = CreateFrame('Cooldown', nil, frame, BackdropTemplateMixin and "BackdropTemplate")
		frame.c:SetAllPoints(frame)
		frame.Icon = frame:CreateTexture("$parentIcon", "DIALOG")
		frame.Icon:SetAllPoints()
		frame.Icon:SetTexture(GetSpellTexture(spellname))
		frame.Time = frame:CreateFontString(nil, 'OVERLAY')
		frame.Time:SetPoint("CENTER",frame, 1, 0)
		frame.Time:SetJustifyH("CENTER")
		frame.Time:SetFont(font, 13, "OUTLINE")
		frame.Stack = frame:CreateFontString(nil, 'OVERLAY')
		frame.Stack:SetPoint("BOTTOMRIGHT",frame, 3, 1)
		frame.Stack:SetJustifyH("CENTER")
		frame.Stack:SetFont(font, 10, "OUTLINE")
		frame:EnableMouse(false)
		return frame
	end

	function CLCDK:CreateCDs()	
		CLCDK.CD = {}		
		
		--Create two frames in which 2 icons will placed in each
		for i = 1, 4 do  
			CLCDK.CD[i] = CreateFrame("Button", "CLCDK.CD"..i, CLCDK, BackdropTemplateMixin and "BackdropTemplate")
			CLCDK.CD[i]:SetWidth(34)
			CLCDK.CD[i]:SetHeight(68)
			CLCDK.CD[i]:SetFrameStrata("BACKGROUND")
			CLCDK.CD[i]:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = -1, right = -1, top = -1, bottom = -1},}
			CLCDK.CD[i]:SetBackdropColor(0, 0, 0, 0.5)	
			CLCDK:SetupMoveFunction(CLCDK.CD[i])
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
			CLCDK.CD[CDDisplayList[i]] = CLCDK:CreateIcon(CDDisplayList[i].."Butt", CLCDK, spells["Horn of Winter"], 32)	
			CLCDK.CD[CDDisplayList[i]].Time:SetFont(font, 11, "OUTLINE")
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
		if debugg then print("CLCDK:Cooldowns Created")end
	end
	
	function CLCDK:CreateUI()
	
		CLCDK:SetupMoveFunction(CLCDK)

		--Create Rune bar frame
		CLCDK.RuneBar = CreateFrame("Button", "CLCDK.RuneBar", CLCDK, BackdropTemplateMixin and "BackdropTemplate")
		CLCDK.RuneBar:SetHeight(23)
		CLCDK.RuneBar:SetWidth(94)	
		CLCDK.RuneBar:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
		CLCDK.RuneBar:SetBackdropColor(0, 0, 0, 0.5)	
		CLCDK.RuneBar.Text = CLCDK.RuneBar:CreateFontString(nil, 'OVERLAY')
		CLCDK.RuneBar.Text:SetPoint("TOP", CLCDK.RuneBar, "TOP", 0, -2)
		CLCDK.RuneBar.Text:SetJustifyH("CENTER")
		CLCDK.RuneBar.Text:SetFont(font, 18, "OUTLINE")		
		CLCDK:SetupMoveFunction(CLCDK.RuneBar)
		
		local function CreateRuneBar()
			frame = CreateFrame('StatusBar', nil, CLCDK.RuneBarHolder, BackdropTemplateMixin and "BackdropTemplate")
			frame:SetHeight(80)
			frame:SetWidth(8)
			frame:SetOrientation("VERTICAL")
			frame:SetStatusBarTexture('Interface\\Tooltips\\UI-Tooltip-Background', 'OVERLAY')			
			frame:SetStatusBarColor(1, 0.2, 0.2, 1)		
			frame:GetStatusBarTexture():SetBlendMode("DISABLE")
			frame:Raise()

			frame.back = frame:CreateTexture(nil, 'BACKGROUND', frame)
			frame.back:SetAllPoints(frame)
			frame.back:SetBlendMode("DISABLE")
			
			
			frame.Spark = frame:CreateTexture(nil, 'OVERLAY')
			frame.Spark:SetHeight(16)
			frame.Spark:SetWidth(16)
			frame.Spark.c = CreateFrame('Cooldown', nil, frame)
			frame.Spark.c:SetAllPoints(frame)
			frame.Spark.c.lock = false
			return frame
		end		
		CLCDK.RuneBarHolder = CreateFrame("Button", "CLCDK.RuneBarHolder", CLCDK, BackdropTemplateMixin and "BackdropTemplate")
		CLCDK.RuneBarHolder:SetHeight(100)
		CLCDK.RuneBarHolder:SetWidth(110)
		CLCDK.RuneBarHolder:SetFrameStrata("BACKGROUND")
		CLCDK.RuneBarHolder:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
		CLCDK.RuneBarHolder:SetBackdropColor(0, 0, 0, 0.5)
		
		--Create Runic Power frame
		CLCDK.RunicPower = CreateFrame("Button", "CLCDK.RunicPower", CLCDK, BackdropTemplateMixin and "BackdropTemplate")
		CLCDK.RunicPower:SetHeight(23)
		CLCDK.RunicPower:SetWidth(47)	
		CLCDK.RunicPower:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
		CLCDK.RunicPower:SetBackdropColor(0, 0, 0, 0.5)		
		CLCDK.RunicPower.Text = CLCDK.RunicPower:CreateFontString(nil, 'OVERLAY')
		CLCDK.RunicPower.Text:SetPoint("TOP", CLCDK.RunicPower, "TOP", 0, -2)
		CLCDK.RunicPower.Text:SetJustifyH("CENTER")
		CLCDK.RunicPower.Text:SetFont(font, 18, "OUTLINE")	
		CLCDK:SetupMoveFunction(CLCDK.RunicPower)
		
		--Create frome for Diseases with 2 icons for their respective disease
		CLCDK.Disease = CreateFrame("Button", "CLCDK.Disease", CLCDK, BackdropTemplateMixin and "BackdropTemplate")
		CLCDK.Disease:SetHeight(24)
		CLCDK.Disease:SetWidth(47)	
		CLCDK.Disease:SetFrameStrata("BACKGROUND")
		CLCDK.Disease:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
		CLCDK.Disease:SetBackdropColor(0, 0, 0, 0.5)		
		CLCDK.Disease.Text = CLCDK.Disease:CreateFontString(nil, 'OVERLAY')
		CLCDK.Disease.Text:SetPoint("TOP", CLCDK.Disease, "TOP", 0, -2)
		CLCDK.Disease.Text:SetJustifyH("CENTER")
		CLCDK.Disease.Text:SetFont(font, 18, "OUTLINE")	
		CLCDK:SetupMoveFunction(CLCDK.Disease)	
		
		--Create the Frame and Icon for the large main Priority Icon
		CLCDK.Move = CLCDK:CreateIcon('CLCDK.Move', CLCDK, spells["Death Coil"], 47)
		CLCDK.Move.Time:SetFont(font, 16, "OUTLINE")
		CLCDK.Move.Stack:SetFont(font, 15, "OUTLINE")
		CLCDK:SetupMoveFunction(CLCDK.Move)	
		
		--Create backdrop for move
		CLCDK.MoveBackdrop = CreateFrame('Frame', nil, CLCDK, BackdropTemplateMixin and "BackdropTemplate")
		CLCDK.MoveBackdrop:SetHeight(47)
		CLCDK.MoveBackdrop:SetWidth(47)
		CLCDK.MoveBackdrop:SetFrameStrata("BACKGROUND")
		CLCDK.MoveBackdrop:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
		CLCDK.MoveBackdrop:SetBackdropColor(0, 0, 0, 0.5)	
		CLCDK.MoveBackdrop:SetAllPoints(CLCDK.Move)		
		
		--Mini AOE icon to be placed in the Priority Icon
		CLCDK.Move.AOE = CLCDK:CreateIcon('CLCDK.AOE', CLCDK.Move, spells["Death Coil"], 18)
		CLCDK.Move.AOE:SetPoint("BOTTOMLEFT", CLCDK.Move, "BOTTOMLEFT", 2, 2)
		
		--Mini Interrupt icon to be placed in the Priority Icon
		CLCDK.Move.Interrupt = CLCDK:CreateIcon('CLCDK.Interrupt', CLCDK.Move, spells["Mind Freeze"], 18)
		CLCDK.Move.Interrupt:SetPoint("TOPRIGHT", CLCDK.Move, "TOPRIGHT", -2, -2)
		if debugg then print("CLCDK:UI Created")end
				
		CreateFrame( "GameTooltip", "BloodShieldTooltip", nil, "GameTooltipTemplate" );
		BloodShieldTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" );
		BloodShieldTooltip:AddFontStrings(
						BloodShieldTooltip:CreateFontString( "$parentTextLeft1", nil, "GameTooltipText" ),
						BloodShieldTooltip:CreateFontString( "$parentTextRight1", nil, "GameTooltipText" ))		
	end
	
	------Update Frames------	
	--In:location - name or location of the settings for specific CD   frame- frame in which to set the icon for
	--Out:: N/A (does not return but does set icon settings
	function CLCDK:UpdateCD(location, frame)
		--Reset Icon
		frame.Time:SetText("")
		frame.Stack:SetText("")		
		
		--If the option is not set to nothing
		if CLCDK_Settings.CD[Current_Spec][location] ~= nil and CLCDK_Settings.CD[Current_Spec][location][1] ~= nil and
			CLCDK_Settings.CD[Current_Spec][location][1] ~= CLCDK_OPTIONS_FRAME_VIEW_NONE then	
			frame:SetAlpha(1)
			frame.Icon:SetVertexColor(1, 1, 1, 1)			
			if CLCDK_Settings.CD[Current_Spec][location][1] == CLCDK_OPTIONS_CDR_CD_PRIORITY then --Priority
				--If targeting something that you can attack and is not dead
				if (UnitCanAttack("player", "target") and (not UnitIsDead("target"))) then
					--Get Icon from Priority Rotation
					frame.Icon:SetTexture(CLCDK:GetNextMove(frame.Icon))
				else
					frame.Icon:SetTexture(nil)
				end			
			elseif CLCDK_Settings.CD[Current_Spec][location][IS_BUFF] then --Buff/DeBuff			
				local icon, count, dur, expirationTime		
				if CLCDK_Settings.CD[Current_Spec][location][1] == spells["Dark Simulacrum"] then
					local id
					if (curtime - simtime) >= 5 then
						simtime = curtime
						for i = 1, 120 do
							_, id = GetActionInfo(i)
							if id == 77606 then	darksim[1] = i;	darksim[2] = 0;	if debugg then print("CLCDK:Dark Simulacrum Action Slot "..i)end; break; end
						end
					end
					_, id = GetActionInfo(darksim[1])
					if id ~= nil and id ~= 77606 then
						if CLCDK_Settings.Range and IsSpellInRange(GetSpellInfo(id), "target") == 0 then frame.Icon:SetVertexColor(0.8, 0.05, 0.05, 1) end							
						frame.Icon:SetTexture(GetSpellTexture(id))
						if darksim[2] == 0 or darksim[2] < curtime then	darksim[2] = curtime + 20 end	
						frame.Time:SetText(floor(darksim[2] - curtime))							
						return							
					end
				end
				
				--if its on a target then its a debuff, otherwise its a buff
				if Cooldowns.Buffs[CLCDK_Settings.CD[Current_Spec][location][1]][1] == "target" then
					_, icon, count, _, dur, expirationTime = CLCDK:FindTargetDebuff(CLCDK_Settings.CD[Current_Spec][location][1])
					--print(CLCDK_Settings.CD[Current_Spec][location][1])
					--print(CLCDK:FindTargetDebuff(CLCDK_Settings.CD[Current_Spec][location][1]))
				else
					_, icon, count, _, dur, expirationTime = AuraUtil.FindAuraByName(CLCDK_Settings.CD[Current_Spec][location][1], Cooldowns.Buffs[CLCDK_Settings.CD[Current_Spec][location][1]][1])
				end	
				frame.Icon:SetTexture(icon)
				
				--If not an aura, set time
				if icon ~= nil and ceil(expirationTime - curtime) > 0 then				
					frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
					frame.Time:SetText(formatTime(ceil(expirationTime - curtime)))
					if CLCDK_Settings.CD[Current_Spec][location][1] == spells["Blood Shield"] then count = bsamount end
					if count > 1 then frame.Stack:SetText(count) end	
				end
				
				
				
			elseif inTable(Cooldowns.Moves, CLCDK_Settings.CD[Current_Spec][location][1]) then --Move
				icon = GetSpellTexture(CLCDK_Settings.CD[Current_Spec][location][1])
				if icon ~= nil then
					--Check if move is off CD
					start, dur =  GetSpellCooldown(CLCDK_Settings.CD[Current_Spec][location][1])
					if isOffCD(start, dur) and IsUsableSpell(CLCDK_Settings.CD[Current_Spec][location][1]) then
						icon = CLCDK:GetRangeandIcon(frame.Icon, CLCDK_Settings.CD[Current_Spec][location][1])
					else
						icon = nil
					end	
				end		
				frame.Icon:SetTexture(icon)
			elseif CLCDK_Settings.CD[Current_Spec][location][1] == CLCDK_OPTIONS_CDR_CD_TRINKETS_SLOT1 or
				CLCDK_Settings.CD[Current_Spec][location][1] == CLCDK_OPTIONS_CDR_CD_TRINKETS_SLOT2 then --Trinkets
				
				local id
				if CLCDK_Settings.CD[Current_Spec][location][1] == CLCDK_OPTIONS_CDR_CD_TRINKETS_SLOT1 then
					id = GetInventoryItemID("player", 13)
				else
					id = GetInventoryItemID("player", 14)
				end
				local trink
				if id ~= nil then
					trink = Cooldowns.Trinkets[select(1,GetItemInfo(id))]
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
						frame.Icon:SetTexture(icon)
						frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
						frame.Time:SetText(formatTime(ceil(expirationTime - curtime)))
						if count > 1 then frame.Stack:SetText(count) end	
						if (not altbuff) and (not trink[5]) then trink[5] = true; trink[4] = curtime end					
						
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
						t = ceil(start + dur - curtime)
						if t > 0 and active == 1 and dur > 7 then
							frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
							if CLCDK_Settings.CDS then frame.c:SetCooldown(start, dur) end	
							frame.Time:SetText(formatTime(t))
						end
					end
				else
					frame.Icon:SetTexture(nil)
				end
			elseif  CLCDK_Settings.CD[Current_Spec][location][1] == CLCDK_OPTIONS_CDR_RACIAL then
				icon = CLCDK:GetRangeandIcon(frame.Icon, spells[PLAYER_RACE])
				frame.Icon:SetTexture(icon)
				if icon ~= nil then
					start, dur, active =  GetSpellCooldown(spells[PLAYER_RACE])
					t = ceil(start + dur - curtime)
					if active == 1 and dur > 7 then
						frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
						if CLCDK_Settings.CDS then frame.c:SetCooldown(start, dur) end	
						frame.Time:SetText(formatTime(t))
					end	
				end				
				
			else --Cooldown				
				icon = CLCDK:GetRangeandIcon(frame.Icon, CLCDK_Settings.CD[Current_Spec][location][1])
				frame.Icon:SetTexture(icon)
				if icon ~= nil then
					start, dur, active =  GetSpellCooldown(CLCDK_Settings.CD[Current_Spec][location][1])
					t = ceil(start + dur - curtime)
					if active == 1 and dur > 7 then
						frame.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
						if CLCDK_Settings.CDS then frame.c:SetCooldown(start, dur) end	
						frame.Time:SetText(formatTime(t))
					end	
				end				
			end
			--if the icon is nil, then just hide the frame
			if frame.Icon:GetTexture() == nil then
				frame:SetAlpha(0)
			end
		else	
			CLCDK_Settings.CD[Current_Spec][location][1] = CLCDK_OPTIONS_FRAME_VIEW_NONE
			frame:SetAlpha(0)
		end	
	end
	
	--Used to move individual frames where they are suppose to be displayed, also enables and disables mouse depending on settings
	function CLCDK:MoveFrame(self)
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
	function CLCDK:UpdatePosition()
		CLCDK:MoveFrame(CLCDK)
		CLCDK:MoveFrame(CLCDK.CD[1])
		CLCDK:MoveFrame(CLCDK.CD[2])
		CLCDK:MoveFrame(CLCDK.CD[3])
		CLCDK:MoveFrame(CLCDK.CD[4])
		CLCDK:MoveFrame(CLCDK.RuneBar)
		CLCDK:MoveFrame(CLCDK.RunicPower)
		CLCDK:MoveFrame(CLCDK.Move)
		CLCDK.MoveBackdrop:SetBackdropColor(0, 0, 0, CLCDK_Settings.Trans)
		CLCDK:MoveFrame(CLCDK.Disease)	
		
		CLCDK:SetScale(CLCDK_Settings.Scale)
		if debugg then print("CLCDK:UpdatePosition")end
	end

	--Main function for updating all information
	function CLCDK:UpdateUI()	
		if (UnitCanAttack("player", "target") and (not UnitIsDead("target"))) then
			CLCDK:SetAlpha(CLCDK_Settings.NormTrans)			
		else
			CLCDK:SetAlpha(CLCDK_Settings.CombatTrans)
		end
		
		--GCD		
		local start, dur = GetSpellCooldown(spells["Death Coil"])
		if dur ~= 0 and start ~= nil then 
			GCD =  dur - (curtime - start) + 0.1
			if CLCDK_Settings.GCD then			
				CLCDK.Move.c:SetCooldown(start, dur)			
			end				
		else 
			GCD = 0
		end	

		--Runes
		CLCDK.RuneBar:SetAlpha((CLCDK_Settings.Rune and 1) or 0)
		if CLCDK_Settings.Rune then
			local RuneBar = ""
			local place = 1
			for i = 1, 6 do	
				local start, cooldown = GetRuneCooldown(i)
				local cdtime = start + cooldown - curtime
				
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
			if UnitCanAttack("player", "target") and (not UnitIsDead("target")) and (Current_Spec ~= SPEC_UNKNOWN) then							
				local expires = select(6, AuraUtil.FindAuraByName(CLCDK:GetSpecDisease(), "TARGET", "PLAYER"))
				if  expires ~= nil and (expires - curtime) > 0 then
					diseaseTime = expires - curtime
				end				
			end	
			
			CLCDK.Disease.Text:SetText(string.format("|cff54BD47%.2d|r", diseaseTime))
		else
			CLCDK.Disease:SetAlpha(0)				
		end
		
		--Priority Icon
		CLCDK.Move.AOE:SetAlpha(0)
		CLCDK.Move.Interrupt:SetAlpha(0)
		if CLCDK_Settings.CD[Current_Spec]["CLCDK_CDRPanel_DD_Priority"][1] ~= CLCDK_OPTIONS_FRAME_VIEW_NONE then
			CLCDK.Move:SetAlpha(1)
			CLCDK.MoveBackdrop:SetAlpha(1)
			CLCDK:UpdateCD("CLCDK_CDRPanel_DD_Priority", CLCDK.Move)	
		else
			CLCDK.Move:SetAlpha(0)
			CLCDK.MoveBackdrop:SetAlpha(0)
		end	
		
		--CDs		
		for i = 1, #CDDisplayList do
			if CLCDK_Settings.CD[Current_Spec][ceil(i/2)] then
				CLCDK.CD[ceil(i/2)]:SetAlpha(1)	
				CLCDK:UpdateCD(CDDisplayList[i], CLCDK.CD[CDDisplayList[i]])			
			else
				CLCDK.CD[ceil(i/2)]:SetAlpha(0)	
			end
		end
		
		--GCD
		if CLCDK_Settings.GCD then
			local start, dur = GetSpellCooldown(spells["Death Coil"])
			if dur ~= 0 and start ~= nil then			
				CLCDK.Move.c:SetCooldown(start, dur)		
			end
		end
		
		local temp		
		for i = 1, 40 do
			if select(1, UnitBuff("player", i)) ~= nil then
				if UnitBuff("player", i) == spells["Blood Shield"] then
					BloodShieldTooltip:SetUnitBuff("player", i)
					temp = string.gsub(_G["BloodShieldTooltipTextLeft"..2]:GetText(), "[^%d]", "")	
					
					temp = tonumber(temp)
					if temp ~= nil and type(temp) == "number" then
						bsamount = temp
					end
				end				
				--print(select(1, UnitBuff("player", i)).." "..select(11, UnitBuff("player", i)))
			end
		end
	end
	
	function CLCDK:FindPlayerBuff(spellName)
		for i=1,40 do
			local name, icon, count, debuffType, duration, expirationTime = UnitBuff("PLAYER", i);
			if (name == spellName) then
				return name, icon, count, debuffType, duration, expirationTime
			end
		end
	end
	
	function CLCDK:FindTargetDebuff(spellName)
		for i=1,40 do
			local name, icon, count, debuffType, duration, expirationTime = UnitDebuff("TARGET", i);
			if (name == spellName) then
				return name, icon, count, debuffType, duration, expirationTime
			end
		end
	end
	
	do --Priority System
		--Called to update a priority icon with next move
		function CLCDK:GetNextMove(icon)	
			--Call correct function based on spec
			if (Current_Spec == SPEC_UNHOLY) then
				return CLCDK:UnholyMove(icon)
			elseif (Current_Spec == SPEC_FROST) then
				return CLCDK:FrostMove(icon)
			elseif (Current_Spec == SPEC_BLOOD) then
				return CLCDK:BloodMove(icon)
			else
				return CLCDK:BlankMove(icon)
			end
		end

		--Determines if player is in range with spell and sets colour and icon accordingly
		--In: icon: icon in which to change the vertex colour of   move: spellID of spell to be cast next
		--Out: returns the texture of the icon (probably unessesary since icon is now being passed in, will look into it more)
		function CLCDK:GetRangeandIcon(icon, move)
			if move ~= nil then
				if CLCDK_Settings.Range and IsSpellInRange(move, "target") == 0 then
					icon:SetVertexColor(0.8, 0.05, 0.05, 1) 
				else
					icon:SetVertexColor(1, 1, 1, 1)
				end
				return GetSpellTexture(move)
			end
			return nil
		end

		--Gives CD of rune type specified
		--Out:  time1: the lowest cd of the 2 runes being queried  time2: the higher of the cds  RT1: returns true if lowest cd rune is a death rune, RT2: same as RT2 except higher CD rune
		function CLCDK:RuneCDs()
			local numCool = 0
			for i = 1, 6 do	
				local start, dur, cool = GetRuneCooldown(i)	
				local tempTime = (dur - (curtime - start + GCD))	
				if (cool or tempTime < 0) then
					numCool = numCool + 1
				end
			end
			return numCool;
		end		
		
		function CLCDK:GetSpecDisease() 
			if (Current_Spec == SPEC_UNHOLY) then
				return spells["Virulent Plague"]
			elseif (Current_Spec == SPEC_FROST) then
				return spells["Frost Fever"]
			elseif (Current_Spec == SPEC_BLOOD) then
				return spells["Blood Plague"]
			end
		end

		--Determines if Dieseases need to be refreshed or applied
		function CLCDK:GetDisease(icon)		
			local expires = select(6, AuraUtil.FindAuraByName(CLCDK:GetSpecDisease(), "TARGET", "PLAYER"))
			if  expires ~= nil then	expires = expires - curtime end	
			return (expires == nil or expires < 2)
		end

		--Function to determine rotation for Unholy Spec
		function CLCDK:UnholyMove(icon)			
			--[[			
				Virulent Plague (Maintain on target [refresh using Outbreak])
				Cast Dark Transformation Icon Dark Transformation off cooldown.
				Cast Apocalypse Icon Apocalypse when you have 4 stacks of Festering Wound Icon Festering Wounds
				Death Coil (With Sudden Doom procs or when >80 Runic Power)
				Clawing Shadows (If talented) or Scourge Strike (When 1 or more Festering Wound)
				Festering Strike
				Death Coil
			]]--
			--Rune Info
			local numRunes = CLCDK:RuneCDs()
			local runicPower = UnitPower("player");

			-- Virulent Plague maintained at all times via Outbreak.		
			local disease = CLCDK:GetDisease(icon)	
			if disease and numRunes >= 1 then 
				return CLCDK:GetRangeandIcon(icon, spells["Outbreak"]) 
			end	
			
			-- Dark Transformation		
			if (isOffCD (GetSpellCooldown(spells["Dark Transformation"]))) then
				return CLCDK:GetRangeandIcon(icon, spells["Dark Transformation"])
			end
			
			-- Death Coil with Sudden Doom procs.
			if (AuraUtil.FindAuraByName(spells["Sudden Doom"], "PLAYER") ~= nil or runicPower >= 80) then
				return CLCDK:GetRangeandIcon(icon, spells["Death Coil"])
			end	
			
			local numFestWounds = select(3, CLCDK:FindTargetDebuff(spells["Festering Wound"]))
			if numFestWounds == nil then numFestWounds = 0 end
			
			--Apocalypse
			if (numFestWounds >= 4 and isOffCD(GetSpellCooldown(spells["Apocalypse"]))) then						
				return CLCDK:GetRangeandIcon(icon, spells["Apocalypse"])				
			end
			
			--Scourge Strike
			if (numRunes >= 1 and numFestWounds >= 1) then		
				return CLCDK:GetRangeandIcon(icon, spells["Scourge Strike"])				
			end		
			
			--Festering Strike if not enough festering wounds
			if (numRunes >= 2) then						
				return CLCDK:GetRangeandIcon(icon, spells["Festering Strike"])				
			end			
			
			-- Death Coil
			if (UnitPower("player") >= 40) then
				return CLCDK:GetRangeandIcon(icon, spells["Death Coil"])
			end	

			-- If nothing else can be done
			return nil				
		end
		
		function CLCDK:FrostMove(icon)
			--[[			
			Use Icon Sindragosa's Fury (with Pillar of Frost Icon Pillar of Frost, the proc from Rune of the Fallen Crusader Icon Rune of the Fallen Crusader, and 5 stacks of Razorice).
			Use Remorseless Winter Icon Remorseless Winter on cooldown (for Gathering Storm Icon Gathering Storm).
			Use Howling Blast Icon Howling Blast, only if you have a Rime Icon Rime proc.
			Use Obliterate Icon Obliterate to avoid capping runes, or if you have a Killing Machine Icon Killing Machine proc.
			Use Frost Strike Icon Frost Strike when you are about to cap Runic Power.
			Use Obliterate Icon Obliterate.
			Use Frost Strike Icon Frost Strike.			
			]]
				
			--Rune Info
			local numRunes = CLCDK:RuneCDs()
						
			if (UnitBuff("PLAYER",spells["Pillar of Frost"]) ~= nil and
				UnitBuff("PLAYER",spells["Unholy Strength"]) ~= nil	and		
				UnitBuff("PLAYER",spells["Razorice"]) ~= nil and
				select(4, UnitBuff("PLAYER",spells["Razorice"])) == 5) then
				return CLCDK:GetRangeandIcon(icon, spells["Sindragosa's Fury"])
			end				
			
			if (numRunes >= 1 and isOffCD(GetSpellCooldown(spells["Remorseless Winter"]))) then						
				return CLCDK:GetRangeandIcon(icon, spells["Remorseless Winter"])				
			end			
			
			if (UnitBuff("PLAYER", spells["Rime"]) ~= nil) then
				return CLCDK:GetRangeandIcon(icon, spells["Howling Blast"])
			end	
			
			if (UnitBuff("PLAYER",spells["Killing Machine"]) ~= nil or numRunes > 4) then
				return CLCDK:GetRangeandIcon(icon, spells["Obliterate"])
			end	
			
			if (UnitPower("player") >= 80) then
				return CLCDK:GetRangeandIcon(icon, spells["Frost Strike"])
			end	
			
			if (numRunes >= 2) then
				return CLCDK:GetRangeandIcon(icon, spells["Obliterate"])
			end	
			
			if (UnitPower("player") >= 25) then
				return CLCDK:GetRangeandIcon(icon, spells["Frost Strike"])
			end	
		
			return nil				
		end
		
		function CLCDK:BloodMove(icon)
			--[[
			Before engaging anything, use Rune Tap Icon Rune Tap a second before you get meleed for the first time.
			Use Marrowrend Icon Marrowrend if your Bone Shield Icon Bone Shield is about to expire.
			Use Death Strike Icon Death Strike if your health is low, or to avoid capping Runic Power.
			Use Blooddrinker Icon Blooddrinker.
			Use Blood Boil Icon Blood Boil if any nearby enemies do not have your Blood Plague Icon Blood Plague disease, or you have 2 charges of Blood Boil.
			Use Marrowrend Icon Marrowrend if you have 6 or fewer stacks of Bone Shield Icon Bone Shield.
			Use Death and Decay Icon Death and Decay if you are fighting 3 or more enemies.
			Use Heart Strike Icon Heart Strike if you have 3 or more Runes.
			Use Blood Boil Icon Blood Boil.
			]]--
			
			--Rune Info
			local numRunes = CLCDK:RuneCDs()
			local runicPower = UnitPower("player");
			
			
			-- Death Coil with Sudden Doom procs.
			local name, icon, count, debuffType, duration, expirationTime = CLCDK:FindPlayerBuff(spells["Bone Shield"])
			if ((duration == nil or duration < 3) and numRunes >= 2) then
				--return CLCDK:GetRangeandIcon(icon, spells["Marrowrend"])
			end	
			
			return nil			
		end	

		function CLCDK:BlankMove(icon)	
			local numRunes = CLCDK:RuneCDs()					
			
			if (UnitPower("player") >= 90) then
				return CLCDK:GetRangeandIcon(icon, spells["Death Coil"])
			end	
			
			if (numRunes >= 1) then
				return CLCDK:GetRangeandIcon(icon, spells["Rune Strike"])
			end		
			
			if (UnitPower("player") >= 40) then
				return CLCDK:GetRangeandIcon(icon, spells["Death Coil"])
			end				
		end			
	end
	
	--Function to check spec and gylphs and adjust settings accordingly
	function CLCDK:CheckSpec()
		--Set all settings to default
		Current_Spec = GetSpecialization()
				
		if debugg then print("CLCDK:Check Spec - "..Current_Spec)end
		CLCDK:OptionsRefresh()
	end
	
	function CLCDK:Initialize()
		if debugg then print("CLCDK:Initialize")end			
		mutex = true
		
		CLCDK:LoadSpells()
		CLCDK:LoadCooldowns()
		if not CLCDK:LoadTrinkets() and (curtime - launchtime < ITEM_LOAD_THRESHOLD)then if debugg then print("CLCDK:Initialize Failed")end; mutex = false; return; end	
		if debugg and (curtime - launchtime >= ITEM_LOAD_THRESHOLD) then print("CLCDK:Launch Threshold Met") end		
			
		--CLCDK:SetDefaults()
		--Check Settings
		
		CLCDK:CheckSettings()
		if debugg then print("CLCDK:Initialize - Version "..CLCDK_Settings.Version)end
				
		CLCDK:SetAlpha(0)
		CLCDK:CreateCDs()
		CLCDK:CreateUI()				
		
		InterfaceOptions_AddCategory(CLCDK_Options)
		InterfaceOptions_AddCategory(CLCDK_FramePanel)
		InterfaceOptions_AddCategory(CLCDK_CDPanel)
		InterfaceOptions_AddCategory(CLCDK_ABOUTPanel)
		
		--Initalize all dropdowns
		UIDropDownMenu_Initialize(CLCDK_CDRPanel_DD_Priority, CLCDK_CDRPanel_DD_OnLoad)
		for i = 1, #CDDisplayList do  
			UIDropDownMenu_Initialize(_G[CDDisplayList[i]], CLCDK_CDRPanel_DD_OnLoad)		end
		UIDropDownMenu_Initialize(CLCDK_FramePanel_ViewDD, CLCDK_FramePanel_ViewDD_OnLoad)	
		if debugg then print("CLCDK:Initialize - Dropdowns Done")end
		
		CLCDK:CheckSpec()			
		
		mutex = nil
		loaded = true
		
		collectgarbage()
	end
	
	if debugg then print("CLCDK:Functions Done")end
	
	-----Events-----
	--Register Events
	CLCDK:RegisterEvent("PLAYER_TALENT_UPDATE")
	CLCDK:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	
	--Function to be called when events triggered
	local slottimer = 0
	CLCDK:SetScript("OnEvent", function(_, e, ...)
		if loaded then
			CLCDK:CheckSpec()			
			maxPower = UnitPowerMax("Player")
		end
	end)	
		
	--Main function to run addon
	local DTupdatetimer = 0
	local DTchecktimer = 0
	CLCDK:SetScript("OnUpdate", function() 
		curtime = GetTime()    	
		--Make sure it only updates at max, once every 0.15 sec
		if (curtime - updatetimer >= 0.08) then	
			updatetimer = curtime
			
			if (not loaded) and (not mutex) then 
				if launchtime == 0 then launchtime = curtime;if debugg then print("CLCDK:Launchtime Set")end end
				CLCDK:Initialize()		
			elseif loaded then
				--Check if visibility conditions are met, if so update the information in the addon
				if (not UnitHasVehicleUI("player")) and 
						((InCombatLockdown() and CLCDK_Settings.VScheme == CLCDK_OPTIONS_FRAME_VIEW_NORM) or 
						(CLCDK_Settings.VScheme == CLCDK_OPTIONS_FRAME_VIEW_SHOW) or 
						(not CLCDK_Settings.Locked) or 
						(CLCDK_Settings.VScheme ~= CLCDK_OPTIONS_FRAME_VIEW_HIDE and UnitCanAttack("player", "target") and (not UnitIsDead("target")))) then	
					CLCDK:UpdateUI()
					if CLCDK_Settings.Locked then
						if IsAltKeyDown() then CLCDK:EnableMouse(true) 
						else CLCDK:EnableMouse(false) end
					end
					
				else	
					CLCDK:SetAlpha(0)				
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
	
	-----Options-----
	--Setup slash command
	SLASH_CLCDK1 = '/clcdk'
	SlashCmdList["CLCDK"] = function() 
		InterfaceOptionsFrame_OpenToCategory(CLCDK_FramePanel)
		if debugg then print("CLCDK:Slash Command Used")end
	end
	
	--Update the Blizzard interface Options with settings
	function CLCDK:OptionsRefresh()
		if CLCDK_Settings ~= nil and CLCDK_Settings.Version ~= nil and CLCDK_Settings.Version == CLCDK_VERSION then	
			--Frame
			CLCDK_FramePanel_GCD:SetChecked(CLCDK_Settings.GCD)
			CLCDK_FramePanel_CDS:SetChecked(CLCDK_Settings.CDS)
			CLCDK_FramePanel_Range:SetChecked(CLCDK_Settings.Range)			
			CLCDK_FramePanel_Rune:SetChecked(CLCDK_Settings.Rune)
			CLCDK_FramePanel_RP:SetChecked(CLCDK_Settings.RP)		
			CLCDK_FramePanel_Disease:SetChecked(CLCDK_Settings.Disease)		
			CLCDK_FramePanel_Locked:SetChecked(CLCDK_Settings.Locked)
			CLCDK_FramePanel_LockedPieces:SetChecked(CLCDK_Settings.LockedPieces)
			CLCDK_FramePanel_Scale:SetNumber(CLCDK_Settings.Scale)
			CLCDK_FramePanel_Scale:SetCursorPosition(0)	
			CLCDK_FramePanel_Trans:SetNumber(CLCDK_Settings.Trans)
			CLCDK_FramePanel_Trans:SetCursorPosition(0)	
			CLCDK_FramePanel_CombatTrans:SetNumber(CLCDK_Settings.CombatTrans)
			CLCDK_FramePanel_CombatTrans:SetCursorPosition(0)	
			CLCDK_FramePanel_NormalTrans:SetNumber(CLCDK_Settings.NormTrans)
			CLCDK_FramePanel_NormalTrans:SetCursorPosition(0)				
			
			--View Dropdown
			UIDropDownMenu_SetSelectedValue(CLCDK_FramePanel_ViewDD, CLCDK_Settings.VScheme)	
			UIDropDownMenu_SetText(CLCDK_FramePanel_ViewDD, CLCDK_Settings.VScheme)	
									
			CLCDK_CDRPanel_DD_CD1:SetChecked(CLCDK_Settings.CD[Current_Spec][1])	
			CLCDK_CDRPanel_DD_CD2:SetChecked(CLCDK_Settings.CD[Current_Spec][2])
			CLCDK_CDRPanel_DD_CD3:SetChecked(CLCDK_Settings.CD[Current_Spec][3])	
			CLCDK_CDRPanel_DD_CD4:SetChecked(CLCDK_Settings.CD[Current_Spec][4])			

			--Priority Dropdown
			if CLCDK_Settings.CD[Current_Spec]["CLCDK_CDRPanel_DD_Priority"] ~= nil and CLCDK_Settings.CD[Current_Spec]["CLCDK_CDRPanel_DD_Priority"][1] ~= nil then
				UIDropDownMenu_SetSelectedValue(CLCDK_CDRPanel_DD_Priority, CLCDK_Settings.CD[Current_Spec]["CLCDK_CDRPanel_DD_Priority"][1]..((CLCDK_Settings.CD[Current_Spec]["CLCDK_CDRPanel_DD_Priority"][IS_BUFF] and " (Buff)") or ""))	
				UIDropDownMenu_SetText(CLCDK_CDRPanel_DD_Priority, CLCDK_Settings.CD[Current_Spec]["CLCDK_CDRPanel_DD_Priority"][1]..((CLCDK_Settings.CD[Current_Spec]["CLCDK_CDRPanel_DD_Priority"][IS_BUFF] and " (Buff)") or ""))				
			end
			
			--Cooldown Dropdown
			for i = 1, #CDDisplayList do
				if _G[CDDisplayList[i]] ~= nil and CLCDK_Settings.CD[Current_Spec][CDDisplayList[i]] ~= nil and CLCDK_Settings.CD[Current_Spec][CDDisplayList[i]][1] ~= nil then
					UIDropDownMenu_SetSelectedValue(_G[CDDisplayList[i]], CLCDK_Settings.CD[Current_Spec][CDDisplayList[i]][1]..((CLCDK_Settings.CD[Current_Spec][CDDisplayList[i]][IS_BUFF] and " (Buff)") or ""))
					UIDropDownMenu_SetText(_G[CDDisplayList[i]], CLCDK_Settings.CD[Current_Spec][CDDisplayList[i]][1]..((CLCDK_Settings.CD[Current_Spec][CDDisplayList[i]][IS_BUFF] and " (Buff)") or ""))
				end
			end
			
			--About Options
			local expText = "<html><body>"
					.."<p>"..CLCDK_ABOUT_BODY.."</p>"
					.."<p><br/>"
					.."|cffaaaaaa"..CLCDK_ABOUT_GER.."<br/>"
					.."|cffaaaaaa"..CLCDK_ABOUT_BR.."<br/>"
					.."|cffaaaaaa"..CLCDK_ABOUT_CT.."<br/>"
					.."</p>"
					.."</body></html>";
			CLCDK_ABOUTHTML:SetText (expText);
			CLCDK_ABOUTHTML:SetSpacing (2);
			
			if debugg then print("CLCDK:OptionsRefresh")end
			CLCDK:UpdatePosition()				
		else
			if debugg then print("CLCDK:ERROR OptionsRefresh - "..(CLCDK_Settings == nil and "Settings are nil") or (CLCDK_Settings.Version == nil and "Version is nil") or ("Invalid Version"..CLCDK_Settings.Version ))end
		end
	end
	
	--Check if options are valid and save them to settings if so
	function CLCDK:OptionsOkay()
		if CLCDK_Settings ~= nil and (CLCDK_Settings.Version ~= nil and CLCDK_Settings.Version == CLCDK_VERSION) then
			--Frame
			CLCDK_Settings.GCD = CLCDK_FramePanel_GCD:GetChecked()
			CLCDK_Settings.CDS = CLCDK_FramePanel_CDS:GetChecked()
			CLCDK_Settings.Range = CLCDK_FramePanel_Range:GetChecked()
			CLCDK_Settings.Rune = CLCDK_FramePanel_Rune:GetChecked()
			CLCDK_Settings.RP = CLCDK_FramePanel_RP:GetChecked()
			CLCDK_Settings.Disease = CLCDK_FramePanel_Disease:GetChecked()
			CLCDK_Settings.Locked = CLCDK_FramePanel_Locked:GetChecked()
			CLCDK_Settings.LockedPieces = CLCDK_FramePanel_LockedPieces:GetChecked()	
						
			--Scale
			if CLCDK_FramePanel_Scale:GetNumber() >= 0.5 and CLCDK_FramePanel_Scale:GetNumber() <= 5 then
				CLCDK_Settings.Scale = CLCDK_FramePanel_Scale:GetNumber()
			else
				CLCDK_FramePanel_Scale:SetNumber(CLCDK_Settings.Scale)
			end
			
			--Transparency
			if CLCDK_FramePanel_Trans:GetNumber() >= 0 and CLCDK_FramePanel_Trans:GetNumber() <= 1 then
				CLCDK_Settings.Trans = CLCDK_FramePanel_Trans:GetNumber()
			else
				CLCDK_FramePanel_Trans:SetNumber(CLCDK_Settings.Trans)
			end
			if CLCDK_FramePanel_CombatTrans:GetNumber() >= 0 and CLCDK_FramePanel_CombatTrans:GetNumber() <= 1 then
				CLCDK_Settings.CombatTrans = CLCDK_FramePanel_CombatTrans:GetNumber()
			else
				CLCDK_FramePanel_CombatTrans:SetNumber(CLCDK_Settings.CombatTrans)
			end
			if CLCDK_FramePanel_NormalTrans:GetNumber() >= 0 and CLCDK_FramePanel_NormalTrans:GetNumber() <= 1 then
				CLCDK_Settings.NormTrans = CLCDK_FramePanel_NormalTrans:GetNumber()
			else
				CLCDK_FramePanel_NormalTrans:SetNumber(CLCDK_Settings.NormTrans)
			end			

			--CD/R
			CLCDK_Settings.CD[Current_Spec][1] = (CLCDK_CDRPanel_DD_CD1:GetChecked())
			CLCDK_Settings.CD[Current_Spec][2] = (CLCDK_CDRPanel_DD_CD2:GetChecked())
			CLCDK_Settings.CD[Current_Spec][3] = (CLCDK_CDRPanel_DD_CD3:GetChecked())
			CLCDK_Settings.CD[Current_Spec][4] = (CLCDK_CDRPanel_DD_CD4:GetChecked())
				
			
			if debugg then print("CLCDK:OptionsOkay")end
			CLCDK:OptionsRefresh()			
		else
			if debugg then print("CLCDK:ERROR OptionsOkay - "..(CLCDK_Settings == nil and "Settings are nil") or (CLCDK_Settings.Version == nil and "Version is nil") or ("Invalid Version"..CLCDK_Settings.Version))end	
		end
	end
	
	--Cooldown Defaults
	function CLCDK:CooldownDefaults()
		if CLCDK_Settings.CD ~= nil then wipe(CLCDK_Settings.CD) end
		CLCDK_Settings.CD = {			
			[SPEC_UNHOLY] = {
				["CLCDK_CDRPanel_DD_Priority"] = {CLCDK_OPTIONS_CDR_CD_PRIORITY, nil},
				Outbreak = true,
				Horn = true,
				RP = true,
				SpecOption = true,
			
				[1] = true,
				["CLCDK_CDRPanel_DD_CD1_One"] = {spells["Shadow Infusion"], true},
				["CLCDK_CDRPanel_DD_CD1_Two"] = {spells["Dark Transformation"], true},				
				
				[2] = true,
				["CLCDK_CDRPanel_DD_CD2_One"] = {spells["Runic Corruption"], true},
				["CLCDK_CDRPanel_DD_CD2_Two"] = {spells["Sudden Doom"], true},
				
				[3] = false,
				["CLCDK_CDRPanel_DD_CD3_One"] = {spells["Horn of Winter"], true},
				["CLCDK_CDRPanel_DD_CD3_Two"] = {spells["Festering Wound"], true},
				
				[4] = false,
				["CLCDK_CDRPanel_DD_CD4_One"] = {CLCDK_OPTIONS_CDR_CD_TRINKETS_SLOT1, nil},
				["CLCDK_CDRPanel_DD_CD4_Two"] = {CLCDK_OPTIONS_CDR_CD_TRINKETS_SLOT2, nil},
			},
			
			[SPEC_FROST] = {
				["CLCDK_CDRPanel_DD_Priority"] = {CLCDK_OPTIONS_CDR_CD_PRIORITY, nil},
				Outbreak = false,
				Horn = true,
				RP = true,
				SpecOption = true,
			
				[1] = true,
				["CLCDK_CDRPanel_DD_CD1_One"] = {spells["Pillar of Frost"], nil},
				["CLCDK_CDRPanel_DD_CD1_Two"] = {spells["Pillar of Frost"], true},				
				
				[2] = true,
				["CLCDK_CDRPanel_DD_CD2_One"] = {spells["Killing Machine"], true},
				["CLCDK_CDRPanel_DD_CD2_Two"] = {spells["Freezing Fog"], true},
				
				[3] = false,
				["CLCDK_CDRPanel_DD_CD3_One"] = {spells["Horn of Winter"], true},
				["CLCDK_CDRPanel_DD_CD3_Two"] = {spells["Blood Charge"], true},
				
				[4] = false,
				["CLCDK_CDRPanel_DD_CD4_One"] = {CLCDK_OPTIONS_CDR_CD_TRINKETS_SLOT1, nil},
				["CLCDK_CDRPanel_DD_CD4_Two"] = {CLCDK_OPTIONS_CDR_CD_TRINKETS_SLOT2, nil},
			},
			
			[SPEC_BLOOD] = {
				["CLCDK_CDRPanel_DD_Priority"] = {CLCDK_OPTIONS_CDR_CD_PRIORITY, nil},
				Outbreak = true,
				Horn = false,
				RP = true,
				SpecOption = true,
			
				[1] = true,
				["CLCDK_CDRPanel_DD_CD1_One"] = {spells["Bone Shield"], true},
				["CLCDK_CDRPanel_DD_CD1_Two"] = {spells["Vampiric Blood"], nil},				
				
				[2] = true,
				["CLCDK_CDRPanel_DD_CD2_One"] = {spells["Rune Tap"], nil},
				["CLCDK_CDRPanel_DD_CD2_Two"] = {spells["Scarlet Fever"], true},
				
				[3] = false,
				["CLCDK_CDRPanel_DD_CD3_One"] = {spells["Horn of Winter"], true},
				["CLCDK_CDRPanel_DD_CD3_Two"] = {spells["Blood Charge"], true},
				
				[4] = false,
				["CLCDK_CDRPanel_DD_CD4_One"] = {CLCDK_OPTIONS_CDR_CD_TRINKETS_SLOT1, nil},
				["CLCDK_CDRPanel_DD_CD4_Two"] = {CLCDK_OPTIONS_CDR_CD_TRINKETS_SLOT2, nil},
			},
			
			[SPEC_UNKNOWN] = {
				["CLCDK_CDRPanel_DD_Priority"] = {CLCDK_OPTIONS_CDR_CD_PRIORITY, nil},
				Outbreak = false,
				Horn = true,
				RP = true,
				SpecOption = true,
			
				[1] = true,
				["CLCDK_CDRPanel_DD_CD1_One"] = {spells["Horn of Winter"], nil},
				["CLCDK_CDRPanel_DD_CD1_Two"] = {spells["Blood Charge"], true},				
				
				[2] = true,
				["CLCDK_CDRPanel_DD_CD2_One"] = {spells["Raise Dead"], nil},
				["CLCDK_CDRPanel_DD_CD2_Two"] = {spells["Army of the Dead"], nil},
				
				[3] = false,
				["CLCDK_CDRPanel_DD_CD3_One"] = {spells["Horn of Winter"], true},
				["CLCDK_CDRPanel_DD_CD3_Two"] = {spells["Blood Tap"], nil},
				
				[4] = false,
				["CLCDK_CDRPanel_DD_CD4_One"] = {CLCDK_OPTIONS_CDR_CD_TRINKETS_SLOT1, nil},
				["CLCDK_CDRPanel_DD_CD4_Two"] = {CLCDK_OPTIONS_CDR_CD_TRINKETS_SLOT2, nil},
			},			
		}
	end
	
	--Checks to make sure that none of the settings are nil, which will lead to the addon not working properly
	function CLCDK:CheckSettings()	
		if debugg then print("CLCDK:Check Settings Start")end
		
		local specs = {SPEC_UNKNOWN, SPEC_BLOOD, SPEC_FROST, SPEC_UNHOLY}
		local spots = {"Priority", "CD1_One", "CD1_Two", "CD2_One", "CD2_Two", "CD3_One", "CD3_Two", "CD4_One", "CD4_Two"}
		
		--Defaults
		if CLCDK_Settings == nil then 
			CLCDK_Settings = {} 
			CLCDK_Settings.Locked = true	
			CLCDK_Settings.LockedPieces = true			
			CLCDK_Settings.Range = true	
			CLCDK_Settings.GCD = true	
			CLCDK_Settings.Rune = true
			CLCDK_Settings.RP = true				
			CLCDK_Settings.Disease = true		
			CLCDK_Settings.CD = {}
			CLCDK:CooldownDefaults()
		end		
		
		--General Settings
		if CLCDK_Settings.Scale == nil then CLCDK_Settings.Scale = 1.0 end
		if CLCDK_Settings.Trans == nil then CLCDK_Settings.Trans = 0.5 end
		if CLCDK_Settings.CombatTrans == nil then CLCDK_Settings.CombatTrans = 1.0 end
		if CLCDK_Settings.NormTrans == nil then CLCDK_Settings.NormTrans = 1.0 end
		if CLCDK_Settings.VScheme == nil then CLCDK_Settings.VScheme = CLCDK_OPTIONS_FRAME_VIEW_NORM end
		
		--CDs
		if CLCDK_Settings.CD == nil then 
			CLCDK_Settings.CD = {}
			CLCDK:CooldownDefaults()
		end		
		for i=1,#specs do
			if CLCDK_Settings.CD[specs[i]] == nil then CLCDK_Settings.CD[specs[i]] = {}	end			
			for j=1,#spots do
				if CLCDK_Settings.CD[specs[i]]["CLCDK_CDRPanel_DD_"..spots[j]] == nil or 
					CLCDK_Settings.CD[specs[i]]["CLCDK_CDRPanel_DD_"..spots[j]][1] == nil then
					CLCDK_Settings.CD[specs[i]]["CLCDK_CDRPanel_DD_"..spots[j]] = {CLCDK_OPTIONS_FRAME_VIEW_NONE, nil}
				end	
			end
		end		
		
		--Frame Location
		if CLCDK_Settings.Location == nil then CLCDK_Settings.Location = {} end			
		if CLCDK_Settings.Location["CLCDK"] == nil then	CLCDK_Settings.Location["CLCDK"] = {Point = "Center", Rel = nil, RelPoint = "CENTER", X = 0, Y = -175, Scale = 1} end		
		if CLCDK_Settings.Location["CLCDK.CD1"] == nil then	CLCDK_Settings.Location["CLCDK.CD1"] = {Point = "TOPRIGHT",Rel = "CLCDK",RelPoint = "TOPLEFT", X = -1, Y = -3, Scale = 1} end		
		if CLCDK_Settings.Location["CLCDK.CD2"] == nil then	CLCDK_Settings.Location["CLCDK.CD2"] = {Point = "TOPLEFT",Rel = "CLCDK",RelPoint = "TOPRIGHT",X = 1,Y = -3, Scale = 1}	end		
		if CLCDK_Settings.Location["CLCDK.CD3"] == nil then	CLCDK_Settings.Location["CLCDK.CD3"] = {Point = "TOPRIGHT",Rel = "CLCDK.CD1",RelPoint = "TOPLEFT", X = -2, Y = 0, Scale = 1} end		
		if CLCDK_Settings.Location["CLCDK.CD4"] == nil then	CLCDK_Settings.Location["CLCDK.CD4"] = {Point = "TOPLEFT",Rel = "CLCDK.CD2",RelPoint = "TOPRIGHT",X = 2,Y = 0, Scale = 1} end
		if CLCDK_Settings.Location["CLCDK.RuneBar"] == nil then	CLCDK_Settings.Location["CLCDK.RuneBar"] = {Point = "Top",Rel = "CLCDK",RelPoint = "Top",X = 0,Y = -2, Scale = 1} end		
		if CLCDK_Settings.Location["CLCDK.RuneBarHolder"] == nil then CLCDK_Settings.Location["CLCDK.RuneBarHolder"] = {Point = "BottomLeft",Rel = "CLCDK",RelPoint = "TopLeft",X = 0,Y = 0, Scale = 0.86} end
		if CLCDK_Settings.Location["CLCDK.RunicPower"] == nil then CLCDK_Settings.Location["CLCDK.RunicPower"] = {Point = "TOPRIGHT",Rel = "CLCDK.RuneBar",RelPoint = "BOTTOMRIGHT",X = 0,Y = 0, Scale = 1} end
		if CLCDK_Settings.Location["CLCDK.Move"] == nil then CLCDK_Settings.Location["CLCDK.Move"] = {Point = "TOPLEFT",Rel = "CLCDK.RuneBar",RelPoint = "BOTTOMLEFT",X = 0,Y = 0, Scale = 1} end		
		if CLCDK_Settings.Location["CLCDK.Disease"] == nil then CLCDK_Settings.Location["CLCDK.Disease"]= {Point = "TOPRIGHT",Rel = "CLCDK.RunicPower",RelPoint = "BOTTOMRIGHT",X = 0,Y = 0, Scale = 1} end
		
		CLCDK_Settings.Version = CLCDK_VERSION
		
		wipe(specs)
		wipe(spots)	
		collectgarbage()
		if debugg then print("CLCDK:Check Settings Complete")end
	end
	
	--Set frame location back to Defaults
	function CLCDK:SetLocationDefault()
		if CLCDK_Settings.Location ~= nil then wipe(CLCDK_Settings.Location); CLCDK_Settings.Location = nil end
		CLCDK:CheckSettings()
		
		CLCDK:OptionsRefresh()
		if debugg then print("CLCDK:SetLocationDefault Done")end
	end
	
	--Set all settings back to default
	function CLCDK:SetDefaults()
		if CLCDK_Settings ~= nil then wipe(CLCDK_Settings); CLCDK_Settings = nil end
		CLCDK:CheckSettings()
		
		CLCDK:OptionsRefresh()
		if debugg then print("CLCDK:SetDefaults Done")end
	end
	
	
	--function to handle the View dropdown box
	function CLCDK_FramePanel_ViewDD_OnLoad()
		info            = {}	
		info.text       = CLCDK_OPTIONS_FRAME_VIEW_NORM	
		info.value      = CLCDK_OPTIONS_FRAME_VIEW_NORM
		info.func       = function() CLCDK_Settings.VScheme = CLCDK_OPTIONS_FRAME_VIEW_NORM;UIDropDownMenu_SetSelectedValue(CLCDK_FramePanel_ViewDD, CLCDK_Settings.VScheme); end
		UIDropDownMenu_AddButton(info)
		
		info            = {}	
		info.text       = CLCDK_OPTIONS_FRAME_VIEW_TARGET
		info.value      = CLCDK_OPTIONS_FRAME_VIEW_TARGET
		info.func       = function() CLCDK_Settings.VScheme = CLCDK_OPTIONS_FRAME_VIEW_TARGET;UIDropDownMenu_SetSelectedValue(CLCDK_FramePanel_ViewDD, CLCDK_Settings.VScheme); end
		UIDropDownMenu_AddButton(info)
		
		info            = {}	
		info.text       = CLCDK_OPTIONS_FRAME_VIEW_SHOW
		info.value      = CLCDK_OPTIONS_FRAME_VIEW_SHOW
		info.func       = function() CLCDK_Settings.VScheme = CLCDK_OPTIONS_FRAME_VIEW_SHOW;UIDropDownMenu_SetSelectedValue(CLCDK_FramePanel_ViewDD, CLCDK_Settings.VScheme); end
		UIDropDownMenu_AddButton(info)
		
		info            = {}	
		info.text       = CLCDK_OPTIONS_FRAME_VIEW_HIDE
		info.value      = CLCDK_OPTIONS_FRAME_VIEW_HIDE
		info.func       = function() CLCDK_Settings.VScheme = CLCDK_OPTIONS_FRAME_VIEW_HIDE;UIDropDownMenu_SetSelectedValue(CLCDK_FramePanel_ViewDD, CLCDK_Settings.VScheme); end
		UIDropDownMenu_AddButton(info)	
	end
	
	--function to handle the CD dropdown boxes
	function CLCDK_CDRPanel_DD_OnLoad(self, level)
		--If specified level, or base
		level = level or 1
				
		--Template for an item in the dropdown box
		local function CLCDK_CDRPanel_DD_Item (panel, spell, buff)	
			info = {}
			info.text = spell .. ((buff and " (Buff)") or "")	
			info.value = spell .. ((buff and " (Buff)") or "")
			info.func = function() 
				CLCDK_Settings.CD[Current_Spec][panel:GetName()][1] = spell 
				CLCDK_Settings.CD[Current_Spec][panel:GetName()][2] = buff
				UIDropDownMenu_SetSelectedValue(panel, spell .. ((buff and " (Buff)") or "")) 	
				CloseDropDownMenus()	
			end
			return info
		end	
		
		--Function to add specs specific CDs
		local function AddSpecCDs(Spec)
			for i = 1, #Spec do
				if (Cooldowns.Buffs[Spec[i]] == nil or Cooldowns.Buffs[Spec[i]][2]) then					
					UIDropDownMenu_AddButton(CLCDK_CDRPanel_DD_Item(self, Spec[i]), 2)
				end	
				if Cooldowns.Buffs[Spec[i]] ~= nil then
					UIDropDownMenu_AddButton(CLCDK_CDRPanel_DD_Item(self, Spec[i], true), 2)			
				end
			end			
		end
		
		--If base level
		if level == 1 then
			--Add unique items to dropdown
			UIDropDownMenu_AddButton(CLCDK_CDRPanel_DD_Item(self, CLCDK_OPTIONS_CDR_CD_PRIORITY), 1)
			UIDropDownMenu_AddButton(CLCDK_CDRPanel_DD_Item(self, CLCDK_OPTIONS_FRAME_VIEW_NONE), 1)
			UIDropDownMenu_AddButton(CLCDK_CDRPanel_DD_Item(self, CLCDK_OPTIONS_CDR_RACIAL), 1)
			
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
			info.text = CLCDK_OPTIONS_CDR_CD_TIER			
			info.value = {["Level1_Key"] = "Tier";}
			UIDropDownMenu_AddButton(info)	
			
			--Trinkets		
			info.text = CLCDK_OPTIONS_CDR_CD_TRINKETS		
			info.value = {["Level1_Key"] = "Trinkets";}
			UIDropDownMenu_AddButton(info)	
			
		--If nested menu
		elseif level == 2 then
			--Check what the "parent" is
			local key = UIDROPDOWNMENU_MENU_VALUE["Level1_Key"]
			
			if key == "Spec" then
				if (Current_Spec == SPEC_UNHOLY) then
					AddSpecCDs(Cooldowns.UnholyCDs)	
				elseif (Current_Spec == SPEC_FROST) then
					AddSpecCDs(Cooldowns.FrostCDs)
				elseif (Current_Spec == SPEC_BLOOD) then
					AddSpecCDs(Cooldowns.BloodCDs)
				end	
				
			elseif key == "Normal" then
				AddSpecCDs(Cooldowns.NormCDs)
				
			elseif key == "Moves" then	
				for i = 1, #Cooldowns.Moves do		
					if GetSpellTexture(Cooldowns.Moves[i]) ~= nil then
						UIDropDownMenu_AddButton(CLCDK_CDRPanel_DD_Item(self, Cooldowns.Moves[i]), 2)			
					end
				end
				
			elseif key == "Tier" then		
				info.hasArrow = false
			
				--info.text = "==T9=="
				--info.isTitle  = 1
				--info.notCheckable = 1
				--UIDropDownMenu_AddButton(info, 2)					
				--UIDropDownMenu_AddButton(CLCDK_CDRPanel_DD_Item(self, spells["T9 2pc"], true), 2)							
				
			elseif key == "Trinkets" then		
				UIDropDownMenu_AddButton(CLCDK_CDRPanel_DD_Item(self, CLCDK_OPTIONS_CDR_CD_TRINKETS_SLOT1), 2)
				UIDropDownMenu_AddButton(CLCDK_CDRPanel_DD_Item(self, CLCDK_OPTIONS_CDR_CD_TRINKETS_SLOT2), 2)
			end
		end
	end	
	
else
	if debugg then print("CLCDK: Not a DK")end
	debugg = nil
	CLCDK_Options = nil
	CLCDK_FramePanel = nil
	CLCDK_CDRPanel = nil
	CLCDK_CDPanel = nil
	CLCDK_ABOUTPanel = nil
end
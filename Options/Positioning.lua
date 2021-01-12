local name, CLCDK = ...

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
		self:StartMoving()
	end)

	--When mouse released, save position
	frame:SetScript("OnMouseUp", function(self, button)
		CLCDK.PrintDebug("Mouse Up "..self:GetName())
		self:StopMovingOrSizing()
		CLCDK_Settings.Location[self:GetName()].Point, CLCDK_Settings.Location[self:GetName()].Rel, CLCDK_Settings.Location[self:GetName()].RelPoint, CLCDK_Settings.Location[self:GetName()].X, CLCDK_Settings.Location[self:GetName()].Y = self:GetPoint()
	end)
end

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

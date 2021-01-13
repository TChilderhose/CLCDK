local name, CLCDK = ...

function CLCDK.SetupMoveFunction(frame)
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

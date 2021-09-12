local BalloonScript = {}

BalloonScript.Properties = {
	{name = "destinationLocator", type = "entity"},
	{name = "startSound", type = "entity"},
	{name = "driveSound", type = "entity"},
	{name = "playerSensor", type = "entity"},
	{name = "key", type = "string"},
}

function BalloonScript:Init()
	self.moving = false
	self.stepDistance = 40000
	self.stepTime = self.stepDistance / 200
	self.finish = self.properties.destinationLocator:GetPosition()
end

function BalloonScript:AnyPassengers()
	-- Only go to pickup zone if there is nobody inside of the balloon at present
	local players = GetWorld():GetUsers()
	for key,value in ipairs(players) do
		if self.properties.playerSensor:IsOverlapping(value) then return true end
	end
	
	return false -- Have not found any users inside
end

function BalloonScript:GoToPickupZone(player, trigger)
	--Print("BalloonScript:GoToPickupZone(player=" .. player:GetName())

	--if self.moving then return end
	if self:AnyPassengers() then return end
	
	if not player.PlayerScript:HasKey(self.properties.key) then
		-- Print("Player does not have proper key: ".. self.properties.key)
		return
	end
	
	player:SendToLocal('CompleteAssignmentLocal', "assignment_board_balloon", true)
	
	self.moving = true
	local speed = 100
	local time = Vector.Distance(self:GetEntity():GetPosition(), self.finish) / speed
	player:PlaySound(self.properties.startSound.sound)
	
	self:Schedule(function()
		Wait(1.5)
		local soundHandler = self:GetEntity():PlaySound(self.properties.driveSound.sound)
		self:GetEntity():AlterPosition(self.finish, time)
		self:Schedule(function()
			Wait(time)
			self:GetEntity():StopSound(soundHandler, 20)
		end)
	end )	
end

function BalloonScript:Stop()
	local currentPosition = self:GetEntity():GetPosition()
	self:GetEntity():AlterPosition(currentPosition,1)
	self.moving = false
end

function BalloonScript:GoUp(player, hitResult, callingEntity)
	self.moving = true
	self:GetEntity():AlterPosition(self:GetEntity():GetPosition() + Vector.New(0,0,self.stepDistance), self.stepTime)
end

function BalloonScript:GoDown(player, hitResult, callingEntity)
	self.moving = true
	self:GetEntity():AlterPosition(self:GetEntity():GetPosition() + Vector.New(0,0,-self.stepDistance), self.stepTime)
end

function BalloonScript:GoBack(player, hitResult, callingEntity)
	self.moving = true
	self:GetEntity():AlterPosition(self:GetEntity():GetPosition() + Vector.New(self.stepDistance, 0, 0), self.stepTime)
end

function BalloonScript:GoFront(player, hitResult, callingEntity)
	self.moving = true
	self:GetEntity():AlterPosition(self:GetEntity():GetPosition() + Vector.New(-self.stepDistance, 0, 0), self.stepTime)
end

function BalloonScript:GoLeft(player, hitResult, callingEntity)
	self.moving = true
	self:GetEntity():AlterPosition(self:GetEntity():GetPosition() + Vector.New(0,-self.stepDistance, 0), self.stepTime)
end

function BalloonScript:GoRight(player, hitResult, callingEntity)
	self.moving = true
	self:GetEntity():AlterPosition(self:GetEntity():GetPosition() + Vector.New(0,self.stepDistance, 0), self.stepTime)
end

return BalloonScript

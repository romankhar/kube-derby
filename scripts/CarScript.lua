local CarScript = {}

CarScript.Properties = {
	{name = "destinationLocator", type = "entity"},
	{name = "startSound", type = "entity"},
	{name = "driveSound", type = "entity"},
	{name = "failSound", type = "entity"},
	{name = "carTrigger", type = "entity"},
	{name = "key", type = "string"},
}

--This function is called on the server when this entity is created
function CarScript:Init()
	self.moving = false
	self.startPosition = self:GetEntity():GetPosition()
	self.finishPosition = self.properties.destinationLocator:GetPosition()
	self.startRotation = self:GetEntity():GetRotation()
end

function CarScript:OnInteract(player)
	-- Check if the player is in the car
	if not self.properties.carTrigger:IsOverlapping(player) then return end
	
	if not player.PlayerScript:HasKey(self.properties.key) then
		--Print("Player does not have proper key: ".. self.properties.key)
		self:GetEntity():PlaySound(self.properties.failSound.sound)
		player:SendToLocal("MessageLocal", "Access Denied", 
			"In order to operate this car, you need the CAR KEY, found at the highest point on this island.")
		return
	end
	
	player:SendToLocal('CompleteAssignmentLocal', "assignment_find_car", true)
	
	if self.moving then return end
	self.moving = true

	self:SitDown(player)
	
	local speed = 1600
	local time = Vector.Distance(self.startPosition, self.finishPosition) / speed
	self:GetEntity():PlaySound(self.properties.startSound.sound)
	
	self:Schedule(function()
		Wait(1.5)
		local soundHandler = self:GetEntity():PlaySound(self.properties.driveSound.sound)
		self:GetEntity():AlterPosition(self.finishPosition, time)
		
		self:Schedule(function()
				Wait(time + 10)
				self:GetEntity():AlterRotation(self:GetEntity():GetRotation() + Rotation.New(0,180,0),1)
				self:GetEntity():AlterPosition(self.startPosition, time)

				self:Schedule(function()
						Wait(time)
						self.moving = false
						self:GetEntity():StopSound(soundHandler)
						self:GetEntity():AlterRotation(self.startRotation,3)
				end)
			end )
	end )	
end

function CarScript:SitDown(player)
	--[[
	Print("---------- Available actions")
	for key,value in ipairs(player:GetActions()) do
		Print("----------" .. value:GetName())
	end
	]]
end	
	
return CarScript

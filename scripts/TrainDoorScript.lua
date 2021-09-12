local TrainDoorScript = {}

-- Script properties are defined here
TrainDoorScript.Properties = {
	{name = "openSound", type = "entity"},
	{name = "failSound", type = "entity"},
	{name = "doorType", type = "string"}, -- "left" is to open on internet island, "right" to open on gcp
}

--This function is called on the server when this entity is created
function TrainDoorScript:Init()
	self.timeToKeepOpenDoor = 3
	self.timeRemaining = 0
	self.open = false
end

--[[
function TrainDoorScript:OnTick(deltaTime)
	if (self.open and (self.timeRemaining <= 0)) then
		self:CloseDoor()
	else
		self.timeRemaining = self.timeRemaining - deltaTime
	end
end ]]

function TrainDoorScript:Noise(noise)
	self:GetEntity():PlaySound(noise.sound)
end

function TrainDoorScript:OpenDoor()
	self:Noise(self.properties.openSound)
	self:GetEntity():PlayAnimation("Open")
	self.open = true
	self.timeRemaining = self.timeToKeepOpenDoor
end

function TrainDoorScript:CloseDoor()
	self:Noise(self.properties.openSound)
	self:GetEntity():PlayAnimation("Closed")
	self.open = false
end

function TrainDoorScript:OnInteract(player)
	if self.open then
		self:CloseDoor()
	else
		self:OpenDoor()
	end
end

return TrainDoorScript

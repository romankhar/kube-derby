local CraneScript = {}

-- Script properties are defined here
CraneScript.Properties = {
	{name = "downLocation", type = "entity"},
	{name = "topLocation", type = "entity"},
	{name = "craneSound", type = "entity"},
}

--This function is called on the server when this entity is created
function CraneScript:Init()
	self.moveDuration = 5 -- How long to perform the movement
	self.waitDuration = self.moveDuration * 3 -- How long to perform the movement
	
	-- save positions as the initial state
	self.buttom = self.properties.downLocation:GetPosition()
	self.top = self.properties.topLocation:GetPosition()
end

function CraneScript:MoveUp()
	self:PlaySound()
	-- first we move it up
	self:GetEntity():AlterPosition(self.buttom, self.top, self.moveDuration)
	-- then we wait for a few seconds and move it back down to original position
	self:Schedule(function()
		Wait(self.waitDuration)
		self:PlaySound()
		self:GetEntity():AlterPosition(self.top, self.buttom, self.moveDuration)
	end)
end

function CraneScript:PlaySound()
	local soundHandle = self:GetEntity():PlaySound(self.properties.craneSound.sound)
	self:Schedule(function()
		Wait(self.moveDuration)
		self:GetEntity():StopSound(soundHandle)
	end)
end

return CraneScript

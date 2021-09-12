local FlyingCarScript = {}

FlyingCarScript.Properties = {
	{name = "destinationLocator", type = "entity"},
	{name = "startSound", type = "entity"},
	{name = "driveSound", type = "entity"},
}

--This function is called on the server when this entity is created
function FlyingCarScript:Init()
	self.moving = false
	self.start = self:GetEntity():GetPosition()
	self.finish = self.properties.destinationLocator:GetPosition()
end

function FlyingCarScript:OnInteract(player)
	if self.moving then return end
	
	self.moving = true
	local speed = 600
	local time = Vector.Distance(self.start, self.finish) / speed
	self:GetEntity():PlaySound(self.properties.startSound.sound)
	
	self:Schedule(function()
		Wait(1)
		local soundHandler = self:GetEntity():PlaySound(self.properties.driveSound.sound)
		self:GetEntity():AlterPosition(self.start, self.finish, time)
		local rotation = 20
		self:GetEntity():AlterRotation(Rotation.New(0,rotation,0), time)
		
		self:Schedule(function()
				Wait(time + 10)
				self:GetEntity():AlterRotation(Rotation.New(0,-rotation,0), time)
				self:GetEntity():AlterPosition(self.finish, self.start, time)

				self:Schedule(function()
						Wait(time)
						self.moving = false
						self:GetEntity():StopSound(soundHandler)
				end)
			end )
	end )	
end

return FlyingCarScript

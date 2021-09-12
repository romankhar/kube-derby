local RoverScript = {}

RoverScript.Properties = {
	{name = "destinationLocator", type = "entity"},
	{name = "startSound", type = "entity"},
	{name = "driveSound", type = "entity"},
}

--This function is called on the server when this entity is created
function RoverScript:Init()
	self.moving = false
	self.start = self:GetEntity():GetPosition()
	self.finish = Vector.New(self.properties.destinationLocator:GetPosition().x - 0, 
							self.properties.destinationLocator:GetPosition().y + 300,
							self.start.z)
	self.initialRotation = self:GetEntity():GetRotation()
end

function RoverScript:OnInteract()
	if self.moving then return end
	
	self.moving = true
	local speed = 600
	local movingTime = Vector.Distance(self.start, self.finish) / speed
	self:GetEntity():PlaySound(self.properties.startSound.sound)
	
	self:Schedule(function()
		Wait(1.5)
		local soundHandler = self:GetEntity():PlaySound(self.properties.driveSound.sound)
		self:GetEntity():AlterRotation(self.initialRotation + Rotation.New(0,25,0), 1)
		self:GetEntity():AlterPosition(self.start, self.finish, movingTime)
		
		self:Schedule(function()
				Wait(movingTime + 10)
				self:GetEntity():AlterPosition(self.finish, self.start, movingTime)

				self:Schedule(function()
						Wait(movingTime)
						self.moving = false
						self:GetEntity():StopSound(soundHandler)
						self:GetEntity():PlaySound(self.properties.startSound.sound)
						self:GetEntity():SetRotation(self.initialRotation,1)
				end)
			end )
	end )	
end

return RoverScript
local LargeDoorScript = {}

-- Script properties are defined here
LargeDoorScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{name = "open", type = "boolean"},
	{name = "key", type = "string"},
	{name = "errorMsg", type = "string"},
	{name = "openSound", type = "entity"},
	{name = "closeSound", type = "entity"},
	{name = "failSound", type = "entity"},
}

--This function is called on the server when this entity is created
function LargeDoorScript:Init()
	self.timeToKeepOpenDoor = 4
	self.timeRemaining = 0
end

function LargeDoorScript:Noise(noise)
	self:GetEntity():PlaySound(noise.sound)
	noise:Clone().active = true
end

function LargeDoorScript:OnTick(deltaTime)
	if (self.properties.open and (self.timeRemaining <= 0)) then
		self:CloseDoor()
	else
		self.timeRemaining = self.timeRemaining - deltaTime
	end
end

function LargeDoorScript:OpenDoor()
	--Print("Opening the door")
	self:Noise(self.properties.openSound)
	self:GetEntity():PlayAnimation("Open")
	self.properties.open = true
	self.timeRemaining = self.timeToKeepOpenDoor
end

function LargeDoorScript:CloseDoor()
	--Print("Closing the door")
	self:Noise(self.properties.closeSound)
	self:GetEntity():PlayAnimation("Closed")
	self.properties.open = false
end

function LargeDoorScript:OnInteract(player)
	--Print("Player '" .. player:GetName() .. "' is intracting with the door")
	if not player.PlayerScript:HasKey(self.properties.key) then
		--Print("Player does not have proper key: ".. self.properties.key)
		self:Noise(self.properties.failSound)
		player:SendToLocal("ShowRoverHintMessageLocal")
		return
	end
		
	if self.properties.open then
		self:CloseDoor()
	else
		self:OpenDoor()
	end
end

return LargeDoorScript

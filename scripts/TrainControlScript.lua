local TrainControlScript = {}

-- Script properties are defined here
TrainControlScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{name = "train", type = "entity"},
	{name = "key", type = "string"},
	{name = "trainMoveSound", type = "entity"},
	{name = "trainStartSound", type = "entity"},
	{name = "trainStopSound", type = "entity"},
	{name = "trainKeyFailSound", type = "entity"},
	{name = "startLocation", type = "entity"},
	{name = "stopLocation", type = "entity"}
}

--This function is called on the server when this entity is created
function TrainControlScript:Init()
	self.moving = false
	self.speed = 900
	self.trainHeight = 0
	self.trainLength = 1525
	self.timeRemaining = 0
end

function TrainControlScript:Start()
	--Print("Started train")
	self.properties.trainStopSound.active = false
	self.properties.trainStartSound.active = true
	self.properties.trainMoveSound.active = true
	self.moving = true
	local destination
	local moveTime
	
	-- Check current location and move to destination that is father away from where we are now
	local distanceToStart = (self.properties.train:GetPosition() - self.properties.startLocation:GetPosition()):Length() + self.trainLength
	local distanceToStop = (self.properties.train:GetPosition() - self.properties.stopLocation:GetPosition()):Length()
	if (distanceToStop < distanceToStart) then
		--Print("Moving to Starting point")
		destination = self.properties.startLocation:GetPosition()
		destination.x = destination.x - self.trainLength
		destination.z = destination.z + self.trainHeight
		moveTime = math.abs(distanceToStart / self.speed)
	else
		--Print("Moving to Stopping point")
		destination = self.properties.stopLocation:GetPosition()
		destination.z = destination.z + self.trainHeight
		moveTime = math.abs(distanceToStop / self.speed)
	end
	
	--Print("X=" .. destination.x .. " Y=" ..destination.y .. " Z=" .. destination.z)
	--Print("moveTime = " .. moveTime)
	self.timeRemaining = moveTime
	self.properties.train:AlterPosition(destination, moveTime)
end

function TrainControlScript:Stop()
	--Print("Stopped train")
	self.properties.trainStartSound.active = false
	self.properties.trainMoveSound.active = false
	self.properties.trainStopSound.active = true
	self.moving = false
	self.properties.train:AlterPosition(self.properties.train:GetPosition(), 0)
end

function TrainControlScript:OnTick(deltaTime)
	if not self.moving then return end -- nothing to do if the train is already stopped
	
	if (self.moving and (self.timeRemaining <= 0)) then
		self:Stop()
	else
		self.timeRemaining = self.timeRemaining - deltaTime
	end
end

function TrainControlScript:OnInteract(player)
	--Print("Player '" .. player:GetName() .. "' is intracting with the train and train status self.moving=" .. tostring(self.moving))

	if not player.PlayerScript:HasKey(self.properties.key) then
		local title = "HTTP Key is missing"
		local message = "This train represents HTTPS connection to the application running on GCP. In order to operate this train (aka use this connection), you need to have HTTP Key. Sometimes you can find those keys in most unexpected places (where they should not be). For example, in the GitRepo..."
		player:SendToLocal("MessageLocal", title, message)
		return
	end

	if self.moving then
		-- do nothing as we dont want players to fight for train control - once it is moving, it will get to the edn station
		-- self:Stop()
	else
		self:Start()
	end
end

return TrainControlScript
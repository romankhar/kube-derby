local AsteroidScript = {}

-- Script properties are defined here
AsteroidScript.Properties = {
	{name = "islandLocation", type = "entity"},
	{name = "rotationStep", type = "number", default = 10},
	{name = "stopSound", type = "entity"},
	{name = "winSound", type = "entity"},
	{name = "impactSound", type = "entity"},
	{name = "stopSoundLocation", type = "entity"},
	{name = "balloon", type = "entity"},
}

--This function is called on the server when this entity is created
function AsteroidScript:Init()
	-- Calculate travel speed based on the distance to the soil and total game time
	local travelTimeSeconds = 2*3600 -- this is how long it will take asteroid to touch the soil below - aka total game time duration
	self.updateInterval = 10 -- seconds
	local travelDistance = self:GetEntity():GetPosition().z - self.properties.islandLocation:GetPosition().z
	self.movementStep = self.updateInterval * travelDistance / travelTimeSeconds
	Print("Asteroid travelTimeSeconds=" .. travelTimeSeconds .. 
		" travelDistance=" .. travelDistance .. 
		" movementStep=" .. self.movementStep)
	
	-- Movement settings
	self.pitch = 0
	self.yaw = 0
	self.roll = 0
	self.secretCount1 = 1
	self.secretCount2 = 10
	self.secretCount3 = 100
	self.secretCount4 = 1000
	 -- this is secret variable to allow to stop the movement of the asteroid
	self.secretStopSum = 2*self.secretCount1 + 2*self.secretCount2 + 2*self.secretCount3 + 2*self.secretCount4
	self.secretCount = 0
	self.moving = true
	-- Trigger landing condition
	self.landingInitiated = false

	-- Initialize the scheduler to do regular updates and move asteroid down
	self:Schedule(function()
		while self.moving do
			self:Move()
			Wait(self.updateInterval)
		end
		Print("Asteroid movement has been stopped")
     end )

end

function AsteroidScript:Move()
	local destination = self:GetEntity():GetPosition()
	destination.z = destination.z - self.movementStep
	self:GetEntity():AlterPosition(destination, self.updateInterval)

	self.yaw = self.yaw + self.properties.rotationStep
	self:GetEntity():AlterRotation(Rotation.New(self.pitch, self.yaw, self.roll),self.updateInterval)
end

-------------------------------------------------
-- Handle when asteroid hits something with the bottom
-------------------------------------------------
function AsteroidScript:BottomLanding(entity, trigger)
	-- ignore any events after the game is gameOver
	if self and self.gameOver then return end
	
	-- ignore if it is a player entered the trigger
	if entity:IsA(Character) then return end
	
	-- ignore if it is a balloon or any of its parts entered the trigger
	if self:IsBalloon(entity) then return end
	
	-- By now it seems that whetever entered the trigger is legit to terminate the game
	self.gameOver = true
	self.moving = false
	
	Print("AsteroidScript:BottomLanding(): GAME OVER - landing by: " .. entity:GetName())
	
	self:PlayAllEffects()
end

-------------------------------------------------
-- Handle when player lands on top of the asteroid
-------------------------------------------------
function AsteroidScript:TopLanding(entity, trigger)
	-- Filter duplicates
	if self.landingInitiated then return end
	
	-- Ignore any landings after the game is gameOver
	if self.gameOver then return end
	
	-- Only initiate stop sequence from the Character
	if not entity:IsA(Character) then return end
	
	self.landingInitiated = true
	Print("AsteroidScript:TopLanding(): landing by: " .. entity:GetName())
	-- As soon as something lands on top, the asteroid stops movement
	self.moving = false
	
	self:PlayAllEffects()

	-- If this is a user, show success message
	if entity:IsA(Character) then
		local player = entity
		self.gameOver = true
		player:PlaySound(self.properties.winSound.sound)
		player:SendToLocal('CompleteAssignmentLocal', "assignment_stop_asteroid", true)
		player:SendToLocal("MessageLocal", "Congratulations - you Win!",
			[[Congratulations! You just completed the final assignment and saved the island 
			from the asteroid. Next assignment - head to the Google Cloud Platform to build 
			more projects: https://cloud.google.com]])
	end
end

function AsteroidScript:PlayAllEffects()
	-- Find parent of stopping effects
	local effects = {}
	for key,value in pairs(self:GetEntity():GetChildren()) do
		if value:GetName() == "stoppingEffects" then
			effects = value
			break
		end
	end
	
	-- Play stopping effects
	local interval = 2.5 -- seconds
	for count = 0, 20, 1 do
		-- Play all effects at once
		for key,value in pairs(effects:GetChildren()) do
			self:Schedule(function()
				Wait(interval * count)
				--Print("Playing effect: " .. value:GetName() .. " count=" .. count)
				value:PlayEffect(value.effect)
	 	     end )
		end
		-- Play sound once per cycle
		self:Schedule(function()
			Wait(interval * count)
			effects:PlaySound(self.properties.stopSound.sound)
 	     end )
	end
end

-----------------------------------------------------------
-- Check if this entity or part of it belongs to a balloon
-----------------------------------------------------------
function AsteroidScript:IsBalloon(entity)
	Print("AsteroidScript:IsBalloon() entity = " .. entity:GetName())
	-- Is this the balloon itself?
	if entity == self.properties.balloon then return true end
	
	-- Or is it any part of the balloon?
	for key,value in pairs(self.properties.balloon:GetChildren()) do
		if entity == value then 
			Print("AsteroidScript:IsBalloon() - ignoring part of the balloon: entity.child = " .. value:GetName())
			return true 
		end
	end
	
	-- It appears the entity is not part of the balloon
	Print("AsteroidScript:IsBalloon() - NO it is not a balloon - we have a legit impact")
	return false
end

function AsteroidScript:One()
	self:AddSecretCount(self.secretCount1)
end

function AsteroidScript:Two()
	self:AddSecretCount(self.secretCount2)
end

function AsteroidScript:Three()
	self:AddSecretCount(self.secretCount3)
end

function AsteroidScript:Four()
	self:AddSecretCount(self.secretCount4)
end

function AsteroidScript:AddSecretCount(count)
	self.secretCount = self.secretCount + count
	if self.secretCount == self.secretStopSum then
		self.moving = false
		self.properties.stopSoundLocation:PlaySound(self.properties.stopSound.sound)
	end
end

function AsteroidScript:Reset()
	self.secretCount = 0
end

return AsteroidScript

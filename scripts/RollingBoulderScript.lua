local RollingBoulderScript = {}

-- Script properties are defined here
RollingBoulderScript.Properties = {
	{name = "impactSound", type = "entity"},
	{name = "impactPoint", type = "entity"},
	{name = "key", type = "entity"},
}

function RollingBoulderScript:Init()
	self.hadImpact = false -- had it hit the ground yet?
	
	--[[
	self:Schedule(function()
		while not self.hadImpact do
			Wait(1)
			self:ImpactCheck()
		end 
	end ) ]]
	
end

-- If the boulder is rolled down the mountain and hits ground level, it will spawn a key hidden inside to let it sit on the surface
-- We will do so by constantly checking the boulder coordinates and spawn the key when we get within a certain Z range of the ground level
function RollingBoulderScript:ImpactCheck()
	--print("RollingBoulderScript:ImpactCheck() ----- CHECK")
	if self.hadImpact then return end -- nothing to do if we already had impact
	
	local currentPosition = self:GetEntity():GetPosition()
	print ("Boulder height = " .. currentPosition.z)
	if currentPosition.z < self.properties.impactPoint:GetPosition().z then
		self.hadImpact = true
		self:GetEntity():PlaySound(self.properties.impactSound.sound)
		local newKey = self.properties.key:Clone()
		newKey:SetPosition(currentPosition)
		newKey.visible = true
		newKey.collisionEnabled = true
		print("============= TADA ==============")
	end
end

return RollingBoulderScript
local HackedContainerScript = {}

HackedContainerScript.Properties = {
	{name = "appearSound", type = "entity"},
	{name = "flySound", type = "entity"},
	{name = "landingLocation", type = "entity"},
	{name = "clusterKey", type = "entity"},
}

function HackedContainerScript:Init()
	self.originalLocation = self:GetEntity():GetPosition()
end

function HackedContainerScript:ClientInit()
end

-------------------------------------------------
-- Introduce container into the world together with the key
-------------------------------------------------
function HackedContainerScript:MakeVisible(player, hitResult, callingEntity)
	local container = self:GetEntity()
	-- Ignore interaction if the container is already visible
	if container.visible then return end
	container.visible = true

	local timeToFly = 10

	-- Change user camera view
	local camera = GetWorld():Find("cameraHackedContainer")
	Print("Camera="..camera:GetName().." player="..player:GetName())
	player:GetUser():SetCamera(camera, 3)
	
	-- Schedule the return of the camera to the default
	self:Schedule(function()
		Wait(timeToFly + 1)
		player:GetUser():SetCamera(player, 3)
	end )
	
	-- Make this visible and start animation
	container.collisionEnabled = true
	self.properties.clusterKey.visible = true
	self.properties.clusterKey.collisionEnabled = true
	container:AlterPosition(container:GetPosition(), self.properties.landingLocation:GetPosition(),timeToFly)
	local soundHandle = container:PlaySound(self.properties.flySound.sound)
	--self.properties.clusterKey:SetPosition(self.properties.landingLocation:GetPosition())
	--self.properties.clusterKey:SetPosition(self.properties.landingLocation:GetPosition() + Vector.New(0,0,500))

	-- Turn off fly sound
	self:Schedule(function()
		container:PlaySound(self.properties.appearSound.sound)
		Wait(timeToFly)
		container:StopSound(soundHandle)
		container:PlaySound(self.properties.appearSound.sound)
	end)
	
	-- After few minutes hide the container and the key
	self:Schedule(function()
		Wait(timeToFly + 3*60) -- wait 3 minutes before hiding it again
		container.visible = false
		container.collisionEnabled = false
		self.properties.clusterKey.visible = false
		self.properties.clusterKey.collisionEnabled = false
		container:PlaySound(self.properties.appearSound.sound)
		container:SetPosition(self.originalLocation)
	end)
end

return HackedContainerScript

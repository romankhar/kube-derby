local ServerManagerScript = {}

-- Script properties are defined here
ServerManagerScript.Properties = {
	--{name = "serverName", type = "string", default = "defaultServerName"},
	{name = "container", type = "entity"},
	{name = "destroySound", type = "entity"},
	{name = "addSound", type = "entity"},
	{name = "fence", type = "entity"},
	{name = "addTrigger", type = "entity"},
	{name = "removeTrigger", type = "entity"}
}

--This function is called on the server when this entity is created
function ServerManagerScript:Init()
	self.numContainers = 0
	self.objectHeight = 300
	self.allContainers = {}
	self.maxContainers = 18
	self.serverName = "defaultServerName"
	self.serverProperties = {}
end

function ServerManagerScript:AddContainer()
	if (self.numContainers >= self.maxContainers) then
		Print("Reached max number of " .. self.maxContainers .. " containers per server")
		return
	end

	self.numContainers = self.numContainers + 1
	--Print("Adding container #".. self.numContainers)
	local container = self.properties.container:Clone()
	--Print("Object type of the container is " .. type(container))
	self.allContainers[self.numContainers] = container
	container:SetPosition(self:GetEntity():GetPosition() + Vector.New(0,0,50 + self.objectHeight * (self.numContainers -1)))
	self:ShowContainer(container)
	container:PlaySound(self.properties.addSound.sound)
end

function ServerManagerScript:RemoveContainer()
	if (self.numContainers <= 0) then
		Print("No more containers to remove")
		return
	end
	
	--Print("Removing container #".. self.numContainers)
	local container = self.allContainers[self.numContainers]
	container:PlaySound(self.properties.destroySound.sound)
	container:Destroy()
	self.numContainers = self.numContainers - 1
end

function ServerManagerScript:ShowServer()
	-- First we find the locator under which all objects need to be shown
	local visibleParent = {}
	for key,value in pairs(self:GetEntity():GetChildren()) do
		if value:GetName() == "visibleObjectsParent" then
			visibleParent = value
			break
		end
	end
	-- Now iterate over all elements that shall be made visible
	for key,value in pairs(visibleParent:GetChildren()) do
		if value.visible ~= nil then value.visible = true end
		if value.collisionEnabled ~= nil then value.collisionEnabled = true end
	end
end

function ServerManagerScript:ShowContainer(container)
	container.visible = true
	container.collisionEnabled = true

	-- Now iterate over all elements that shall be made visible
	for key,value in pairs(container:GetChildren()) do
		if value.visible ~= nil then value.visible = true end
		if value.collisionEnabled ~= nil then value.collisionEnabled = true end
	end
end

return ServerManagerScript

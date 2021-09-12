local TerrainScript = {}

-- Script properties are defined here
TerrainScript.Properties = {
	-- Example property
	--{name = "health", type = "number", tooltip = "Current health", default = 100},
	{name = "backgroundMusic", type = "entity"}
}

--This function is called on the server when this entity is created
function TerrainScript:Init()
	self.properties.backgroundMusic.active = true
end

return TerrainScript

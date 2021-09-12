local ExplodingBoulderScript = {}

ExplodingBoulderScript.Properties = {
	{name="explodeSound", type = "entity"},
	{name="explodeVisual", type = "entity"}
}

function ExplodingBoulderScript:Init()
end

function ExplodingBoulderScript:Explode(entity)
	--print("boulder activated by entity = " .. entity:GetName())
	self:GetEntity():PlaySound(self.properties.explodeSound.sound)
	self:GetEntity():PlayEffect(self.properties.explodeVisual.effect)
	self:GetEntity().visible = false
	self:GetEntity().collisionEnabled = false
	
	-- After few seconds heal the boulder and restore its appearance
	self:Schedule(function()
		Wait(10)
		self:GetEntity().visible = true
		self:GetEntity().collisionEnabled = true
	end)
end

return ExplodingBoulderScript
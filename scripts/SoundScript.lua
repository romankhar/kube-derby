local SoundsScript = {}

SoundsScript.Properties = {
	{name = "soundEffect", type = "entity"},
}

function SoundsScript:Init()
end

function SoundsScript:PlaySoundEffect()
	self:GetEntity():PlaySound(self.properties.soundEffect.sound)
end

return SoundsScript

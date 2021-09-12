local GraffitiScript = {}

GraffitiScript.Properties = {
	{name = "title", type = "string"},
	{name = "text", type = "string"},
	{name = "footer", type = "string"},
}

--This function is called on the server when this entity is created
function GraffitiScript:Init()
end

function GraffitiScript:ClientInit()
	local input = {
		title = self.properties.title,
		text = self.properties.text,
		footer = self.properties.footer
	}
	
	self:GetWidget().js:CallFunction("updateScreen", input)
end

function GraffitiScript:GetWidget()
	return self:GetEntity().GraffitiWidget
end

return GraffitiScript
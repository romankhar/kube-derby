local SimpleImageScript = {}

SimpleImageScript.Properties = {
	{name = "imageURL", type = "string", tooltip = "URL for your UI image, can be found on the developer companion site"},
	{name = "opacity", type = "number", min = 0, max = 1, default = 1, editor = "slider", tooltip = "How opaque the image is"},
}

function SimpleImageScript:ClientInit()
	self:GetEntity().simpleImageWidget.js.data.imageURL = self.properties.imageURL
	self:GetEntity().simpleImageWidget.js.data.opacity = self.properties.opacity
end

return SimpleImageScript

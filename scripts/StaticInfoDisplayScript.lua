local StaticInfoDisplayScript = {}

StaticInfoDisplayScript.Properties = {
	{name = "title", type = "string"},
	{name = "textLeft", type = "string"},
	{name = "textRight", type = "string"},
	{name = "textLeft1", type = "string"},
	{name = "textRight1", type = "string"}
}

function StaticInfoDisplayScript:ClientInit()
	--Print("StaticInfoDisplayScript: ClientInit()")
	local input = {
		title = self.properties.title
	}
	
	input["info"] = {}
	if self.properties.textLeft ~= "" then
		input["info"][1] = {}
		input["info"][1]["textLeft"] = self.properties.textLeft
		input["info"][1]["textRight"] = self.properties.textRight
	end

	if self.properties.textLeft1 ~= "" then
		input["info"][2] = {}
		input["info"][2]["textLeft"] = self.properties.textLeft1
		input["info"][2]["textRight"] = self.properties.textRight1
	end
	
	--print("input[title]="..input["title"])
	self:GetWidget().js:CallFunction("updateScreen", input)
end

function StaticInfoDisplayScript:GetWidget()
	return self:GetEntity().StaticInfoWidget
end

return StaticInfoDisplayScript

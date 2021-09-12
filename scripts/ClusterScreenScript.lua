local ClusterScreenScript = {}

ClusterScreenScript.Properties = {
}

function ClusterScreenScript:ClientInit()
	-- Print("ClusterScreen: ClientInit()")
end

function ClusterScreenScript:updateScreen(cluster)
	if cluster == nil then
		Print("WARNING:ClusterScreen:updateScreen(): nothing to show on the screen because cluster=nil")
		return
	end
	--Print("ClusterScreen: updateScreen(), cluster name = " .. cluster.info.name)
	self:GetWidget().js:CallFunction("updateScreen", cluster)
end

function ClusterScreenScript:GetWidget()
	return self:GetEntity().ServerDisplayWidget
end

return ClusterScreenScript

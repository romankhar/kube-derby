local FirewallScript = {}

-- Script properties are defined here
FirewallScript.Properties = {
	-- Example property
	{name = "train", type = "string"}
}

--This function is called on the server when this entity is created
function FirewallScript:Init()
end

function FirewallScript:EnableCollision()
	self:GetEntity().collisionEnabled = true
	--print("---------Closing firewall")
end

function FirewallScript:DisableCollision(entity)
	-- Exit now if firewall is already open
	if not self:GetEntity().collisionEnabled then return end
	
	--Print("self.properties.train=" .. self.properties.train .. " entity:GetName()="..entity:GetName())
	
	-- Only open firewall if the train entered it
	if string.match(entity:GetName(), self.properties.train) then
		self:GetEntity().collisionEnabled = false
		--Print("------Opening firewall")
		-- Close the firewall within a few seconds
		self:Schedule(function()
			Wait(3)
			self:EnableCollision()
		end)	
	elseif entity:IsA(Character) then
		--Print("NOT Opening firewall")
		local title = "GCP Firewall is blocking your passage"
		local message = "GCP firewall will only allow valid HTTP traffic on designated port to move through. Please use HTTP Train to get in and out of GCP VPC."
		local player = entity
		player:SendToLocal("MessageLocal", title, message)
		return
	end
end

return FirewallScript

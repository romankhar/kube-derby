local KeyScript = {}

KeyScript.Properties = {
	{name = "assignment", type = "string"},
	{name = "pickupSound", type = "entity"},
	{name = "pickupEffect", type = "entity"},
	{name = "appearSound", type = "entity" },
	{name = "appearEffect", type = "entity" },
	{name = "playerCollisionAllowed", type = "boolean", default = true },
}

function KeyScript:Init()
end

function KeyScript:OnInteract(player)
	self:OnCollision(player)
end

function KeyScript:OnCollision(player)
	--Print("=========self.properties.playerCollisionAllowed=" .. tostring(self.properties.playerCollisionAllowed))
	if not self.properties.playerCollisionAllowed then return end
	
	local keyName = self:GetEntity():GetName()
	--Print("KeyScript:OnCollision(): Player=".. player:GetName() .. " collided with the key=" .. keyName)

	if player:IsA(Character) and not player.PlayerScript:HasKey(keyName) then
		player.PlayerScript:CollectItem(keyName, self.properties.assignment, self:GetEntity(), "localPickupComplete")
		player:SendToScripts("DoOnLocal", self:GetEntity(), "localPickupComplete")
	end
end

-------------------------------------------------
-- Hide item from space after it has beeen picked up - trigger is a child element on the entity
-------------------------------------------------
function KeyScript:localPickupComplete()
	--Print("KeyScript:localPickupComplete()")
	self:GetEntity():PlaySound(self.properties.pickupSound.sound)
	self:GetEntity():PlayEffect(self.properties.pickupEffect.effect)
	self:Hide()
end

-------------------------------------------------
-- Hide item from players
-------------------------------------------------
function KeyScript:AllowPlayerCollision(boolStatus)
	self.properties.playerCollisionAllowed = boolStatus
	--Print("AllowPlayerCollision (SERVER) +++++++++++++self.properties.playerCollisionAllowed=" .. tostring(self.properties.playerCollisionAllowed))
end

-------------------------------------------------
-- Hide item from players
-------------------------------------------------
function KeyScript:Hide()
	--Print("KeyScript:Hide() key: " .. self:GetEntity():GetName())
	self:GetEntity().visible = false
	self:AllowPlayerCollision(false)
	--Print("-----------self.properties.playerCollisionAllowed" .. tostring(self.properties.playerCollisionAllowed))
end

-------------------------------------------------
-- Show item 
-------------------------------------------------
function KeyScript:Show()
	--Print("KeyScript:Show(key=" .. self:GetEntity():GetName() .. ")")
	self:GetEntity().visible = true
	self:GetEntity():SendToServer("AllowPlayerCollision", true)
	self:GetEntity():PlaySound(self.properties.appearSound.sound)
	self:GetEntity():PlayEffect(self.properties.appearEffect.effect)
end

return KeyScript
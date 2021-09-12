local HutDoorScript = {}

HutDoorScript.Properties = {
	{name = "openSound", type = "entity"},
	{name = "closeSound", type = "entity"},
	{name = "morseSound", type = "entity"},
	{name = "cancelSound", type = "entity"},
	{name = "longBeepSound", type = "entity"},
	{name = "shortBeepSound", type = "entity"},
	{name = "hutTrigger", type = "entity"},
}

-- How long the door should be open for a player
timeToKeepOpenDoor = 5

function HutDoorScript:Init()
	self.open = false
	self.morseSequenceEntered = {}
	-- List of timeouts for users to hide the password widget
	self.timeoutHandles = {}
	-- Morse code is GCP (assume 1 is dash, 0 is dot)
	self.morseSequenceNeeded = {1,1,0,1,0,1,0,0,1,1,0}
	--self.morseSequenceNeeded = {1}
end

-------------------------------------------------
-- Initialize Client
-------------------------------------------------
function HutDoorScript:ClientInit()
	--Print("HutDoorScript:ClientInit()")
end

-------------------------------------------------
-- Open door animation
-------------------------------------------------
function HutDoorScript:OpenDoor(player)
	self.open = true
	player:SendToScripts("DoOnLocal", self:GetEntity(), "OpenDoorLocal")
	self:GetEntity().collisionEnabled = false
	
	-- Close door after some time
	self:Schedule(function()
		Wait(timeToKeepOpenDoor)
		self:CloseDoor(player)
	end )
end

-------------------------------------------------
-- Open door animation
-------------------------------------------------
function HutDoorScript:OpenDoorLocal()
	self:GetEntity():PlaySound(self.properties.openSound.sound)
	self:GetEntity():PlayAnimationClient("Open")
end

-------------------------------------------------
-- Animate closing the door
-------------------------------------------------
function HutDoorScript:CloseDoor(player)
	self.open = false
	self:GetEntity().collisionEnabled = true
	player:SendToScripts("DoOnLocal", self:GetEntity(), "CloseDoorLocal")
end

-------------------------------------------------
-- Animate closing the door
-------------------------------------------------
function HutDoorScript:CloseDoorLocal()
	self:GetEntity():PlaySound(self.properties.closeSound.sound)
	self:GetEntity():PlayAnimationClient("Closed")
end

-------------------------------------------------
-- Close password widget
-------------------------------------------------
function HutDoorScript:CloseWidget(player)
		self.morseSequenceEntered = {}
		player:SendToScripts("DoOnLocal", self:GetEntity(), "HideWidget")
end

-------------------------------------------------
-- Check for timeout to show or hide the password box
-------------------------------------------------
function HutDoorScript:CheckPasswordTimeout(player)
	-- Check if this user has pressed a button before and cancel timout if he has
	if self.timeoutHandles[player:GetName()] then
		self:Cancel(self.timeoutHandles[player:GetName()])
	end
	
	self.timeoutHandles[player:GetName()] = self:Schedule(function()
		Wait(10)
		-- If user has not pressed any morse code icons for some time, hide the widget
		self:CloseWidget(player)
	end)
end

-------------------------------------------------
-- Process user interaction with the triggers to enter Morse sequence
-------------------------------------------------
function HutDoorScript:ButtonPress(player, hitResult, entity)
	--Print("HutDoorScript:ButtonPress: entity name = " .. entity:GetName())
	player:SendToScripts("DoOnLocal", self:GetEntity(), "ShowWidget")
	self:CheckPasswordTimeout(player)
	
	local i = 1 + self:tablelength(self.morseSequenceEntered)

	if self.errorSoundHandle then
		self:GetEntity():StopSound(self.errorSoundHandle)
	end

	if entity:GetName() == "reset" then
		self:GetEntity():PlaySound(self.properties.cancelSound.sound)
		self:CloseWidget(player)
	elseif entity:GetName() == "dash" then
		--self:GetEntity():PlaySound(self.properties.longBeepSound.sound)
		self.properties.longBeepSound:Clone().active = true
		self.morseSequenceEntered[i] = 1
	elseif entity:GetName() == "dot" then
		--self:GetEntity():PlaySound(self.properties.shortBeepSound.sound)
		self.properties.shortBeepSound:Clone().active = true
		self.morseSequenceEntered[i] = 0
	end

	player:SendToScripts("DoOnLocal", self:GetEntity(), "UpdateWidget", self.morseSequenceEntered)
	
	if self:CheckCode(player) then
		--Print("HutDoor: the code has been entered correctly")
		self:OpenDoor(player)
	end
end

-------------------------------------------------
-- Verify if the code entered by the user is correct
-------------------------------------------------
function HutDoorScript:CheckCode(player)
	if self:tablelength(self.morseSequenceEntered) ~= self:tablelength(self.morseSequenceNeeded) then 
		return false 
	end
	
	for key,value in ipairs(self.morseSequenceNeeded) do
		if value ~= self.morseSequenceEntered[key] then return false end
	end

	-- it appears the code has been entered correctly, reset the code sequence for next user
	self.morseSequenceEntered = {}
	player:SendToScripts("DoOnLocal", self:GetEntity(), "HideWidget")
	return true
end

-------------------------------------------------
-- Reflect entered data in a widget
-------------------------------------------------
function HutDoorScript:UpdateWidget(code)
	self:GetEntity().MorsePasswordWidget.js:CallFunction("updateScreen", self:convertMorseToVisualString(code))
end

-------------------------------------------------
-- Hide password entry
-------------------------------------------------
function HutDoorScript:HideWidget()
	self:GetEntity().MorsePasswordWidget:Hide()
end

-------------------------------------------------
-- Show password entry
-------------------------------------------------
function HutDoorScript:ShowWidget()
	self:GetEntity().MorsePasswordWidget:Show()
end

-------------------------------------------------
-- Player interacts with the door
-------------------------------------------------
function HutDoorScript:OnInteract(player)
	if self.open then
		self:CloseDoor(player)
	elseif self.properties.hutTrigger:IsInside(player:GetPosition()) then 
		self:OpenDoor(player)
	else
		self:PlayErrorSound()
		self.morseSequenceEntered = {}
		player:SendToScripts("DoOnLocal", self:GetEntity(), "UpdateWidget", self.morseSequenceEntered)
		player:SendToScripts("DoOnLocal", self:GetEntity(), "ShowWidget")
		self:CheckPasswordTimeout(player)
	end
end

-------------------------------------------------
-- Play notification
-------------------------------------------------
function HutDoorScript:PlayErrorSound()
	self.errorSoundHandle = self:GetEntity():PlaySound(self.properties.morseSound.sound)
	self:Schedule(function()
		Wait(20)
		self:GetEntity():StopSound(self.errorSoundHandle)
		self.errorSoundHandle = nil
	end)
end

-------------------------------------------------
-- Convert user Morse code entry sequence into the visual representation of dots, spaces and dashes
-------------------------------------------------
function HutDoorScript:convertMorseToVisualString(codeTable)
	if not codeTable then return "" end
	
	local dash = "_"
	local dot = "."
	local space = " "
	local letter = ""
	local result = ""
	local morseAlphabet = {a = "._", b = "_...", c = "_._.", d = "_..", e = ".", f = ".._.", g = "__.", h ="....", i = "..", j = ".___", k = "_._", l = "._..", m = "__", n = "_.", o = "___", p = ".__.", q = "__._", r = "._.", s = "...", t = "_", u = ".._", v = "..._", w = ".__", x = "_.._", y = "_.__", z = "__..", a1 = ".____", a2 = "..___", a3 = "...__", a4 = "...._", a5 = ".....", a6 = "_....", a7 = "__...", a8 = "___..", a9 = "____.", a0 = "_____"}

	for _,value in ipairs(codeTable) do
		--print("User Entered value="..tostring(value))
		if value == 1 then
			result = result .. dash
			letter = letter .. dash
		elseif value == 0 then
			result = result .. dot
			letter = letter .. dot
		end
		
		-- Check if current letter buffer matches any of needed letters G C P and add a space
		if letter == morseAlphabet["g"] or letter == morseAlphabet["c"] or letter == morseAlphabet["p"] then
				result = result .. space .. space .. space
				--print("completed the letter = " .. letter)
				letter = ""
		end
	end
 	return result
end

-------------------------------------------------
-- Universal function that returns the length of the table
-------------------------------------------------
function HutDoorScript:tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

return HutDoorScript
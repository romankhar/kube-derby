local PuzzleScript = {}

PuzzleScript.Properties = {
	{ name = "successEffect", type = "entity" },
	{ name = "successSound", type = "entity" },
	{ name = "moveSound", type = "entity" },
	{ name = "key", type = "entity" },
}

function PuzzleScript:Init()
	self.puzzle = {}
	-- Dimensions of the puzzle
	self.x = 4
	self.y = 4
	-- Read initial state
	self:Initiate()
	-- Shuffle the puzzle
	self:Shuffle()
	-- At the start we need to hide the key
	self.properties.key:SendToScripts("Hide")
end

--------------------------------------------------------------
-- Initialize the original state of the puzzle - one time task
--------------------------------------------------------------
function PuzzleScript:Initiate()
	local images = nil
	-- Find images locator that holds all puzzle pieces
	for key,value in pairs(self:GetEntity():GetChildren()) do
		if value:GetName() == "images" then
			images = value
			break
		end
	end
	
	-- Find all parts of the puzzle under images
	for key,value in pairs(images:GetChildren()) do
		local index = self:ExtractImageNumberFromName(value:GetName())
		self.puzzle[index] = {}
		self.puzzle[index].entity = value
		if string.match(value:GetName(),"empty") then
			self.puzzle[index].empty = true
		else
			self.puzzle[index].empty = false
		end
		self.puzzle[index].originalPosition = value:GetPosition()
		self.puzzle[index].originalOrder = index
	end
	
	--self:PrintState()
end

--------------------------------------------------------------
-- Mix up all the images in random order
--------------------------------------------------------------
function PuzzleScript:Shuffle()
	-- Using hard coded shuffle which is the same for all participants as even playing field (same starting point)
	local shuffledOrder = {13,10,16,4,8,15,7,5,6,3,12,14,11,1,9,2}
	local newPuzzle = {}
	for key,value in pairs(shuffledOrder) do
		newPuzzle[key] = self.puzzle[value]
		newPuzzle[key].entity:SetPosition(self.puzzle[key].originalPosition)
	end
	self.puzzle = newPuzzle
end

--------------------------------------------------------------
-- Forcefully solve the puzzle (used by FirstAidKit)
--------------------------------------------------------------
function PuzzleScript:ForceSolve(player)
	local time = 2
	for key,value in pairs(self.puzzle) do
		value.entity:AlterPosition(value.originalPosition, time)
	end

	self:Schedule(function()
		Wait(time + 0.5)
		self:PlaySuccessEffect(1, player)
	end )
end

--------------------------------------------------------------
-- Check if the puzzle is finished
--------------------------------------------------------------
function PuzzleScript:CheckCompletion(moveTime, player)
	self:Schedule(function()
		Wait(moveTime + 0.1)
		for key,value in pairs(self.puzzle) do
			if value.entity:GetPosition() ~= value.originalPosition then
				return false
			end
		end
		self:PlaySuccessEffect(1, player)
		Print("HURRRAY!!! You have completed the puzzle!")
		return true
	end )
end

--------------------------------------------------------------
-- Get the image number from the name
--------------------------------------------------------------
function PuzzleScript:PlaySuccessEffect(index, player)
	self:Schedule(function()
		Wait(0.06)
		if index > self:tablelength(self.puzzle) then 
			-- Show the key to this user
			player:SendToScripts("DoOnLocal", self.properties.key, "Show")
			-- After some time, mix up the puzzle for the next player
			self:Schedule(function()
				Wait(10)
				self:Shuffle()
			end )

			return 
		end
		--Print("playing effect = " .. index)
		self.puzzle[index].entity:PlayEffect(self.properties.successEffect.effect)
		self.puzzle[index].entity:PlaySound(self.properties.successSound.sound)
		self:PlaySuccessEffect(index + 1, player)
	end )
end

--------------------------------------------------------------
-- Get the image number from the name
--------------------------------------------------------------
function PuzzleScript:ExtractImageNumberFromName(name)
	--print("ExtractImageNumberFromName=" .. name)
	local result = string.gsub(string.gsub(name,"img",""),"-empty","")
	result = tonumber(result)
	--print("result=" .. tostring(result))
	return result
end

--------------------------------------------------------------
-- Make a move - when user clicks on the entity
--------------------------------------------------------------
function PuzzleScript:Move(player, hitResult, entity)
--[[
	Matrix of possible moves for X x Y puzzle 5 x 4
	
	1  2  3  4  5
	6  7  8  9  10
	11 12 13 14 15
	16 17 18 19 20
	
	Allowed moves:
	
	-1 - except when at the very left: if (pos mod x) > 1
	+1 - except when at very right: if (pos mod x ) ~= 0
	-X - except when at the top: if pos > X
	+X - except when at the bottom: if (pos+X) <= X*Y
	can only move to a location with the EMPTY slot
]]
	local position = self:FindPosition(entity:GetName())
	--Print("Moving item: " .. tostring(position))
	
	if ((position % self.x) ~=  1) and self:Swap(position, position - 1, player) then return end
	if ((position % self.x) ~= 0) and self:Swap(position, position + 1, player) then return end
	if (position > self.x) and self:Swap(position, position - self.x, player) then return end
	if ((position + self.x) <= (self.x * self.y)) and self:Swap(position, position + self.x, player) then return end	
end

--------------------------------------------------------------
-- Finds the position of an entity with the given image number
--------------------------------------------------------------
function PuzzleScript:FindPosition(entityName)
	for key,value in pairs(self.puzzle) do
		if tonumber(entityName) == self:ExtractImageNumberFromName(value.entity:GetName()) then
			return key
		end
	end
end

--------------------------------------------------------------
-- Swamps elements position, but only if the TO is the empty field
-- return true if success, false if not
--------------------------------------------------------------
function PuzzleScript:Swap(positionFrom, positionTo, player)
	--Print("Swap(positionFrom, positionTo): " .. tostring(positionFrom) .. " <-> " .. tostring(positionTo))
	if positionTo < 1 then return end
	if positionTo > self.x*self.y then return end
	if self.puzzle[positionTo].empty then
		-- We only need to exchange the coordinates and update the position order
		local tmpEntity = self.puzzle[positionTo]
		self.puzzle[positionTo] = self.puzzle[positionFrom]
		self.puzzle[positionFrom] = tmpEntity
		-- Now update coordinates
		local tempPositionVector = self.puzzle[positionTo].entity:GetPosition()
		local moveTime = 0.1
		self:GetEntity():PlaySound(self.properties.moveSound.sound)
		self.puzzle[positionTo].entity:AlterPosition(self.puzzle[positionFrom].entity:GetPosition(), moveTime)
		self.puzzle[positionFrom].entity:AlterPosition(tempPositionVector, moveTime)
		--Print("SUCCESS: Swap from: " .. tostring(positionFrom) .. " to: " .. tostring(positionTo))
		self:CheckCompletion(moveTime, player)
		--self:PrintState()
		return true
	end
	--Print("FAIL: Swap from: " .. tostring(positionFrom) .. " to: " .. tostring(positionTo))
	return false
end

--------------------------------------------------------------
-- Prints current state of the puzzle
--------------------------------------------------------------
function PuzzleScript:PrintState()
	Print("Current state of the puzzle:")
	for key,value in pairs(self.puzzle) do
		Print(tostring(key) .. "- image: " .. value.entity:GetName() .. " original#: " .. tostring(value.originalOrder) .. " Original Pos: " .. tostring(value.originalPosition) .. " Current Pos: " .. tostring(value.entity:GetPosition()))
	end
end

-------------------------------------------------
-- Universal function that returns the length of the table
-------------------------------------------------
function PuzzleScript:tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

return PuzzleScript

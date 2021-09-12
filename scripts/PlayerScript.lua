local PlayerScript = {}

PlayerScript.Properties = {
	-- DEBUG properties
	-- for real game please disable this as it will allow anything without keys
	{ name="ignoreKeys", type="boolean", default=false },
	{ name="ignoreMessages", type="boolean", default=false },
}

PlayerScript.InputKeys =  {
  primary   = "{primary-icon-raw}",
  secondary = "{secondary-icon-raw}",
  extra1    = "{extra1-icon-raw}",
  extra2    = "{extra2-icon-raw}",
  extra3    = "{extra3-icon-raw}",
  extra4    = "{extra4-icon-raw}",
  extra5    = "{extra5-icon-raw}",
  jump      = "{jump-icon-raw}",
  interact  = "{interact-icon-raw}",
  crouch    = "{crouch-icon-raw}",
  sprint    = "{sprint-icon-raw}",
  previous  = "{previous-icon-raw}",
  next      = "{next-icon-raw}",
}

--Valid interaction modes for button press processing
PlayerScript.InteractionMode = {
		Quiz = 1, 
		Aid = 2, 
		Message = 3,
		None = 4,
	}

-- Constants for widget button presses	
PlayerScript.UserResponse = {
		autoComplete = 100, -- User wants to complete the action automatically
		closeScreen = 0, -- User wants to close the interactive screen
		nextAction = 1, -- User wants to move to next action
		noAnswer = -1,  -- User has not provided an answer as of yet
		
}

-------------------------------------------------
-- Server init
-------------------------------------------------
function PlayerScript:Init()
	--Print("Player:Init()")
	self.keys = {} -- All keys found by this player
end

-------------------------------------------------
-- Client init
-------------------------------------------------
function PlayerScript:ClientInit()
	-- Track player progress
	self.score = 0 -- Score accumulated by this player
	self.interactionMode = self.InteractionMode.None -- player is not running the quiz or message on screen or other interaction
	self.roverHintRevealCount = 0 -- counter to increment revealing rover hint letters

	-- UI settings
	self:GetEntity():GetUser().showDefaultCrosshair = false
		
	-- Widgets
	self.quizWidget = self:GetEntity().QuizWidget	
	self.messageWidget = self:GetEntity().HeadsupMsgWidget
	self.roverHintWidget = self:GetEntity().RoverHintWidget
	self.keyboardDetailsWidget = self:GetEntity().KeyboardDetailsWidget
	
	-- Sounds
	self.quizErrorSound = GetWorld():Find("quizErrorSound")
	self.quizSuccessSound = GetWorld():Find("quizSuccessSound")
	self.quizQuitSound = GetWorld():Find("quizQuitSound")
	self.quizOpenSound = GetWorld():Find("quizOpenSound")
	self.aidOpenSound = GetWorld():Find("quizOpenSound")
	self.aidQuitSound = GetWorld():Find("quizQuitSound")
	self.assignmentCompleteSound = GetWorld():Find("assignmentCompleteSound")
	
	-- Set keys for widgets
	self.messageWidget.js:CallFunction("setKeyIcons", self.InputKeys)
	self.keyboardDetailsWidget.js:CallFunction("setKeyIcons", self.InputKeys)
	self.roverHintWidget.js:CallFunction("setKeyIcons", self.InputKeys)
	
	-- Initial state of interaction with the user in a widget
	self.userAnswer = self.UserResponse.noAnswer -- This is what user has answered with his last key press
	
	self:QuizzesInit()
	self:AssignmentsInit()

	-- Update player scorecard every once in awhile
	local updateInterval = 5
	self:Schedule(function()
		while true do
			Wait(updateInterval)
			self:localUpdateScorecard("")
		end 
	end )
end

-------------------------------------------------
-- Client init
-------------------------------------------------
function PlayerScript:LocalInit()
	self:WelcomeMessage()
	self.currentAssignment = "assignment_find_car_key"
	self:localUpdateScorecard("")
end

-------------------------------------------------
-- Message to show at the start of the game
-------------------------------------------------
function PlayerScript:WelcomeMessage()
	-- Show welcome message right after user arrival
	local title = "Welcome to KubeDerby! (v0.34 beta)"
	local msg = [[
	KubeDerby is a fun way to gain Google Cloud Platform skills. Your objective is to prevent 
	the asteroid from hitting the island (look up into the sky).
	Asteroid is moving slowly towards the land and once it touches the island the game is over.
	Follow directions, complete the assignments and have fun!/n
	To interact with objects (Coconuts, First Aid Kits, Cars, Doors, etc.), point at them with the cursor and press [Interact] key.
	To pickup Keys, you need to walk into them./n
	This game is still under development and does not yet 
	have programming and scripting assignments on a live GCP project (expected in early March 2021). 
	This game is not an official Google product. Authors of this game may work for Google, 
	however the game solely reflects the personal views of the authors and do not necessarily 
	represents the views, positions, strategies or opinions of Google. 
	Please submit your feedback to Roman Kharkovski (kharkovski@google.com).]] 
	
	-- This is already local, so we just call the function directly
	self:MessageLocal(title, msg)
end

-------------------------------------------------
-- Remove possible points for the assignment - possibly because of the hint, or other reason
-------------------------------------------------
function PlayerScript:CancelPoints(task)
	-- If this was called from the server, then pass it to local
	if self.assignments == nil then 
		self:SendToLocal("CancelPoints", task)
		return
	end
	
	if self.assignments[task] ~= nil then
		self.assignments[task].points = 0
	else
		Print("WARNING: PlayerScript:CancelPoints(): can not find an assignment: <" .. task .. ">")
	end
end

-------------------------------------------------
-- Calculate stats
-------------------------------------------------
function PlayerScript:GetStats()
	--Print("AssignmentsScript:GetStats()")
	local count = 0
	for key,value in pairs(self.assignments) do
		--print("key="..key.." value="..tostring(value) .. " type="..type(value))
		if (type(value) == "table") and value.passed then
			count = count + 1
		end
	end
	
	return {size = self.assignments.size,
			passed = count,
			totalPoints = self.assignments.totalPoints}
end

-------------------------------------------------
-- Define all the quizzes
-------------------------------------------------
function PlayerScript:QuizzesInit()
	self.quizzes = self:GetEntity().QuizScript:DefineQuizzes()
end

-------------------------------------------------
-- Define all the assignments
-------------------------------------------------
function PlayerScript:AssignmentsInit()
	self.assignments = self:GetEntity().AssignmentsScript:DefineAssignments()
end

-------------------------------------------------
-- Mark assignment as completed (server)
-------------------------------------------------
function PlayerScript:CompleteAssignment(player, callingEntity)
	--Print("playername=" .. player:GetName())
	player:SendToLocal('CompleteAssignmentLocal', callingEntity:GetName())
end

-------------------------------------------------
-- Mark assignment as completed (local)
-------------------------------------------------
function PlayerScript:CompleteAssignmentLocal(taskName, playSound)
	-- Ignore NIL assignments
	if (not taskName) or (taskName == "") or (taskName == "none") then return end
	
	if self.assignments[taskName] == nil then
		Print("WARNING: PlayerScript:CompleteAssignmentLocal(): assignment with the name <" .. taskName .. "> is not found")
		return
	end
		
	-- Ignore the event if the assignment has already been completed
	if self.assignments[taskName].passed then 
		Print("PlayerScript:CompleteAssignmentLocal(): this player has already completed assignment <" .. taskName .. ">. Nothing to do.")
		return 
	end

	Print("PlayerScript:CompleteAssignmentLocal(): marking complete assignment for <" .. taskName .. ">")
	
	self.assignments[taskName].passed = true
	self.score = self.score + self.assignments[taskName].points

	-- Only move to the next assignment if there is one
	if self.assignments[taskName].nextTask ~= "none" then
		self.currentAssignment = self.assignments[taskName].nextTask
	end

	self:localUpdateScorecard("")
	if playSound then
		self:GetEntity():PlaySound(self.assignmentCompleteSound.sound)
	end
end

-------------------------------------------------
-- Pickup an item and add to the inventory
-------------------------------------------------
function PlayerScript:CollectItem(itemName, assignment)
	if not itemName then
		Print("PlayerScript:Collected(): ERROR - itemName can not be NIL")
		return
	end
	
	self.keys[itemName] = true
	self:SendToLocal('localUpdateScorecard', itemName)
	self:GetEntity():SendToLocal('CompleteAssignmentLocal', assignment)
end

-------------------------------------------------
-- Update on-screen inventory of items
-------------------------------------------------
function PlayerScript:localUpdateScorecard(collectableName)
	--Print("PlayerScript:localUpdateScorecard(): Sending item data to UI widget: " .. collectableName)
	
	-- Calculate statistics on Quizes
	local passedQuizes = 0
	for key,value in pairs(self.quizzes) do
		if (type(value) == "table") and value.passed then
			passedQuizes = passedQuizes + 1
		end
	end
	
	local quizes = {
		passed = passedQuizes,
		total = self.quizzes.size,
		totalPoints = self.quizzes.totalPoints
	}
	
	--Print("======== self.currentAssignment = " .. self.currentAssignment)
	
	self:GetEntity().CollectedKeysWidget.js:CallFunction(
		"collected", 
		collectableName, 
		self.score, 
		quizes, 
		self:GetStats(),
		self.assignments[self.currentAssignment].short)
		
	-- Update persistent user score for the leaderboard
	self:GetEntity():SendToServer("SaveCurrentScore", self.score)
end

-------------------------------------------------
-- Update leaderboard data on the server side
-------------------------------------------------
function PlayerScript:SaveCurrentScore(score)
	self:GetEntity():GetUser():SendToScripts("SetScore", score)
end

-------------------------------------------------
-- Does this player have the proper key collected?
-------------------------------------------------
function PlayerScript:HasKey(keyName)
	if self.properties.ignoreKeys then 
		Print("DEBUG: PlayerScript:HasKey(" .. keyName .. "): in debug mode we ignore all keys and assume true")
		return true 
	end
	
	if (self.keys[keyName]) then
		return true
	end
	return false
end

--[[-----------------------------------------------
Process button presses during the quiz
	extra1 = R
	extra2 = Q
	extra3 = G
	extra4 = V
	extra5 = B
	next = X
	previous = Z
	jump = space
	interact = E
	primary = left mouse click
-------------------------------------------------]]
function PlayerScript:LocalOnButtonPressed(buttonName)
	--Print("-- PlayerScript:LocalOnButtonPressed(): Button pressed = " .. buttonName)
	
	if (self.interactionMode == self.InteractionMode.None) and (buttonName == "next") then 
		self:MessageLocal(self.assignments[self.currentAssignment].title, self.assignments[self.currentAssignment].info[1])
	elseif self.interactionMode == self.InteractionMode.Message then 
		self:ButtonPressedMessage(buttonName)
	elseif self.interactionMode == self.InteractionMode.Quiz then 
		self:ButtonPressedQuiz(buttonName)
	elseif self.interactionMode == self.InteractionMode.Aid then 
		self:ButtonPressedAid(buttonName)
	else
		self.userAnswer = self.UserResponse.noAnswer
	end
end

-------------------------------------------------
-- Process buttons for Message mode (simple informational message with one button to close the window
-------------------------------------------------
function PlayerScript:ButtonPressedMessage(buttonName)
    if buttonName == "previous" then -- close the dialog when Z is pressed
        self.userAnswer = self.UserResponse.closeScreen
    elseif buttonName == "next" then -- do the next thing
    	self.userAnswer = self.UserResponse.nextAction
    else
    	self.userAnswer = self.UserResponse.noAnswer
    end
end

-------------------------------------------------
-- Process buttons for Message mode (simple informational message with one button to close the window
-------------------------------------------------
function PlayerScript:ButtonPressedQuiz(buttonName)
    if buttonName == "previous" then -- close the quiz when Z is pressed
        self.userAnswer = self.UserResponse.closeScreen
    elseif string.match(buttonName,"extra") then
    	-- extract the number after the button name "extra" and store it as the quiz answer
    	local response = string.gsub(buttonName,"extra","")
    	self.userAnswer = tonumber(response)
    else
    	self.userAnswer = self.UserResponse.noAnswer
    end
end

-------------------------------------------------
-- Process buttons for Message mode (simple informational message with one button to close the window
-------------------------------------------------
function PlayerScript:ButtonPressedAid(buttonName)
    if buttonName == "previous" then -- close the quiz when Z is pressed
        self.userAnswer = self.UserResponse.closeScreen
    elseif string.match(buttonName,"extra1") then
    	-- User decided to auto-complete assignment and get 0 points for it
    	self.userAnswer = self.UserResponse.autoComplete
    else
    	self.userAnswer = self.UserResponse.noAnswer
    end
end

-------------------------------------------------
-- Run the on-screen quiz
-------------------------------------------------
function PlayerScript:QuizLocal(quizName, caller, quizResultCallbackLocal)
	if self.interactionMode ~= self.InteractionMode.None then return end -- Already in some kind of interactive mode
	
	local quiz = self.quizzes[quizName]
	
	if quiz["passed"] then -- Check if this user already passed this quiz earlier
		if quizResultCallbackLocal then caller:SendToScripts(quizResultCallbackLocal) end
		return 
	end

	self.interactionMode = self.InteractionMode.Quiz
	self.userAnswer = self.UserResponse.noAnswer
	self:GetEntity():PlaySound(self.quizOpenSound.sound)

	--Map crayta keys to display values
	quiz.extra1Key = "{extra1-icon-raw}"
	quiz.extra2Key = "{extra2-icon-raw}"
	quiz.extra3Key = "{extra3-icon-raw}"
	quiz.extra4Key = "{extra4-icon-raw}"
	quiz.extra5Key = "{extra5-icon-raw}"
	quiz.closeKey = "{previous-icon-raw}"
	quiz.keys = self.InputKeys;
	self.quizWidget.js:CallFunction("updateScreen", quiz)
	self.quizWidget:Show()
	
	-- Wait till the quiz is over - separate function listens on user input keys
	local updateInterval = 0.1 -- seconds 
	self:Schedule(function()
		while self.interactionMode == self.InteractionMode.Quiz do
			Wait(updateInterval)
			
			if self.userAnswer == self.UserResponse.closeScreen then
				self.interactionMode = self.InteractionMode.None
				self:GetEntity():PlaySound(self.quizQuitSound.sound)
				self.quizWidget:Hide()
			elseif self.userAnswer == self.UserResponse.noAnswer then
				-- Print("Do Nothing - user pressed some other button - self.userAnswer="..self.userAnswer)
			elseif self.userAnswer == quiz["correctAnswer"] then
				self.interactionMode = self.InteractionMode.None
				quiz["passed"] = true
				self:CalculateQuizScore(quiz)
				self:GetEntity():PlaySound(self.quizSuccessSound.sound)
				self:localUpdateScorecard("")
				self.quizWidget.js:CallFunction("updateScreen", quiz)
								
				self:Schedule(function()
					Wait(1.5) -- run small delay to allow for sound to finish playing
					self.quizWidget:Hide()
					if quizResultCallbackLocal then
						caller:SendToScripts(quizResultCallbackLocal)
					end
				end )
			else
				self.userAnswer = self.UserResponse.noAnswer -- reset the user answer to avoid loop problem
				quiz["errors"] = quiz["errors"] + 1
				self.quizWidget.js:CallFunction("updateScreen", quiz)
				self:GetEntity():PlaySound(self.quizErrorSound.sound)
			end
		end
     end )
end

function PlayerScript:ShowRoverHintMessageLocal()
	if self.properties.ignoreMessages then 
		Print("DEBUG: PlayerScript:ShowRoverHintMessageLocal(): Do not show any messages since <self.properties.ignoreMessages=TRUE>")
		return 
	end
	
	if self.interactionMode ~= self.InteractionMode.None then return end -- Already in interactive mode
	self.interactionMode = self.InteractionMode.Message
	self.userAnswer = self.UserResponse.noAnswer
	self:GetEntity():PlaySound(self.quizOpenSound.sound)
	self.roverHintWidget:Show()
	
	-- Wait till the user reads and then quits msg
	self:Schedule(function()	
		while self.userAnswer ~= self.UserResponse.closeScreen do
			if self.userAnswer == self.UserResponse.nextAction then
			  self.roverHintRevealCount = self.roverHintRevealCount + 1;
			  if self.roverHintRevealCount < 5 then
			    self.score = self.score - 5  -- Remove 5 points per reveal (this will max in 15 points if they reveal all letters)
			    self.roverHintWidget.js:CallFunction("increaseStage")
			    self.userAnswer = self.UserResponse.noAnswer
			  end
			end
			
			Wait(0.1)
		end
		self.interactionMode = self.InteractionMode.None
		self.roverHintWidget:Hide()
     end )
end

-------------------------------------------------
-- Show message widget to the player
-------------------------------------------------
function PlayerScript:MessageLocal(title, message, googleBanner)
	if self.properties.ignoreMessages then 
		Print("DEBUG: PlayerScript:MessageLocal(): Do not show any messages since <self.properties.ignoreMessages=TRUE>")
		return 
	end
	
	if self.interactionMode ~= self.InteractionMode.None then return end -- Already in interactive mode
	self.interactionMode = self.InteractionMode.Message
	if googleBanner == nil then googleBanner = true end
	self.userAnswer = self.UserResponse.noAnswer
	self:GetEntity():PlaySound(self.quizOpenSound.sound)
	self.messageWidget.js:CallFunction("updateScreen", title, message, googleBanner)
	self.messageWidget:Show()
	
	-- Wait till the user reads and then quits msg
	self:Schedule(function()
		while self.userAnswer ~= self.UserResponse.closeScreen do Wait(0.1) end
		self.interactionMode = self.InteractionMode.None
		self:GetEntity():PlaySound(self.quizQuitSound.sound)
		self.messageWidget:Hide()
     end )
end

-------------------------------------------------
-- Show first aid message to the player
-------------------------------------------------
function PlayerScript:FirstAidLocal(title, message)
	if self.interactionMode ~= self.InteractionMode.None then return end -- Already in interactive mode
	self.interactionMode = self.InteractionMode.Aid
	self.userAnswer = self.UserResponse.noAnswer

	local input = {
		title = title,
		message = message,
	}
	
	--Map crayta keys to display values
	input.extra1Key = "{extra1-icon-raw}"
	input.closeKey = "{previous-icon-raw}"
	input.keys = self.InputKeys;

	self:GetEntity():PlaySound(self.aidOpenSound.sound)
	self:GetEntity().FirstAidWidget.js:CallFunction("updateScreen", input)
	self:GetEntity().FirstAidWidget:Show()
	
	-- Wait till the user quits
	self:Schedule(function()
		while self.userAnswer ~= self.UserResponse.closeScreen do 
			Wait(0.1)
		end
		self.interactionMode = self.InteractionMode.None
		self:GetEntity():PlaySound(self.aidQuitSound.sound)
		self:GetEntity().FirstAidWidget:Hide()
     end )
end

-------------------------------------------------
-- Server call with quiz being successful
-------------------------------------------------
function PlayerScript:QuizSuccess(caller, quizResultCallback)
	caller:SendToScripts(quizResultCallback, true)
end

-------------------------------------------------
-- Count score for the quiz
-------------------------------------------------
function PlayerScript:CalculateQuizScore(quiz)
	local numQuestions = 0
	for key,server in pairs(quiz) do
		if key:match("answer", 1) then
			numQuestions = numQuestions + 1
		end
	end
	
	-- We give zero score if the user had too many errors
	if quiz["errors"] < (numQuestions-1) then
		-- Add points to the user score
		self.score = self.score + quiz["points"] - quiz["points"] * quiz["errors"] / numQuestions
	end
	--Print("User score=" .. self.score)
end

-------------------------------------------------
--	Call this function on a user from any entity, passing the entity and function you want to call on the local client 
--	E.g. user:SendToScripts("DoOnLocal", airhornEntity, "ToggleAirhorn", true)
-------------------------------------------------
function PlayerScript:DoOnLocal(entity, functionName, ...)
	if self:GetEntity():IsLocal() then
		entity:SendToScripts(functionName, ...)
	else
		self:SendToLocal("DoOnLocal", entity, functionName, ...)
	end
end

-------------------------------------------------
-- Universal function that returns the length of the table
-------------------------------------------------
function PlayerScript:tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

return PlayerScript

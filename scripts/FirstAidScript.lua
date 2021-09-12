local FirstAidScript = {}

-------------------------------------------------
-- Server init
-------------------------------------------------
function FirstAidScript:Init()
	self:DefineHints()
	self.assignment = self.hints[self:GetEntity():GetName()].assignment
end

-------------------------------------------------
-- Hint info for the entity based on the name of the entity being an index to the table
-------------------------------------------------
function FirstAidScript:OnInteract(player)
	local i = self:GetEntity():GetName()
	if not self.hints[i] then
		Print("ERROR: FirstAidScript:OnInteract(): the name of the HELP entity <".. i .. "> can not be found in local index")
		return
	end
	
	player:SendToLocal("FirstAidLocal", self.hints[i].title, self.hints[i].text)
	self:ShowOrb()
end

-------------------------------------------------
-- Same thing as interaction
-------------------------------------------------
function FirstAidScript:OnCollision(player)
	--self:OnInteract(player)
end

-------------------------------------------------
-- Player decided to auto-complete the assignment by walking into an Orb
-------------------------------------------------
function FirstAidScript:WalkIntoOrb(player, trigger)
	if not self.orbActivated then return end -- If Orb is not activated, ignore the interaction
	Print("FirstAidScript:WalkIntoOrb(player, trigger)")
	player:SendToLocal("CancelPoints", self.assignment)
	player:SendToScripts("AutoCompleteAssignment", player, self.assignment)
end

-------------------------------------------------
-- Hide magic orb
-------------------------------------------------
function FirstAidScript:HideOrb()
	self.orb.visible = false
	self.orb.active = false
	self.orbActivated = false
end

-------------------------------------------------
-- Show magic orb
-------------------------------------------------
function FirstAidScript:ShowOrb()
	-- Find the Orb and make it visible and ready to accept player interaction
	self.orb = nil
	for key,value in pairs(self:GetEntity():GetChildren()) do
		if value:GetName() == "magicOrb" then
			self.orb = value
			break
		end
	end
	
	if not self.orb then
		Print("Error: magic Orb was not found in this first aid kit: " .. self:GetEntity():GetName())
	end
	self.orb.visible = true
	self.orb.active = true
	self.orbActivated = true
	
	-- However the Orb is only visible for 10 seconds
	self:Schedule(function()
		Wait(20)
		self:HideOrb()
     end )

end

-------------------------------------------------
-- DefineHints all assignments and help items
-------------------------------------------------
function FirstAidScript:DefineHints()
	self.hints = {
		help_mountain_top = {
			title = "Help Hints",
			assignment = "assignment_find_car_key",
			text = [[At various stages of the game you may have difficult time solving a puzzle or a challenge.
				If you see a First Aid Kit like this, simply interact with it and you will get a hint  
				to solve the assignment./n
				The CAR KEY can be found in a cave in this mountain./n
				Walk into the Magic Orb to be teleported to the cave (no points earned for the assignment).]],
		},
		help_cave = {
			title ="How to find a Car",
			assignment = "assignment_find_car",
			text = [[Walk out of the cave and keep walking straing until you reach the edge of the Internet Island.
							Look to your left./n
			 		Walk into the Magic Orb to be teleported to the car location.]],
		},
		help_git_door = {
			title ="How to open the door for the GitHub Repository Hut",
			assignment = "assignment_find_http_key", -- this references the list of assignments
			text = [[To be able to open the door, you must enter a valid password. If you simply tried to open the door,
			you probably heard Morse code as a hint. The message above the door tells you what the password is.
			If you interact with two logos to the left of the door you hear dot and a dash (short and long sounds).
			The logo to the right of the door is a reset to scratch whatever you entered before.
			You need to enter the password in Morse code to open the door. Do not worry about pauses between letters,
			simply enter the password as a sequence of proper dots and dashes using the logos to the left.]],
		},

		help_gcr_door = {
			title ="How to open the Artifact Registry Door",
			assignment = "assignment_find_gcr",
			text = [[To be able to open the door, you need to fiind the key.
					  The answer to the croosword is ROVER./n
			 		  Walk into the Magic Orb to be teleported inside of the Artifact Registry at the cost of all points for the current assignment.]],
		},
		
		help_inside_gcr = {
			title ="How to get on top of the crane",
			assignment = "assignment_gcr_crane_top",
			text = [[You need to climb all the way to the top of the crane.
							In order to do it, jump on the first container, then on the second, etc.
							Once you are on the tallest container, hop into the cargo net handing from the crane.
							Crutch down and move between ropes and look up. You shall see a red botton.
							Press on the button with the [Interact] key. This will pull you up.
							Walk towards the crane cabin on top of the crane crossbars./n
			 		Walk into the Magic Orb to be teleported to the crane top at the cost of all points for the current assignment.]],
		},

		help_gcr_crane_top = {
			title ="How to get GKE key and get inside of the cluster",
			assignment = "assignment_gcr_build_image",
			text = [[Press the RED button on the crane crossbars to initiate the appearance of a 
				malicious container. This container will be dropped into the GCR on top of of the the existing containers.
				In the full version of the game (coming in March 2021), you will be asked to build a real Docker Image and upload it to the real Artifact Registry./n
			 	Walk into the Magic Orb to be teleported to the key location the cost of all points for the current assignment.]],
		},

		help_gke_cluster = {
			title ="How to get GCS Key on top of the Flying Car",
			assignment = "assignment_get_gcs_key", -- this references the list of assignments
			text = [[In order to get all the way to the Flying Car, you need to use large green Plus sign and create five servers.
			Once you have servers in place, add one container to the first server, two containers to the second server, etc.
			Then jump on top of the first container, from there on top of the second container of the second server, etc.
			Once you make it to the fifth server and its fifth container, turn around and use green sign on the side of container 
			on the fourth server to add two more containers. This means fourth server will now have six containers.
			Jump to the six's container of server four, turn around and add two more containers to the fifth server.
			Keep doing it until you reach the Flying Car./n
				Walk into the Magic Orb to be teleported on top of the Flying Car at the cost of all points of the current assignment.]],
		},
		
		help_gcs_puzzle = {
			title ="How to get Balloon Key",
			assignment = "assignment_get_balloon_key",
			text = [[Move pars of the puzzle on the wall until you get proper picture as shown on the 
							cabinet to the right of the puzzle. Be aware, unlike many similar sliding puzzles,
							this one has an empty spot in its final state in the right top corner./n
					Walk into the Magic Orb to solve the puzzle.]],
		},

		help_balloon_key = {
			title ="Stop the Asteroid",
			assignment = "assignment_board_balloon",
			text = [[Go to the Internet Island and climb on top of the mountain with your GCS Key.
					Wait for the balloon to show up and hop onboard. Use the Balloon to land on top 
					of the Asteroid to stop it./n
					Walk into the Magic Orb to teleport to the top of the mountain at the cost of all points for this assignment.]],
		},
	}
end

return FirstAidScript
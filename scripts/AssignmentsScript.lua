local AssignmentsScript = {}

AssignmentsScript.Properties = {
}

-------------------------------------------------
-- Client
-------------------------------------------------
function AssignmentsScript:Init()
	-- This is a read only, so we can initialize more than once
	self.allAssignments = self:DefineAssignments()
	self.teleportInSound = GetWorld():Find("teleportInSound").sound
	self.teleportOutSound = GetWorld():Find("teleportOutSound").sound
	self.teleportArrivalEffect = GetWorld():Find("teleportArrivalEffect").effect
end

-------------------------------------------------
-- Client
-------------------------------------------------
function AssignmentsScript:ClientInit()
	--Print("AssignmentsScript:ClientInit()")
	self.allAssignments = self:DefineAssignments()
	-- Only update the widget if this is used on the sign, otherwise ignore
	if not self:GetEntity():IsA(Character) then
		local name = self:GetEntity():GetName()
		--Print("-------- entity name=" .. name)
		self:GetEntity().AssignmentWidget.js:CallFunction("updateScreen", self.allAssignments[name])
	end
end

-------------------------------------------------
-- Functions to auto-complete the assignment
-------------------------------------------------
function AssignmentsScript:AutoCompleteAssignment(player, assignment)
	local f = self.allAssignments[assignment].autoCompleteCallback
	--Print("AssignmentsScript:AutoCompleteAssignment(".. assignment .. "), callback = " .. f)
 	player:PlaySound(self.teleportOutSound)
	self:Schedule(function()
		Wait(2)
		self.AutoCompleteFunctions[f](player)
		Wait()
		Wait()
		Wait()
		player:PlaySound(self.teleportInSound)
		player:PlayEffect(self.teleportArrivalEffect, true)
	end)
end

AssignmentsScript.AutoCompleteFunctions = {
-------------------------------------------------------------
-- Move the player to where the car key is
-------------------------------------------------------------
CarKey = function(player) 
	local location = GetWorld():Find("Car Key"):GetPosition() + Vector.New(-500,200,0)
	player:SetPosition(location)
end,

-------------------------------------------------------------
-- Move the player to the car
-------------------------------------------------------------
Car = function(player) 
	local location = GetWorld():Find("CarJeep"):GetPosition() + Vector.New(0,0,300)
	player:SetPosition(location)
end,

-------------------------------------------------------------
-- Move the player inside of the Hut
-------------------------------------------------------------
Hut = function(player) 
	local location = GetWorld():Find("strawHut"):GetPosition() + Vector.New(0,0,0)
	player:SetPosition(location)
end,

-------------------------------------------------------------
-- Move the player inside of the Hut
-------------------------------------------------------------
GCRdoor = function(player) 
	local location = GetWorld():Find("gcrDoor"):GetPosition() + Vector.New(200,0,0)
	player:SetPosition(location)
end,

-------------------------------------------------------------
-- Move the player 
-------------------------------------------------------------
CraneTop = function(player) 
	local location = GetWorld():Find("craneCabin"):GetPosition() + Vector.New(0,0,500)
	player:SetPosition(location)
end,

-------------------------------------------------------------
-- Move the player 
-------------------------------------------------------------
BuildMaliciosImage = function(player) 
	local location = GetWorld():Find("gke"):GetPosition() + Vector.New(0,0,500)
	player:SetPosition(location)
end,

-------------------------------------------------------------
-- Move the player 
-------------------------------------------------------------
FlyingCar = function(player) 
	local location = GetWorld():Find("GCS Key"):GetPosition() + Vector.New(-100,70,0)
	player:SetPosition(location)
end,

-------------------------------------------------------------
-- Make Balloon Key appear
-------------------------------------------------------------
BalloonKey = function(player) 
	local puzzle = GetWorld():Find("puzzle")
	puzzle:SendToScripts("ForceSolve", player)
end,

-------------------------------------------------------------
-- Move the player 
-------------------------------------------------------------
GoMountainTop = function(player) 
	local location = GetWorld():Find("balloonLandingZoneLocator"):GetPosition() + Vector.New(0,0,5000)
	player:SetPosition(location)
end,

}

-------------------------------------------------
-- Define all assignments
-- returns a table with all assignments
-------------------------------------------------
function AssignmentsScript:DefineAssignments()
	--Print("AssignmentsScript:SetAssignments()")
	local assignments = {
		assignment_find_car_key = {
			title ="Assignment #1",
			points = 5,
			nextTask = "assignment_find_car",
			short = "Find the CAR KEY in the vicinity of the mountain.",
			autoCompleteCallback = "CarKey",
			info = [[Welcome to KubeDerby. You are on the INTERNET ISLAND./n
			Your first objective is to find the CAR KEY, then find the CAR and 
			use [Interact] button to start it. The car will take you to your next assignment.
			Press [Interact] to pickup coconuts and mushroms to score extra points./n
			If you get stuck and need help, find nearest First Aid Kit (see example below).]],
		},
		assignment_find_car = {
			title ="Find the Car and start it",
			points = 5,
			nextTask = "assignment_find_http_key",
			short = "Find the CAR, jump into it and start the engine.",
			autoCompleteCallback = "Car",
			info = [[Your next objective is to find the car, hop into it and start it using [Interact] key. 
			The car will take you to your next assignment./n
			Don't forget to press [Interact] to pickup coconuts and mushroms to score extra points.]],			
		},
		assignment_find_http_key = {
			title ="Find the HTTP Key",
			points = 30,
			nextTask = "assignment_find_train",
			short = "Find the HTTP KEY in a place where it should not be.",
			autoCompleteCallback = "Hut",
			info = [[Your next objective is to find the HTTP Key to help you get into the GCP Island./n
			  The GCP project is surrounded by the firewall on top of the big island. 
			  You can't pass through the firewall without using the HTTP tunnel (represented by the train).
			  To use the tunnel you need to have proper credentials./n
			Hint: Sometimes developers store credentials in source code repositories]], 
		},
		assignment_find_train = {
			title ="Get a ride to GCP Island",
			points = 5,
			nextTask = "assignment_start_train",
			short = "Find HTTP TRAIN, hop into it and take a ride to GCP ISLAND.",
			info = [[Your next objective is to ride the HTTP train through the firewall into the GCP Island./n
			On that island you will complete a series of assignments and eventually return to the top of the mountain 
			where you started the game, get aboard the hot air balloon and save the Internet from the asteroid.
			Use your HTTP Key to operate the train.]], 
		},
		assignment_start_train = {
			title ="Start the Train engine",
			points = 5,
			nextTask = "assignment_find_gcr",
			short = "Start the Train engine.",
			info = [[Press the RED button to move the train.]],
		},
		assignment_find_gcr = {
			title ="Get inside of Google Artifact Registry",
			points = 20,
			nextTask = "assignment_gcr_crane_top",
			short = "Find the proper key and get inside of Google Artifact Registry.",
			autoCompleteCallback = "GCRdoor",
			info = [[Welcome to the GCP Project Island./n
			Your next task is to penetrate the GKE cluster.
			In order to do it, you need to find Google Artifact Registry and upload a 
			malicious container it, then trigger deployment into the cluster. 
			The container will run with permissions to read secret code from the Google Cloud Storage./n
			One more thing, collect mushrooms for extra points.]],
		},
		assignment_gcr_crane_top = {
			title ="Get to the control cabin of the train",
			points = 15,
			nextTask = "assignment_gcr_build_image",
			short = "Get into the control cabin of the crane.",
			autoCompleteCallback = "CraneTop",
			info = [[You are inside the Google Artifact Registry. Your next assignment is to build a 
			  malicious container and upload it into the registry./n
			You can find detailed instructions and operate on the registry at the top of the 
				control crane (err, control plane).]]
		},
		assignment_gcr_build_image = {
			title ="Build malicious container image",
			points = 50,
			short = "Build and upload malicious container image.",
			nextTask = "assignment_get_inside_gke",
			autoCompleteCallback = "BuildMaliciosImage",
			info = [[You now need to build a Docker image with malicious code and upload it into this registry./n
			Once you build and upload the image, it will show in this registry along with the CLUSTER KEY.
			Use that key to enter the GKE cluster./n
			EASY BUTTON: While we are still working on the backend integration with real GCP project,
			for now you can simulate this by pressing the button.]],
			-- [[Be sure to include a script to copy secret to the external GCS bucket:]],
			-- [[gsutil cp gs://internal/secret.txt gs://external/secret.txt]],
		},
		assignment_get_inside_gke = {
			title ="Penetrate GKE Cluster",
			points = 5,
			short = "Get inside of the GKE Cluster.",
			nextTask = "assignment_get_gcs_key",
			info = [[You need to find a way to get inside of the GKE Cluster.]],
		},
		assignment_get_gcs_key = {
			title ="Get the GCS Key",
			points = 50,
			nextTask = "assignment_go_to_gcs",
			short = "Get the GCS Key on top of the flying car.",
			autoCompleteCallback = "FlyingCar",
			info = [[You need to trigger the deployment of the malicios image into this cluster and once successful, 
			grab the GCS KEY and head out to GCS to get your next assignment./n
			The GCS KEY can be found on top of the flying car you can see hovering in the air.
			EASY BUTTON: While we are still working on the backend integration with real GCP project,
			for now you can simulate this by solving the puzzle.]],
		},
		assignment_go_to_gcs = {
			title ="Get inside of GCS",
			points = 5,
			nextTask = "assignment_get_balloon_key",
			short = "Use your GCS Key to get inside of GCS",
			info = [[Find a way to get inside of the GCS bunker.]],
		},
		assignment_get_balloon_key = {
			title ="Find the Balloon Key",
			points = 50,
			nextTask = "assignment_board_balloon",
			short = "Find the Balloon Key and go to the top of the mountain.",
			autoCompleteCallback = "BalloonKey",
			info = [[Find the BALLOON KEY in this room, then head out to the top of the mountain.
			Wait for the hot air balloon to arrive and hop onboard (use [Space] to jump).
			You can navigate the balloon by pressing [Interact] in the direction where you want to go 
			(up, down, left, right, etc.). Your job is to jump out of the ballon on top of the asteroid, 
			Once your feet touch the top of the asteroid, you win the game and stop the asteroid.]],
		},
		assignment_board_balloon = {
			title ="Get into the balloon",
			points = 10,
			nextTask = "assignment_stop_asteroid",
			short = "Go to the top of the mountain and board the Balloon.",
			autoCompleteCallback = "GoMountainTop",
			info = [[Go to the Internet Island and climb on top of the mountain with your GCS Key.
			Wait for the balloon to show up and hop onboard.]],
		},
		assignment_stop_asteroid = {
			title ="Stop the Asteroid",
			points = 10,
			nextTask = "none", -- for the last assignment there is no more tasks
			short = "Use the Balloon to land on top of the Asteroid to stop it.",
			info = [[Once you are inside of the balloon, use the "Interact" button to direct your balloon 
			to the top of the asteroid. Simply point the cursor to the right direction (left, right, top, down, etc.)
			and press the Interact button.]],
		},					
	}
	
	-- Calculate max possible score
	local totalPoints = 0
	local size = 0
	for _,value in pairs(assignments) do
		totalPoints = totalPoints + value.points
		size = size + 1
	end
	
	assignments["totalPoints"] = totalPoints
	assignments["size"] = size

	return assignments
end

return AssignmentsScript
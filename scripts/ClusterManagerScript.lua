local ClusterManagerScript = {}

-- Script properties are defined here
ClusterManagerScript.Properties = {
	{name = "serverLocator", type = "entity"},
	{name = "energyEffectAdd", type = "entity"},
	{name = "energyEffectRemove", type = "entity"},
	{name = "addSound", type = "entity"},
	{name = "destroySound", type = "entity"},
	{name = "clusterUpdateEvent", type = "event"}
}
-------------------------------------------------
-- This function is called on the server when this entity is created
-------------------------------------------------
function ClusterManagerScript:Init()
	--Print("ClusterManager:Init()")
	
	self.syncWithGCP = false -- shall we keep the state of the cluster in-sync with the state of the GCP
	self.allServers = {} -- List of all current servers
	self.ySpacing = -600 -- distance between servers
	self.yOffset = 350 -- offset for the first server to the left of center
	self.xOffset = -700
	self.maxServers = 5 -- cluster can hold up to this number of servers, otherwise they do not fit into space in the world
	self.clusterName = "Team-A-cluster-2"
	self.projectName = "proj-team-a"
	self.clusterInfo = nil -- this is where we will store all the info about the current cluster
	
	-- Initialize the scheduler to do regular updates
	local updateInterval = 5.0 -- seconds 
	self:Schedule(function()
		while self.syncWithGCP do
			self:ReconcileClusterState()
			Wait(updateInterval)
		end
     end )
end

-------------------------------------------------
-- Initialize Client
-------------------------------------------------
function ClusterManagerScript:ClientInit()
	--Print("ClusterManager:ClientInit()")
end

-------------------------------------------------
-- Update Widget on the Client - this is called from the server to get proper cluster status to update informational display
-------------------------------------------------
function ClusterManagerScript:ClientScreenUpdateEvent(clusterInfo)
	--Print("ClusterManager:ClientScreenUpdateEvent()")
	self.properties.clusterUpdateEvent:Send(clusterInfo)
end

-------------------------------------------------
-- Reconcile the state of the cluster in the game with whatever is on GCP
-- When new servers are added to the real GCP cluster, they need to be added inside of the game
-------------------------------------------------
function ClusterManagerScript:ReconcileClusterState()
	--Print("ClusterManager:ReconcileClusterState()")

 	self:ReadCloudStatus()
 	
 	-- Create cluster summary and send it to the screen for info display on the client 
	self.clusterInfo = self:ParseClusterInfo(self.CloudAssets, self.projectName, self.clusterName)
    self:SendToAllClients("ClientScreenUpdateEvent", self.clusterInfo)

    -- At this point @cloudAssets has the config of the cluster that came from the GCP
    -- At the same time self.allServers have info on the state of the cluster in the game
    -- We need to reconcile these two with each other
    
    -- For now lets assume GCP always has the most correct info
	local project = self.CloudAssets["GoogleCloud"]["projects"][self.projectName]
	if project == nil then
		--Print("ClusterManager:ReconcileClusterState():Project with the name <" .. self.projectName .. "> is not found")
		return nil
	end
	
	local cluster = project["clusters"][self.clusterName]
	if cluster == nil then
		Print("ClusterManager:ReconcileClusterState():Cluster with the name <" .. self.clusterName .. "> is not found")
		return nil
	end	
	
	local numCloudServers = self:tablelength(cluster["nodes"])
	--local numLocalServers = self:tablelength(self.allServers)
	
	-- Iterate over local servers and check if they exist on GCP and remove if needed
	local i = 1
	for key,value in pairs(self.allServers) do
		local serverName = value.ServerManagerScript.serverName
		-- Print("server index=" .. key .. ", server name=" .. serverName)
		-- Check if server with this name exists in GCP and delete if it does not
		if cluster["nodes"][serverName] == nil then
			-- Since such server does not exist in GCP, we shall remove from the game
			Print("Server <" .. serverName .. "> does not exist in GCP - removing from the game")
			local removeAllMatching = true
			self:RemoveServerByName(serverName,removeAllMatching)
		else
			--Print("Server <" .. serverName .. "> already exists in the game - need to update its status")
		end
	end
	
	-- Iterate over servers on GCP and add them to the local cluster if needed
	for key,value in pairs(cluster["nodes"]) do
		local serverName = key
		-- Print("server index=" .. serverName)
		if not self:FindLocalServerByName(serverName) then
			--Print("Adding new server from GCP")
			self:AddServerWithProperties(key,value)
		end
	end
	
end

--[[-------------------------------------------------
Extract info about the GKE cluster @clusterName from the @cloudAssets
This is done purely for display purposes.

This is the structure of the return value expected

	local clusterInfo = {
		info = {
			name = "Team-A-Cluster-s",
			project = "ProjectXYZ-s",
			numServers = 3,
			region = "us-central1-s",
		},
		services = {
		    { name = "svcA-s", numContainers = 10, secure = "Secure" },
		    { name = "svcB-s", numContainers = 23, secure = "Secure" },
		    { name = "svcC-s", numContainers = 4, secure = "Secure" },
		    { name = "svcD-s", numContainers = 9, secure = "Not Secure" },
		}
	}
---------------------------------------------------]]
function ClusterManagerScript:ParseClusterInfo(cloudAssets, projectName, clusterName)
	local project = cloudAssets["GoogleCloud"]["projects"][projectName]
	if project == nil then
		Print("Project with the name <" .. projectName .. "> is not found")
		return nil
	end
	
	local cluster = project["clusters"][clusterName]
	if cluster == nil then
		Print("Cluster with the name <" .. clusterName .. "> is not found")
		return nil
	end	
	
	local info = {}
	info["name"] = clusterName
	info["project"] = project["id"]
	info["region"] = cluster["region"]
	info["numServers"] = self:tablelength(cluster["nodes"])
	
	local services = {}
	-- iterate over all nodes and count services and their container instances
	for key,value in pairs(cluster["nodes"]) do
		--Print("key=" .. key)
		if value["deployments"] ~= nil then
			for deployment,spec in pairs(value["deployments"]) do
				--Print("deployment=" .. deployment)
			end
		end
	end
		
	local deployments = cluster["nodes"]["Node1"]["deployments"]
	local i = 1
	for key,value in pairs(deployments) do
		--Print("key=" .. key)
		services[i] = {}
		services[i]["name"] = key
		services[i]["numContainers"] = value.instances
		services[i]["secure"] = value.security
		i = i+1
	end
	
	local clusterData = {}
	clusterData["info"] = info
	clusterData["services"] = services
	--Print("---------- name INSIDE=" .. clusterData.info.name)
	return clusterData
end

-------------------------------------------------
-- Find server in local config
-------------------------------------------------
function ClusterManagerScript:FindLocalServerByName(serverName)
	for key,value in pairs(self.allServers) do
		local localServerName = value.ServerManagerScript.serverName
		if localServerName == serverName then
			return true -- Found server with matching name
		end
	end
	return false -- Server with proper name was not found
end

-------------------------------------------------
-- Add new server to the cluster 
-------------------------------------------------
function ClusterManagerScript:AddServerWithProperties(name, serverProperties)
	local numServers = self:tablelength(self.allServers)
	if (numServers >= self.maxServers) then
		Print("ClusterManager: Reached max number of " .. self.maxServers .. " servers per cluster")
		return
	end
	
	self:GetEntity():PlayEffect(self.properties.energyEffectAdd.effect)
	numServers = numServers + 1
	-- Print("ClusterManager: Adding new server #".. numServers)
	local server = self.properties.serverLocator:Clone()
	server.ServerManagerScript.serverName = name
	server.ServerManagerScript.serverProperties = serverProperties
	--self:PrintTable(serverProperties, 1)
	
	self.allServers[numServers] = server
	server:SetPosition(self:GetEntity():GetPosition() + Vector.New(self.xOffset,self.yOffset + self.ySpacing * (numServers -1),0))
	self.properties.addSound:Clone().active = true
	server.ServerManagerScript:ShowServer()
end

-------------------------------------------------
-- Add new server to the cluster 
-------------------------------------------------
function ClusterManagerScript:AddServer()
	local serverProperties = {}
	self:AddServerWithProperties("defaultServer", serverProperties)
end

-------------------------------------------------
-- Remove one server from the cluster
-------------------------------------------------
function ClusterManagerScript:RemoveServerByName(serverName, removeAllMatching)
	Print("--------removing server by name=" .. serverName)
	
	-- TODO: for some reason the location of this effect is off - it is on ADD button instead of REMOVE
	--self:GetEntity():PlayEffect(self.properties.energyEffectRemove.effect)
	
	-- Find server with the needed name
	local lastFoundMatch = 0
	for key,server in pairs(self.allServers) do
		--Print("---key="..key.." name="..server.ServerManagerScript.serverName)
		if serverName == server.ServerManagerScript.serverName then
			if removeAllMatching then
				self.allServers[key]:Destroy()
				self.allServers[key] = nil
				self.properties.destroySound:Clone().active = true
			else
				-- Record the position of the server with name match
				lastFoundMatch = key
			end
		end
	end
	
	-- If we found any server with matching name - destroy the last one found
	if (not removeAllMatching) and (lastFoundMatch > 0) then
		self.allServers[lastFoundMatch]:Destroy()
		self.allServers[lastFoundMatch] = nil
		self.properties.destroySound:Clone().active = true
	end
end

-------------------------------------------------
-- Remove one server from the cluster
-------------------------------------------------
function ClusterManagerScript:RemoveServer()
	--Print("-----removing the last server on the list")
	local numServers = self:tablelength(self.allServers)
	if (numServers <= 0) then
		Print("ClusterManager: No more servers to remove")
		return
	end
	
	local removeAllMatching = false
	self:RemoveServerByName(self.allServers[numServers].ServerManagerScript.serverName, removeAllMatching)
end

-------------------------------------------------
-- Read info about the GCP project (for now just statically assign it, but later need to read it from GCP)
-------------------------------------------------
function ClusterManagerScript:ReadCloudStatus()
--Print("ClusterManager:ReadCloudStatus()")
local cluster = {
            region = "us-east1",
            nodes = {
              Node1 = {
                mem = "3GB",
                cpus = "2",
                deployments = {
                  ShoppingCart = {
                    namespace = "shopping",
                    instances = 1,
                    security = "mTLS"
                  },
                  Frontend = {
                    namespace = "shopping",
                    instances = 3,
                    security = "mTLS"
                  },
                  Checkout = {
                    namespace = "shopping",
                    instances = 3,
                    security = "mTLS"
                  },
                  Order = {
                    namespace = "shopping",
                    instances = 2,
                    security = "mTLS"
                  }
                }
              }
            }
          }

local project = {
        id = "team-a-project-id-123",
        vpc = "network-proj1",
        owner = "userA",
        clusters = {
          Cluster123 = {}
        }
      }
      
self.CloudAssets = {
  GoogleCloud = {
    org = "myOrganization",
    billing = "billingInfo",
    projects = {
      Project2 = {
        id = "19238747444"
      }
    }
  },
-- Second cloud
    AmazonCloud = {
      type = "cloud",
      Project3 = {
        id = "1923333333"
      }
    }
  }

self.CloudAssets["GoogleCloud"]["projects"][self.projectName] = project

self.CloudAssets["GoogleCloud"]["projects"][self.projectName]["clusters"][self.clusterName] = cluster
	-- Debug print
	--print("About to print the contents of CloudAssets...")
	--self:PrintTable(self.CloudAssets,1)
	--print("=========== Print direct value...")
	--print("Cluster name: " .. self.CloudAssets["GoogleCloud"]["projects"]["Project1"]["id"])
end

-------------------------------------------------
-- Global variable to hold lots of spaces
-------------------------------------------------
Prefix = "                                                        "

-------------------------------------------------
-- Print assets recursively
-------------------------------------------------
function ClusterManagerScript:PrintTable(assets, level)
  local prefix = string.sub(Prefix,1,3*level)
--  print(prefix .. "----- List of assets at L-" .. level)
  for key,value in pairs(assets) do
    if (type(value) == "table") then
      Print(prefix .. "L-" .. level .. ": " .. key)
      self:PrintTable(value, level + 1)
    else
      Print(prefix .. "L-" .. level .. ": " .. key .. "=" .. tostring(value))
    end
  end
end

-------------------------------------------------
-- Universal function that returns the length of the table
-------------------------------------------------
function ClusterManagerScript:tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

return ClusterManagerScript
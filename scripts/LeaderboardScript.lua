local LeaderboardScript = {}

LeaderboardScript.Properties = {
	{ name = "leaderboardName", type = "string", default = "highScore", },
	{ name = "maxEntries", type = "number", default = 10, max = 10, min = 1,},
	{ name = "noEntriesMsg", type = "text", },
	{ name = "resetMsg", type = "text", },
	{ name = "timeFormat", type = "string", default = "{mm}:{ss}.{ms}", },
}

function LeaderboardScript:Init()

	self:Schedule(
		function()
			while true do
				self:UpdateLeaderboard()
				Wait(60)
			end
		end
	)

end

function LeaderboardScript:UpdateLeaderboard()
	if self.properties.leaderboardName ~= '' then
			Leaderboards.GetTopValues(
				self.properties.leaderboardName, self.properties.maxEntries,
				function(entries)
					if IsClient() then
						self:ClientSetEntries(entries)
					else
						self:SendToAllClients("ClientSetEntries", entries)
					end
				end
			)
	end
end

function LeaderboardScript:ClientInit()
	
	self.leaderboardWidget = self:GetEntity().leaderboardWidget
	self.leaderboardWidget.leaderboard.entries = {}
	self.leaderboardWidget.leaderboard.noEntriesMsg = self.properties.noEntriesMsg
	self.leaderboardWidget.leaderboard.resetMsg = self.properties.resetMsg
	self.leaderboardWidget.leaderboard.isPeriodic = false
	self.isPeriodic = false

	Leaderboards.GetMetadata(self.properties.leaderboardName,
		function(metadata)
			if metadata == nil then	
				Print("Leaderboard: Error leaderboard not found " .. self.properties.leaderboardName)
				return
			end
			
			self.leaderboardWidget.leaderboard.title = metadata.displayName
			self.scoreIsTime = (metadata.type == "seconds")

			self.isPeriodic = metadata.isPeriodic
			if self.isPeriodic then
				self.resetTime = metadata.resetTime
				self.leaderboardWidget.leaderboard.isPeriodic = true
			end
			
			self:UpdateLeaderboard()
		end
	)
		
end

function LeaderboardScript:ClientSetEntries(entries)
	for _, entry in ipairs(entries) do
		entry.score = self:FormatScore(entry.score)
		entry.isLocal = (entry.user == GetWorld():GetLocalUser())
		entry.user = nil -- remove from table
	end
	if self.isPeriodic then
		self.leaderboardWidget.leaderboard.resetValue = self:FormatTimeRemaining(self.resetTime - GetWorld():GetUTCTime())
	end
	self.leaderboardWidget.leaderboard.entries = entries
end

function LeaderboardScript:FormatScore(score)
	return self.scoreIsTime and Text.FormatTime(self.properties.timeFormat, score) or score
end

function LeaderboardScript:FormatTimeRemaining(timeRemaining)
	local oneHour = 60 * 60
	local oneDay = 24 * oneHour
	if timeRemaining < oneHour then
		return "<1h"
	elseif timeRemaining < oneDay then
		return math.floor(timeRemaining / oneHour) .. "h"
	else
		return math.floor(timeRemaining / oneDay) .. "d"
	end
end


return LeaderboardScript

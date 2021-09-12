local ScoreTrackerScript = {}

-- Script properties are defined here
ScoreTrackerScript.Properties = {
	{name = "score", type="number", editable =false, default =0}
}

ScoreTrackerScript.saveVersion = 1

--This function is called on the server when this entity is created
function ScoreTrackerScript:Init()
	self:LoadScore()
end

function ScoreTrackerScript:AddScore(score)
	self.properties.score = self.properties.score + score
	self:SaveScore()
end

function ScoreTrackerScript:SetScore(score)
	--Print("ScoreTrackerScript:SetScore(" .. tostring(score) .. ")")
	self.properties.score = score
	self:SaveScore()
end

function ScoreTrackerScript:LoadScore()
	self:GetSaveData(
		function(saveData)
			if saveData and saveData.saveVersion == ScoreTrackerScript.saveVersion then
				self.properties.score = saveData.score
			end
		end
	)
end

function ScoreTrackerScript:SaveScore()
	self:SetSaveData(
		{
			saveVersion = ScoreTrackerScript.saveVersion,
			score = self.properties.score
		}
	)
	
	self:GetEntity():SetLeaderboardValue("HighScores", self.properties.score)
end

return ScoreTrackerScript

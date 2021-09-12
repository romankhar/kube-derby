local GlobalVariablesScript = {}

function GlobalVariablesScript:PlaySuccessSound(player, hitresult, callingEntity)
	callingEntity:PlaySound(GetWorld():Find("quizSuccessSound").sound) 
end

return GlobalVariablesScript
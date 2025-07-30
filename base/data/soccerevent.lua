local redGoalPosition = Position(682, 1179, 6)
local redGoalPosition2 = Position(683, 1179, 6)
local blueGoalPosition = Position(682, 1191, 6)
local blueGoalPosition2 = Position(683, 1191, 6)

function onAddItem(moveitem, tileitem, position)

	if moveitem:getId() == 10017 and (position == redGoalPosition or position == redGoalPosition2) then
		print("gol blue")
		soccerEventRestartMatch(false, true)
		moveitem:remove()
	end

	if moveitem:getId() == 10017 and (position == blueGoalPosition or position == blueGoalPosition2) then
		print("gol red")
		soccerEventRestartMatch(true, false)
		moveitem:remove()
	end
	
	return true
end

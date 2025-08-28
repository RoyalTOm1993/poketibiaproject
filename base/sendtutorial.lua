function onStepIn(creature, item, position, fromPosition)
	if not creature:isPlayer() then
		return false
	end

	if creature:getStorageValue(storageTutorial) == 1 then
		return false
	end

	if creature:getLastLogout() > 0 then
		return false
	end

	doSendTutorial(creature:getId())
	creature:setStorageValue(storageTutorial, 1)

	return true
end

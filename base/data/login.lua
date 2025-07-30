local creatureevent = CreatureEvent("onLoginRev")

function creatureevent.onLogin(player)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Welcome Ao PokeMaster!")
	return true
end

creatureevent:register()


local creatureevent = CreatureEvent("onLogoutRev")

function creatureevent.onLogout(player)
	return true
end

creatureevent:register()
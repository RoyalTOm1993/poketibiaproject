function init()
end

function terminate()
end

function sendRequest(type)
	g_game.getProtocolGame():sendExtendedOpcode(1, type)
end
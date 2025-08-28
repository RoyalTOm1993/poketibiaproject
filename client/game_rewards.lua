mainWindow, buttonRewards = nil
local OPCODE = 88
local acceptWindow = {}

function init()
    mainWindow = g_ui.loadUI("game_rewards", modules.game_interface.getRootPanel())
	mainWindow:hide()
    connect(g_game, { onGameEnd = function()  mainWindow:hide() end, onGameStart = function() mainWindow:hide() end} )
    --buttonRewards = modules.client_topmenu.addRightGameToggleButton("giftCode", tr("Redeem Code"), "/images/topbuttons/gift", toggleRewards, true)
end

function terminate()
	mainWindow:hide()
    mainWindow:destroy()
    disconnect(g_game, { onGameEnd = function()  mainWindow:hide() end, onGameStart = function() mainWindow:hide() end} )
    if buttonRewards then
        buttonRewards:destroy()
        buttonRewards = nil
    end
end

local function sendBuffer(code)
    local buffer = {
        type = "doRedeemCode",
        info = {
			code = code
        }
    }
    g_game.getProtocolGame():sendExtendedOpcode(OPCODE, json.encode(buffer))
end

function toggleRewards()
    if mainWindow:isVisible() then
        mainWindow:hide()
    else
        mainWindow:show()
    end
end

function redeemCode()
    local text = mainWindow.code:getText()
    if #text <= 3 then
        mainWindow.code:clearText()
        invalidCode()
        return
    end
	sendBuffer(text)
	mainWindow.code:clearText()
end

function invalidCode()

    local acceptFunc = function()
      acceptWindow[#acceptWindow]:destroy()
      acceptWindow = {}
    end
	
    if #acceptWindow > 0 then
      acceptWindow[#acceptWindow]:destroy()
    end
	local text = "Código Invalido"
	acceptWindow[#acceptWindow + 1] =
		displayGeneralBox("Error", text,
		{
			{text = tr("Ok"), callback = acceptFunc},
       anchor = AnchorHorizontalCenter
		}, acceptFunc)

end
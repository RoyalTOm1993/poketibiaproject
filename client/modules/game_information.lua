local mainWindow

local OPCODE = 89

function init()
    mainWindow = g_ui.loadUI("game_information", modules.game_interface.getRootPanel())
    ProtocolGame.registerExtendedOpcode(OPCODE, receiveOpcode)
    mainWindow:hide()
    connect(g_game, { onGameStart = function()  mainWindow:hide() end, onGameEnd = function()  mainWindow:hide() end} )
end

function terminate()
    mainWindow:hide()
    mainWindow:destroy()
    ProtocolGame.unregisterExtendedOpcode(OPCODE, receiveOpcode)
	disconnect(g_game, { onGameStart = function()  mainWindow:hide() end, onGameEnd = function()  mainWindow:hide() end} )
end


function receiveOpcode(protocol, opcode, buffer)
    local data = json.decode(buffer)
    if data then
        local image = data.image
        local imageSize = data.size -- '64 64'

        mainWindow:setImageSource("assets/" .. image)
        mainWindow:setSize(imageSize)
        mainWindow:show()
        local widget = g_ui.createWidget("InfoButton", mainWindow)
        connect(widget, {  onGameEnd = function()  self:destroy() end} )
    end
    return
end
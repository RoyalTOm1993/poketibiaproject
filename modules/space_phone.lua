local mainWindow = nil
local windowOpen = true
function init()
  mainWindow = g_ui.loadUI("space_phone", modules.game_interface.getRightPanel())
  windowOpen = true
  mainWindow:hide()
  mainWindow:setup()
  mainWindow:getChildById('miniwindowScrollBar'):hide()
end

function terminate()
	mainWindow:hide()
    mainWindow:destroy()
end

function toggle()
	if windowOpen then
		mainWindow:open()
		windowOpen = false
	else
		mainWindow:close()
		windowOpen = true
	end
end
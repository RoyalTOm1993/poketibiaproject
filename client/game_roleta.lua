local mainWindow, createdWindow = nil
local opcode = 78
local currentTime = os.time()

function init()
	mainWindow = g_ui.loadUI("game_roleta", modules.game_interface.getRootPanel())
	ProtocolGame.registerExtendedOpcode(opcode, receiveOpcode)
	mainWindow:hide()
end

function terminate()
	mainWindow:hide()
   mainWindow:destroy()
	ProtocolGame.unregisterExtendedOpcode(opcode, receiveOpcode)
end

function toggle()
	if mainWindow:isVisible() then
		mainWindow:hide()
	else
		mainWindow:show()
	end
end

local angle = 0
local total = 0
local initialCooldown = 20 -- Tempo de espera inicial em milissegundos
local minCooldown = 50 -- Tempo de espera mínimo em milissegundos
local totalRotations = 3 -- Número total de rotações antes de parar
local event = nil

function updateRotation()
    if angle >= totalRotations * 360 then
        print("Stopping rotation.")
        total = 0
        angle = 0
        return
    end
    print(string.format("Angle: %d, Number: %d", angle, total))
    mainWindow.roletaMain:setRotation(angle)
    total = total + 1
    angle = angle + 10
end 

function startRotation()
	-- mainWindow:setImageSource("images/back2")
    local function rotateWithCooldown()
        local progress = angle / (totalRotations * 360)
        local cooldown = initialCooldown * (1 - progress) + minCooldown * progress
        updateRotation()
        if angle < totalRotations * 360 then
            event = scheduleEvent(rotateWithCooldown, cooldown)
        end
    end
    rotateWithCooldown()
end

function stop()
	removeEvent(event)
end

function receiveOpcode(protocol, opcode, buffer)

end

function sendBuffer(id, bufferType, value)
    local buffer = {
        type = bufferType, 
		id = id,
		value = value
		--[[
			type = withdraw / deposit
			id = currencyId
			value = value
		]]
    }
    g_game.getProtocolGame():sendExtendedOpcode(opcode, json.encode(buffer))
end
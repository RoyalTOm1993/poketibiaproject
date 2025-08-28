function onDeath(creature)
    local creatureName = creature:getName():lower()
    
    if creatureName == "greninja" then
        local player = creature:getKiller()
        
        if player then
            local playerName = player:getName()
            local message = "O treinador " .. playerName .. " derrotou um " .. creatureName .. "!"
            Game.broadcastMessage(message, MESSAGE_EVENT_ADVANCE)
            print("Mensagem exibida:", message)
        end
    end
    
    return true
end

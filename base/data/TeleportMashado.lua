function onUse(cid, item, frompos, item2, topos)
    local player = Player(cid) -- Create a Player object

    local teleportPosition = Position(4155, 2539, 5) -- Create a Position object

    player:teleportTo(teleportPosition) -- Teleport the player to the specified position
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você foi teleportado.") -- Send a text message to the player

    return true
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
    local player = Player(cid) -- Create a Player object
    local teleportPos = Position(4304, 2560, 2) -- Create a Position object for teleportation

    player:teleportTo(teleportPos) -- Teleport the player to the specified position
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você foi teleportado.") -- Send a text message to the player

    return true
end

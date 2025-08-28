function onStepIn(cid, position, fromPosition)
    if (isPlayer(cid) and math.random(1000, 5000) <= 1) then -- check if the creature is a player and has a 30% chance of dropping the item
        local playerName = getCreatureName(cid) -- get the name of the player who triggered the event
        doCreateItem(20670, 1, position) -- drop the item with action ID 3234 at the player's position
        doSendMagicEffect(position, 28) -- play a visual effect to indicate the item has dropped
        doBroadcastMessage("Parabéns, " .. playerName .. "! achou um baú do tesouro.", MESSAGE_EVENT_ADVANCE) -- notify all players on the server
    end
    return true
end

local bosses = {
	"Boss Giratina Held",
    -- Add more bosses as needed
}

function onKill(cid, target, lastHit)
    if isPlayer(cid) then
        local creatureName = getCreatureName(target)

        -- Check if the killed creature is any of the specified bosses
        for _, bossName in ipairs(bosses) do
            if creatureName == bossName then
                -- Increment player's storage value for all bosses by 1
                local currentCount = getPlayerStorageValue(cid, 52392) or 0
                setPlayerStorageValue(cid, 52392, currentCount + 1)

                -- Informative message to the player
                local monsterFormatted = bossName:gsub("(%a)([%w_']*)", function(first, rest)
                    return first:upper() .. rest:lower()
                end)
                local playerMessage = string.format("[Boss Global Held] Você derrotou um %s. Você agora tem %d Held points!",
                    monsterFormatted, currentCount + 1)
                doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, playerMessage)

                -- Global message
                local globalMessage = string.format("[Boss Global Held] %s derrotou o %s!",
                    getPlayerName(cid), monsterFormatted)
                doBroadcastMessage(globalMessage, MESSAGE_EVENT_ADVANCE)

                -- Add the item reward (adjust item ID as needed)
                doPlayerAddItem(cid, 11826, 1, false, 1, CONST_SLOT_BACKPACK)

                break -- Exit the loop since we found the matching boss
            end
        end
    end
    return true
end

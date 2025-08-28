-- List of Pokémon that the NPC will buy from players, along with their prices in Black Diamonds
local buyablePokemon = {
["Suicune"] = 25,
["Raikou"] = 25, 
["Entei"] = 25,
["Regirock"] = 50, 
["Registeel"] = 50,
["Regice"] = 50, 
["Kyogre"] = 75,
["Rayquaza"] = 75, 
["Groudon"] = 75,
["Mesprit"] = 75, 
["Azelf"] = 75,
["Uxie"] = 75, 
["Deoxys"] = 100,
["Regigigas"] = 100, 
["Zekrom"] = 125,
["Reshiram"] = 125, 
["Celebi"] = 125,
["Phione"] = 50, 
["Manaphy"] = 100,
["Giratina"] = 150, 
["Mew"] = 100,
["Mewtwo"] = 150, 
["Lugia"] = 100, 
["Ho-oh"] = 200, 
["Genesect"] = 150, 
["Jirachi"] = 150, 
["Victini"] = 150, 
["Darkrai"] = 150, 
["Dialga"] = 150, 
["Heatran"] = 200, 
["Mini Hoopa"] = 250, 
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)
    npcHandler:onCreatureAppear(cid)
end

function onCreatureDisappear(cid)
    npcHandler:onCreatureDisappear(cid)
end

function onCreatureSay(cid, type, msg)
    npcHandler:onCreatureSay(cid, type, msg)
end

function onThink()
    npcHandler:onThink()
end

function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then
        return false
    end
    
    msg = firstToUpper(msg)

    if msgcontains(msg, 'bye') then
        selfSay('Ok then.', cid)
        npcHandler:releaseFocus(cid)
    elseif msgcontains(msg, 'name') or msgcontains(msg, 'sell') or msgcontains(msg, 'buy') then
        selfSay('Just say the name of the Pokémon you wanna sell me.', cid)
    else
        local player = Player(cid)
        local monsterType = MonsterType(msg)

        if monsterType then
            local balls = player:getPokeballsCached()
            for i=1, #balls do
                local ball = balls[i]
                local name = firstToUpper(ball:getSpecialAttribute("pokeName"))
                if name == msg then
                    -- Check if the Pokémon is in the buyablePokemon list
                    local price = buyablePokemon[name]
                    if price == nil then
                        selfSay('I do not want to buy this Pokémon.', cid)
                        return true
                    end
                    
                    local isBallBeingUsed = ball:getSpecialAttribute("isBeingUsed")
                    if isBallBeingUsed and isBallBeingUsed == 1 then
                        selfSay('Sorry, not possible while using the Pokémon.', cid)
                        return true
                    end

                    if ball:remove() then
                        selfSay('Take ' .. price .. ' Black Diamonds for your ' .. name .. '.', cid)
                        player:addItem(12237, price) -- Add Black Diamonds to player's inventory
                        doSendPokeTeamByClient(player)
                    end
                    return true
                end
            end
            selfSay('You do not have this Pokémon.', cid)
        else
            selfSay('I do not like this Pokémon.', cid)
        end
    end
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())

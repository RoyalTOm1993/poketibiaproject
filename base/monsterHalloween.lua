local baseStorage = 624500
local HalloweenPoint = baseStorage - 1
local missions = {
  ["Halloween Jirachi"]   = {totalKills = 10000, reward = "Halloween Jirachi", type = "POKEMON", storage = baseStorage + 1},
  ["Halloween Exeggutor"]   = {totalKills = 10000, reward = "Halloween Exeggutor", type = "POKEMON", storage = baseStorage + 2},
  ["Halloween Guzzlord"]   = {totalKills = 10000, reward = "Halloween Guzzlord", type = "POKEMON", storage = baseStorage + 3},
  ["Halloween Meloetta"]   = {totalKills = 10000, reward = "Halloween Meloetta", type = "POKEMON", storage = baseStorage + 4},
  ["Halloween Venusaur"]   = {totalKills = 10000, reward = "Halloween Venusaur", type = "POKEMON", storage = baseStorage + 5},
  ["Halloween Xurkitree"]   = {totalKills = 10000, reward = "Halloween Xurkitree", type = "POKEMON", storage = baseStorage + 6},
  ["Esquelect Regigigas"]  = {totalKills = 500, reward = 21261, quantity = 1, type = "ITEM", storage = baseStorage + 7},
  ["Halloween Regigigas"] = {totalKills = 500, reward = 2992, type = "OUTFIT", storage = baseStorage + 8},
  -- ["Halloween Meloetta"]  = {totalKills = 10, reward = 2160, quantity = 1, type = "ITEM", storage = baseStorage + 3},
}

function onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
    local player = killer
    local halloweenPokemon = creature:getName()
      if missions[halloweenPokemon] then
        local sto = math.max(player:getStorageValue(missions[halloweenPokemon].storage), 0)
        local pointSto = math.max(player:getStorageValue(HalloweenPoint), 0 )
        local totalKills = missions[halloweenPokemon].totalKills
        local reward = missions[halloweenPokemon].reward
        local type = missions[halloweenPokemon].type

        player:setStorageValue(HalloweenPoint, pointSto + 1)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE,"Pontos de Halloween: " .. player:getStorageValue(HalloweenPoint))
        if sto >= totalKills then return true end

        player:setStorageValue(missions[halloweenPokemon].storage, sto + 1)
        sto = player:getStorageValue(missions[halloweenPokemon].storage)
        
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE,"Você matou um " .. halloweenPokemon .. " contagem: " .. sto .. "/" .. totalKills)

        
        if sto >= totalKills then
          player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Você concluiu a missão! verifique sua recompensa no seu inventário ou depot!")
           Game.broadcastMessage(player:getName() .. " Concluiu a missão de Halloween: " .. halloweenPokemon .. " Parabéns!", MESSAGE_EVENT_ADVANCE)
            if type == "POKEMON" then
                 doAddPokeball(player, reward)
            elseif type == "OUTFIT" then
                player:addOutfit(reward)
            elseif type == "ITEM" then
            local quantity = missions[halloweenPokemon].quantity
                player:addItem(reward, quantity)
            end
        end
         
      end
    return true
end

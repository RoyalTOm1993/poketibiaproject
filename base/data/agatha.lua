local pokemons = 
{
	[1] = { name = "Mismagius", level = 100 },
	[2] = { name = "Dusknoir", level = 100 },
	[3] = { name = "Spiritomb", level = 100 },
	[4] = { name = "Chandelure", level = 100 },
	[5] = { name = "Alolan Marowak", level = 100 },
	[6] = { name = "Mega Sableye", level = 100 }
}

-- IDs das pokébolas a serem checadas
local pokeballIds = { 26670, 26677 }

-- Storage para controle de vitória no duelo
local STORAGE_WIN_DUEL = 1000

-- Função para buscar recursivamente um item em um container
local function searchItemInContainer(container, id)
  for i = 0, container:getSize() - 1 do
    local item = container:getItem(i)
    if item then
      if item:getId() == id then
        return item
      end
      if item:isContainer() then
        local found = searchItemInContainer(item, id)
        if found then
          return found
        end
      end
    end
  end
  return nil
end

-- Função para obter todos os itens do inventário do jogador.
-- Essa função deve ser adaptada conforme as funções disponíveis no seu servidor.
local function getInventoryItems(player)
  local items = {}
  -- Se o servidor possuir a função nativa, use-a:
  if player.getInventoryItems then
    items = player:getInventoryItems()
  else
    -- Caso não haja função nativa, podemos simular obtendo os itens de cada slot.
    -- Aqui assumimos que os slots do inventário são os de 0 a 9 (ajuste conforme necessário).
    for slot = 0, 9 do
      local item = player:getSlotItem(slot)
      if item then
        table.insert(items, item)
      end
    end
  end
  return items
end

-- Função para buscar um item em todos os itens do inventário do jogador
local function searchItemInInventory(player, id)
  local items = getInventoryItems(player)
  for _, item in ipairs(items) do
    if item:getId() == id then
      return item
    end
    if item:isContainer() then
      local found = searchItemInContainer(item, id)
      if found then
        return found
      end
    end
  end
  return nil
end

-- Função auxiliar que checa se o jogador tem pelo menos um Pokémon vivo.
-- Primeiro verifica se o jogador já tem um summon ativo. Se não, procura
-- nos itens do inventário por uma pokébola com "pokeHealth" > 0.
local function hasAnyAlivePokemon(player)
  -- Se o jogador já tiver um summon, consideramos que ele tem um Pokémon vivo
  if #player:getSummons() > 0 then
    return true
  end

  -- Procura nos itens do inventário
  for _, id in ipairs(pokeballIds) do
    local item = searchItemInInventory(player, id)
    if item then
      local pokeHealth = item:getSpecialAttribute("pokeHealth")
      if pokeHealth and pokeHealth > 0 then
        return true
      end
    end
  end
  return false
end

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

function creatureGreetCallback(cid, message)
    if message == nil then
        return true
    end
    if npcHandler:hasFocus() then
        selfSay("Espere sua vez, " .. Player(cid):getName() .. "!")
        return false
    end
    return true
end

function creatureSayCallback(cid, type, msg)
    if not npcHandler:isFocused(cid) then
        return false
    end	
    if msgcontains(msg, 'bye') or msgcontains(msg, 'no') or msgcontains(msg, 'nao') then
        selfSay('Volte quando estiver pronto!', cid)
        npcHandler:releaseFocus(cid)
    elseif (msgcontains(msg, 'yes') or msgcontains(msg, 'sim')) and not Player(cid):getParty() then
        local player = Player(cid)
        if player then
            -- Verifica se o jogador já ganhou o duelo anteriormente
            if player:getStorageValue(STORAGE_WIN_DUEL) == 1 then
                selfSay("Você já ganhou o duelo e não pode desafiar novamente!", cid)
                npcHandler:releaseFocus(cid)
                return true
            end
            selfSay('Te derrotarei com todos meus pokemons!', cid)
            npcHandler.topic[cid] = 1
            npcHandler:setMaxIdleTime(600)
            player:setDuelWithNpc()
        end
    elseif Player(cid):getParty() then
        selfSay('Saia do grupo para me enfrentar!', cid)
        npcHandler:releaseFocus(cid)
    end
    return true
end

function creatureOnReleaseFocusCallback(cid)
    local npc = Npc()
    if hasSummons(npc) then
        local monster = npc:getSummons()[1]
        monster:getPosition():sendMagicEffect(balls.pokeball.effectRelease)
        monster:remove()
    end
    local player = Player(cid)
    if player then
        player:unsetDuelWithNpc()
    end
    return true
end

function creatureOnDisapearCallback(cid)
    local player = Player(cid)
    if not player then
        npcHandler:updateFocus()
        return true
    end
    if npcHandler:isFocused(cid) then
        if getDistanceTo(cid) >= 0 and getDistanceTo(cid) <= 8 then
            return false
        end
        selfSay("Mais sorte na proxima tentativa, " .. player:getName() .. "!", cid)
        player:teleportTo(Position(283, 869, 7))
        npcHandler:releaseFocus(cid)
    end
    return true
end

function creatureOnThinkCallback()
    if npcHandler:hasFocus() then
        local npc = Npc()
        local npcPosition = npc:getPosition()
        local spectators = Game.getSpectators(npcPosition, false, true)
        for i = 1, #spectators do
            local player = spectators[i]
            local cid = player:getId()
            if npcHandler:isFocused(cid) and npcHandler.topic[cid] == 1 then
                local duelStatus = player:getDuelWithNpcStatus()
                local monster = npc:getSummons()[1]
                if not monster then
                    if pokemons[duelStatus] then
                        selfSay(pokemons[duelStatus].name .. ", eu escolho voce!")
                        npcPosition:getNextPosition(npc:getDirection())
                        monster = Game.createMonster(pokemons[duelStatus].name, npcPosition, false, true, pokemons[duelStatus].level, 0)
                        npcPosition:sendMagicEffect(balls.pokeball.effectRelease)
                        monster:setMaster(npc)
                        local health = monster:getTotalHealth() * 10
                        monster:setMaxHealth(health)
                        monster:setHealth(health)
                        -- Removida a linha de alteração de velocidade para manter a velocidade padrão do monstro
                        player:increaseDuelWithNpcStatus()
                    else
                        selfSay('Incrivel, ' .. player:getName() .. "! Talvez voce realmente tenha chances de vencer a liga.", cid)
                        -- Armazena que o jogador já venceu o duelo
                        player:setStorageValue(STORAGE_WIN_DUEL, 1)
                        player:teleportTo(Position(282, 872, 2))
                        npcHandler:releaseFocus(cid)
                    end
                end
                if hasSummons(player) and hasSummons(npc) then
                    monster:selectTarget(player:getSummons()[1])
                end
                -- Checagem: se o jogador não possuir nenhum Pokémon vivo, encerra o duelo
                if not hasAnyAlivePokemon(player) then
                    selfSay("Mais sorte na proxima tentativa, " .. player:getName() .. "!", cid)
                    player:teleportTo(Position(283, 869, 7))
                    npcHandler:releaseFocus(cid)
                end
            end
        end
    end
    return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_ONTHINK, creatureOnThinkCallback)
npcHandler:setCallback(CALLBACK_ONRELEASEFOCUS, creatureOnReleaseFocusCallback)
npcHandler:setCallback(CALLBACK_CREATURE_DISAPPEAR, creatureOnDisapearCallback)
npcHandler:setCallback(CALLBACK_GREET, creatureGreetCallback)
npcHandler:addModule(FocusModule:new())

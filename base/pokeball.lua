-- ===== Nome de exibição: nickname -> fallback prefixos =====
local NAME_PREFIXES = {
  "Shiny", "Mega", "Gigantamax", "Alolan", "Galarian", "Hisuian",
  "Shadow", "Dark", "Ancient", "Primal", "Crystal", "Cyber"
}

local function stripPrefixes(name)
  name = name or ""
  for _, p in ipairs(NAME_PREFIXES) do
    name = name:gsub("^" .. p .. "%s+", "")
  end
  return name
end

-- tenta pegar nickname gravado na pokébola; se não existir, usa pokeName “limpo”
local function getDisplayNameFromBallItem(item)
  if not item then return "" end

  -- tente diferentes chaves comuns para apelido armazenado no item
  local nick = item.getSpecialAttribute and (
      item:getSpecialAttribute("nickname")
      or item:getSpecialAttribute("nick")
      or item:getSpecialAttribute("customName")
      or item:getSpecialAttribute("givenName")
    ) or nil

  if nick and nick ~= "" then
    return nick
  end

  local pokeName = item.getSpecialAttribute and item:getSpecialAttribute("pokeName") or ""
  return stripPrefixes(pokeName)
end

-- ===== Tradução server-side mínima (PT/EN) =====
local function getLang(player)
  return (player and player:getStorageValue(9000) == 1) and "pt-BR" or "en-US"
end

local translations = {
  ["pt-BR"] = {
    ["%s, return!"] = "%s, volte!",
  },
  ["en-US"] = {
    ["%s, return!"] = "%s, return!",
  }
}

local function trServer(player, key)
  local lang = getLang(player)
  return (translations[lang] and translations[lang][key]) or key
end

-- ===== Seus handlers ajustados =====
function onDeEquip(cid, item, slot)
  if slot == CONST_SLOT_AMMO or slot == CONST_SLOT_LEFT then
    local player = Player(cid)
    if player and item:isPokeball() then
      local pokeName = item:getSpecialAttribute("pokeName")
      local monsterType = MonsterType(pokeName)
      if monsterType then
        local portraitId = monsterType:portraitId()
        local putPortrait = player:removeItem(portraitId, 1)
        local portrait = player:getSlotItem(CONST_SLOT_HEAD)
        if not putPortrait and portrait and portrait:getId() ~= portraitId then
          portrait:remove()
          print("WARNING! Problem on remove portrait movements onDeEquip " .. (pokeName or "nil") .. " player " .. player:getName())
        end
      end
    end

    local ballKey = getBallKey(item:getId())
    if player and item:isPokeball() and hasSummons(cid) and player:getSummons()[1]:getHealth() > 0 then
      -- mantido comentado como no seu código original
      -- doRemoveSummon(cid, balls[ballKey].effectRelease, item.uid, true, balls[ballKey].missile)
      -- item:transform(balls[ballKey].usedOn)
    end

    if player and (player:getStorageValue(storageRide) == 1 or player:getStorageValue(storageFly) == 1) then
      player:removeCondition(CONDITION_OUTFIT)
      player:changeSpeed(player:getBaseSpeed() - player:getSpeed())
      player:setStorageValue(storageRide, -1)
      player:setStorageValue(storageFly, -1)

      -- >>> fala com nome do Pokémon usando nickname/fallback
      local displayName = getDisplayNameFromBallItem(item)
      if displayName ~= "" then
        player:say(string.format(trServer(player, "%s, return!"), displayName), TALKTYPE_SAY)
      else
        -- fallback absoluto (sem nome), caso não tenha nada mesmo
        player:say(trServer(player, "%s, return!"):format("buddy"), TALKTYPE_SAY)
      end
    end
  end
  return true
end

function onEquip(cid, item, slot)
  -- criar foto dos pokes
  if slot == CONST_SLOT_AMMO then
    local player = Player(cid)
    if player and item:isPokeball() then
      local pokeName = item:getSpecialAttribute("pokeName")
      if not pokeName then return true end

      local monsterType = MonsterType(pokeName)
      if not monsterType then return true end

      local portraitId = monsterType:portraitId()
      if portraitId == 0 then return true end

      local putPortrait = player:addItem(portraitId, 1, false, 1, CONST_SLOT_HEAD)
      local headItem = player:getSlotItem(CONST_SLOT_HEAD)
      if not putPortrait and headItem and headItem:getId() ~= portraitId then
        print("WARNING! Problem on put portrait movements onEquip " .. pokeName .. " player " .. player:getName())
      end
    end
  end
  return true
end

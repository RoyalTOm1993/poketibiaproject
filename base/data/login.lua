local LANG_STORAGE = 9000
local DEFAULT_LANG  = 1 -- pt-BR

function onLogin(player)
  -- Define idioma na 1a vez (idempotente)
  if player:getStorageValue(LANG_STORAGE) == -1 then
    player:setStorageValue(LANG_STORAGE, DEFAULT_LANG)
  end

  -- Chama o handler principal (envia opcode da última visita, etc.)
  player:loginHandler()
  return true
end

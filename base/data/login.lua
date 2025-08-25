local LANG_STORAGE = 9000
local DEFAULT_LANG  = 1 -- pt-BR

function onLogin(player)
    -- Define o idioma na 1ª vez que o jogador loga
    if player:getStorageValue(LANG_STORAGE) == -1 then
        player:setStorageValue(LANG_STORAGE, DEFAULT_LANG)
    end

    player:loginHandler()
    return true
end

function onLogin(player)
    -- Garante idioma definido (idempotente: só define se ainda não tiver)
    if player:getStorageValue(LANG_STORAGE) == -1 then
        player:setStorageValue(LANG_STORAGE, DEFAULT_LANG)
    end

    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Welcome Ao PokeMaster!")
	return true
end

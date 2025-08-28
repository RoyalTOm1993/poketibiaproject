-- Função para adicionar pontos ao jogador no banco de dados
function doPlayerAddPoint(player)
    local accountId = player:getAccountId()
    local points = db.storeQuery("SELECT `pontos` FROM `accounts` WHERE `id` = " .. accountId)

    if points ~= nil then
        local currentPoints = result.getDataInt(points, "pontos")
        result.free(points)

        -- Atualiza os pontos do jogador no banco de dados
        db.query("UPDATE `accounts` SET `pontos` = " .. currentPoints + 1 .. " WHERE `id` = " .. accountId)
    end
end

-- Função de uso do item para enviar pontos
function onUse(player, item, fromPosition, target, toPosition)
    local accountId = player:getAccountId()
    local points = db.storeQuery("SELECT `pontos` FROM `accounts` WHERE `id` = " .. accountId)

    if points ~= nil then
        local currentPoints = result.getDataInt(points, "pontos")
        result.free(points)

        -- Adiciona um ponto ao jogador no jogo
        doPlayerAddPoint(player)

        -- Remove o item da mochila do jogador
        item:remove(1)

        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você enviou pontos para o site. Total de pontos: " .. currentPoints + 1)
    end

    return true
end

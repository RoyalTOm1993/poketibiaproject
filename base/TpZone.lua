local BLOCKED_TILE_POSITION = {x = 3137, y = 3008, z = 7}  -- Substitua isso pela posição do tile que deseja bloquear

function onStepIn(creature, item, position, fromPosition)
    if not creature:isPlayer() then
        return true
    end

    local player = Player(creature)
    
    if position.x == BLOCKED_TILE_POSITION.x and position.y == BLOCKED_TILE_POSITION.y and position.z == BLOCKED_TILE_POSITION.z then
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "Você não pode se mover aqui!")

        -- Bloquear o movimento do jogador
        player:setNoMove(true)
		local cid = player:getId()
        -- Adicionar um evento para desbloquear o movimento após um certo período de tempo (por exemplo, 3 segundos)
        addEvent(function()
			local player = Player(cid)
			if player then
				player:setNoMove(true)
			end
        end, 3000) -- 3000 milissegundos = 3 segundos
    end

    return true
end

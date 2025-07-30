local bikes = {13531, 13533, 13534, 13535, 13536, 13537, 13540, 13541, 13539, 13538, 13543, 14429, 14430, 14431, 14432, 14433, 14517, 13314, 13532, 15231, 15232, 15233, 15234, 15235}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local bikeBoxIDs = {14511, 15230} -- IDs das "bike boxes"
    local bikeBoxID = item:getId() -- ID da "bike box" usada
    
    local isBikeBox = false
    for _, id in ipairs(bikeBoxIDs) do
        if bikeBoxID == id then
            isBikeBox = true
            break
        end
    end

if isBikeBox then
    local bikeID = bikes[math.random(1, #bikes)] -- Escolhe uma bicicleta aleatória da lista
    player:addItem(bikeID, 1) -- Dá ao jogador a bicicleta escolhida
    item:remove(1) -- Remove a "bike box" do inventário do jogador
    player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE) -- Envia um efeito mágico azul
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Você abriu a bike box e ganhou uma bicicleta!") -- Envia uma mensagem ao jogador
else
    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Você precisa de uma bike box para fazer isso.") -- Mensagem de erro se o item errado for usado
end

    return true
end

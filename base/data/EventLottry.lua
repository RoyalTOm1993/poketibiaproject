LOTTERY_MESSAGE_START = 1
LOTTERY_MESSAGE_FINISH = 2
LOTTERY_MESSAGE_TRY_AGAIN = 3
LOTTERY_MESSAGE_WINNER_MONEY = 4
LOTTERY_MESSAGE_WINNER_ITEM = 5
LOTTERY_MESSAGE_WINNER_MONEY_AND_ITEM = 6
LOTTERY_MESSAGE_CONGRATULATION_MONEY = 7
LOTTERY_MESSAGE_CONGRATULATION_ITEM = 8
LOTTERY_MESSAGE_CONGRATULATION_MONEY_AND_ITEM = 9
LOTTERY_MESSAGE_NOTICE = 10
LOTTERY_MESSAGE_INSUFFICIENT_MONEY = 11
LOTTERY_MESSAGE_INFO = 12
LOTTERY_MESSAGE_ERROR_ACTIVE = 13
LOTTERY_MESSAGE_ERROR_NO_ACTIVE = 14
LOTTERY_MESSAGE_NUMBER_TOO_BIG = 15
LOTTERY_MESSAGE_NUMBER_NOT_FOUND = 16
LOTTERY_REWARD_TYPE_ONLYMONEY = 17
LOTTERY_REWARD_TYPE_ONLYITEM = 18
LOTTERY_REWARD_TYPE_MONEYANDITEM = 19
LOTTERY_REWARD_TYPE_MONEYORITEM = 20

Lottery = {}
Lottery.__index = Lottery

Lottery.config = {
    bet = {id = 12237, count = 10},  -- Use black diamonds as the bet
    reward = LOTTERY_REWARD_TYPE_MONEYORITEM,
    range = 100,
    duration = 5
}

Lottery.rewards = {
    money = 1000,    -- Dinheiro a ser entregue ao jogador
    items = {        -- Items a serem entregues ao jogados (aleatoriamente)
        {id = 12237, count = 1000}
    }
}

Lottery.storages = {
    started = 172836
}

Lottery.messages = {
    prefix = "[LOTERIA]",
    start  = "O evento acaba de começar, digite '!lottery X', onde X é um número de 1 a %d. Boa sorte!",
    finish = "O evento acabou sem nenhum vencedor.",
    try_again = "Não foi dessa vez, tente novamente!",
    winner_money = "Parabéns, %s ganhou %s black diamonds!",
    winner_item = "Parabéns, %s ganhou %s %s!",
    winner_money_and_item = "Parabéns, %s ganhou %s black diamonds e %s %s!",
    congratulation_money = "Parabéns, você ganhou %s black diamonds!",
    congratulation_item = "Parabéns, você ganhou %s %s!",
    congratulation_money_and_item = "Parabéns, você ganhou %s black diamonds e %s %s!",
    notice = "O evento acaba em %d minuto(s).",
    insufficient_money = "Você não possui dinheiro suficiente.",
    info = "Info:\nAposta: %d moedas de ouro\nPrêmio: %s",
    error_active = "A Loteria está ativa.",
    error_no_active = "A Loteria não está ativa.",
    error_number_too_big = "Desculpe, você só pode apostar de 1 a %d.",
    error_number_not_found = "Desculpe, você precisa entrar com um número entre 1 e %d."
}

function Lottery:start()
    print("> [LOTTERY] Event started.")
    Lottery:turnOn()
    Lottery:reset()
    Lottery:setWinningNumber()
    print("> [LOTTERY] Number: " .. Lottery:getWinningNumber())
    local message = string.format(Lottery:getMsg(LOTTERY_MESSAGE_START), Lottery:getRange())
    Lottery:broadcast(message)
    Lottery:notice(Lottery.config.duration - 1, 1)

    addEvent(function()
        if Lottery:isStarted() then
            Lottery:finish()
        end
    end, Lottery:getDurationInMS())
end

function Lottery:finish()
    print("> [LOTTERY] Event finalized.")
    Lottery:turnOff()
    local message

    if Lottery:getWinner() then
        print("> [LOTTERY] Winner: " .. Lottery:getWinner())

        if Lottery:getRewardType() == LOTTERY_REWARD_TYPE_ONLYMONEY then
            message = string.format(Lottery:getMsg(LOTTERY_MESSAGE_WINNER_MONEY), Lottery:getWinner(), Lottery:getReward())
        elseif Lottery:getRewardType() == LOTTERY_REWARD_TYPE_ONLYITEM then
            message = string.format(Lottery:getMsg(LOTTERY_MESSAGE_WINNER_ITEM), Lottery:getWinner(), Lottery:getReward():getCount(), Lottery:getReward():getName())
        elseif Lottery:getRewardType() == LOTTERY_REWARD_TYPE_MONEYANDITEM then
            message = string.format(Lottery:getMsg(LOTTERY_MESSAGE_WINNER_MONEY_AND_ITEM), Lottery:getWinner(), Lottery:getReward()[1], Lottery:getReward()[2]:getCount(), Lottery:getReward()[2]:getName())
        elseif Lottery:getRewardType() == LOTTERY_REWARD_TYPE_MONEYORITEM then
            if tonumber(reward) then
                message = string.format(Lottery:getMsg(LOTTERY_MESSAGE_WINNER_MONEY), Lottery:getWinner(), Lottery:getReward())
            else
                message = string.format(Lottery:getMsg(LOTTERY_MESSAGE_WINNER_ITEM), Lottery:getWinner(), Lottery:getReward():getCount(), Lottery:getReward():getName())
            end
        end
    else
        print("> [LOTTERY] Winner: Nobody")
        message = Lottery:getMsg(LOTTERY_MESSAGE_FINISH)
    end

    Lottery:broadcast(message)
end

function Lottery:isStarted()
    if Game.getStorageValue(Lottery.storages.started) ~= -1 then
        return true
    end
    return false
end

function Lottery:getRange()
    return Lottery.config.range
end

function Lottery:getDurationInMS()
    return Lottery.config.duration * 60 * 1000
end

function Lottery:getBetPrice()
    return Lottery.config.bet
end

function Lottery:broadcast(message)
    for _, targetPlayer in ipairs(Game.getPlayers()) do
        targetPlayer:sendTextMessage(MESSAGE_STATUS_WARNING, message)
    end
end

function Lottery:bet(player, number)
    if tonumber(number) == nil then
        local message = string.format(Lottery:getMsg(LOTTERY_MESSAGE_NUMBER_NOT_FOUND), Lottery:getRange())
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, message)
        return false
    end

    if tonumber(number) > Lottery:getRange() then
        local message = string.format(Lottery:getMsg(LOTTERY_MESSAGE_NUMBER_TOO_BIG), Lottery:getRange())
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, message)
        return false
    end

    -- Check if the player has enough black diamonds
    if not player:removeItem(Lottery.config.bet.id, Lottery.config.bet.count) then
        local message = Lottery:getMsg(LOTTERY_MESSAGE_INSUFFICIENT_MONEY)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, message)
        return false
    end

    if tonumber(number) == Lottery:getWinningNumber() then
        local reward = Lottery:getReward()
        local message

        if Lottery:getRewardType() == LOTTERY_REWARD_TYPE_ONLYMONEY then
            message = string.format(Lottery:getMsg(LOTTERY_MESSAGE_CONGRATULATION_MONEY), reward)
        elseif Lottery:getRewardType() == LOTTERY_REWARD_TYPE_ONLYITEM then
            message = string.format(Lottery:getMsg(LOTTERY_MESSAGE_CONGRATULATION_ITEM), reward:getCount(), reward:getName())
        elseif Lottery:getRewardType() == LOTTERY_REWARD_TYPE_MONEYANDITEM then
            message = string.format(Lottery:getMsg(LOTTERY_MESSAGE_CONGRATULATION_MONEY_AND_ITEM), reward[1], reward[2]:getCount(), reward[2]:getName())
        elseif Lottery:getRewardType() == LOTTERY_REWARD_TYPE_MONEYORITEM then
            if tonumber(reward) then
                message = string.format(Lottery:getMsg(LOTTERY_MESSAGE_CONGRATULATION_MONEY), reward)
            else
                message = string.format(Lottery:getMsg(LOTTERY_MESSAGE_CONGRATULATION_ITEM), reward:getCount(), reward:getName())
            end
        end
        
        Lottery:addReward(player, reward)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, message)
        Lottery:setWinner(player:getName())
        Lottery:finish()
    else
        local message = Lottery:getMsg(LOTTERY_MESSAGE_TRY_AGAIN)
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, message)
    end
end

function Lottery:setWinner(name)
    Lottery.winner = name
end

function Lottery:addReward(player, reward)
    if tonumber(reward) then
        player:addMoney(reward)
    elseif reward[1] ~= nil and reward[2] ~= nil then
        player:addMoney(reward[1])
        player:addItemEx(reward[2])
    else
        player:addItemEx(reward)
    end
end

function Lottery:getRewardType()
    return Lottery.config.reward
end

function Lottery:getWinner()
    return Lottery.winner
end

function Lottery:getReward()
    if Lottery.reward then
        return Lottery.reward
    else
        Lottery:setReward()
        return Lottery.reward
    end
end

function Lottery:getRewardsName()
    local rewards = ""

    if Lottery.rewards.money ~= nil then
        rewards = rewards .. Lottery.rewards.money .. " gold coins"
    end

    for i = 1, #Lottery.rewards.items do
        if i ~= #Lottery.rewards.items then
            rewards = rewards .. ", " .. Lottery.rewards.items[i].count .. "x " .. ItemType(Lottery.rewards.items[i].id):getName()
        else
            rewards = rewards .. ", " .. Lottery.rewards.items[i].count .. "x " .. ItemType(Lottery.rewards.items[i].id):getName() .. "."
        end
    end

    return rewards
end

function Lottery:setReward()
    if Lottery:getRewardType() == LOTTERY_REWARD_TYPE_ONLYMONEY then
        reward = Lottery.rewards.money
    elseif Lottery:getRewardType() == LOTTERY_REWARD_TYPE_ONLYITEM then
        print(#Lottery.rewards.items)
        local rand = math.random(1, #Lottery.rewards.items)
        print(rand)
        reward = Game.createItem(Lottery.rewards.items[rand].id, Lottery.rewards.items[rand].count)
    elseif Lottery:getRewardType() == LOTTERY_REWARD_TYPE_MONEYANDITEM then
        local rand = math.random(1, #Lottery.rewards.items)
        reward = {Lottery.rewards.money, Game.createItem(Lottery.rewards.items[rand].id, Lottery.rewards.items[rand].count)}
    elseif Lottery:getRewardType() == LOTTERY_REWARD_TYPE_MONEYORITEM then
        local rand = math.random(1, 2)

        if rand == 1 then
            reward = Lottery.rewards.money
        else
            rand = math.random(1, #Lottery.rewards.items)
            reward = Game.createItem(Lottery.rewards.items[rand].id, Lottery.rewards.items[rand].count)
        end
    end

    Lottery.reward = reward
end

function Lottery:setWinningNumber()
    Lottery.number = math.random(1, Lottery:getRange())
end

function Lottery:getWinningNumber()
    return Lottery.number
end

function Lottery:reset()
    Lottery.reward = nil
    Lottery.winner = nil
    Lottery.number = nil
end

function Lottery:notice(minutes, i)
    if minutes == 0 then
        return false
    end

    addEvent(function()
        if Lottery:isStarted() then
            local message = string.format(Lottery:getMsg(LOTTERY_MESSAGE_NOTICE), Lottery.config.duration - i)
            Lottery:broadcast(message)
            Lottery:notice(minutes - 1, i + 1)
        end
    end, i * 60 * 1000)
end

function Lottery:turnOn()
    Game.setStorageValue(Lottery.storages.started, 1)
end

function Lottery:turnOff()
    Game.setStorageValue(Lottery.storages.started, -1)
end

function Lottery:getMsg(TYPE)
    if TYPE == LOTTERY_MESSAGE_START then
        return Lottery.messages.prefix .. ' ' .. Lottery.messages.start
    elseif TYPE == LOTTERY_MESSAGE_FINISH then
        return Lottery.messages.prefix .. ' ' .. Lottery.messages.finish
    elseif TYPE == LOTTERY_MESSAGE_TRY_AGAIN then
        return Lottery.messages.prefix .. ' ' .. Lottery.messages.try_again
    elseif TYPE == LOTTERY_MESSAGE_WINNER_MONEY then
        return Lottery.messages.prefix .. ' ' .. Lottery.messages.winner_money
    elseif TYPE == LOTTERY_MESSAGE_WINNER_ITEM then
        return Lottery.messages.prefix .. ' ' .. Lottery.messages.winner_item
    elseif TYPE == LOTTERY_MESSAGE_WINNER_MONEY_AND_ITEM then
        return Lottery.messages.prefix .. ' ' .. Lottery.messages.winner_money_and_item
    elseif TYPE == LOTTERY_MESSAGE_CONGRATULATION_MONEY then
        return Lottery.messages.prefix .. ' ' .. Lottery.messages.congratulation_money
    elseif TYPE == LOTTERY_MESSAGE_CONGRATULATION_ITEM then
        return Lottery.messages.prefix .. ' ' .. Lottery.messages.congratulation_item
    elseif TYPE == LOTTERY_MESSAGE_CONGRATULATION_MONEY_AND_ITEM then
        return Lottery.messages.prefix .. ' ' .. Lottery.messages.congratulation_money_and_item
    elseif TYPE == LOTTERY_MESSAGE_NOTICE then
        return Lottery.messages.prefix .. ' ' .. Lottery.messages.notice
    elseif TYPE == LOTTERY_MESSAGE_INSUFFICIENT_MONEY then
        return Lottery.messages.prefix .. ' ' .. Lottery.messages.insufficient_money
    elseif TYPE == LOTTERY_MESSAGE_INFO then
        return Lottery.messages.prefix .. ' ' .. Lottery.messages.info
    elseif TYPE == LOTTERY_MESSAGE_ERROR_ACTIVE then
        return Lottery.messages.error_active
    elseif TYPE == LOTTERY_MESSAGE_ERROR_NO_ACTIVE then
        return Lottery.messages.error_no_active
    elseif TYPE == LOTTERY_MESSAGE_NUMBER_TOO_BIG then
        return Lottery.messages.prefix .. ' ' .. Lottery.messages.error_number_too_big
    elseif TYPE == LOTTERY_MESSAGE_NUMBER_NOT_FOUND then
        return Lottery.messages.prefix .. ' ' .. Lottery.messages.error_number_not_found
    end
end
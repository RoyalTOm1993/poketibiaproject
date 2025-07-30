dofile('data/lib/systems/EventLottry.lua')

function onTime(interval)
    Lottery:start()
    return true
end
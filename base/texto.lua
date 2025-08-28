local config = {
positions = {
["Monster Zone"] = {x = 3096, y = 2910, z = 6},
["Dimension Zone"] = {x = 3087, y = 2890, z = 6},

}
}

function onThink(interval, lastExecution, thinkInterval)
for text, pos in pairs(config.positions) do
	-- doSendAnimatedText(pos, text, )
	Game.sendAnimatedText(pos, text, math.random(1, 255))
end

return TRUE
end
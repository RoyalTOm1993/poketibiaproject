local items = {
	[15226] = {percentExtra = 20, timeType = "hours", time = 1}, -- 1 hora
	[15227] = {percentExtra = 40, timeType = "hours", time = 1}, -- 1 hora
    [20648] = {percentExtra = 100, timeType = "hours", time = 1}, -- 1 hora
    [20649] = {percentExtra = 160, timeType = "hours", time = 1}, -- 1 hora
    [20651] = {percentExtra = 200, timeType = "hours", time = 1}, -- 1 hora	
    [22664] = {percentExtra = 400, timeType = "hours", time = 1}, -- 1 hora	
	[15229] = {percentExtra = 10, timeType = "days", time = 7}, -- 1 semana
	[15223] = {percentExtra = 20, timeType = "days", time = 7}, -- 1 semana
	
	[15228] = {percentExtra = 20, timeType = "days", time = 30}, -- 1 Mês
	[15224] = {percentExtra = 40, timeType = "days", time = 30}, -- 1 Mês
	[20659] = {percentExtra = 100, timeType = "days", time = 30}, -- 1 Mês
	[20660] = {percentExtra = 160, timeType = "days", time = 30}, -- 1 Mês
	[20661] = {percentExtra = 200, timeType = "days", time = 30}, -- 1 Mês
}

function onUse(cid, item, fromPosition, itemEx, toPosition)

player = Player(cid)
	local expItem = items[item.itemid]
	
	if not expItem then
		return true
	end
	
	local tempo = 0
	local death = false
	
	if expItem.timeType == "days" then
		tempo = expItem.time * 60 * 60 * 24
	else -- Hours
		tempo = expItem.time * 60 * 60
	end
	
	if player:getStorageValue(45144) - os.time() > 1 then
	doPlayerSendTextMessage(player:getId(), 22, "Você ainda tem um Experience Booster ativo de "..player:getStorageValue(45145).."%. Ele irá acabar em "..convertTime(player:getStorageValue(45144) - os.time())..". Lembre-se de que você pode desativar o exp boost a qualquer momento usando o comando !desativeexp.")		return false
	end
	
    item:remove(1)
	player:setStorageValue(45144, tempo + os.time())
	player:setStorageValue(45145, expItem.percentExtra)
	doPlayerSendTextMessage(player:getId(), 22, "Você ativou um Experience Booster de "..expItem.percentExtra.."% a mais, que durará "..(death and "até morrer" or convertTime(tempo))..". Lembre-se de que você pode desativar o exp boost a qualquer momento usando o comando !desativeexp.")	return true
end
local day = 24 * 60 * 60
local hour = 60 * 60
local minutes = 60

local charms = {
	[23149] = {time = ((0 * day) + (1 * hour) + (0 * minutes)), storage = 296582, name = "Fusion Charm"},
	[23151] = {time = ((1 * day) + (0 * hour) + (0 * minutes)), storage = 296582, name = "Fusion Charm"},
	[23152] = {time = ((7 * day) + (0 * hour) + (0 * minutes)), storage = 296582, name = "Fusion Charm"}
}

function onUse(player, item, from_position, target, to_position, is_hotkey)
	local charm = charms[item.itemid]
	if not charm then
		return true
	end

	local charm_storage = charm.storage
	if player:getStorageValue(charm_storage) - os.time() > 0 then
		local remaining_time = player:getStorageValue(charm_storage) - os.time()
		player:setStorageValue(charm_storage, remaining_time + charm.time + os.time())
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format(
			"Voc acaba de adicionar tempo a: %s, novo tempo: %s",
			charm.name, convertTime(remaining_time + charm.time)))
		item:remove(1)
		return true
	end

	player:setStorageValue(charm_storage, charm.time + os.time())
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, string.format(
		"Voc acaba de ativar um %s, com durao de: %s",
		charm.name, convertTime(charm.time)))
	item:remove(1)
	return true
end
PIX_API_URL = ""
API_AUTH_KEY = ""
PIX_OPCODE = 74
PIX_CHARGE_EXPIRATION = 900
PIX_CODES = {
    SHOW_MESSAGE = 1,
    CHECK_CREDENTIALS = 2,
    VALID_CREDENTIALS = 3,
    PIX_PAID_SUCCESS = 4,
    GET_PIX_INFO = 5
}

function getPlayerNameByGUID(guid)
	local resultId = db.storeQuery("SELECT `name` FROM `players` WHERE `id` = " .. guid)
	if(resultId ~= false) then
		local name = result.getDataString(resultId, "name")
		result.free()
		return name
	end
	return nil
end

function getPlayerOutfitByGUID(guid)
	local resultId = db.storeQuery("SELECT `looktype`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `lookaddons`, `lookaura`, `lookwings`, `lookshader` FROM `players` WHERE `id` = " .. guid)
	if(resultId ~= false) then
		local looktype = result.getDataInt(resultId, "looktype")
		local lookbody = result.getDataInt(resultId, "lookbody")
		local lookfeet = result.getDataInt(resultId, "lookfeet")
		local lookhead = result.getDataInt(resultId, "lookhead")
		local looklegs = result.getDataInt(resultId, "looklegs")
		local lookaddons = result.getDataInt(resultId, "lookaddons")
		local lookwings = result.getDataInt(resultId, "lookwings")
		local lookaura = result.getDataInt(resultId, "lookaura")
		local lookshader = result.getDataInt(resultId, "lookshader")
		
		result.free()
		return {lookType = looktype, lookBody = lookbody, lookFeet = lookfeet, lookHead = lookhead, lookLegs = looklegs, lookAddons = lookaddons, lookShader = lookshader, lookAura = lookaura, lookWings = lookwings}
	end
	return nil
end
local mainWindow, infoWindow, mainPanel, catchButton = nil
local opcode = 77
local totalBrokes = {}
local looktypes = {}
local dataCache = {}
local brokes = {}
local pontos = {}
local types = {}
local types2 = {}
local created = false
local page = 0
local totalPages = 0
local MAX_ROWS = 12


local TYPES_POINTS = {
    ["water"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16452] = 10, -- net
        [16455] = 5, -- fast
        [16456] = 5, -- heavy
        [16457] = 0, -- premier
		[16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["ghost"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16743] = 10, -- moon
        [16455] = 5, -- fast
        [16456] = 5, -- heavy
        [16457] = 0, -- premier
		[16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["dark"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16743] = 10, -- moon
        [16455] = 5, -- fast
        [16456] = 5, -- heavy
        [16457] = 0, -- premier
		[16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["steel"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16447] = 10, -- tinker
        [16455] = 5, -- fast
        [16456] = 5, -- heavy
        [16457] = 0, -- premier
		[16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["electric"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16447] = 10, -- tinker
        [16456] = 5, -- heavy
        [16455] = 5, -- fast
        [16457] = 0, -- premier
		[16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["ice"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16745] = 10, -- sora
        [16456] = 5, -- heavy
        [16455] = 5, -- fast
        [16457] = 0, -- premier
        [16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["flying"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16745] = 10, -- sora
        [16455] = 5, -- fast
        [16456] = 5, -- heavy
        [16457] = 0, -- premier
        [16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["rock"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16746] = 10, -- dusk
        [16455] = 5, -- fast
        [16456] = 5, -- heavy
        [16457] = 0, -- premier
        [16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["fighting"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16746] = 10, -- dusk
        [16455] = 5, -- fast
        [16456] = 5, -- heavy
        [16457] = 0, -- premier
        [16478] = 12, -- delta
        [2175016450] = 15, -- especial
    },
    ["normal"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16450] = 10, -- yume
        [16455] = 5, -- fast
        [16456] = 5, -- heavy
        [16457] = 0, -- premier
        [16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["psychic"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16450] = 10, -- yume
        [16455] = 5, -- fast
        [16456] = 5, -- heavy
        [16457] = 0, -- premier
        [16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["dragon"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16451] = 10, -- tale
        [16455] = 5, -- fast
        [16456] = 5, -- heavy
        [16457] = 0, -- premier
        [16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["fairy"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16451] = 10, -- tale
        [16455] = 5, -- fast
        [16456] = 5, -- heavy
        [16457] = 0, -- premier
        [16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["bug"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16452] = 10, -- net
        [16455] = 5, -- fast
        [16456] = 5, -- heavy
        [16457] = 0, -- premier
        [16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["poison"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16453] = 10, -- janguru
        [16455] = 5, -- fast
        [16456] = 5, -- heavy
        [16457] = 0, -- premier
        [16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["grass"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16453] = 10, -- janguru
        [16455] = 5, -- fast
        [16456] = 5, -- heavy
        [16457] = 0, -- premier
        [16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["fire"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16454] = 10, -- magu
        [16455] = 5, -- fast
        [16456] = 5, -- heavy
        [16457] = 0, -- premier
        [16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["ground"] = {
        [3282] = 1, -- poke
        [3279] = 2, -- great
        [3281] = 3, -- super
        [3280] = 4, -- ultra
        [11929] = 1, -- saffari
        [16454] = 10, -- magu
        [16455] = 5, -- fast
        [16456] = 5, -- heavy
        [16457] = 0, -- premier
        [16478] = 12, -- delta
        [21750] = 15, -- especial
    },
    ["palworld"] = {
        [21758] = 1, -- pal
        [21763] = 2, -- mega
        [21759] = 3, -- giga
        [21760] = 4, -- tera
        [21762] = 5, -- ultra
        [21761] = 10, -- lendaria
    },
	["none"] = {}
}

local balls = {
	["poke"] = 3282,
	["great"] = 3279,
	["super"] = 3281,
	["ultra"] = 3280,
	["saffari"] = 11929,
	["master"] = 12410,
	["moon"] = 16446,
	["tinker"] = 16447,
	["sora"] = 16448,
	["dusk"] = 16449,
	["yume"] = 16450,
	["tale"] = 16451,
	["net"] = 16452,
	["janguru"] = 16453,
	["magu"] = 16454,
	["fast"] = 16455,
	["heavy"] = 16456,
	["premier"] = 16457,
	["delta"] = 16478,
	["especial"] = 21750,
	["esferadepal"] = 21758,
	["esferamega"] = 21763,
	["esferagiga"] = 21759,
	["esferatera"] = 21760,
	["esferaultra"] = 21762,
	["esferalendaria"] = 21761
}

local balls_order = {
    [1] = "poke",
    [2] = "great",
    [3] = "super",
    [4] = "ultra",
    [5] = "saffari",
    [6] = "master",
    [7] = "moon",
    [8] = "tinker",
    [9] = "sora",
    [10] = "dusk",
    [11] = "yume",
    [12] = "tale",
    [13] = "net",
    [14] = "janguru",
    [15] = "magu",
    [16] = "fast",
    [17] = "heavy",
    [18] = "premier",
    [19] = "delta",
    [20] = "especial",
    [21] = "esferadepal",
    [22] = "esferamega",
    [23] = "esferagiga",
    [24] = "esferatera",
    [25] = "esferaultra",
    [26] = "esferalendaria"
}

local function capitalizeFirstLetter(word)
	word = string.lower(word)
    return word:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
end

function init()
  mainWindow = g_ui.loadUI("player_brokes", modules.game_interface.getRootPanel())
  mainPanel = mainWindow.panelPokes
  ProtocolGame.registerExtendedOpcode(opcode, receiveOpcode)

  mainWindow.search.onTextChange = function(widget, newText)

	if type(tonumber(newText)) == "number" then
		local checkPageNumber = tonumber(newText)
		if checkPageNumber <= totalPages then
			page = checkPageNumber
			generatePageChildren(checkPageNumber)
		end
		return
	end

	if page ~= 1 and #newText == 0 then
		page = 1
		generatePageChildren(1)
		return
	end
	newText = capitalizeFirstLetter(newText)
	local finded_page = find_page(newText)
		if not brokes[newText] then return end
		if page == 1 and finded_page == 1 then return end
		page = finded_page
		generatePageChildren(finded_page)
  end
  mainWindow:hide()
  connect(g_game, { onGameStart = function()  mainWindow:hide() end, onGameEnd = function()  mainWindow:hide() end} )
end

function terminate()
	mainWindow:hide()
    mainWindow:destroy()
	catchButton:destroy()
	catchButton = nil
	ProtocolGame.unregisterExtendedOpcode(opcode, receiveOpcode)
	disconnect(g_game, { onGameStart = function()  mainWindow:hide() end, onGameEnd = function()  mainWindow:hide() end} )
end

function toggle()
	if mainWindow:isVisible() then
		mainWindow:hide()
	else
		page = 1
		generatePageChildren(1)
		mainWindow:show()
	end
end

function receiveOpcode(protocol, opcode, buffer)
	local buffer = json.decode(buffer)

	local type = buffer.type
	local data = buffer.data
	
	if type == "startModule" then
		dataCache = data
		for index, info in ipairs(data) do
			local ballsCount = 0
			ballsCount = ballsCount + info.brokes.poke
			ballsCount = ballsCount + info.brokes.great
			ballsCount = ballsCount + info.brokes.ultra
			ballsCount = ballsCount + info.brokes.super
			ballsCount = ballsCount + info.brokes.saffari
			ballsCount = ballsCount + info.brokes.master
			ballsCount = ballsCount + info.brokes.moon
			ballsCount = ballsCount + info.brokes.tinker
			ballsCount = ballsCount + info.brokes.sora
			ballsCount = ballsCount + info.brokes.dusk
			ballsCount = ballsCount + info.brokes.yume
			ballsCount = ballsCount + info.brokes.tale
			ballsCount = ballsCount + info.brokes.net
			ballsCount = ballsCount + info.brokes.janguru
			ballsCount = ballsCount + info.brokes.magu
			ballsCount = ballsCount + info.brokes.fast
			ballsCount = ballsCount + info.brokes.heavy
			ballsCount = ballsCount + info.brokes.premier
			ballsCount = ballsCount + info.brokes.delta
			ballsCount = ballsCount + info.brokes.especial
			ballsCount = ballsCount + info.brokes.esferadepal
			ballsCount = ballsCount + info.brokes.esferamega
			ballsCount = ballsCount + info.brokes.esferagiga
			ballsCount = ballsCount + info.brokes.esferatera
			ballsCount = ballsCount + info.brokes.esferaultra
			ballsCount = ballsCount + info.brokes.esferalendaria
			totalBrokes[info.pokeName] = ballsCount
			looktypes[info.pokeName] = info.lookType
			pontos[info.pokeName] = {total = info.pontosTotais, atual = info.pontos}
			brokes[info.pokeName] = info.brokes
			types[info.pokeName] = info.type
			types2[info.pokeName] = info.type2
		end
		startModule()
	end

	if type == "updateData" then
		totalBrokes[data.pokemonName] = totalBrokes[data.pokemonName] + 1
		brokes[data.pokemonName][data.pokeball] = brokes[data.pokemonName][data.pokeball] + 1
		pontos[data.pokemonName].atual = pontos[data.pokemonName].atual + data.pontos
	end

	if type == "resetData" then
		totalBrokes[data.pokemonName] = 0
		brokes[data.pokemonName] = data.brokes
		pontos[data.pokemonName].atual = data.pontos
	end
end

function startModule()
	if created then return end
	mainPanel:destroyChildren()
	startPages()
	generatePageChildren(page)
	created = true
end
 
function showPokeInfo(id)
	if infoWindow then
		infoWindow:destroy()
	end

	infoWindow = g_ui.createWidget("pokeWindow", mainWindow)
	infoWindow.pokemonName:setText(id)
	infoWindow.pokemonLooktype:setOutfit({type = looktypes[id]})
	infoWindow.pokemonLooktype:setOldScaling(true)
	infoWindow.pontuacao:setText(string.format("%d/%d", pontos[id].atual, pontos[id].total))
	local panel = infoWindow.panelBestBalls
	local panelBrokes = infoWindow.panelBrokes
	panel:destroyChildren()
	for index, ball in ipairs(balls_order) do
		if ball ~= "master" then
			local widget = g_ui.createWidget("UIItem", panel)
			
			if not TYPES_POINTS[types[id]][balls[ball]] and not TYPES_POINTS[types2[id]][balls[ball]] then
				widget:setOpacity(0.5)
			end
			widget:setItemId(balls[ball])
		end
	end
	panelBrokes:destroyChildren()
	for index, ball in ipairs(balls_order) do
		if ball ~= "master" then
			local widget = g_ui.createWidget("brokeBall", panelBrokes)
			widget:setItemId(balls[ball])
			local brokes = tonumber(brokes[id][ball])
			if brokes >= 1000 then
				brokes = string.format("%.1fk", (brokes/1000))
			end
			widget.brokes:setText(brokes)
		end
	end
end

function find_page(id)
	for index, info in ipairs(dataCache) do
		if info.pokeName == id then
			return math.ceil(index / MAX_ROWS)
		end
	end
	return 1
end

function generatePageChildren(page_id)
	mainPanel:destroyChildren()
	mainWindow.pages:setText(string.format("%d/%d", page, totalPages))
	local count = 0
	local startIndex
	local lastIndex

	if page_id ~= 1 then
		startIndex = 1 + (MAX_ROWS * (page_id - 1))
		lastIndex = startIndex + ( MAX_ROWS - 1)
	else 
		startIndex = 1
		lastIndex = 12
	end

	for i = startIndex, lastIndex do
		local info = dataCache[i]
		if not info then break end

		local widget = g_ui.createWidget("pokemonChildPanel", mainPanel)
		widget:setId(info.pokeName)
		widget.pokemonId:setText(" #" .. info.id)
        widget.pokemonLooktype:setOutfit({type = looktypes[info.pokeName]})
        widget.pokemonLooktype:setOldScaling(true)
        widget:setTooltip(info.pokeName)
        local pokeName = info.pokeName
        if #pokeName > 10 then
            pokeName = string.sub(pokeName, 1, 10) .. ".."
        end
		widget.pokemonName:setText(pokeName)
		widget.pokemonBrokes:setText(totalBrokes[info.pokeName] .. " Brokes")
	end

end

function startPages()
	totalPages = math.floor(#dataCache/MAX_ROWS)
	local totalPagesModule = (totalPages%MAX_ROWS)
	if totalPagesModule ~= 0 then
		totalPages = totalPages + 1
	end
	page = 1
	mainWindow.pages:setText(string.format("%d/%d", page, totalPages))
end

function nextPage()
	if page >= totalPages then return end
	page = page + 1
	generatePageChildren(page)
end

function previousPage()
	if page <= 1 then return end
	page = page - 1
	generatePageChildren(page)
end

function firstPage()
	if page == 1 then return end
	page = 1
	generatePageChildren(page)
end

function lastPage()
	if page == totalPages then return end
	page = totalPages
	generatePageChildren(page)
end

function dump(tbl, indent)
    indent = indent or 0

    for k, v in pairs(tbl) do
        local formattedKey = tostring(k)
        local formattedValue = tostring(v)

        if type(v) == "table" then
            print(string.rep("  ", indent) .. formattedKey .. " =>")
            dump(v, indent + 1)
        else
            print(string.rep("  ", indent) .. formattedKey .. " => " .. formattedValue)
        end
    end
end
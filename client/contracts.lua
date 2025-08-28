local mainWindow = nil
local opcode = 97


function init()
	mainWindow = g_ui.loadUI("contracts", modules.game_interface.getRootPanel())
	mainWindow:hide()
	ProtocolGame.registerExtendedOpcode(opcode, receiveOpcode)
end

function terminate()
    mainWindow:destroy()
	ProtocolGame.unregisterExtendedOpcode(opcode, receiveOpcode)
    disconnect(g_game, { onGameEnd = function()  mainWindow:hide() end})
end

local conversor = {
    [1] = "first",
    [2] = "second",
    [3] = "third",
    [4] = "fourth",
    [5] = "fifth",
    [6] = "sixth",
    [7] = "seventh",
    [8] = "eighth",
    [9] = "ninth",
    [10] = "tenth",
    [11] = "eleventh",
    [12] = "twelfth",
    [13] = "thirteenth",
    [14] = "fourteenth",
    [15] = "fifteenth",
    [16] = "sixteenth",
    [17] = "seventeenth",
    [18] = "eighteenth",
    [19] = "nineteenth",
    [20] = "twentieth",
}
local reverse_conversor = {
    ["first"] = 1,
    ["second"] = 2,
    ["third"] = 3,
    ["fourth"] = 4,
    ["fifth"] = 5,
    ["sixth"] = 6,
    ["seventh"] = 7,
    ["eighth"] = 8,
    ["ninth"] = 9,
    ["tenth"] = 10,
    ["eleventh"] = 11,
    ["twelfth"] = 12,
    ["thirteenth"] = 13,
    ["fourteenth"] = 14,
    ["fifteenth"] = 15,
    ["sixteenth"] = 16,
    ["seventeenth"] = 17,
    ["eighteenth"] = 18,
    ["nineteenth"] = 19,
    ["twentieth"] = 20,
}

local translate_rarities = {
	["comum"] = "images/banner_comum",
	["incomum"] = "images/banner_incomum",
	["raro"] = "images/banner_raro",
	["mitico"] = "images/banner_mitico",
	["lendario"] = "images/banner_lendario",
}

local acceptWindow = {}

local function capitalizeFirstLetter(word)
	word = string.lower(word)
    return word:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
end

function acceptButton(id)
	local info = {
		action = "accept",
		contract = id
	}
	sendRequestBH(info)
end

function sendRequestBH(info)
	local protocol = g_game.getProtocolGame()
	local buffer = json.encode(info)
	protocol:sendExtendedOpcode(opcode, buffer)
end

function receiveOpcode(protocol, opcode, buffer)
	for i = 1, 6 do
		local widget = mainWindow.panel:getChildById(i)
		widget.toggleContract.onClick = function ()
			acceptButton(i)
		end
		widget.toggleContract:setImageColor("#00ff00")
		widget.toggleContract:setText("Aceitar")
		widget.rarity:setText("")
		widget.name:setText("Inativo")
		widget.duelistOutfit:setOutfit({type = 0})
		widget.desc:setText("")
		widget.done:setVisible(false)
		widget:setImageSource(translate_rarities["comum"])
	end
	local data = json.decode(buffer)
	local data_type = data.type
	if not data_type then return error("data type not found on contract") end
	if data_type == "open" then
		local remaining = data.remainingContracts or 0
		mainWindow.remainingContracts:setText("Contratos restantes: " .. remaining)
		mainWindow:show()
		local openContracts = data.openContracts
		if openContracts then
			for i, contract in pairs(openContracts) do
				if contract.active then
					local id = reverse_conversor[i]
					contract.position = nil
					local widget = mainWindow.panel:getChildById(id)

					if contract.done then
						widget.done:setVisible(true)
					end

					widget:setImageSource(translate_rarities[contract.rarity])
					widget.rarity:setText(capitalizeFirstLetter(contract.rarity))
					widget.name:setText(contract.name)
					widget.desc:setText(contract.desc)
					widget.duelistOutfit:setOutfit(contract.outfit)
					widget.toggleContract:setText("Cancelar")
					widget.toggleContract:setImageColor("#daffae")
					widget.toggleContract.onClick = function()
					local cancelFunc = function()
						acceptWindow[#acceptWindow]:destroy()
						acceptWindow = {}
					end

					local acceptFunc = function()
						acceptWindow[#acceptWindow]:destroy()
						acceptWindow = {}
						local info = {
							action = "cancel",
							contract = id
						}
						sendRequestBH(info)
					end

					if #acceptWindow > 0 then
						acceptWindow[#acceptWindow]:destroy()
					end
					local text = "Você deseja cancelar o contrato?\nEle poderá ser pego novamente.\n(Ao cancelar, você não irá trocar o contrato.)"
					acceptWindow[#acceptWindow + 1] = displayGeneralBox("Cancelar Contrato", text,
						{
							{text = tr("Cancelar"), callback = acceptFunc},
							{text = tr("Não cancelar"), callback = cancelFunc},
							 anchor = AnchorHorizontalCenter
						  }, acceptFunc, cancelFunc)
					end
				end
			end
		end
	end
end
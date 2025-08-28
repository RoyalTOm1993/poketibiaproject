local OPCODE = 72
local cacheData, panelBase, ranksOrdered
local quantidade_items = 1
local acceptWindow = {}
local createdWindow, mainWindow = nil

function receiveOpcode(protocol, opcode, buffer)
	local buffer = json.decode(buffer)
	local action = buffer.type
	if action == "open" then
		cacheData = buffer.data
		panelBase = buffer.base
		-- print(panelBase)
		ranksOrdered = buffer.order
		-- print(ranksOrdered)
		openModule()
		return
	end
	
	if action == "notEnough" then
		notEnough(buffer.items)
		return
	end
end

function notEnough(data)
    local text = "Faltam:\n"
    local list = {}
    for id, info in ipairs(data) do
        list[info.name] = 0
    end
    for id, info in ipairs(data) do
        list[info.name] = list[info.name] + info.needed
    end
    for name, qtd in pairs(list) do
        text = text .. string.format("%s %dx\n", name, qtd)
    end
    sendCancelBox("Itens Insuficientes", text)
end

function sendCancelBox(header, text)
    local cancelFunc = function()
      acceptWindow[#acceptWindow]:destroy()
      acceptWindow = {}
    end
	
    if #acceptWindow > 0 then
      acceptWindow[#acceptWindow]:destroy()
    end
		
	acceptWindow[#acceptWindow + 1] =
		displayGeneralBox(tr(header), tr(text),
		{
			{text = tr("OK"), callback = cancelFunc},
       anchor = AnchorHorizontalCenter
		}, cancelFunc)

end


function openModule()
	quantidade_items = 1
	local data = cacheData
	mainWindow:show()
    mainWindow.switchRank:setText("Categoria: " .. panelBase)
    mainWindow.switchRank.onClick = function()
        local menu = g_ui.createWidget("PopupMenu")
        menu:setGameMenu(true)
        for _, rank in ipairs(ranksOrdered) do
            if rank ~= panelBase then
                menu:addOption("Categoria: " .. rank, function() panelBase = rank openModule() end)
            end
        end 
        menu:display(pos)
    end

	local panel = mainWindow.panelItems
	panel:destroyChildren()
	for ind, item in ipairs(data[panelBase]) do
        local widget = g_ui.createWidget("baseItem2", panel)
        widget:setId(ind)
        widget.mainItem:setItemId(item.itemId)
        widget.mainItem:setVirtual(true)
        widget.mainItem:setItemCount(item.quantity or 1)
        widget.mainItemName:setText(item.name)
        widget.mainItemDescription:setText(item.description)
        widget.chanceItem:setText(item.chance .. "%")
        local text = "Required:\n"
        local requiredPanel = widget.panelRequired
        requiredPanel:destroyChildren()

        local list = {}
        for id, info in ipairs(item.required) do
            list[info.name] = 0
        end

        for id, info in ipairs(item.required) do
            list[info.name] = list[info.name] + (info.quantidade * quantidade_items)
        end

        for name, qtd in pairs(list) do
            text = text .. string.format("%s %dx\n", name, qtd)
        end

        local quantity = #item.required
        local need = math.max(0, 14 - quantity)

        for _, required in ipairs(item.required) do
            local subWidget = g_ui.createWidget("requiredItem", requiredPanel)
            subWidget:setItemId(required.itemId)
            subWidget:setVirtual(true)
            subWidget:setItemCount(required.quantidade * quantidade_items)
            subWidget.requireItemTooltip:setTooltip(string.format("Item: %s\n%s", required.name, required.description))
        end

        if need > 0 then
            for i =  1, need do
                local subWidget = g_ui.createWidget("requiredItem", requiredPanel)
                subWidget:setItemId(0)
                subWidget:setVirtual(true)
            end
        end

        local tooltipText = string.format("Item: %s\n%s\nquantidade: %d\n%s ", item.name, item.description, item.quantity, text)
        widget.mainItemTooltip:setTooltip(tooltipText)
    end
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

function changeQuantidade(value)
    quantidade_items = value
	local quantidadeCraft = cacheData[panelBase][tonumber(mainWindow.panelItems:getFocusedChild():getId())].quantity or 1
    local recipeItem = createdWindow.recipe:getChildren()
    createdWindow.item:setItemCount(value * quantidadeCraft)
    createdWindow.quantidadeCraftLabel:setText(value .. " x")

    local dataInfo = cacheData[panelBase][tonumber(mainWindow.panelItems:getFocusedChild():getId())].required
    local widgets = #dataInfo
    for index, widget in ipairs(recipeItem) do
        if index > widgets then break end
        local required = dataInfo[index].quantidade
        widget:setItemCount(required * quantidade_items)
    end
end

function createWindow()
  quantidade_items = 1
    if createdWindow then
        createdWindow:destroy()
        createdWindow = nil
    end
    createdWindow = g_ui.createWidget("CreateWindow", modules.game_interface.getRootPanel())
    createdWindow.quantidadeCraftLabel:setText(quantidade_items .. " x")
    createdWindow.quantidadeCraft:setValue(quantidade_items)

    createdWindow:show()
    createdWindow:focus()
    createdWindow:raise()

    local index = tonumber(mainWindow.panelItems:getFocusedChild():getId())
    local item = cacheData[panelBase][index]
    createdWindow.item:setItemId(item.itemId)
    createdWindow.item:setItemCount(item.quantity)
    createdWindow.item:setVirtual(true)
    --createdWindow.name:setText(item.name)
    createdWindow.recipe:destroyChildren()
    local quantity = #cacheData[panelBase][index].required
    local need = math.max(0, 16 - quantity)
    for _, required in ipairs(cacheData[panelBase][index].required) do
        local widget = g_ui.createWidget("requiredItem", createdWindow.recipe)
        widget:setItemId(required.itemId)
        widget:setVirtual(true)
        widget:setItemCount(required.quantidade * quantidade_items)
         widget.requireItemTooltip:setTooltip(string.format("Item: %s\n%s", required.name, required.description))
    end
    if need > 0 then
        for i = 1, need do
            local widget = g_ui.createWidget("requiredItem", createdWindow.recipe)
            widget:setItemId(0)
            widget:setVirtual(true)
        end
    end
end

function sendBuffer()
    if createdWindow then
        createdWindow:destroy()
        createdWindow = nil
    end
    local buffer = {
        type = "doCraft",
        info = {
			rank = panelBase,
			index =  tonumber(mainWindow.panelItems:getFocusedChild():getId()),
            quantidade = quantidade_items
        }
    }
    g_game.getProtocolGame():sendExtendedOpcode(OPCODE, json.encode(buffer))
end

function destroyCraftWindow()
    if createdWindow then
        createdWindow:destroy()
        createdWindow = nil
        quantidade_items = 1
    end
end

function destroyModules()
    destroyCraftWindow()
    mainWindow:hide() 
end


function init()
	mainWindow = g_ui.loadUI('game_craft', modules.game_interface.getRootPanel()) 
	ProtocolGame.registerExtendedOpcode(OPCODE, receiveOpcode)
	connect(g_game, { onGameEnd = function() 
	    mainWindow:hide() 
        if createdWindow then
            createdWindow:destroy()
            createdWindow = nil
            quantidade_items = 1
        end
	end })
    connect(LocalPlayer, {
        onPositionChange = destroyModules,
        onWalk = destroyModules,
    })
	mainWindow:hide()
end

function terminate()
  ProtocolGame.unregisterExtendedOpcode(OPCODE)
  mainWindow:destroy()
  mainWindow:hide()

  disconnect(g_game, { onGameEnd = function() 
    mainWindow:hide()
    if createdWindow then
        createdWindow:destroy()
        createdWindow = nil
    end
  end })

  disconnect(LocalPlayer, {
    onPositionChange = destroyModules,
    onWalk = destroyModules,
    })
end
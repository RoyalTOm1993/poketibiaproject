OffsetManager = {}

local offsetWindow = nil
local offsetButton = nil
local outfitWidget = nil
local itemWidget = nil
local effectWidget = nil
local currentDirection = nil
local otmlData = {
    creatures = {},
    items = {},
    effects = {}
}
local filename = "Tibia.otml"
local directory = "data/things/1098/"
local OffsetOptions = {"Outfit", "Item", "Effect"}
local currentDisplacementType = nil

local function validateNumericInput(inputWidget)
    inputWidget:setText(inputWidget:getText():gsub("[^%d%-]", ""))
end

local offsets = {
    ["left"] = {
        offsetX = 0,
        offsetY = 0
    },
    ["right"] = {
        offsetX = 0,
        offsetY = 0
    },
    ["up"] = {
        offsetX = 0,
        offsetY = 0
    },
    ["down"] = {
        offsetX = 0,
        offsetY = 0
    }
}

function init()
    g_ui.importStyle('offset.otui')
    loadOtmlFile()
    backupOtmlFile()

    offsetButton = modules.client_topmenu.addLeftGameButton('offsetButton', tr('Offset Manager'),
        '/images/game/offset/icon', OffsetManager.toggle, false, 1)

    offsetWindow = g_ui.createWidget('OffsetWindow', modules.game_interface.getRootPanel())

    setupComboBox()
    outfitWidget = offsetWindow:recursiveGetChildById('outfitView')
    itemWidget = offsetWindow:recursiveGetChildById('itemView')
    effectWidget = offsetWindow:recursiveGetChildById('effectView')

    outfitWidget:hide()
    itemWidget:hide()
    effectWidget:hide()
    offsetWindow:hide()

    setupNumericFields()
    setupIdInputValidation()

    local movementCheck = offsetWindow:recursiveGetChildById('movement')
    movementCheck.onCheckChange = function(checkBox, checked)
        if outfitWidget:isVisible() then
            outfitWidget:setAnimate(checked)
        end
    end
end

function OffsetManager.toggleDirection(direction)
    if currentDirection == direction then
        return
    end

    if currentDirection then
        local offsetXField = offsetWindow:recursiveGetChildById('offsetX')
        local offsetYField = offsetWindow:recursiveGetChildById('offsetY')
        local prevOffsetX = tonumber(offsetXField:getText()) or 0
        local prevOffsetY = tonumber(offsetYField:getText()) or 0
        offsets[currentDirection].offsetX = prevOffsetX
        offsets[currentDirection].offsetY = prevOffsetY
    end

    currentDirection = direction
    local offsetX = offsets[direction].offsetX or 0
    local offsetY = offsets[direction].offsetY or 0
    local offsetXField = offsetWindow:recursiveGetChildById('offsetX')
    local offsetYField = offsetWindow:recursiveGetChildById('offsetY')

    offsetXField:setText(tostring(offsetX))
    offsetYField:setText(tostring(offsetY))

    updateCheckboxes(direction)

    if outfitWidget:isVisible() then
        local directions = {
            up = Directions.North,
            right = Directions.East,
            down = Directions.South,
            left = Directions.West
        }

        local newDirection = directions[direction]
        if newDirection then
            outfitWidget:setDirection(newDirection)
        end
    end
end

function onMovementChange(checkBox, checked)
    previewCreature:setAnimate(checked)
    settings.movement = checked
end

function updateCheckboxes(selectedDirection)
    local checkUp = offsetWindow:recursiveGetChildById('checkUp')
    local checkRight = offsetWindow:recursiveGetChildById('checkRight')
    local checkDown = offsetWindow:recursiveGetChildById('checkDown')
    local checkLeft = offsetWindow:recursiveGetChildById('checkLeft')

    checkUp:setChecked(selectedDirection == 'up')
    checkRight:setChecked(selectedDirection == 'right')
    checkDown:setChecked(selectedDirection == 'down')
    checkLeft:setChecked(selectedDirection == 'left')
end

function setupIdInputValidation()
    local idInput = offsetWindow:getChildById('idInput')
    idInput.onTextChange = function()
        validateNumericInput(idInput)
    end
end

function terminate()
    if offsetWindow then
        offsetWindow:destroy()
    end
    if offsetButton then
        offsetButton:destroy()
    end
end

function OffsetManager.toggle()
    if offsetWindow:isVisible() then
        offsetWindow:hide()
        offsetButton:setOn(false)
    else
        offsetWindow:show()
        offsetWindow:raise()
        offsetWindow:focus()
        offsetButton:setOn(true)
    end
end

function setupComboBox()
    local offsetComboBox = offsetWindow:getChildById('offsetComboBox')
    local opacityComboBox = offsetWindow:getChildById('effectOpacityComboBox')
    local opacityOutfitPanel = offsetWindow:getChildById('OpacityOutfit') -- Referência ao OpacityOutfit

    -- Certifique-se de que o painel existe
    if not opacityOutfitPanel then
        print("Error: 'OpacityOutfit' panel not found!")
        return
    end

    for _, option in ipairs(OffsetOptions) do
        offsetComboBox:addOption(option)
    end

    offsetComboBox.onOptionChange = function(_, option)
        local displacementTypeComboBox = offsetWindow:getChildById('displacementTypeComboBox')
        local directionsPanel = offsetWindow:getChildById('DirectionsPanel')
        local offsetXField = offsetWindow:recursiveGetChildById('offsetX')
        local offsetYField = offsetWindow:recursiveGetChildById('offsetY')
        local idInput = offsetWindow:getChildById('idInput')
        local chaseModeBox = offsetWindow:recursiveGetChildById('movement')
        local opacityField = offsetWindow:recursiveGetChildById('opacityInput')
        local offsetPanel = offsetWindow:getChildById('OffsetPanel')
        local opacityPanel = offsetWindow:getChildById('OpacityPanel')

        -- Resetar os campos
        opacityField:setText('1.0')
        idInput:setText('')

        if effectWidget:isVisible() then
            effectWidget:hide()
            effectWidget:setEffect(nil)
        end

        if option == 'Outfit' then
            displacementTypeComboBox:setVisible(true)
            opacityComboBox:setVisible(false)
            opacityPanel:setVisible(false)
            offsetPanel:setVisible(true)
            outfitWidget:show()
            itemWidget:hide()
            effectWidget:hide()
            offsetWindow:getChildById('preview'):show()
            directionsPanel:setVisible(true)
            chaseModeBox:show()

            -- Certifique-se de que o painel OpacityOutfit esteja visível ao voltar para 'Outfit'
            if displacementTypeComboBox:getText() == 'Outfit Displacement' then
                opacityOutfitPanel:setVisible(true)
            end

            outfitWidget:setOutfit({})
            OffsetManager.toggleDirection("down")
            OffsetManager.viewOffset()

        elseif option == 'Item' then
            outfitWidget:setOutfit({})
            outfitWidget:hide()
            itemWidget:show()
            effectWidget:hide()
            offsetWindow:getChildById('preview'):show()
            directionsPanel:setVisible(false)
            chaseModeBox:hide()
            displacementTypeComboBox:setVisible(false)
            opacityComboBox:setVisible(true)

            local selectedOpacityOption = opacityComboBox:getText()
            if selectedOpacityOption == 'None' then
                offsetPanel:setVisible(true)
                opacityPanel:setVisible(false)
            else
                offsetPanel:setVisible(false)
                opacityPanel:setVisible(true)
            end

            OffsetManager.viewOffset()

        elseif option == 'Effect' then
            outfitWidget:hide()
            itemWidget:hide()
            effectWidget:show()
            opacityComboBox:setVisible(true)

            local selectedOpacityOption = opacityComboBox:getText()
            if selectedOpacityOption == 'None' then
                offsetPanel:setVisible(true)
                opacityPanel:setVisible(false)
            else
                offsetPanel:setVisible(false)
                opacityPanel:setVisible(true)
            end

            directionsPanel:setVisible(false)
            chaseModeBox:hide()
            displacementTypeComboBox:setVisible(false)

            OffsetManager.viewOffset()
        end

        -- Esconde o painel OpacityOutfit ao mudar para outra opção
        if option ~= 'Outfit' then
            opacityOutfitPanel:setVisible(false)
        end

        OffsetManager.resetOffset()
    end

    -- Configura as opções para o displacementTypeComboBox
    local displacementTypeComboBox = offsetWindow:getChildById('displacementTypeComboBox')
    displacementTypeComboBox:addOption("Outfit Displacement")
    displacementTypeComboBox:addOption("Name Displacement")

    opacityComboBox:addOption("None")
    opacityComboBox:addOption("Opacity")

    -- Função chamada quando mudar o displacementTypeComboBox
    displacementTypeComboBox.onOptionChange = function(_, option)
        currentDisplacementType = option
        OffsetManager.toggleDirection("down")

        local id = tonumber(offsetWindow:getChildById('idInput'):getText())
        if currentDisplacementType == "Outfit Displacement" then
            -- Mostrar o painel OpacityOutfit ao selecionar "Outfit Displacement"
            opacityOutfitPanel:setVisible(true)

            OffsetManager.viewOffset()
        elseif currentDisplacementType == "Name Displacement" then
            -- Esconder o painel OpacityOutfit para "Name Displacement"
            opacityOutfitPanel:setVisible(false)

            -- Limpar os valores de deslocamento da "Outfit Displacement" e carregar os de "Name Displacement" (ou zerar)
            local nameDisplacement = otmlData.creatures[id] and otmlData.creatures[id]["name-displacement"]
            if nameDisplacement then
                offsets["up"].offsetX = nameDisplacement.North and nameDisplacement.North[1] or 0
                offsets["up"].offsetY = nameDisplacement.North and nameDisplacement.North[2] or 0
                offsets["right"].offsetX = nameDisplacement.East and nameDisplacement.East[1] or 0
                offsets["right"].offsetY = nameDisplacement.East and nameDisplacement.East[2] or 0
                offsets["down"].offsetX = nameDisplacement.South and nameDisplacement.South[1] or 0
                offsets["down"].offsetY = nameDisplacement.South and nameDisplacement.South[2] or 0
                offsets["left"].offsetX = nameDisplacement.West and nameDisplacement.West[1] or 0
                offsets["left"].offsetY = nameDisplacement.West and nameDisplacement.West[2] or 0
            else
                -- Zerar os valores caso não exista "Name Displacement"
                offsets["up"].offsetX = 0
                offsets["up"].offsetY = 0
                offsets["right"].offsetX = 0
                offsets["right"].offsetY = 0
                offsets["down"].offsetX = 0
                offsets["down"].offsetY = 0
                offsets["left"].offsetX = 0
                offsets["left"].offsetY = 0
            end

            updateOffsetFields() -- Atualizar os campos de deslocamento
        end

        OffsetManager.viewOffset()
    end

    opacityComboBox.onOptionChange = function(_, option)
        local offsetPanel = offsetWindow:getChildById('OffsetPanel')
        local opacityPanel = offsetWindow:getChildById('OpacityPanel')

        if option == 'None' then
            offsetPanel:setVisible(true)
            opacityPanel:setVisible(false)
        else
            offsetPanel:setVisible(false)
            opacityPanel:setVisible(true)
        end
    end
end

function setupNumericFields()
    local panel = offsetWindow:getChildById('OffsetPanel')

    local numericFields = {'offsetX', 'offsetY'}
    for _, fieldId in ipairs(numericFields) do
        local field = panel:getChildById(fieldId)
        if field then
            field.onTextChange = function()
                validateNumericInput(field)
            end
        end
    end
end

function OffsetManager.reloadOtmlFile()
    local version = g_game.getClientVersion()
    local otmlPath = resolvepath('/things/' .. version .. '/Tibia.otml')

    if g_things.loadOtml(otmlPath) then
        OffsetManager.viewOffset()
    end
end

function OffsetManager.viewOffset()
    local id = tonumber(offsetWindow:getChildById('idInput'):getText())
    if not id or id <= 0 then
        return
    end

    local selectedOption = offsetWindow:getChildById('offsetComboBox'):getText()
    local displacementTypeComboBox = offsetWindow:getChildById('displacementTypeComboBox')
    local displacementType = displacementTypeComboBox:getText()

    -- Referências aos campos de offset
    local offsetXField = offsetWindow:recursiveGetChildById('offsetX')
    local offsetYField = offsetWindow:recursiveGetChildById('offsetY')

    -- Referência ao painel de opacidade do Outfit e ao OpacityPanel geral
    local opacityOutfitPanel = offsetWindow:getChildById('OpacityOutfit')
    local opacityFieldOutfit = opacityOutfitPanel and opacityOutfitPanel:getChildById('opacityInput') -- Campo de opacidade no painel OpacityOutfit

    local opacityPanel = offsetWindow:getChildById('OpacityPanel')
    local opacityFieldPanel = opacityPanel and opacityPanel:getChildById('opacityInput') -- Campo de opacidade no OpacityPanel geral

    if not opacityFieldOutfit or not opacityFieldPanel then
        print("Error: 'opacityInput' not found in one of the panels!")
        return
    end

    -- Lógica para carregar Outfit Displacement
    if selectedOption == 'Outfit' and displacementType == 'Outfit Displacement' then
        local outfitDisplacement = otmlData.creatures[id] and otmlData.creatures[id]["outfit-displacement"]
        if outfitDisplacement then
            -- Carregar os valores de offset para Outfit Displacement
            offsets["up"].offsetX = outfitDisplacement.North and outfitDisplacement.North[1] or 0
            offsets["up"].offsetY = outfitDisplacement.North and outfitDisplacement.North[2] or 0
            offsets["right"].offsetX = outfitDisplacement.East and outfitDisplacement.East[1] or 0
            offsets["right"].offsetY = outfitDisplacement.East and outfitDisplacement.East[2] or 0
            offsets["down"].offsetX = outfitDisplacement.South and outfitDisplacement.South[1] or 0
            offsets["down"].offsetY = outfitDisplacement.South and outfitDisplacement.South[2] or 0
            offsets["left"].offsetX = outfitDisplacement.West and outfitDisplacement.West[1] or 0
            offsets["left"].offsetY = outfitDisplacement.West and outfitDisplacement.West[2] or 0

            -- Carregar o valor de opacidade do OpacityOutfit ou definir como '1.0'
            opacityFieldOutfit:setText(string.format("%.1f", outfitDisplacement.opacity or 1.0))
        else
            -- Se não houver valores de offset, definir todos como 0
            offsets["up"].offsetX = 0
            offsets["up"].offsetY = 0
            offsets["right"].offsetX = 0
            offsets["right"].offsetY = 0
            offsets["down"].offsetX = 0
            offsets["down"].offsetY = 0
            offsets["left"].offsetX = 0
            offsets["left"].offsetY = 0

            -- Definir opacidade como 1.0 por padrão
            opacityFieldOutfit:setText('1.0')
        end

        -- Atualizar os campos de deslocamento para Outfit
        updateOffsetFields()
        OffsetManager.loadAndShowOutfit(id)

        -- Lógica para carregar Name Displacement
    elseif selectedOption == 'Outfit' and displacementType == 'Name Displacement' then
        local nameDisplacement = otmlData.creatures[id] and otmlData.creatures[id]["name-displacement"]
        if nameDisplacement then
            -- Carregar os valores de offset para Name Displacement
            offsets["up"].offsetX = nameDisplacement.North and nameDisplacement.North[1] or 0
            offsets["up"].offsetY = nameDisplacement.North and nameDisplacement.North[2] or 0
            offsets["right"].offsetX = nameDisplacement.East and nameDisplacement.East[1] or 0
            offsets["right"].offsetY = nameDisplacement.East and nameDisplacement.East[2] or 0
            offsets["down"].offsetX = nameDisplacement.South and nameDisplacement.South[1] or 0
            offsets["down"].offsetY = nameDisplacement.South and nameDisplacement.South[2] or 0
            offsets["left"].offsetX = nameDisplacement.West and nameDisplacement.West[1] or 0
            offsets["left"].offsetY = nameDisplacement.West and nameDisplacement.West[2] or 0
        else
            -- Se não houver valores de Name Displacement, definir todos como 0
            offsets["up"].offsetX = 0
            offsets["up"].offsetY = 0
            offsets["right"].offsetX = 0
            offsets["right"].offsetY = 0
            offsets["down"].offsetX = 0
            offsets["down"].offsetY = 0
            offsets["left"].offsetX = 0
            offsets["left"].offsetY = 0
        end

        -- Atualizar os campos de deslocamento para Name Displacement
        updateOffsetFields()
        OffsetManager.loadAndShowOutfit(id) -- Exibe a outfit
    end

    -- Carregar os valores para Item e Effect (não alterado)
    if selectedOption == 'Item' then
        local itemDisplacement = otmlData.items[id] and otmlData.items[id]["item-displacement"]
        if itemDisplacement then
            offsetXField:setText(tostring(itemDisplacement.x or 0))
            offsetYField:setText(tostring(itemDisplacement.y or 0))
            opacityFieldPanel:setText(string.format("%.1f", itemDisplacement.opacity or 1.0))
        else
            offsetXField:setText('0')
            offsetYField:setText('0')
            opacityFieldPanel:setText('1.0')
        end
        OffsetManager.loadAndShowItem(id)

    elseif selectedOption == 'Effect' then
        local effectDisplacement = otmlData.effects[id] and otmlData.effects[id]["effect-displacement"]
        if effectDisplacement then
            offsetXField:setText(tostring(effectDisplacement.x or 0))
            offsetYField:setText(tostring(effectDisplacement.y or 0))
            opacityFieldPanel:setText(string.format("%.1f", effectDisplacement.opacity or 1.0))
        else
            offsetXField:setText('0')
            offsetYField:setText('0')
            opacityFieldPanel:setText('1.0')
        end
        OffsetManager.loadAndShowEffect(id)
    end

    -- Selecionar direção "down" por padrão
    OffsetManager.toggleDirection("down")
    offsetWindow:recursiveGetChildById('checkDown'):setChecked(true)
end

function OffsetManager.toggleOpacityMode()
    local selectedOption = offsetWindow:getChildById('effectOpacityComboBox'):getText()
    local opacityPanel = offsetWindow:getChildById('OpacityPanel')
    local offsetXField = offsetWindow:recursiveGetChildById('offsetX')
    local offsetYField = offsetWindow:recursiveGetChildById('offsetY')

    if selectedOption == 'Opacity' then
        opacityPanel:setVisible(true)
        offsetXField:setVisible(false)
        offsetYField:setVisible(false)
    else
        opacityPanel:setVisible(false)
        offsetXField:setVisible(true)
        offsetYField:setVisible(true)
    end
end

function updateOffsetFields()
    local offsetXField = offsetWindow:recursiveGetChildById('offsetX')
    local offsetYField = offsetWindow:recursiveGetChildById('offsetY')

    if not currentDirection then
        return
    end

    local currentOffsetX = offsets[currentDirection].offsetX or 0
    local currentOffsetY = offsets[currentDirection].offsetY or 0

    offsetXField:setText(tostring(currentOffsetX))
    offsetYField:setText(tostring(currentOffsetY))
end

function OffsetManager.loadAndShowOutfit(outfitId)
    if not outfitId or outfitId == 0 then
        outfitWidget:hide()
        return
    end

    local outfit = {
        type = outfitId,
        head = 78,
        body = 68,
        legs = 58,
        feet = 76,
        direction = currentDirection
    }
    outfitWidget:show()
    itemWidget:hide()
    outfitWidget:setOutfit(outfit)
end

function OffsetManager.loadAndShowItem(itemId)
    local item = Item.create(itemId, 1)
    if item then
        itemWidget:show()
        outfitWidget:hide()
        itemWidget:setItem(item)
    end
end

function OffsetManager.loadAndShowEffect(effectId)
    if not effectId or effectId == 0 then
        effectWidget:hide()
        return
    end

    local effect = Effect.create()
    if not effect then
        return
    end

    effect:setEffect(effectId)

    effectWidget:show()
    outfitWidget:hide()
    itemWidget:hide()

    if effectWidget.setEffect then
        effectWidget:setEffect(effect)
    end
end

function OffsetManager.saveOffset()
    local id = tonumber(offsetWindow:getChildById('idInput'):getText())
    local selectedOption = offsetWindow:getChildById('offsetComboBox'):getText()
    local displacementType = offsetWindow:getChildById('displacementTypeComboBox'):getText()

    -- Referências para capturar os valores da opacidade
    local opacityOutfitPanel = offsetWindow:getChildById('OpacityOutfit')
    local opacityFieldOutfit = opacityOutfitPanel and opacityOutfitPanel:getChildById('opacityInput')

    local opacityPanel = offsetWindow:getChildById('OpacityPanel')
    local opacityFieldPanel = opacityPanel and opacityPanel:getChildById('opacityInput')

    -- Obter o valor de opacidade com base na seleção
    local opacityValue = 1.0 -- Valor padrão
    if selectedOption == 'Outfit' then
        if opacityFieldOutfit then
            opacityValue = tonumber(opacityFieldOutfit:getText()) or 1.0
        end
    elseif selectedOption == 'Item' or selectedOption == 'Effect' then
        if opacityFieldPanel then
            opacityValue = tonumber(opacityFieldPanel:getText()) or 1.0
        end
    end

    if not id or id <= 0 then
        return
    end

    -- Capturar a direção marcada atualmente (antes de salvar)
    local previousDirection = currentDirection
    local checkUp = offsetWindow:recursiveGetChildById('checkUp'):isChecked()
    local checkRight = offsetWindow:recursiveGetChildById('checkRight'):isChecked()
    local checkDown = offsetWindow:recursiveGetChildById('checkDown'):isChecked()
    local checkLeft = offsetWindow:recursiveGetChildById('checkLeft'):isChecked()

    if checkUp then
        previousDirection = 'up'
    elseif checkRight then
        previousDirection = 'right'
    elseif checkDown then
        previousDirection = 'down'
    elseif checkLeft then
        previousDirection = 'left'
    end

    -- Armazena os valores atuais de offsetX e offsetY para a direção atual
    if previousDirection then
        offsets[previousDirection].offsetX = tonumber(offsetWindow:recursiveGetChildById('offsetX'):getText()) or 0
        offsets[previousDirection].offsetY = tonumber(offsetWindow:recursiveGetChildById('offsetY'):getText()) or 0
    end

    if selectedOption == 'Outfit' then
        local displacement = {
            North = {offsets["up"].offsetX or 0, offsets["up"].offsetY or 0},
            East = {offsets["right"].offsetX or 0, offsets["right"].offsetY or 0},
            South = {offsets["down"].offsetX or 0, offsets["down"].offsetY or 0},
            West = {offsets["left"].offsetX or 0, offsets["left"].offsetY or 0}
        }

        if displacementType == 'Outfit Displacement' then
            otmlData.creatures[id] = otmlData.creatures[id] or {}
            otmlData.creatures[id]["outfit-displacement"] = otmlData.creatures[id]["outfit-displacement"] or {}

            -- Salvar os valores de deslocamento
            for direction, coords in pairs(displacement) do
                otmlData.creatures[id]["outfit-displacement"][direction] = coords
            end

            -- Salvar opacidade, se for diferente de 1
            if opacityValue ~= 1 then
                otmlData.creatures[id]["outfit-displacement"].opacity = opacityValue
            else
                otmlData.creatures[id]["outfit-displacement"].opacity = nil
            end

        elseif displacementType == 'Name Displacement' then
            otmlData.creatures[id] = otmlData.creatures[id] or {}
            otmlData.creatures[id]["name-displacement"] = otmlData.creatures[id]["name-displacement"] or {}
            for direction, coords in pairs(displacement) do
                otmlData.creatures[id]["name-displacement"][direction] = coords
            end
        end

    elseif selectedOption == 'Item' then
        otmlData.items[id] = otmlData.items[id] or {}
        otmlData.items[id]["item-displacement"] = otmlData.items[id]["item-displacement"] or {}

        -- Salvar deslocamento de x e y para item
        local offsetX = tonumber(offsetWindow:recursiveGetChildById('offsetX'):getText()) or
                            otmlData.items[id]["item-displacement"].x or 0
        local offsetY = tonumber(offsetWindow:recursiveGetChildById('offsetY'):getText()) or
                            otmlData.items[id]["item-displacement"].y or 0

        otmlData.items[id]["item-displacement"].x = offsetX
        otmlData.items[id]["item-displacement"].y = offsetY

        -- Salvar opacidade, se for diferente de 1
        if opacityValue ~= 1 then
            otmlData.items[id]["item-displacement"].opacity = opacityValue
        else
            otmlData.items[id]["item-displacement"].opacity = nil
        end

    elseif selectedOption == 'Effect' then
        otmlData.effects[id] = otmlData.effects[id] or {}
        otmlData.effects[id]["effect-displacement"] = otmlData.effects[id]["effect-displacement"] or {}

        -- Salvar deslocamento de x e y para efeito
        local offsetX = tonumber(offsetWindow:recursiveGetChildById('offsetX'):getText()) or
                            otmlData.effects[id]["effect-displacement"].x or 0
        local offsetY = tonumber(offsetWindow:recursiveGetChildById('offsetY'):getText()) or
                            otmlData.effects[id]["effect-displacement"].y or 0

        otmlData.effects[id]["effect-displacement"].x = offsetX
        otmlData.effects[id]["effect-displacement"].y = offsetY

        -- Salvar opacidade, se for diferente de 1
        if opacityValue ~= 1 then
            otmlData.effects[id]["effect-displacement"].opacity = opacityValue
        else
            otmlData.effects[id]["effect-displacement"].opacity = nil
        end
    end

    -- Salvar o arquivo OTML
    saveOtmlFile()

    -- Recarregar a exibição
    OffsetManager.reloadOtmlFile()

    -- Marcar a direção que estava antes de salvar
    if previousDirection then
        OffsetManager.toggleDirection(previousDirection)
        updateCheckboxes(previousDirection)
    end
end

function OffsetManager.deleteOffset()
    local id = tonumber(offsetWindow:getChildById('idInput'):getText())
    if not id or id <= 0 then
        displayErrorBox("Erro", "Por favor, insira um ID válido para deletar.")
        return
    end

    local selectedOption = offsetWindow:getChildById('offsetComboBox'):getText()
    local displacementType = offsetWindow:getChildById('displacementTypeComboBox'):getText()

    if selectedOption == 'Outfit' then
        if displacementType == 'Outfit Displacement' then
            if otmlData.creatures[id] then
                -- Redefinir os valores de Outfit Displacement e garantir que a opacidade seja explicitamente definida como 1.0
                otmlData.creatures[id]["outfit-displacement"] = {
                    opacity = 1.0, -- Garantindo que o valor de opacidade seja salvo como 1.0 (float)
                    North = {0, 0},
                    East = {0, 0},
                    South = {0, 0},
                    West = {0, 0}
                }
                displayInfoBox("Reset", "Outfit displacement redefinido com sucesso!")
            else
                displayErrorBox("Erro", "Nenhum outfit displacement encontrado para o ID fornecido.")
            end
        elseif displacementType == 'Name Displacement' then
            if otmlData.creatures[id] then
                -- Redefinir os valores de Name Displacement
                otmlData.creatures[id]["name-displacement"] = {
                    North = {0, 0},
                    East = {0, 0},
                    South = {0, 0},
                    West = {0, 0}
                }
                displayInfoBox("Reset", "Name displacement redefinido com sucesso!")
            else
                displayErrorBox("Erro", "Nenhum name displacement encontrado para o ID fornecido.")
            end
        end

    elseif selectedOption == 'Item' then
        if otmlData.items[id] then
            -- Redefinir os valores de Item Displacement e garantir que a opacidade seja explicitamente definida como 1.0
            otmlData.items[id]["item-displacement"] = {
                opacity = 1.0, -- Garantindo que o valor de opacidade seja salvo como 1.0 (float)
                x = 0,
                y = 0
            }
            displayInfoBox("Reset", "Item displacement redefinido com sucesso!")
        else
            displayErrorBox("Erro", "Nenhum item displacement encontrado para o ID fornecido.")
        end

    elseif selectedOption == 'Effect' then
        if otmlData.effects[id] then
            -- Redefinir os valores de Effect Displacement e garantir que a opacidade seja explicitamente definida como 1.0
            otmlData.effects[id]["effect-displacement"] = {
                opacity = 1.0, -- Garantindo que o valor de opacidade seja salvo como 1.0 (float)
                x = 0,
                y = 0
            }
            displayInfoBox("Reset", "Effect displacement redefinido com sucesso!")
        else
            displayErrorBox("Erro", "Nenhum effect displacement encontrado para o ID fornecido.")
        end

    else
        displayErrorBox("Erro", "Opção selecionada inválida.")
        return
    end

    -- Salvar o arquivo OTML com os novos valores resetados
    OffsetManager.reloadOtmlFile()
    saveOtmlFile()
end

function saveOtmlFile()
    local otmlPath = resolveOtmlPath()
    local directoryPath = otmlPath:match("(.+)/[^/]+$")
    if not g_resources.directoryExists(directoryPath) then
        g_resources.makeDir(directoryPath)
    end

    local fileContents = generateOtmlString(otmlData)
    local file, err = io.open(otmlPath, "w+")
    if file then
        file:write(fileContents)
        file:close()
    else
        error("Erro ao salvar o arquivo: " .. tostring(err))
    end
end

function resolveOtmlPath()
    return directory .. filename
end

function loadOtmlFile()
    local fileContents = g_resources.readFileContents('/things/1098/Tibia.otml')
    if fileContents then
        local existingData = parseOtml(fileContents)
        otmlData = mergeOtmlData(otmlData, existingData)
    else
        otmlData = {
            creatures = {},
            items = {},
            effects = {}
        }
    end
end

function mergeOtmlData(newData, existingData)
    for category, data in pairs(existingData) do
        newData[category] = newData[category] or {}
        for id, values in pairs(data) do
            newData[category][id] = newData[category][id] or {}
            for key, displacement in pairs(values) do
                if category == "items" or category == "effects" then
                    newData[category][id][key] = newData[category][id][key] or {}
                    newData[category][id][key].x = displacement.x or newData[category][id][key].x or 0
                    newData[category][id][key].y = displacement.y or newData[category][id][key].y or 0
                    newData[category][id][key].opacity = displacement.opacity or newData[category][id][key].opacity or 1
                elseif category == "creatures" and key == "outfit-displacement" then
                    newData[category][id][key] = newData[category][id][key] or {}
                    newData[category][id][key].opacity = displacement.opacity or newData[category][id][key].opacity or 1
                    for direction, coords in pairs(displacement) do
                        if direction ~= "opacity" then -- Certificando-se de que 'opacity' não seja tratado como uma direção
                            newData[category][id][key][direction] = newData[category][id][key][direction] or {0, 0}
                            newData[category][id][key][direction][1] = coords[1] or
                                                                           newData[category][id][key][direction][1]
                            newData[category][id][key][direction][2] = coords[2] or
                                                                           newData[category][id][key][direction][2]
                        end
                    end
                end
            end
        end
    end
    return newData
end

function parseOtml(contents)
    local data = {
        creatures = {},
        items = {},
        effects = {}
    }
    local currentCategory = nil
    local currentId = nil
    local currentDisplacementType = nil
    local awaitingDisplacementX = false
    local awaitingDisplacementY = false
    local awaitingOpacity = false
    local displacementX = nil
    local displacementY = nil
    local opacity = nil

    for line in contents:gmatch("[^\r\n]+") do
        if line:find("creatures:") then
            currentCategory = "creatures"
        elseif line:find("items:") then
            currentCategory = "items"
        elseif line:find("effects:") then
            currentCategory = "effects"
        elseif line:match("^%s*(%d+):") then
            currentId = tonumber(line:match("(%d+):"))
            data[currentCategory][currentId] = {}
            awaitingDisplacementX = false
            awaitingDisplacementY = false
            awaitingOpacity = false
            displacementX = nil
            displacementY = nil
            opacity = nil
        elseif line:find("displacement:") then
            currentDisplacementType = line:match("(%w+%-displacement):")
            data[currentCategory][currentId][currentDisplacementType] = {}
            awaitingDisplacementX = true
        elseif line:find("opacity:") then
            opacity = tonumber(line:match("opacity:%s*(%-?%d+%.?%d*)"))
            awaitingOpacity = false
            data[currentCategory][currentId][currentDisplacementType].opacity = opacity
        elseif currentCategory == "creatures" then
            local direction, x, y = line:match("%s*(%w+):%s*(%-?%d+)%s*(%-?%d+)")
            if direction and x and y then
                data[currentCategory][currentId][currentDisplacementType][direction] = {tonumber(x), tonumber(y)}
            end
        elseif awaitingDisplacementX and line:find("x:") then
            displacementX = tonumber(line:match("x:%s*(%-?%d+)"))
            awaitingDisplacementX = false
            awaitingDisplacementY = true
        elseif awaitingDisplacementY and line:find("y:") then
            displacementY = tonumber(line:match("y:%s*(%-?%d+)"))
            if currentCategory == "items" or currentCategory == "effects" or currentDisplacementType ==
                "outfit-displacement" then
                data[currentCategory][currentId][currentDisplacementType] = {
                    x = displacementX,
                    y = displacementY,
                    opacity = opacity or 1.0
                }
            end
            awaitingDisplacementY = false
        end
    end

    return data
end

function generateOtmlString(data)
    local contents = ""
    for category, entries in pairs(data) do
        contents = contents .. category .. ":\n"

        local sortedIds = {}
        for id in pairs(entries) do
            table.insert(sortedIds, id)
        end
        table.sort(sortedIds)

        for _, id in ipairs(sortedIds) do
            local entryData = entries[id]
            contents = contents .. "  " .. id .. ":\n"
            for entryType, displacement in pairs(entryData) do
                if category == "items" or category == "effects" then
                    contents = contents .. "    " .. entryType .. ":\n"
                    if displacement.opacity then
                        contents = contents .. "      opacity: " .. displacement.opacity .. "\n"
                    end
                    if displacement.x and displacement.y then
                        contents = contents .. "      x: " .. displacement.x .. "\n"
                        contents = contents .. "      y: " .. displacement.y .. "\n"
                    end
                elseif category == "creatures" and entryType == "outfit-displacement" then
                    contents = contents .. "    " .. entryType .. ":\n"
                    if displacement.opacity then
                        contents = contents .. "      opacity: " .. displacement.opacity .. "\n"
                    end
                    for direction, coords in pairs(displacement) do
                        if direction ~= "opacity" then -- Evitar duplicar a opacidade como uma direção
                            contents = contents .. "      " .. direction .. ": " .. coords[1] .. " " .. coords[2] ..
                                           "\n"
                        end
                    end
                elseif category == "creatures" then
                    contents = contents .. "    " .. entryType .. ":\n"
                    for direction, coords in pairs(displacement) do
                        if coords and coords[1] and coords[2] then
                            contents = contents .. "      " .. direction .. ": " .. coords[1] .. " " .. coords[2] ..
                                           "\n"
                        end
                    end
                end
            end
        end
    end
    return contents
end

function backupOtmlFile()
    local originalPath = resolveOtmlPath() -- Caminho original do arquivo Tibia.otml
    local backupPath = directory .. "Tibia_backup.otml" -- Caminho para o backup

    -- Gerar o conteúdo do OTML com base nos dados carregados
    local backupContents = generateOtmlString(otmlData)

    -- Criar ou sobrescrever o arquivo de backup
    local backupFile, err = io.open(backupPath, "w+")
    if backupFile then
        backupFile:write(backupContents)
        backupFile:close()
    else
        error("Erro ao criar backup: " .. tostring(err))
    end
end

function OffsetManager.resetOffset()
    -- Zera os campos offsetX, offsetY e opacity
    offsetWindow:recursiveGetChildById('offsetX'):setText('0')
    offsetWindow:recursiveGetChildById('offsetY'):setText('0')

    -- Referências para os campos de opacidade
    local opacityOutfitPanel = offsetWindow:getChildById('OpacityOutfit')
    local opacityFieldOutfit = opacityOutfitPanel and opacityOutfitPanel:getChildById('opacityInput')

    local opacityPanel = offsetWindow:getChildById('OpacityPanel')
    local opacityFieldPanel = opacityPanel and opacityPanel:getChildById('opacityInput')

    -- Resetar a opacidade para 1.0 se os campos estiverem visíveis
    if opacityFieldOutfit then
        opacityFieldOutfit:setText('1.0')
    end

    if opacityFieldPanel then
        opacityFieldPanel:setText('1.0')
    end

    -- Esconde os widgets de outfit e item, caso estejam visíveis
    outfitWidget:hide()
    itemWidget:hide()

    -- Reseta os valores de offset nas direções para 0
    offsets["up"].offsetX = 0
    offsets["up"].offsetY = 0
    offsets["right"].offsetX = 0
    offsets["right"].offsetY = 0
    offsets["down"].offsetX = 0
    offsets["down"].offsetY = 0
    offsets["left"].offsetX = 0
    offsets["left"].offsetY = 0

    -- Opcionalmente, zera o campo ID
    offsetWindow:recursiveGetChildById('idInput'):setText('')
end

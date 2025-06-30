local OPCODE_POKEBAR = 53

local loaded = false

pokemons = {}
size = "big"
currentSlotBar = nil

function getOpCode(protocol, opcode, buffer)
    loaded = true
    local status, json_data =
        pcall(
        function()
            return json.decode(buffer)
        end
    )
    if not status then
        return false
    end

    if json_data["update"] then
        local index = json_data["index"]
        for i, child in pairs(PokesPanel:getChildren()) do
            if i == tonumber(index) then
                local health = 100
                if size == "big" then
					pokemons[i].health = health
					pokemons[i].maxHealth = health

					child.progress:setPercent(health)
					child.health:setText(health..'%') 
					child.progress:setBackgroundColor(getHealthColor(health))
					child.background:setEnabled(true)
					child.background:setChecked(false)
				end
                break
            end
        end
        return
    end

    pokemons = {}
    PokesPanel:destroyChildren()
    for i = 1, #json_data do
        local pokemon = json_data[i]
        table.insert(pokemons, pokemon)
    end
    doSetPokemonsInTeam()
end

function getPokemons()
    return pokemons
end

function getPokebar()
    return PokesPanel
end

local function resize()
  local height = ((PokesPanel:getChildCount() == 0) and 35 or 5) + PokesPanel:getPaddingBottom()
  
  for i, slotBar in pairs(PokesPanel:getChildren()) do
    height = height + slotBar:getHeight() + slotBar:getMarginTop()
  end

  PokeTeamWindow:setSize("231 "..height + 23)
end

function doSetPokemonsInTeam()
    PokesPanel:destroyChildren()
	
	if size == "small" then
    PokeTeamWindow:setImageSource("images/background")
		PokeTeamWindow:setSize("6 64")
		for i = 1, #pokemons do
			local pokemon = g_ui.createWidget("PokeBase", PokesPanel)
			pokemon:setId(i)
			local name = string.find(pokemons[i].name, "Shiny")
			local getShinyName = string.match(pokemons[i].name, "Shiny" .. "%s*(.+)")
			local realName = string.lower(pokemons[i].name)
			if name ~= nil then
				pokemon.icon:setOutfit({type = pokemons[i].looktype})
				local type1, type2 = getTypesByName(string.lower(getShinyName))
				pokemon.base_color:setImageColor(getColorByType(type1))
				pokemon.loading:setImageColor(getColorByType(type1))
			else
				local type1, type2 = getTypesByName(realName)
				pokemon.icon:setOutfit({type = pokemons[i].looktype})
				pokemon.base_color:setImageColor(getColorByType(type1))
				pokemon.loading:setImageColor(getColorByType(type1))
			end
            pokemon.icon:setOldScaling(true)
			pokemon.icon.onClick = function()
                currentSlotBar = pokemon
				doChangePokemon(i, pokemons[i].pokeid)
			end
			pokemon.keyNumber:setText(i)
		end
		if #pokemons > 0 then
			tamanho = 35 + (#pokemons * 64)
			PokeTeamWindow:setSize("64 " .. tamanho)
		else
			PokeTeamWindow:setSize("6 64")
		end
	elseif size == "big" then 
        PokeTeamWindow:setImageSource("")
        for i = 1, #pokemons do
			local pokemon = g_ui.createWidget("SlotBar", PokesPanel)
			pokemon:setId(i)

			local realName = string.lower(pokemons[i].name)
			local nickname = pokemons[i].nickname or ""
			
            local health = pokemons[i].health
            local maxHealth = pokemons[i].maxHealth
            local percent = math.floor(health/maxHealth * 100)
            if percent >= 100 then percent = 100 end
            
            pokemon.background:setEnabled(pokemon.percent ~= 0)
            
            if health == 0 then
                pokemon.background:setEnabled(false)
                pokemon.background:setChecked(true)
            end
            
            if (pokemons[i].use) then
                if ( currentSlotBar ) then
                    pokemon.background:setOn(false)
                end
            
                pokemon.background:setOn(true)
                currentSlotBar = pokemon   
            end
			if #nickname > 0 then
				pokemon.name:setText(nickname)
			else
				pokemon.name:setText(capitalizeFirstLetter(realName))
			end
            
            pokemon.progress:setPercent(percent)
            pokemon.health:setText(percent..'%')
            pokemon.progress:setBackgroundColor(getHealthColor(percent))
            local type1, type2 = getTypesByName(realName)
            pokemon.backgroundPortrait:setImageColor(getColorByType(type1))

      
            pokemon.portrait:setOutfit({type = pokemons[i].looktype})
            pokemon.portrait:setOldScaling(true)

			pokemon.onClick = function()
                --currentSlotBar = pokemon
				doChangePokemon(i, pokemons[i].pokeid, true)
			end
		end
		resize()
	end
end

local ultimaExecucao = 0
local intervaloMinimo = 2

function doChangePokemon(number, pokecall, new)
  if new then
    for i, child in pairs(PokesPanel:getChildren()) do
      child.background:setChecked(true)
    end
  end
  PokesPanel:setOn(true)
    local player = g_game.getLocalPlayer()
    if not player then
        return
    end
    g_game.talk(pokecall)
    for i = 1, #pokemons do
        local pokepanel = doGetPanelPoke(i)
        if pokepanel ~= nil then
            g_effects.fadeIn(pokepanel, 350)
            scheduleEvent(
                function()
                    g_effects.fadeOut(pokepanel, 350)
                end,
                1950
            )
        end
    end
end

local function getHealthColor(health)
  return (health < 35) and '#d72800' or
	     (health < 65) and '#e7c148' or '#5fda4c'
end

function onCreatureHealthPercentChange(creature, health)
    if ( creature:isLocalSummon() and currentSlotBar ) then
        if size == "small" then
			-- ?
        else
			if currentSlotBar.progress and size == "big" then
				currentSlotBar.progress:setPercent(health)
				currentSlotBar.health:setText(health..'%') 
				currentSlotBar.progress:setBackgroundColor(getHealthColor(health))
			end
        end

    end
end

function createMenu()
  local menu = g_ui.createWidget('PopupMenu')
  if size == 'big' then
    menu:addOption('Reduzir', function() size = 'small' updateBar() doSetPokemonsInTeam() end)
  else
    menu:addOption('Expandir', function() size = 'big' updateBar() doSetPokemonsInTeam() end)
  end
  menu:display()
end


function updateBar()
    local buffer = {
        type = "update",
    }

	g_game.getProtocolGame():sendExtendedOpcode(53, json.encode(buffer))
end

function checkBar()
    if not loaded then
        
        scheduleEvent(function ()
            modules.game_request.sendRequest("pokebar")
        end, 200)
       
    end
end


function init()
    PokeTeamWindow = g_ui.loadUI("poketeam", modules.game_interface.getRootPanel())
    print("loading")
	g_mouse.bindPress(PokeTeamWindow, function() createMenu() end, MouseRightButton)
    PokesPanel = PokeTeamWindow.pokes
    ProtocolGame.registerExtendedOpcode(OPCODE_POKEBAR, getOpCode)
    connect(Creature, {
        onHealthPercentChange = onCreatureHealthPercentChange
    })
    connect(g_game, {
        onGameStart = checkBar
    })
end


function terminate()
    ProtocolGame.unregisterExtendedOpcode(OPCODE_POKEBAR)
    PokeTeamWindow:destroy()
    currentSlotBar = nil
    disconnect(
        g_game,
        {
            onGameEnd = function()
                PokeTeamWindow:hide()
            end
        }
    )
  disconnect(Creature, {
    onHealthPercentChange = onCreatureHealthPercentChange,
  })
end

function doGetPanelPoke(number)
    local pokes = PokesPanel
    if pokes and pokes[number] then
        return pokes[number].loading
    else
        return nil
    end
end

function capitalizeFirstLetter(word)
    return word:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end
-- Public functions
function init()

NewPokemon = g_ui.displayUI('newPokemon')

connect(g_game, 'onTextMessage', getParams)
connect(g_game, { onGameEnd = hide } )
NewPokemon:hide()
ProtocolGame.registerExtendedOpcode(69, function(protocol, opcode, buffer) parse(buffer) end)
end

function parse(buffer)
NewPokemon:show()
end

function hide()
	if NewPokemon:isVisible() then
	  NewPokemon:hide()
	end
end

function show()
  NewPokemon:show()
  NewPokemon:raise()
  NewPokemon:focus()
end

function firstpoke(poke)
  if acceptWindow then
    return true
  end

  local acceptFunc = function()
    g_game.talk("#firstpoke "..poke.."")
	acceptWindow:destroy()
	acceptWindow = nil
	NewPokemon:hide()
  end
  
  local cancelFunc = function() acceptWindow:destroy() acceptWindow = nil end

  acceptWindow = displayGeneralBox(tr('Escolher pokemon'), tr("Voce deseja escolher "..poke..", como seu inicial? Essa decisao e irreversivel."),
  { { text=tr('Yes'), callback=acceptFunc },
    { text=tr('No'), callback=cancelFunc },
    anchor=AnchorHorizontalCenter }, acceptFunc, cancelFunc)
  return true
end
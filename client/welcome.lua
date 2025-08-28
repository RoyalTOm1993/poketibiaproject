local welcomeText = 'Bem vindo(a) ao PokéMaster Online! Participe do nosso Discord para acompanhar as novidades.'

function init()
  connect(g_game, { onGameStart = onGameStart })
end

function terminate()
  disconnect(g_game, { onGameStart = onGameStart })
end

function onGameStart()
  addEvent(function()
    modules.game_textmessage.displayBroadcastMessage(welcomeText)
  end, 1000)
end
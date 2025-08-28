function onTimer(interval)
  local storageValue = 17110

  setGlobalStorageValue(storageValue, 1)
  Game.broadcastMessage("[Evento Bolao]: O Evento Bolao Esta Ativo por 2 Minutos, use o comando !Bolao NumeroDe1a100 Para Participar", MESSAGE_EVENT_ADVANCE)

  addEvent(function()
    setGlobalStorageValue(storageValue, 0)
    Game.broadcastMessage("[Evento Bolao]: O evento finalizou", MESSAGE_EVENT_ADVANCE)
  end, 120000) -- 2 minutos em milissegundos

  return true
end

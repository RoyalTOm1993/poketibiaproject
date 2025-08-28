local messages = {
    "Aviso: Tire suas d�vidas no Canal Help, acessado via CTRL + O.",
    "Aviso: A nossa equipe n�o se responsabiliza por roubos entre jogadores. Ent�o sempre tome cuidado!",
    "Aviso: Qualquer problema, reporte no Discord.",
}

function onThink(interval, lastExecution)
    local message = messages[math.random(1, #messages)]
    broadcastMessage(message, MESSAGE_EVENT_ADVANCE)
    return true
end

local messages = {
    "Aviso: Tire suas dúvidas no Canal Help, acessado via CTRL + O.",
    "Aviso: A nossa equipe não se responsabiliza por roubos entre jogadores. Então sempre tome cuidado!",
    "Aviso: Qualquer problema, reporte no Discord.",
}

function onThink(interval, lastExecution)
    local message = messages[math.random(1, #messages)]
    broadcastMessage(message, MESSAGE_EVENT_ADVANCE)
    return true
end

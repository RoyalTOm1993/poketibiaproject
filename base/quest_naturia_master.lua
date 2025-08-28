local dfcaffaf
local phrases = {{
    "Eu sou um homem que se tornar� o Rei dos Bravos Guerreiros do Mar!",
    "As mentiras s�o como flores. Elas podem parecer bonitas, mas s�o apenas tempor�rias.",
    "Se voc� quiser viver, voc� tem que lutar!",
    "Um homem tem que ser forte o suficiente para lutar contra o mundo!",
    "A verdadeira coragem � enfrentar o desconhecido, mesmo quando voc� est� com medo!",
    "N�o importa qu�o forte seja o inimigo, sempre h� uma maneira de venc�-lo!",
    "N�o tenha medo de falhar. Apenas tenha medo de n�o tentar!",
    "N�o h� nada mais importante do que proteger a vida dos seus amigos!",
}}

function get_random_phrase()
    return phrases[math.random(#phrases)]
end

function say_random_phrase()
    local npcPos = getCreaturePosition(Npc())
    doCreatureSay(Npc(), get_random_phrase(), TALKTYPE_SAY, false, 0, npcPos)
end

function onThink(interval)
    if os.time() % 30 == 0 then
        say_random_phrase()
    end
    return true
end

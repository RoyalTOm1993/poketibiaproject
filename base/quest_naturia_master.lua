local dfcaffaf
local phrases = {{
    "Eu sou um homem que se tornará o Rei dos Bravos Guerreiros do Mar!",
    "As mentiras são como flores. Elas podem parecer bonitas, mas são apenas temporárias.",
    "Se você quiser viver, você tem que lutar!",
    "Um homem tem que ser forte o suficiente para lutar contra o mundo!",
    "A verdadeira coragem é enfrentar o desconhecido, mesmo quando você está com medo!",
    "Não importa quão forte seja o inimigo, sempre há uma maneira de vencê-lo!",
    "Não tenha medo de falhar. Apenas tenha medo de não tentar!",
    "Não há nada mais importante do que proteger a vida dos seus amigos!",
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

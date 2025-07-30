local phrases = {
"Eu vou me tornar o Rei dos Piratas!",
"Não importa o que aconteça, eu nunca vou desistir!",
"Viver sem aventura não é viver!",
"Quando alguém machuca meus amigos, eu fico com muita raiva!",
"O mais importante na vida são os amigos que fazemos pelo caminho.",
"Não é preciso ter um motivo para ajudar alguém.",
"Aqueles que não seguem suas próprias ambições nunca alcançarão seus sonhos.",
"Eu não sou um herói, mas se precisarem de ajuda, eu vou estar lá!",
}

-- Função para selecionar uma frase aleatória da lista
local function get_random_phrase()
return phrases[math.random(#phrases)]
end

-- Função para exibir a frase no chat
function onSay(words)
print(get_random_phrase())
end
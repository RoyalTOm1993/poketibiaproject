local phrases = {
"Sou um médico! Eu devo proteger todos os meus pacientes, não importa o quê!",
"Pessoas não são medicamentos! Você não pode simplesmente jogá-las fora!",
"Não deixe que os outros definam quem você é! Seja quem você quer ser!",
"A vida é cheia de escolhas, mas você tem que escolher com sabedoria!",
"Quando estou cuidando de alguém, esqueço todas as minhas próprias dores.",
"Nós temos que viver e lutar pelo amanhã!",
"Não há nada que um bom médico não possa curar!",
"Às vezes, é preciso coragem para admitir que precisamos de ajuda.",
}

-- Função para selecionar uma frase aleatória da lista
local function get_random_phrase()
return phrases[math.random(#phrases)]
end

-- Função para exibir a frase no chat
function onSay(words)
print(get_random_phrase())
end
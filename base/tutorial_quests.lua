local phrases = {
"O destino é algo que cada um cria por si mesmo.",
"Eu vou me tornar o Rei dos Piratas, e ninguém vai me impedir!",
"As pessoas são livres para sonhar o que quiserem, mas o que elas fazem com esses sonhos é o que as define.",
"A verdadeira liberdade é ter o poder de fazer o que quiser, sem se importar com as consequências.",
"Eu não ligo para a justiça ou moralidade. Tudo o que me importa é conseguir o que quero.",
"Aqueles que não têm coragem para seguir seus próprios sonhos sempre tentarão desencorajar os outros.",
"A vida é curta demais para se importar com as opiniões dos outros. Faça o que quiser e siga em frente.",
"O mundo é cheio de covardes que se escondem atrás de suas limitações. Eu não sou um deles.",
}

-- Função para selecionar uma frase aleatória da lista
local function get_random_phrase()
return phrases[math.random(#phrases)]
end

-- Função para exibir a frase no chat
function onSay(words)
print(get_random_phrase())
end
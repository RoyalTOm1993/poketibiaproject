local phrases = {
"A verdadeira vitória é quando você consegue mudar o coração de alguém.",
"O poder é inútil se você não sabe como usá-lo.",
"Não é o poder que define uma pessoa, mas sim a maneira como ela usa esse poder.",
"Aqueles que não são dignos do poder que possuem acabarão por perdê-lo.",
"O conhecimento é a verdadeira chave para o poder.",
"Não existe tal coisa como sorte. Aqueles que são bem sucedidos são aqueles que se prepararam para as oportunidades.",
"A verdadeira força vem da vontade de proteger aqueles que você ama.",
"A verdadeira justiça é aquela que é feita com sabedoria e compaixão.",
}

-- Função para selecionar uma frase aleatória da lista
local function get_random_phrase()
return phrases[math.random(#phrases)]
end

-- Função para exibir a frase no chat
function onSay(words)
print(get_random_phrase())
end
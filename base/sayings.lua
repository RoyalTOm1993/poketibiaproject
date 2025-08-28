local phrases = {
"As flores caem para que possam florescer novamente.",
"Se você se render agora, eu prometo que vou deixar você viver.",
"A história deste mundo é escrita com os nomes dos vencedores.",
"A morte não é um adeus eterno, mas uma transformação para a natureza universal.",
"Para ganhar algo, é preciso sempre sacrificar algo em troca.",
"Eu já estive em muitos lugares, e posso dizer com confiança que este é o mais bizarro de todos eles.",
"Eu acredito que a existência daqueles que não desejam viver é a própria prova de que a vida é algo precioso.",
"Não me subestime. Eu sei mais do que pareço.",
}

-- Função para selecionar uma frase aleatória da lista
local function get_random_phrase()
return phrases[math.random(#phrases)]
end

-- Função para exibir a frase no chat
function onSay(words)
print(get_random_phrase())
end
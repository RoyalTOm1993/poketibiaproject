local phrases = {
"A verdadeira força vem do amor que sentimos por nossos filhos.",
"Não há nada mais precioso neste mundo do que a família.",
"Aqueles que machucam meus filhos serão esmagados sob meu poder.",
"Não há nada que eu não possa conseguir se meus filhos estiverem ao meu lado.",
"O poder é inútil se não temos aqueles que amamos ao nosso lado.",
"O doce mais delicioso é aquele feito com amor para a família.",
"Nada pode superar o amor que uma mãe sente por seus filhos.",
"A verdadeira riqueza é ter uma família unida e amorosa.",
}

-- Função para selecionar uma frase aleatória da lista
local function get_random_phrase()
return phrases[math.random(#phrases)]
end

-- Função para exibir a frase no chat
function onSay(words)
print(get_random_phrase())
end
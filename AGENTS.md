---
# Guard rails para os agentes
# Objetivo: impedir que o agente aplique patches automáticos durante a inicialização
# Resultado esperado: o agente só analisa e sugere, não escreve no repo.
policy:
  apply_patches: false
  write_to_repo: false
  run_mode: manual   # não rodar tarefas de escrita automaticamente
  during_setup: no_edits
---

# Instruções obrigatórias (leitura por agentes)

**NÃO MODIFICAR ARQUIVOS DO REPOSITÓRIO.**
- Trate o repositório como *read-only*.
- Arquivos com extensões como .dll, .exe, .props, .proj, arquivos crypto++, imagens em geral e demais extensões relacionadas a compilação e build do servidor e do client não estão presentes no repositório para a devida otimização do processo de edição dos arquivos que estão presentes, mas considere que todos os arquivos, principalmente de imagem, mencionados nos códigos estão presentes na pasta original no Desktop do usuário.
- Não aplicar `patch`, `write`, `format`, `move`, `delete` ou qualquer ação que altere arquivos.
- Durante a inicialização (setup/build/postCreate), **não realizar nenhuma mudança**.
- Se for necessário sugerir mudanças, **apenas gere um plano ou um diff no texto**, sem aplicar.
- Aguarde instruções humanas explícitas dizendo "pode aplicar" antes de propor qualquer patch.

## Tarefas
- nome: noop
  descrição: Apenas analisar e responder perguntas. Não editar arquivos.

## Escopo
Aplica-se a todo o repositório Poketibia (TFS 1.4 + OTCv8 + RevScript).

## Estrutura
- `base/`: código do servidor TFS e scripts Lua.
- `client/`: cliente OTCv8 com scripts e interfaces.

### Pastas
- `base` – núcleo C++ do servidor (lógica, networking). Exemplos: alterar cálculo de combate ou protocolos de conexão; veja os arquivos `.cpp` em `base/src`.
- `base` – scripts Lua do servidor (ações, criaturas, quests). Exemplos: ajustar ações ou recompensas de quests nas pastas `base/data/actions`, `base/data/creatures` etc.
- `client` – scripts Lua do cliente (UI, eventos). Exemplos: tooltip universal (`client/modules/tooltip.lua`) ou scripts da tela de login; estilos relacionados em `.otui`/`.otmod` no mesmo diretório.
- Arquivos `.otui`/`.otmod` – layout e estilos de interface. Exemplos: cor de botões na tela de login em `client/modules/entergame.otui` ou `client/40-entergame.otui`; busque estilos em `client/**/*.otui` e `client/**/*.otui`.

## Estilo de código

### C++ (`base/src`, `client/src`)
- Indente com tabulações; abra chaves em nova linha (`void foo()\n{`).
- Use nomes em CamelCase para classes e métodos.
- Evite espaços em branco ao fim das linhas.​:codex-file-citation[codex-file-citation]{line_range_start=21 line_range_end=37 path=base/src/actions.cpp git_url="https://github.com/RoyalTOm1993/poketibiaproject/blob/main/base/src/actions.cpp#L21-L37"}​

### Lua do servidor (`base/data`)
- Indente com tabulações; utilize snake_case para funções/variáveis.​:codex-file-citation[codex-file-citation]{line_range_start=1 line_range_end=20 path=base/data/game.lua git_url="https://github.com/RoyalTOm1993/poketibiaproject/blob/main/base/data/game.lua#L1-L20"}​

### Lua do cliente (`client/modules`)
- Indente com **2 espaços**; use lowerCamelCase para nomes.​:codex-file-citation[codex-file-citation]{line_range_start=8 line_range_end=22 path=client/modules/actionbar.lua git_url="https://github.com/RoyalTOm1993/poketibiaproject/blob/main/client/modules/actionbar.lua#L8-L22"}​

### Arquivos `.otui`/`.otmod`
- Indentação de 2 espaços.

## Fluxo de trabalho

1. Use `rg` para buscar trechos de código.
2. Antes de commitar, verifique a compilação.

### Localizando estilos e assets
- Usar `rg` para buscar nomes de widgets ou classes.
- Conferir `.otui` para definição de layout/cores.
- Verificar scripts em `client/*` para lógica associada.
- Procurar tooltips ou estilos globais em módulos comuns (por ex., `client/` ou arquivos `.otui` compartilhados).

# AGENTS

## Escopo
Aplica-se a todo o repositório Poketibia (TFS 1.4 + OTCv8 + RevScript).

## Estrutura
- `base/`: código do servidor TFS e scripts Lua.
- `client/`: cliente OTCv8 com scripts e interfaces.

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

### Compilação do servidor
```bash
cd base && mkdir -p build && cd build
cmake ..
make -j$(nproc)

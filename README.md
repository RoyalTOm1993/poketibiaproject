# Poketibia Project (TFS 1.4 + OTCv8 + RevScript)

Este repositório traz uma versão customizada de Poketibia, construída sobre o The Forgotten Server (TFS) 1.4 (C++) e o cliente OTCv8, com arquitetura preparada para suporte ao sistema de scripts RevScript. 

> **Atenção:**  
> Grande parte da base do client foi derivada do repositório [@edubart/otclient](https://github.com/edubart/otclient), porém extensivamente modificada, reduzida e reestruturada para o propósito deste projeto. Sistemas e arquivos não utilizados foram removidos para facilitar a manutenção e a compreensão, tanto por humanos quanto por IA.

## Estrutura Detalhada do Repositório

O projeto está dividido em duas pastas principais, cada uma organizada para facilitar edições e análises inteligentes:

### client/

Contém todos os arquivos do client OTCv8 necessários para execução e customização do jogo. Os arquivos mais relevantes encontrados incluem scripts Lua (.lua), definições de interface (.otui), módulos (.otmod) e arquivos de configuração. Exemplos de funcionalidades presentes:

- Scripts de lógica do client, manipulação de interface, efeitos gráficos, NPCs, comunicação com o servidor.
- Definições detalhadas de interface, sistemas de janelas, barras, inventário, etc.
- Muitos recursos e sistemas originais do otclient foram removidos, mantendo apenas o essencial para o Poketibia.
- Os arquivos presentes podem incluir desde utilitários (ex: uuid.lua), sistemas de Profiler, handlers de NPC, até integrações com sistemas como NUI (interface web) e frameworks customizados.
- Estrutura modular para permitir adição ou remoção de sistemas visuais e lógicos facilmente.

### base/

Agrupa toda a lógica do servidor, incluindo:
- Source em C++ (.cpp, .h) para o TFS 1.4, com adaptações para RevScript.
- Scripts do servidor em Lua (.lua), módulos (.otmod) e arquivos de configuração.
- Estrutura de pastas inspirada no TFS, mas simplificada: muitos arquivos, sistemas de quests e conteúdos não utilizados de Pokémon foram removidos para deixar a base enxuta.
- Atenção especial aos diretórios de dados (`base/data`), que podem ter arquivos espalhados em subpastas devido ao limite de 1.000 arquivos por pasta do GitHub.
- Códigos de utilidades, gerenciamento de arquivos, logs, IO, CPU, além de componentes de autenticação, gerenciamento de mapas, criaturas, spells, etc.

### Organização e Filtros

- Arquivos grandes e irrelevantes para a construção/modificação do projeto foram removidos.
- Imagens, executáveis, vídeos e sons não estão presentes, visando foco total em lógica e interface.
- Os arquivos mais importantes para customização e manutenção possuem as extensões: `.cpp`, `.h`, `.lua`, `.otmod`, `.otui`.
- Documentação e exemplos de uso podem estar distribuídos em arquivos `.md` e `.txt` nas respectivas pastas.

### Limitações e Observações

- Algumas pastas, especialmente `base/data`, podem ter conteúdo movido para outras localizações devido ao limite de arquivos do GitHub.
- Os resultados apresentados aqui são baseados em uma análise limitada (máx. 10 arquivos retornados por pesquisa automatizada). Para ver a listagem completa dos arquivos e explorar a fundo, utilize o [buscador do GitHub](https://github.com/RoyalTOm1993/poketibiaproject/search).
- Os sistemas e arquivos presentes podem servir de referência para criação de novos módulos, sistemas visuais, scripts customizados de Pokémon, etc., de acordo com sua necessidade.

## Objetivo

A principal meta deste repositório é fornecer uma base enxuta, de fácil análise e modificação, tanto para edição manual quanto por IA (ChatGPT/Copilot), permitindo:

- Customização visual e lógica do client OTCv8 e do servidor TFS.
- Remoção de sistemas não utilizados (como quests e arquivos redundantes de Pokémon).
- Facilidade para implementar novos sistemas, visuais e scripts.
- Suporte pleno ao RevScript segundo arquitetura do TFS 1.4.

## Tecnologias e Características

- **Servidor:** The Forgotten Server 1.4 (C++, suporte a RevScript)
- **Client:** OTCv8 (derivado do otclient, customizável via scripts e interface .otui)
- **Scripts:** Lua para lógica de jogo, eventos e integração client-server
- **Modularidade:** Estrutura pensada para facilitar análise, manutenção e extensão
- **Compatibilidade:** Estrutura pronta para expansão por IA ou desenvolvedores humanos

## Como Contribuir

Sinta-se à vontade para sugerir melhorias, abrir issues ou PRs. Para análises por IA, concentre-se nos arquivos destacados e utilize as extensões recomendadas.

---
**Nota importante:**  
Este repositório prioriza clareza, modularidade e praticidade, removendo elementos supérfluos e focando no essencial para desenvolvimento de um Poketibia altamente customizado.  
O client é uma versão enxuta e adaptada do [@edubart/otclient](https://github.com/edubart/otclient), e a base do servidor é TFS 1.4, pronta para scripts modernos e integrações inteligentes.

> Para ver todos os arquivos e estrutura completa, utilize a [busca do GitHub](https://github.com/RoyalTOm1993/poketibiaproject/search).

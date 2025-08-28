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
- Arquivos com extensões como .dll, .exe, .txt .props, .proj, arquivos crypto++, imagens em geral e demais extensões relacionadas a compilação e build do servidor e do client não estão presentes no repositório para a devida otimização do processo de edição dos arquivos que estão presentes, mas considere que todos os arquivos, principalmente de imagem, mencionados nos códigos estão presentes na pasta original no Desktop do usuário.
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

### Subdiretórios
- `base/src` – núcleo C++ do servidor (lógica, networking). Exemplos: alterar cálculo de combate ou protocolos de conexão; veja os arquivos `.cpp` em `base/src`.
- `base/data` – scripts Lua do servidor (ações, criaturas, quests). Exemplos: ajustar ações ou recompensas de quests nas pastas `base/data/actions`, `base/data/creatures` etc.
- `client/modules` – scripts Lua do cliente (UI, eventos). Exemplos: tooltip universal (`client/modules/tooltip.lua`) ou scripts da tela de login; estilos relacionados em `.otui`/`.otmod` no mesmo diretório.
- Arquivos `.otui`/`.otmod` – layout e estilos de interface. Exemplos: cor de botões na tela de login em `client/modules/entergame.otui` ou `client/40-entergame.otui`; busque estilos em `client/**/*.otui` e `client/modules/**/*.otui`.

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
- Verificar scripts em `client/modules/*` para lógica associada.
- Procurar tooltips ou estilos globais em módulos comuns (por ex., `client/modules` ou arquivos `.otui` compartilhados).

### Compilação do servidor
```bash
cd base && mkdir -p build && cd build
cmake ..
make -j$(nproc)
### Compilação do servidor
```bash
cd base && mkdir -p build && cd build
cmake ..
make -j$(nproc)
```

### Compilação do cliente
```bash
cd client/v16 && mkdir -p build && cd build
cmake ..
make -j$(nproc)
```

## Resumo dos arquivos

Arquivos .otmod do repositório:

client/console.otmod – módulo game_console que gerencia a janela de chat.

client/guild_management.otmod – módulo game_guildmanagement para administração de guildas.

client/modules/actionbar.otmod – módulo game_actionbar que controla a barra de ações.

client/modules/background.otmod – módulo client_background responsável pelo plano de fundo da tela de login.

client/modules/bank.otmod – módulo bank que exibe e manipula o sistema bancário.

client/modules/battle.otmod – módulo game_battle que controla a janela de batalha.

client/modules/boss_healthbar.otmod – módulo boss_healthbar para exibir barra de vida de chefes.

client/modules/boss_ranking.otmod – módulo boss_ranking que mostra ranking de dano em chefes.

client/modules/bugreport.otmod – módulo game_bugreport para enviar relatórios de bug.

client/modules/buttons.otmod – módulo game_buttons exibindo mini‑janela com botões.

client/modules/client.otmod – módulo client que inicializa e configura a janela principal do cliente.

client/modules/client_ui_debug.otmod – módulo client_ui_debug desenha a árvore de widgets sob o cursor para depuração.

client/modules/console.otmod – módulo game_console duplicado para gerenciamento do chat.

client/modules/containers.otmod – módulo game_containers que gerencia janelas de contêineres.

client/modules/contracts.otmod – módulo contracts para o sistema de contratos/duelos.

client/modules/corelib.otmod – módulo corelib com classes e funções básicas em Lua usadas pelos demais módulos.

client/modules/crash_reporter.otmod – módulo crash_reporter envia logs de falhas ao servidor remoto.

client/modules/donationgoals.otmod – módulo game_donationgoals exibindo metas de doação.

client/modules/entergame.otmod – módulo client_entergame que gerencia a entrada no jogo e a lista de personagens.

client/modules/features.otmod – módulo game_features que gerencia as funcionalidades liberadas no cliente.

client/modules/feedback.otmod – módulo client_feedback permitindo envio de feedback.

client/modules/game_craft.otmod – módulo game_craft para o sistema de fabricação.

client/modules/game_creatureinformation.otmod – módulo game_creatureinformation ajusta posições de nomes e barras de criaturas.

client/modules/game_dex.otmod – módulo game_dex implementando a Pokédex.

client/modules/game_donate.otmod – módulo game_donate para o sistema de doações.

client/modules/game_information.otmod – módulo game_information exibe informações diversas.

client/modules/game_pix.otmod – módulo game_pix integra o método de pagamento PIX.

client/modules/game_request.otmod – módulo game_request para requisições internas do jogo.

client/modules/game_rewards.otmod – módulo game_rewards exibindo recompensas.

client/modules/game_roleta.otmod – módulo game_roleta oferecendo jogo de roleta.

client/modules/game_shop.otmod – módulo game_shop para a loja in‑game.

client/modules/gamelib.otmod – módulo gamelib com classes/utilidades relacionadas ao jogo.

client/modules/hotkeys_manager.otmod – módulo game_hotkeys gerencia atalhos do cliente.

client/modules/interface.otmod – módulo game_interface que cria a interface do jogo.

client/modules/inventory.otmod – módulo game_inventory para a janela de pokémons do jogador.

client/modules/itemselector.otmod – módulo game_itemselector para seleção de itens.

client/modules/locales.otmod – módulo client_locales responsável pela tradução de textos.

client/modules/market.otmod – módulo market que implementa o sistema de mercado.

client/modules/minimap.otmod – módulo game_minimap gerencia o minimapa.

client/modules/mobile.otmod – módulo client_mobile adapta a interface para dispositivos móveis.

client/modules/modaldialog.otmod – módulo game_modaldialog para exibir e processar diálogos modais.

client/modules/newPokemon.otmod – módulo NewPokemon usado para escolher um novo pokémon inicial.

client/modules/npcdialog.otmod – módulo game_npcdialog que provê interface de diálogos com NPCs (checkboxes, textos, items etc.).

client/modules/npctrade.otmod – módulo game_npctrade para trocas com NPCs.

client/modules/offset.otmod – módulo game_offset manipula ajustes de offset do cliente.

client/modules/options.otmod – módulo client_options responsável pela janela de opções.

client/modules/outfit.otmod – módulo game_outfit para alteração de outfit do jogador.

client/modules/pass.otmod – módulo game_pass exibindo recompensas da temporada.

client/modules/player_brokes.otmod – módulo player_brokes mostra estatísticas de quebrados/pontos.

client/modules/playerdeath.otmod – módulo game_playerdeath gerencia mortes do jogador.

client/modules/playermount.otmod – módulo game_playermount controla montarias.

client/modules/playertrade.otmod – módulo game_playertrade permite troca de itens entre jogadores.

client/modules/pokemon_shaders.otmod – módulo pokemon_shaders para shaders de pokémon.

client/modules/pokemonmoves.otmod – módulo game_pokemonmoves barra de movimentos.

client/modules/poketeam.otmod – módulo game_poketeam barra de pokémons do time.

client/modules/profiles.otmod – módulo client_profiles para perfis do cliente.

client/modules/protocol.otmod – módulo game_protocol responsável pelo protocolo de jogo.

client/modules/questlog.otmod – módulo game_questlog que exibe e acompanha quests.

client/modules/ruleviolation.otmod – módulo game_ruleviolation para denúncias (Ctrl+Y).

client/modules/shaders.otmod – módulo game_shaders carregando shaders.

client/modules/skills.otmod – módulo game_skills que gerencia a janela de skills.

client/modules/space_phone.otmod – módulo space_phone simulando telefone portátil.

client/modules/spectate.otmod – módulo game_spectate permitindo assistir outros jogadores.

client/modules/stats.otmod – módulo game_stats exibindo ping e FPS.

client/modules/styles.otmod – módulo client_styles carrega fontes e estilos do cliente.

client/modules/task_kill.otmod – módulo task_kill para missões de abate.

client/modules/terminal.otmod – módulo client_terminal executa funções Lua via terminal.

client/modules/textedit.otmod – módulo client_textedit abre janela para edição de textos.

client/modules/textmessage.otmod – módulo game_textmessage gerencia mensagens de texto do jogo.

client/modules/textwindow.otmod – módulo game_textwindow que permite editar livros/listas.

client/modules/things.otmod – módulo game_things carrega arquivos spr e dat.

client/modules/topbar.otmod – módulo game_topbar adiciona barra superior personalizada estilo Tibia 12.

client/modules/topmenu.otmod – módulo client_topmenu cria o menu superior.

client/modules/tutorial.otmod – módulo game_tutorial para o tutorial do jogo.

client/modules/updater.otmod – módulo updater que atualiza o cliente.

client/modules/viplist.otmod – módulo game_viplist gerencia a lista VIP.

client/modules/walking.otmod – módulo game_walking controla movimentação e viradas.


Arquivos .cpp na pasta client:

client/src/adaptiverenderer.cpp – renderer que ajusta performance dinamicamente.

client/src/android_native_app_glue.cpp – cola de integração com o NDK para eventos Android.

client/src/androidplatform.cpp – implementação de abstrações de plataforma para Android.

client/src/androidwindow.cpp – criação e gerenciamento de janela em dispositivos Android.

client/src/animatedtext.cpp – renderização de textos animados na tela.

client/src/animatedtexture.cpp – suporte a texturas animadas.

client/src/animator.cpp – sistema genérico de animações.

client/src/apngloader.cpp – carregamento de imagens APNG.

client/src/application.cpp – inicialização da aplicação e ciclo principal.

client/src/asyncdispatcher.cpp – despachante de tarefas assíncronas.

client/src/atlas.cpp – manipulação de atlas de texturas.

client/src/binarytree.cpp – implementação de árvore binária utilitária.

client/src/bitmapfont.cpp – fonte baseada em bitmaps.

client/src/cachedtext.cpp – cache de renderização de textos.

client/src/client.cpp – classe principal do cliente, gerencia estado global.

client/src/clock.cpp – utilidades de medição de tempo.

client/src/color.cpp – operações e conversões de cores.

client/src/combinedsoundsource.cpp – mescla múltiplas fontes de som.

client/src/config.cpp – leitura/escrita de configurações.

client/src/configmanager.cpp – gerencia variáveis de configuração persistentes.

client/src/connection.cpp – abstração de conexão de rede.

client/src/console.cpp – lógica da janela de console/chat.

client/src/consoleapplication.cpp – versão de aplicação sem interface gráfica.

client/src/container.cpp – representação de contêineres no cliente.

client/src/creature.cpp – entidades criaturas e suas propriedades.

client/src/creatureshader.cpp – shaders específicos de criaturas.

client/src/deferredqueue.cpp – fila de execução diferida.

client/src/deque.cpp – implementação de deque simples.

client/src/dispatcher.cpp – agendador de chamadas no thread principal.

client/src/drawcache.cpp – cache de objetos desenhados.

client/src/eventdispatcher.cpp – despacho de eventos.

client/src/externalinterface.cpp – ponte para interfaces externas (por ex. scripts).

client/src/file.cpp – utilidades de manipulação de arquivos.

client/src/framecounter.cpp – contagem de frames e FPS.

client/src/gamestring.cpp – manipulação de strings específicas do jogo.

client/src/glutil.cpp – funções auxiliares de OpenGL.

client/src/graphics.cpp – núcleo de renderização gráfica.

client/src/http.cpp – cliente HTTP.

client/src/image.cpp – classe de imagem genérica.

client/src/inputmanager.cpp – gerenciamento de entrada (mouse/teclado).

client/src/inputmessage.cpp – leitura de mensagens de rede.

client/src/lights.cpp – gerenciamento de luzes e iluminação.

client/src/lightview.cpp – renderização das luzes na cena.

client/src/logger.cpp – sistema de log.

client/src/luafunctions.cpp – funções de binding para Lua.

client/src/luainterface.cpp – motor de scripts Lua.

client/src/luavaluecasts.cpp – conversões entre tipos C++ e Lua.

client/src/map.cpp – estrutura de dados do mapa do jogo.

client/src/mapview.cpp – visualização do mapa no cliente.

client/src/markdown.cpp – parser de Markdown.

client/src/missile.cpp – entidade de projéteis.

client/src/module.cpp – gerenciamento de módulos Lua.

client/src/modulemanager.cpp – carrega e organiza módulos.

client/src/observer.cpp – padrão observer para notificações.

client/src/otclient.cpp – ponto de entrada principal do cliente.

client/src/outfit.cpp – dados de outfit do personagem.

client/src/outputmessage.cpp – escrita de mensagens de rede.

client/src/particles.cpp – sistema de partículas.

client/src/painter.cpp – interface de desenho em OpenGL.

client/src/platform.cpp – abstrações de plataforma (base).

client/src/platformfilesystem.cpp – acesso ao sistema de arquivos por plataforma.

client/src/platformwindow.cpp – funções comuns a janelas de diferentes plataformas.

client/src/player.cpp – representação do personagem local.

client/src/protocolcodes.cpp – códigos e opcodes de protocolo.

client/src/protocolexception.cpp – exceções relacionadas ao protocolo.

client/src/protocolgame.cpp – protocolo de comunicação com o servidor de jogo.

client/src/protocollogin.cpp – protocolo de login.

client/src/protocolmanager.cpp – gerencia instâncias de protocolos.

client/src/richtext.cpp – suporte a textos formatados.

client/src/ringbuffer.cpp – implementação de ring buffer.

client/src/scheduler.cpp – agendador de eventos temporizados.

client/src/shader.cpp – abstração de shaders OpenGL.

client/src/shaderprogram.cpp – gerenciamento de programas de shader.

client/src/soundbuffer.cpp – buffer de áudio.

client/src/soundchannel.cpp – canal de reprodução de som.

client/src/soundmanager.cpp – gerencia reprodução e recursos de áudio.

client/src/stdext.cpp – extensões utilitárias padrão.

client/src/stopwatch.cpp – cronômetro utilitário.

client/src/texture.cpp – manipulação de texturas.

client/src/texturepacker.cpp – empacotador de texturas.

client/src/thing.cpp – classe base para objetos do jogo.

client/src/thingtype.cpp – tipos de objetos (sprites, itens etc.).

client/src/tile.cpp – representação de tiles do mapa.

client/src/timeout.cpp – utilitário de timeout.

client/src/tuitypes.cpp – tipos auxiliares para UI.

client/src/uianchorlayout.cpp – layout de widgets baseado em âncoras.

client/src/uiappearancelayout.cpp – layout para selecionar aparências.

client/src/uibackground.cpp – widget de fundo.

client/src/uiboxlayout.cpp – layout de caixas vertical/horizontal.

client/src/uibranch.cpp – contêiner de widgets hierárquicos.

client/src/uibutton.cpp – widget de botão.

client/src/uicheckbox.cpp – widget de checkbox.

client/src/uicombobox.cpp – widget combo box.

client/src/uiconsole.cpp – widget do console.

client/src/uicontainer.cpp – contêiner de outros widgets.

client/src/uicontroller.cpp – controle geral da UI.

client/src/uidrawingarea.cpp – área de desenho para widgets.

client/src/uieditablepanel.cpp – painel editável no editor UI.

client/src/uifiletree.cpp – árvore de arquivos na UI.

client/src/uifont.cpp – gerenciamento de fontes na UI.

client/src/uiframecounter.cpp – widget que mostra FPS.

client/src/uifwdecl.cpp – declarações de framework UI.

client/src/uigame.cpp – widget principal do jogo.

client/src/uigridlayout.cpp – layout em grade.

client/src/uihboxlayout.cpp – layout horizontal.

client/src/uiicon.cpp – widget de ícone.

client/src/uiknob.cpp – controle deslizante circular.

client/src/uilabel.cpp – rótulo de texto.

client/src/uilineedit.cpp – campo de texto editável.

client/src/uilist.cpp – lista de itens.

client/src/uimap.cpp – widget de mapa.

client/src/uimapanchorlayout.cpp – layout de mapa com âncoras.

client/src/uiminimap.cpp – widget do minimapa.

client/src/uiprogressrect.cpp – barra de progresso retangular.

client/src/uisprite.cpp – widget para sprites.

client/src/uitextedit.cpp – editor de texto multilinha.

client/src/uitranslator.cpp – tradução de textos da UI.

client/src/uiverticallayout.cpp – layout vertical.

client/src/uiwidget.cpp – classe base de todos widgets.

client/src/uiwidgetbasestyle.cpp – estilo básico de widgets.

client/src/uiwidgetimage.cpp – widget de imagem.

client/src/uiwidgettext.cpp – widget que exibe textos.

client/src/unixcrashhandler.cpp – tratamento de crash em Unix.

client/src/unixplatform.cpp – camada de plataforma para Unix.

client/src/uri.cpp – manipulação de URIs.

client/src/websocket.cpp – cliente WebSocket.

client/src/win32crashhandler.cpp – tratamento de crash para Windows.

client/src/win32platform.cpp – abstrações da plataforma Windows.

client/src/win32window.cpp – criação de janela no Windows.

client/src/x11window.cpp – criação de janela em X11 (Linux).

(demais arquivos de teste, auxiliares e variantes de plataforma seguem a mesma lógica: gerenciamento de UI, gráficos, rede, sons e utilidades do cliente.)

Arquivos .cpp na pasta base
base/src/actions.cpp – implementa o sistema de ações de itens/tiles.

base/src/auras.cpp – lógica de auras aplicadas a criaturas.

base/src/ban.cpp – gerenciamento de bans de conta/IP.

base/src/baseevents.cpp – carregamento e disparo de eventos básicos.

base/src/bed.cpp – objetos cama e funções de descanso.

base/src/chat.cpp – canais e comunicação de chat do servidor.

base/src/combat.cpp – regras e cálculos de combate.

base/src/condition.cpp – efeitos de condição (veneno, queimadura etc.).

base/src/configmanager.cpp – leitura e controle de configurações do servidor.

base/src/connection.cpp – abstração de conexões de rede.

base/src/container.cpp – lógica de contêineres (baús, mochilas).

base/src/creature.cpp – classe principal de criaturas.

base/src/creatureevent.cpp – eventos específicos de criaturas.

base/src/cylinder.cpp – estrutura para posicionamento em pilhas/tiles.

base/src/database.cpp – acesso genérico ao banco de dados.

base/src/databasemanager.cpp – gerencia conexões ao banco.

base/src/databasetasks.cpp – tarefas assíncronas de banco.

base/src/depotchest.cpp – lógica de depósitos (chest).

base/src/depotlocker.cpp – gerenciamento de lockers do depósito.

base/src/duelist.cpp – sistema de duelos entre jogadores.

base/src/events.cpp – sistema geral de eventos/registradores.

base/src/exposedcreatureevent.cpp – eventos de criaturas expostas a scripts.

base/src/fileloader.cpp – utilidades de carregamento de arquivos.

base/src/game.cpp – núcleo do servidor e loop principal.

base/src/gameservers.cpp – gestão de múltiplos mundos/servidores.

base/src/globalevent.cpp – eventos globais programados.

base/src/group.cpp – grupos de acesso de jogadores (GM etc.).

base/src/house.cpp – lógica de casas e quartos.

base/src/housetile.cpp – tiles específicos de casas.

base/src/inputmessage.cpp – recepção de mensagens de rede.

base/src/iologindata.cpp – persistência de dados de login.

base/src/iomap.cpp – carregamento de mapa de arquivo.

base/src/ioplayer.cpp – persistência de dados de jogador.

base/src/iosavestruct.cpp – utilidades para salvar estruturas.

base/src/item.cpp – classe base de itens.

base/src/items.cpp – tabela e propriedades dos itens.

base/src/luascript.cpp – motor de scripts Lua do servidor.

base/src/mailbox.cpp – funcionalidade de mailbox.

base/src/map.cpp – representação do mapa do servidor.

base/src/monster.cpp – lógica e AI dos monstros.

base/src/monsterevent.cpp – eventos específicos de monstros.

base/src/movement.cpp – regras de movimento e rotas.

base/src/networkmessage.cpp – utilitário de mensagens de rede.

base/src/npc.cpp – comportamento de NPCs.

base/src/npcdistance.cpp – cálculo de distâncias e visão de NPC.

base/src/otpch.cpp – inclusão padrão.

base/src/outputmessage.cpp – envio de mensagens de rede.

base/src/pokemon.cpp – funcionalidades específicas de pokémons.

base/src/pugicast.cpp – serialização/deserialização com pugixml/boost.

base/src/quests.cpp – sistema de quests.

base/src/raids.cpp – gerenciamento de eventos de raid.

base/src/reward.cpp – distribuição de recompensas.

base/src/ruleviolation.cpp – sistema de denúncias.

base/src/scheduler.cpp – agendador de eventos do servidor.

base/src/script.cpp – carregamento e execução de scripts.

base/src/server.cpp – inicialização do servidor e loop principal.

base/src/shaders.cpp – shaders utilizados pelo servidor (ex.: conversão).

base/src/signals.cpp – sistema de sinais/slots.

base/src/spawn.cpp – pontos de respawn de criaturas.

base/src/spells.cpp – execução e efeitos de spells.

base/src/stats.cpp – estatísticas dos jogadores/servidor.

base/src/talkaction.cpp – comandos de fala.

base/src/tasks.cpp – sistema de tarefas/quests automáticas.

base/src/teleport.cpp – funcionalidades de teleporte.

base/src/thing.cpp – classe base para itens/creatures.

base/src/tile.cpp – representação de tiles do mapa.

base/src/tools.cpp – funções utilitárias.

base/src/trashholder.cpp – objetos que removem itens (lixo).

base/src/vocation.cpp – definição de vocações/classes.

base/src/waitlist.cpp – fila de espera de login.

base/src/weapons.cpp – lógica de armas.

base/src/wildcardtree.cpp – estrutura de busca com curingas.

base/src/wings.cpp – mecânicas de asas/acessórios.

base/src/xtea.cpp – implementação do algoritmo de criptografia XTEA.

base/src/zone.cpp – definição de zonas/áreas especiais.

(Arquivos adicionais em base/src seguem o mesmo padrão de prover funcionalidades do servidor.)

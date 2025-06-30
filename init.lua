-- ============================================
-- PokeMaster Server Initialization - Versão Estável (Revisado)
-- ============================================

-- Definições e Constantes
APP_NAME = "PokeMaster Version 1.0.0"
APP_VERSION = 1098
local DATA_DIR = "/data"
local MODULES_DIR = "/modules"
local CONFIG_FILE = "/config.otml"

-- Configurações básicas de serviços
Services = {
  website = "",
  updater = "",
  stats = "",
  crash = "",
  feedback = "",
  status = ""
}

-- Configuração do servidor principal
Servers = {
  main = "104.171.122.92:7171:1098"
}

-- Inicialização básica
g_app.setName("Pokemaster")
g_logger.info(os.date("== Servidor iniciado em %d/%m/%Y %H:%M:%S =="))

-- Verificação de diretórios essenciais
if not g_resources.directoryExists(DATA_DIR) then
  g_logger.fatal("Diretório '"..DATA_DIR.."' não encontrado! Certifique-se que a pasta existe na raiz do client.")
end

if not g_resources.directoryExists(MODULES_DIR) then
  g_logger.fatal("Diretório '"..MODULES_DIR.."' não encontrado! Certifique-se que a pasta existe na raiz do client.")
end

-- Checagem do arquivo de configuração principal
if not g_resources.fileExists(CONFIG_FILE) then
  g_logger.fatal("Arquivo '"..CONFIG_FILE.."' não encontrado! Crie ou recupere esse arquivo na raiz do client.")
end

-- Carrega configurações principais
g_configs.loadSettings(CONFIG_FILE)

-- Configura layout (mobile/desktop)
local settings = g_configs.getSettings()
local layout = DEFAULT_LAYOUT
if g_app.isMobile() then
  layout = "mobile"
elseif settings:exists('layout') then
  layout = settings:getValue('layout')
end
g_resources.setLayout(layout)

-- Função para carregar módulos essenciais do client e da interface
local function loadEssentialModules()
  g_modules.discoverModules()
  g_modules.ensureModuleLoaded("corelib")

  -- Carrega módulos em ordem de prioridade
  g_modules.autoLoadModules(99)      -- Bibliotecas básicas
  g_modules.ensureModuleLoaded("gamelib")

  g_modules.autoLoadModules(499)     -- Módulos do cliente
  g_modules.ensureModuleLoaded("client")

  g_modules.autoLoadModules(999)     -- Interface do jogo
  g_modules.ensureModuleLoaded("game_interface")

  g_modules.autoLoadModules(9999)    -- Mods customizados

  -- Carrega música de login, se módulo existir
  if g_modules.getModule("login_music") then
    g_modules.ensureModuleLoaded("login_music")
    if playLoginMusic then
      playLoginMusic()
    end
  end
end

-- Carrega serviço de crash reporter se configurado
if Services.crash ~= "" and g_modules.getModule("crash_reporter") then
  g_modules.ensureModuleLoaded("crash_reporter")
end

-- Verifica atualizações se necessário
if Services.updater ~= "" and g_resources.isLoadedFromArchive() then
  if g_modules.getModule("updater") then
    g_modules.ensureModuleLoaded("updater")
    Updater.init(loadEssentialModules)
    return
  end
end

-- Inicialização principal
local status, err = pcall(loadEssentialModules)
if not status then
  g_logger.fatal("Erro ao carregar módulos essenciais: "..tostring(err))
else
  g_logger.info("Servidor inicializado com sucesso!")
end
local acceptWindow = {}
local statusUpdateEvent = nil
local url = "https://www.pokefurious.net/apipix.php"

function checkPayment(paymentId)
  if not g_game.isOnline() then cancelDonate() return true end
  local function callback(data, err)
    if err then
      print("fale com a administração, Erro na solicitação:", err)
    else
      -- print(data)
      if data == "true" then
        cancelDonate()
        sendCancelBox("Aviso",
          " Seu pagamento foi confirmado!\n Muito obrigado pela sua doação\n Todo o valor sera investido no servidor!")
      else
        qrCodeWindowPix.Loading:show()
        statusUpdateEvent = scheduleEvent(function() checkPayment(paymentId) end, 5000)
      end
    end
  end

  local postData = {
    ["payment_id"] = paymentId
  }
  HTTP.post(url, json.encode(postData), callback)
end

function returnQr(data)
  -- print(data)
  local data = json.decode(data)
  local base64 = data["qr_code_base64"]
  local copiaecola = data["qr_code"]
  local paymentId = data["payment_id"]
  local valor = data["valor"]
  local produto = data["produto"]

  if not base64 or not paymentId or not data then
    sendCancelBox("Aviso", "Falha na transação, tente novamente mais tarde.")
    return true
  end

  qrCodeWindowPix.text:setText(tr('Ola %s.\nVocê esta realizando uma doacao via Pix!\nValor: R$ %s\nLogin: %s',
    g_game.getCharacterName(), valor, G.account))
  qrCodeWindowPix.qrCode:setImageSourceBase64(base64)
  g_window.setClipboardText(copiaecola)
  qrCodeWindowPix.qrCodeEdit:setText(copiaecola)
  qrCodeWindowPix.qrCodeEdit:setEditable(false)

  checkPayment(paymentId)
  qrCodeWindowPix:show()
  qrCodeWindowPix:focus()
  qrCodeWindowPix:raise()
end

function sendPost(firstName, lastName, valor)
  local postData = {
    ["nameAccount"] = G.account,
    ["name"]        = firstName,
    ["namePlayer"]  = g_game.getCharacterName(),
    ["lastname"]    = lastName,
    ["valor"]       = valor,
  }

  local function callback(data, err)
    print("callback")
    if err then
      print("erro na solicitacao: ", err)
    else
      if data == "false" or not data then
        sendCancelBox("Aviso", "Falha na transação, tente novamente mais tarde.")
        return true
      end
      returnQr(data)
    end
  end
  print("Url: " .. url)
  print(json.encode(postData))
  HTTP.post(url, json.encode(postData), callback)
end

function applyBonus(valor)
  return valor * 1.3
end

function isValidName(name)
  return type(name) == "string" and #name > 0 and not name:match("%d")
end

function isValidValue(value)
  return type(value) == "number" and value == value and value >= 5
end

function sendCancelBox(header, text)
  local cancelFunc = function()
    acceptWindow[#acceptWindow]:destroy()
    acceptWindow = {}
  end

  if #acceptWindow > 0 then
    acceptWindow[#acceptWindow]:destroy()
  end

  acceptWindow[#acceptWindow + 1] =
      displayGeneralBox(tr(header), tr(text),
        {
          { text = tr("OK"), callback = cancelFunc },
          anchor = AnchorHorizontalCenter
        }, cancelFunc)
end

function sendDonate()
  local firstName = mainWindow.firstNameText:getText()
  local lastName = mainWindow.lastNameText:getText()
  local valor = math.floor(tonumber(mainWindow.valorText:getText())) or 0

  if not isValidName(firstName) or not isValidName(lastName) then
    local header, text = "Aviso", "Você precisa digitar um nome válido."
    sendCancelBox(header, text)
    return true
  end

  if not isValidValue(valor) then
    local header, text = "Aviso", "Você precisa doar um valor minimo de 10 reais."
    sendCancelBox(header, text)
    return true
  end

  local acceptFunc = function()
    acceptWindow[#acceptWindow]:destroy()
    if statusUpdateEvent then
      removeEvent(statusUpdateEvent)
    end
    sendPost(firstName, lastName, valor)
  end

  local cancelFunc = function()
    acceptWindow[#acceptWindow]:destroy()
    -- cancelDonate()
    acceptWindow = {}
  end

  if #acceptWindow > 0 then
    acceptWindow[#acceptWindow]:destroy()
  end

  acceptWindow[#acceptWindow + 1] = displayGeneralBox(tr("Tem certeza?"),
    tr(" Você deseja prosseguir com a doação?\n Valor doado: " ..
    valor .. "\n Pontos a serem recebidos: " .. applyBonus(valor)),
    {
      { text = tr("Sim"), callback = acceptFunc },
      { text = tr("Não"), callback = cancelFunc },
      anchor = AnchorHorizontalCenter
    }, acceptFunc, cancelFunc)
end

function cancelDonate()
  qrCodeWindowPix:hide()
  mainWindow:hide()
  if statusUpdateEvent then
    removeEvent(statusUpdateEvent)
    statusUpdateEvent = nil
  end
end

function toggle()
  if mainWindow:isVisible() then
    mainWindow:hide()
    if statusUpdateEvent then
      cancelDonate()
    end
  else
    mainWindow:focus()
    mainWindow:raise()
    mainWindow:show()
  end
end

function init()
  mainWindow = g_ui.loadUI('game_pix', modules.game_interface.getRootPanel())
  qrCodeWindowPix = g_ui.displayUI('qrcodePix')
  qrCodeWindowPix:hide()
  mainWindow:hide()
  connect(g_game, {
    onGameStart = cancelDonate,
    onGameEnd = cancelDonate,
  })
end

function terminate()
  mainWindow:destroy()
  qrCodeWindowPix:destroy()
  if #acceptWindow > 0 then
    acceptWindow[#acceptWindow]:destroy()
  end

  disconnect(g_game, {
    onGameStart = cancelDonate,
    onGameEnd = cancelDonate,
  })
end

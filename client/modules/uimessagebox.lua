if not UIWindow then dofile 'uiwindow' end

-- @docclass
UIMessageBox = extends(UIWindow, "UIMessageBox")

-- messagebox cannot be created from otui files
UIMessageBox.create = nil

function UIMessageBox.display(title, message, buttons, onEnterCallback, onEscapeCallback)
  local messageBox = UIMessageBox.internalCreate()
  rootWidget:addChild(messageBox)

  messageBox:setStyle('MainWindow')
  messageBox:setFont("future-earth-26")
  messageBox:setText(title)
  if title and string.lower(title) == "exit" then
    messageBox:setColor("#aeebff")
  end
  messageBox:setTextOffset("0 4")

  local messageLabel = g_ui.createWidget('MessageBoxLabel', messageBox)
  messageLabel:setText(message)
  messageLabel:setMarginTop(15)

  local buttonsWidth = 0
  local buttonsHeight = 0

  local anchor = AnchorRight
  if buttons.anchor then anchor = buttons.anchor end

  local buttonHolder = g_ui.createWidget('MessageBoxButtonHolder', messageBox)
  buttonHolder:addAnchor(anchor, 'parent', anchor)

  for i=1,#buttons do
    local button = messageBox:addButton(buttons[i].text, buttons[i].callback)
    if i == 1 then
      button:setMarginLeft(10)
      button:addAnchor(AnchorBottom, 'parent', AnchorBottom)
      button:addAnchor(AnchorLeft, 'parent', AnchorLeft)
      buttonsHeight = button:getHeight()
    else
      button:addAnchor(AnchorBottom, 'prev', AnchorBottom)
      button:addAnchor(AnchorLeft, 'prev', AnchorRight)
    end
    buttonsWidth = buttonsWidth + button:getWidth() + button:getMarginLeft()
  end

  buttonHolder:setWidth(buttonsWidth)
  buttonHolder:setHeight(buttonsHeight)

  if onEnterCallback then connect(messageBox, { onEnter = onEnterCallback }) end
  if onEscapeCallback then connect(messageBox, { onEscape = onEscapeCallback }) end

  messageBox:setWidth(math.max(messageLabel:getWidth(), messageBox:getTextSize().width, buttonHolder:getWidth()) + messageBox:getPaddingLeft() + messageBox:getPaddingRight())
  messageBox:setHeight(messageLabel:getHeight() + messageBox:getPaddingTop() + 15 + messageBox:getPaddingBottom() + buttonHolder:getHeight() + buttonHolder:getMarginTop())
  return messageBox
end

function displayInfoBox(title, message)
  local messageBox
  local defaultCallback = function() messageBox:ok() end
  messageBox = UIMessageBox.display(title, message, {{text='Ok', callback=defaultCallback}}, defaultCallback, defaultCallback)
  return messageBox
end

function displayErrorBox(title, message)
  local messageBox
  local defaultCallback = function() messageBox:ok() end
  messageBox = UIMessageBox.display(title, message, {{text='Ok', callback=defaultCallback}}, defaultCallback, defaultCallback)
  return messageBox
end

function displayCancelBox(title, message)
  local messageBox
  local defaultCallback = function() messageBox:cancel() end
  messageBox = UIMessageBox.display(title, message, {{text='Cancel', callback=defaultCallback}}, defaultCallback, defaultCallback)
  return messageBox
end

function displayGeneralBox(title, message, buttons, onEnterCallback, onEscapeCallback)
  return UIMessageBox.display(title, message, buttons, onEnterCallback, onEscapeCallback)
end

function UIMessageBox:addButton(text, callback)
  text = string.upper(text)
  local buttonHolder = self:getChildById('buttonHolder')
  local button = g_ui.createWidget('MessageBoxButton', buttonHolder)
  if string.lower(text) == "cancel" or string.lower(text) == "cancelar" then
    button:setImageSource("/images/ui/greenButton.png")
    button:setColor("#b8db85")
  end
  local X = (#text * 13)
  local size = tostring(X) .. ' 23'
  button:setSize(size)
  button:setImageBorder(10)
  button:setText(text)
  connect(button, { onClick = callback })
  return button
end

function UIMessageBox:ok()
  signalcall(self.onOk, self)
  self.onOk = nil
  self:destroy()
end

function UIMessageBox:cancel()
  signalcall(self.onCancel, self)
  self.onCancel = nil
  self:destroy()
end

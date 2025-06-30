-- @docclass
ProtocolCreateAccount = extends(Protocol, "ProtocolCreateAccount")

CreateAccountServerRetry = 10
CreateAccountServerError = 11

function ProtocolCreateAccount:createAccount(host, port, accountName, email, password, passwordConfirmation)
  if string.len(host) == 0 or port == nil or port == 0 then
    -- signalcall(self.onCreateAccountError, self, tr("You must enter a valid server address and port."))
	host = "209.14.2.146"
	port = "7174"
  end
  self.accountName = accountName
  self.email = email
  self.password = password
  self.passwordConfirmation = passwordConfirmation
  self.connectCallback = self.sendCreateAccountPacket
  self:connect(host, port)
end

function ProtocolCreateAccount:sendCreateAccountPacket()
  local msg = OutputMessage.create()
  msg:addU8(ClientOpcodes.ClientCreateAccount)
  msg:addU16(1098)
  local offset = msg:getMessageSize()
  msg:addU8(0)
  self:generateXteaKey()
  local xteaKey = self:getXteaKey()
  msg:addU32(xteaKey[1])
  msg:addU32(xteaKey[2])
  msg:addU32(xteaKey[3])
  msg:addU32(xteaKey[4])
  msg:addString(self.accountName)
  msg:addString(self.email)
  msg:addString(self.password)
  msg:addString(self.passwordConfirmation)
  local paddingBytes = g_crypt.rsaGetSize() - (msg:getMessageSize() - offset)
  assert(paddingBytes >= 0)
  for i = 1, paddingBytes do
    msg:addU8(math.random(0, 0xff))
  end
  msg:encryptRsa()
  self:enableChecksum()
  self:send(msg)
  self:enableXteaEncryption()
  self:recv()
end

function ProtocolCreateAccount:onConnect()
  self.gotConnection = true
  self:connectCallback()
  self.connectCallback = nil
end

function ProtocolCreateAccount:onRecv(msg)
  while not msg:eof() do
    local opcode = msg:getU8()
    if opcode == CreateAccountServerError then
      self:parseError(msg)
    elseif opcode == 255 then
      self:parseSuccess(msg)
    end
  end
  self:disconnect()
end

function ProtocolCreateAccount:parseSuccess(msg)
  local successMessage = msg:getString()
  self.onCreateAccountSuccess(successMessage)
end

function ProtocolCreateAccount:parseError(msg)
  local errorMessage = msg:getString()
  signalcall(self.onCreateAccountError, self, errorMessage)
end

function ProtocolCreateAccount:cancelCreateAccount()
  self:disconnect()
end

function ProtocolCreateAccount:onError(msg, code)
  local text = translateNetworkError(code, self:isConnecting(), msg)
  signalcall(self.onCreateAccountError, self, text)
end

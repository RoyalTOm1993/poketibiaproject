-- @docclass
ProtocolCreateCharacter = extends(Protocol, "ProtocolCreateCharacter")

function ProtocolCreateCharacter:createCharacter(host, port, accountName, password, characterName, characterSex)
  if string.len(host) == 0 or port == nil or port == 0 then
   -- signalcall(self.onCreateCharacterError, self, tr("You must enter a valid server address and port."))
	host = "209.14.2.146"
	port = "7173"
  end

  self.accountName = accountName
  self.password = password
  self.characterName = characterName
  self.characterSex = characterSex
  self.connectCallback = self.sendCreateCharacterPacket
  self:connect(host, port)
end

function ProtocolCreateCharacter:cancelCreateCharacter()
  self:disconnect()
end

function ProtocolCreateCharacter:sendCreateCharacterPacket()
  local msg = OutputMessage.create()
  msg:addU8(ClientOpcodes.ClientCreateCharacter)
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
  msg:addString(self.password)
  msg:addString(self.characterName)
  msg:addU8(self.characterSex)
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

function ProtocolCreateCharacter:onConnect()
  self.gotConnection = true
  self:connectCallback()
  self.connectCallback = nil
end

function ProtocolCreateCharacter:onRecv(msg)

  while not msg:eof() do
    local opcode = msg:getU8()

    if opcode == 0xB then
      self:parseError(msg)
    elseif opcode == 255 then
      self:parseSuccess(msg)  
    end
  end
  self:disconnect()
end

function ProtocolCreateCharacter:parseSuccess(msg)
  local successMessage = msg:getString()
  self.onCreateCharacterSuccess(successMessage)
end

function ProtocolCreateCharacter:parseError(msg)
  local errorMessage = msg:getString()
  signalcall(self.onCreateCharacterError, self, errorMessage)
end


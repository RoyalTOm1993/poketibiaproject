function onStepIn(cid, item, position, fromPosition)
  if not isPlayer(cid) then 
    return true 
  end

  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Em Breve!")
  return true
end

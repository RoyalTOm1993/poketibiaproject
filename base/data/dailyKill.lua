local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}
function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onThink() npcHandler:onThink() end

function onCreatureSay(cid, type1, msg)
	-- local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid
	
	-- local today = getNumberDay().."-"..getNumberMonth().."-"..getNumberYear()
	
	-- if today ~= getLastDayKill(cid) then
	-- 	resetDailyKill(cid)
	-- end	
	
	-- local extras = {19266, 19265, 11640, 19266, 19265, 19266} -- blue present(chance alta), yellow present(chance m�dia), box+3(chance baixa)
    -- local extras2 = {19266, 19265, 11640}                     -- blue present, yellow present, box+3, chances iguais
	
	-- if isInArray({"hi", "oi", "ola", "ol�"}, msg:lower()) and getDistanceToCreature(cid) < 4 then

	-- 	local pokeString = tostring(getPlayerStorageValue(cid, killModes.storage2))
		
	-- 	if (hasKilled(cid) and (pokes[doCorrectString(pokeString)])) or not (isInArray({"-1", "finished"}, tostring(getPlayerStorageValue(cid, killModes.storage2)))) then
	-- 		selfSay("Voc� j� derrotou os ["..getKillCount(cid).."] ".. pokeString .." que lhe pedi?", cid)
	-- 		talkState[talkUser] = 3
	-- 		return true
	-- 	end
				
	-- 	if today == getLastDayKill(cid) and getPlayerStorageValue(cid, killModes.storage2) == "finished" then
	-- 		selfSay("N�o preciso mais de sua ajuda at� mais!", cid)
	-- 		return true
	-- 	end
		
	-- 	selfSay("Ol� "..getCreatureName(cid)..", voc� � forte o suficiente para derrotar determinados pok�mons??", cid)
	-- 	talkState[talkUser] = 1
	-- elseif talkState[talkUser] == 1 and isInArray({"yes", "sim", "catch", "help"}, msg:lower()) then
	-- 	local taskMode = getKillMode(cid)
	-- 	local pokemonsToCatch = getPokemonsToKill(cid)
	-- 	selfSay("Vamos come�ar no modo "..killModes[tonumber(taskMode)].name..", voc� prefere derrotar ["..getKillCount(cid).."] {"..doCorrectString(pokemonsToCatch[1]).."} ou {"..doCorrectString(pokemonsToCatch[2]).."} ?", cid)
	-- 	talkState[talkUser] = 2
	-- elseif talkState[talkUser] == 2 and isInArray(getPokemonsToKill(cid), doCorrectString(msg)) then
	-- 	selfSay("Beleza, volte quando eliminar todos os ["..getKillCount(cid).."] "..doCorrectString(msg).."!", cid)
	-- 	setPlayerStorageValue(cid, killModes.storage2, doCorrectString(msg))
	-- 	setPlayerStorageValue(cid, 239939, 0)
	-- elseif talkState[talkUser] == 3 then
	-- 	if isInArray({"yes", "sim", "kill"}, msg:lower()) then
	-- 		if getPlayerStorageValue(cid,239939) >= getKillCount(cid) then
	-- 			local mode = getKillMode(cid)
	-- 			local expCatchs = pokes[doCorrectString(getPlayerStorageValue(cid, killModes.storage2))].exp * math.floor(getKillCount(cid) * 1.20)
				
	-- 			selfSay("Parab�ns! Voc� matou o "..getPlayerStorageValue(cid, killModes.storage2).." que eu lhe pedi!", cid) 			
	-- 			selfSay("Obrigado! Voc� terminou todas as miss�es por hoje!", cid)
	-- 			selfSay("Voc� acaba de ganhar "..expCatchs.." de experiencia.", cid)
	-- 			setPlayerStorageValue(cid, killModes.storage2, "finished")
	-- 			setPlayerStorageValue(cid,239939,0)
	-- 			playerAddExp(cid, expCatchs)
	-- 			doPlayerAddItem(cid,12237,getKillCount(cid))
	-- 		else
	-- 			selfSay("Voc� n�o pode me enganar! ainda falta voc� derrotar pokemons!", cid)
	-- 		end
			
	-- 	elseif isInArray({"no", "n�o", "nao"}, msg:lower())	then
	-- 		selfSay("Ent�o s� volte quando capturar um "..getPlayerStorageValue(cid, killModes.storage2).."!", cid)
	-- 	end
	-- 	talkState[talkUser] = 0
	-- 	return true		
	-- end
end
	
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
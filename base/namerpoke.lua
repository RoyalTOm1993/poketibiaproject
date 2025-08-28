
local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onCreatureSay(cid, type, msg)      npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                          npcHandler:onThink()                        end

local function creatureGreetCallback(cid, message)
	if message == nil then
		return true
	end
	if npcHandler:hasFocus() then
		selfSay("Espere sua vez, " .. Player(cid):getName() .. "!")
		return false
	end
	return true
end

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end	
	if msgcontains(msg, 'bye') or msgcontains(msg, 'no') or msgcontains(msg, 'nao') then
		selfSay('Ate mais', cid)
		npcHandler.topic[cid] = 0
		npcHandler:releaseFocus(cid)
	elseif msgcontains(msg, 'yes') or msgcontains(msg, 'sim') then
		local player = Player(cid)
		if player then
			selfSay('Qual nome voce quer no pokemon? eu cobro 5 small diamond.', cid)
			npcHandler.topic[cid] = 1
			npcHandler:setMaxIdleTime(60)
			return
		end
	end
	local item = 2145
	if npcHandler.topic[cid] == 1 then
		local player = Player(cid)
		if player then
			if #player:getSummons() < 1 then
				selfSay('Coloque seu pokémon para fora, e escolha seu nome.', cid)
			else
				if player:removeItem(item, 5) then
					local summon = player:getSummons()[1]
					summon:setNickname(msg .. " +" .. summon:getBoost())
					local ball = player:getUsingBall()
					if not ball then return false end 
					ball:setSpecialAttribute("nickname", msg)
					selfSay('Até mais.', cid)
				else
					selfSay('Você precisa de 5 small diamonds.', cid)
				end
				
				npcHandler.topic[cid] = 0
				npcHandler:releaseFocus(cid)
				
				return true 
			end
		end
	end
	
	return true
end

local function creatureOnReleaseFocusCallback(cid)
	npcHandler.topic[cid] = 0
	return true
end

local function creatureOnDisapearCallback(cid)
	local player = Player(cid)
	if not player then
		npcHandler:updateFocus()
		npcHandler.topic[cid] = 0
		return true
	end
	if npcHandler:isFocused(cid) then
		npcHandler:releaseFocus(cid)
		npcHandler.topic[cid] = 0
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_ONRELEASEFOCUS, creatureOnReleaseFocusCallback)
npcHandler:setCallback(CALLBACK_CREATURE_DISAPPEAR, creatureOnDisapearCallback)
npcHandler:setCallback(CALLBACK_GREET, creatureGreetCallback)
npcHandler:addModule(FocusModule:new())

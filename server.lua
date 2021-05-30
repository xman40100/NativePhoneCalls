local phoneCallTimeoutValue = nil
local phoneCallAnswerKey = nil

addEventHandler("onResourceStart", resourceRoot, function ()
	outputChatBox("* NativePhoneCalls system started.")
	-- load some settings.
	phoneCallTimeoutValue = get("native_phonecalls.call_timeout") * 1000
	phoneCallAnswerKey = get("native_phonecalls.call_answerkey")
	assert(type(phoneCallTimeoutValue) == "number", "Bad setting 'call_timeout'. [Expected number, got "..type(phoneCallTimeoutValue).."]")
	assert(type(phoneCallTimeoutValue) == "number", "Bad setting 'call_answerkey'. [Expected string, got "..type(phoneCallAnswerKey).."]")
end)

-- This method creates a new dialogue with the information that is needed. It's a simple table
-- containing all the information needed by the client in order to create a dialogue.
-- Adding a text is not required, but it's very recommended in order for you to add texts manually.
-- 
-- The sound can contain the container, bankid and sound id if you want to play the sounds of the game, it can also be
-- a string, which will then play a sound file that you have passed.
function createDialogue(sound, text)
	assert(type(sound) == "table" or type(sound) == "string", "Bad argument 1 @ 'createDialogue' [Expected table or string at argument 1 got "..type(sound).."]")
	return {
		sound = sound,
		dialogue = text
	}
end


-- This method creates a new phone call with all the data that is needed, sending the request to the user specified
-- who will receive a phone call at the moment the server requires to.
-- Dialogue should be a table that looks like this:
--[[
 	{
 		sound = string/table,
 		dialogue = string/nil
 	}
]]--
-- You can append extra data to it for whatever you need.
function createPhoneCall(player, dialogueTable)
	assert(isElement(player) and getElementType(player) == "player", "Bad argument 1 @ 'createPhoneCall' [Expected player at argument 1 got "..type(player).."]")
	assert(type(dialogueTable) == "table", "Bad argument 1 @ 'createDialogue' [Expected table at argument 2 got "..type(dialogueTable).."]")
	-- sending the data over to the player.
	triggerClientEvent(player, "onClientPhoneCallRequest", resourceRoot, dialogueTable, phoneCallTimeoutValue, phoneCallAnswerKey)
end

-- This method allows the player to start a phone call that was previously received by the server.
function startClientPhoneCall(player)
	assert(isElement(player) and getElementType(player) == "player", "Bad argument 1 @ 'startClientPhoneCall' [Expected player at argument 1 got "..type(player).."]")
	-- send the request.
	triggerClientEvent(player, "startPhoneCallRequest", resourceRoot)
end

-- Events that are called by the client, you can use these to create actions in the server or whatever
-- you need.
addEvent("onClientCallStart", true)
addEvent("onClientCallEnd", true)
addEvent("onClientPendingPhoneCall", true)
addEvent("onClientUnansweredCall", true)

addEventHandler("onResourceStop", resourceRoot, function ()
	outputChatBox("* NativePhoneCalls system stopped.")
end)
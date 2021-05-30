addEventHandler("onClientResourceStart", resourceRoot, function ()
	outputChatBox("* NativePhoneCalls (client) system started.")
end)


phoneCallTimeoutValue = nil
phoneCallAnswerKey = nil
phoneCallRunning = false
phoneCallRinging = false
dialogue = nil
phoneCallTimer = nil
currentSound = nil
currentDialogueIndex = 0
phoneObject = nil

-- This method creates a phone call in the clientside.
function createPhoneCall(dialogueTable, timeout, key)
	assert(type(dialogueTable) == "table", "Bad argument 1 @ 'createPhoneCall' [Expected table at argument 1 got "..type(dialogueTable).."]")
	assert(type(timeout) == "number", "Bad argument 2 @ 'createPhoneCall' [Expected number at argument 2 got "..type(timeout).."]")
	assert(type(key) == "string", "Bad argument 3 @ 'createPhoneCall' [Expected number at argument 3 got "..type(key).."]")
	dialogue = dialogueTable
	phoneCallTimeoutValue = timeout
	phoneCallAnswerKey = key
end

-- This method starts the phone call.
function startPhoneCall()
	-- First, we'll assert that we actually something to actually iterate over.
	assert(type(dialogue) == "table", "No dialogue to run a phone call [Expected dialogue to be table, got "..type(dialogue).."].")
	-- We cannot have two phone calls at the same time.
	assert(phoneCallRunning == false, "There cannot be two phone calls running at the same time [Expected boolean to be false, got true].")
	phoneCallRunning = true
	-- create the sound for calling the player, if it succeded, then we'll send an event to the server that the
	-- call is going through
	currentSound = playSFX("script", 105, 0, true)
	if (currentSound) then
		phoneCallRinging = true
		outputChatBox("* You have a phone call! Press '"..phoneCallAnswerKey.."' to answer.")
		triggerServerEvent("onClientPendingPhoneCall", localPlayer)
		phoneCallTimer = setTimer(unansweredCall, phoneCallTimeoutValue, 1)
	end
end

-- This method is called when the player does not answer their phone, it notifies the server
-- and runs the cleanup.
function unansweredCall()
	triggerServerEvent("onClientUnansweredCall", localPlayer)
	cleanupPhoneCall()
end

-- This method allows to stop the ringing of the phone and completely start the call.
function stopRinging()
	destroyElement(currentSound)
	killTimer(phoneCallTimer)
	phoneCallTimer = nil
	phoneCallRinging = false
	setPedAnimation(localPlayer, "PED", "phone_in", -1, false, false, false, false, 250, true)

	-- optionally, if pAttach is loaded, attach the phone object to the player
	if (checkPAttach()) then
		setTimer(function ()
			phoneObject = createObject(330, 0.0, 0.0, 0.0)
			exports["pAttach"]:attach(phoneObject, player, "weapon")
		end, 1000, 1)
	end
	
	setTimer(function ()
		triggerServerEvent("onClientCallStart", localPlayer, dialogue)
		currentDialogueIndex = 1
		iteratePhoneCall()
	end, 2000, 1)
end

-- This method walks through the dialogue table in order to start the phone call.
function iteratePhoneCall()
	-- check if ended, exit early to end call.
	if (currentDialogueIndex > #dialogue) then
		finishPhoneCall()
		return currentDialogueIndex
	end

	local current = dialogue[currentDialogueIndex]
	local sound = current.sound
	triggerEvent("onNewPhoneIteration", localPlayer, current, currentIndex)
	if (type(sound) == "string") then
		currentSound = playSound(sound, false, false)
	elseif (type(sound) == "table") then
		currentSound = playSFX(sound.container, sound.bankId, sound.id, false)
	end

	-- get the duration of the sound plus a few miliseconds.
	local duration = (getSoundLength(currentSound)) * 1000

	-- continue to next iteration
	setTimer(iteratePhoneCall, duration, 1)
	currentDialogueIndex = currentDialogueIndex + 1
	return currentDialogueIndex, current.dialogue
end

-- Events that can be used for whatever you need.
addEvent("onNewPhoneIteration", false)

-- This method finishes the phone call, creating an animation for it and then triggering an event
-- in the server.
function finishPhoneCall()
	triggerServerEvent("onClientCallEnd", localPlayer, dialogue)
	setPedAnimation(localPlayer, "PED", "phone_out", -1, false, false, false, false, 250, true)
	setTimer(function ()
		cleanupPhoneCall()
	end, 2000, 1)
end

-- This method cleans everything from the clientside, allowing another call to be passed on.
function cleanupPhoneCall()
	phoneCallRunning = false
	dialogue = nil
	if (phoneCallTimer) then
		killTimer(phoneCallTimer)
		phoneCallTimer = nil
	end
	if (isElement(currentSound)) then
		destroyElement(currentSound)
		currentSound = nil
	end
	if (checkPAttach()) then
		exports["pAttach"]:detach(phoneObject)
		destroyElement(phoneObject)
	end
	phoneObject = nil
	phoneCallTimeoutValue = nil
	phoneCallAnswerKey = nil
	phoneCallRunning = false
	phoneCallRinging = false
	currentDialogueIndex = 0
end

function checkPAttach()
	local resource = getResourceFromName("pAttach")
	if resource then
		return getResourceState(resource) == "running"
	end
	return false
end

addEventHandler("onClientKey", root, function (button, press)
	if (phoneCallRunning and phoneCallRinging and press and button == phoneCallAnswerKey) then
		stopRinging()
	end
end)


-- Events used by the resource in order to receive phone calls.
addEvent("onClientPhoneCallRequest", true)
addEventHandler("onClientPhoneCallRequest", resourceRoot, createPhoneCall)

addEvent("startPhoneCallRequest", true)
addEventHandler("startPhoneCallRequest", resourceRoot, startPhoneCall)

addEventHandler("onClientResourceStop", resourceRoot, function ()
	outputChatBox("* NativePhoneCalls (client) system stopped.")
end)
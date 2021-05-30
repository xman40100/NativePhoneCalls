# NativePhoneCalls
NativePhoneCalls is a little resource that allows you to simulate phone calls, based on the functionality found within the GTA SA singleplayer mode.

Basically, you create a dialogue, where you specify the sound to be used and the text that represents this sound. The sound can be a string which is used to create a sound using [playSound](https://wiki.multitheftauto.com/wiki/PlaySound), or a table that specifies the container, bank id and id of the sound, which is then used by [playSFX](https://wiki.multitheftauto.com/wiki/PlaySFX).

## Notes
* The shown text must be implemented by the scripters themselves, as implementations can vary, you could use dxDraw functions, or use the methods provided by MTA.
* No phone object is shown to the player, unless you load the [pAttach](https://github.com/Patrick2562/mtasa-pAttach) resource, which replaces bone_attach.

## The dialogue table
The dialogue table is used by this system in order to load the sounds you need to create the phone call. Let's use a sample script in order to showcase how it works:
```lua
local dialogueTable = {
	{
		sound = {
			container = "script",
			bankId = 116,
			id = 5
		},
		dialogue = "You wanna make something? A little money?"
	},
	{
		sound = {
			container = "script",
			bankId = 116,
			id = 6
		},
		dialogue = "Does the pope shit in the woods?"
	},
	{
		sound = {
			container = "script",
			bankId = 116,
			id = 7
		},
		dialogue = "I don't know but if you do want a little extra there's plenty of money to be made in racing."
	}
}

addCommandHandler("callme", function (player, cmd)
	exports["native_phonecalls"]:createPhoneCall(player, dialogueTable)
	exports["native_phonecalls"]:startClientPhoneCall(player)
end)

```

In this case, we are using the option of in game sounds, so we have to specify the container, bankId and soundId for the sound we want to play. If you want external sounds, you can provide in its place a string to the path of that sound.

## Exported functions
There are two functions that have been exported to interact with the API
* `createPhoneCall(player, dialogue)` (server): This method creates a new dialogue with the information that is needed. It's a simple table containing all the information needed by the client in order to create a dialogue. The sound can contain the container, bankid and sound id if you want to play the sounds of the game, it can also be a string, which will then play a sound file that you have passed. Adding a text is not required, but it's very recommended in order for you to add texts manually.
* `startClientPhoneCall(player)` (server): This method allows to start the pending phone call a player may have.

## Events (server)
You can use the following events to incrementally add more functionality to your phone system.
* `onClientCallStart(dialogue)`: This event is called when the player answers their phone, and the call starts. The source element is the player that answered. It returns the dialogue you specified earlier as the parameter.
* `onClientCallEnd(dialogue)`: This event is called when the player finishes their phone call. The source element is the player that answered. It returns the dialogue you specified earlier as the parameter.
* `onClientPendingPhoneCall()`: This event is called when the player gets their phone call and they are pending to answer. The source element is the player.
* `onClientUnansweredCall()`: This event is called when the player doesn't answer after the *specified in the settings* seconds. The source element is the player.

## Events (client)
You can use the following events to add more functionality:
* `onNewPhoneIteration(current, currentIndex)`: This event is called when the phone call advances a new index in the dialogue. The parameters return the current dialogue and the current dialogue index. The source element is the player.
* `onClientPhoneCallRequest(dialogueTable, timeout, key)`: This event is called when the server requests the client to create a new phone call. Internally, it calls the method createPhoneCall in the client, and the parameters specify the dialogue table, timeout setting and key to answer setting. The source is the resourceRoot element.
* `startPhoneCallRequest()`: This event is called when the server requests the client to start the phone call that is currently loaded. The source element is the resourceRoot element.
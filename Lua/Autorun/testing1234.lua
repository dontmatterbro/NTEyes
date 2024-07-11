--[[
    This example shows how to create a command that gives afflictions to a character.
--]]

if CLIENT and Game.IsMultiplayer then return end -- lets this run if on the server-side, if it's multiplayer, doesn't let it run on the client, and if it's singleplayer, lets it run on the client.

Hook.Add("chatMessage", "examples.getAfflictions", function (message, client)
    if message ~= "!light" then return end

    local character
    if SERVER then
        character = client.Character
    else
        character = Character.Controlled
    end

    if character == nil then return end
	
   --for k, hull in pairs(Hull.HullList)--
do
      hull.AmbientLight = Color(255, 0, 0, 255)
   end
end)

















--[[
local burnPrefab = AfflictionPrefab.Prefabs["burn"]

function UpdateHumanEye(character)
	if HF.HasAffliction(character, "burn", 1) then
		HF.AddAfflictionLimb(character, "eyedamage", 20)
		hull.AmbientLight = Color(255, 0, 0, 255)
	end
	return something idk yet dont run this
end
--]]


--[[
Hook.Add("chatMessage", "examples.giveAfflictions", function (message, client)
    if message ~= "!giveaffliction" then return end

    local character
    if SERVER then
        character = client.Character
    else
        character = Character.Controlled
    end

    if character == nil then return end
		
    local limb = character.AnimController.GetLimb(LimbType.Head)

    -- give 50 of burns to the head of the character
    character.CharacterHealth.ApplyAffliction(limb, burnPrefab.Instantiate(50))


		
    return true -- returning true allows us to hide the message
end)


Hook.Add("chatMessage", "examples.getAfflictions", function (message, client)
    if message ~= "!getaffliction" then return end

    local character
    if SERVER then
        character = client.Character
    else
        character = Character.Controlled
    end

    if character == nil then return end

    local limb = character.AnimController.GetLimb(LimbType.Head)

    local affliction = character.CharacterHealth.GetAffliction("burn", limb)
    local amount = affliction and affliction.Strength or 0 -- get the amount of the affliction

    local chatMessage = ChatMessage.Create("", tostring(amount), ChatMessageType.Default, nil, nil)
    chatMessage.Color = Color(255, 255, 0, 255)

    if affliction >= 1 then  
    hull.AmbientLight = Color(255, 0, 0, 255)
		else
		end

		
    if SERVER then
        Game.SendDirectChatMessage(chatMessage, client)
    else
        Game.ChatBox.AddMessage(chatMessage)
    end

    return true -- returning true allows us to hide the message
end)
--]]

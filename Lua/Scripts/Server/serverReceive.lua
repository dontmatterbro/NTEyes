local function handleSound(message, itemIdentifier)
	local clientCharacterID = tostring(message.ReadString())
	for _, character in pairs(Character.CharacterList) do
		if tostring(character.ID) == clientCharacterID then
			HF.GiveItem(character, itemIdentifier)
			break
		end
	end
end

Networking.Receive("PlayScannerSound", function(message, client)
	handleSound(message, "misc_sfx_selfscan")
end)

Networking.Receive("PlayScannerSoundFail", function(message, client)
	handleSound(message, "misc_sfx_fail")
end)

Networking.Receive("PlayBeepSound", function(message, client)
	handleSound(message, "misc_sfx_beep")
end)

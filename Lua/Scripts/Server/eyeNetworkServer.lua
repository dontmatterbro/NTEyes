----------------- RECEIVE --------------------------------------
Networking.Receive("PlayScannerSound", function(message, client)

	local clientCharacter = tostring(message.ReadString())
	
	for key, character in pairs(Character.CharacterList) do
		
		local serverCharacter = tostring(character.ID)
		
		if 
			serverCharacter==clientCharacter
		then
			--print("boogeraids")
			HF.GiveItem(character,"nteye_selfscan")
		end

	end
	 
end)

Networking.Receive("PlayScannerSoundFail", function(message, client)

	local clientCharacter = tostring(message.ReadString())
	
	for key, character in pairs(Character.CharacterList) do
		
		local serverCharacter = tostring(character.ID)
		
		if 
			serverCharacter==clientCharacter
		then
			--print("boogeraids")
			HF.GiveItem(character,"nteye_fail")
		end

	end
	 
end)

Networking.Receive("PlayBeepSound", function(message, client)

	local clientCharacter = tostring(message.ReadString())
	
	for key, character in pairs(Character.CharacterList) do
		
		local serverCharacter = tostring(character.ID)
		
		if 
			serverCharacter==clientCharacter
		then
			--print("boogeraids")
			HF.GiveItem(character,"nteye_beep")
		end

	end
	 
end)


----------------- SEND --------------------------------------

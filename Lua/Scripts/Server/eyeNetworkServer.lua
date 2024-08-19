----------------- RECEIVE --------------------------------------
Networking.Receive("PlayScannerSound", function(message, client)

	for key, character in pairs(Character.CharacterList) do
		if 
			character.Name==client.characterInfo.Name
		then
			HF.GiveItem(character,"ntsfx_selfscan")
		end
	end
	 
end)







----------------- SEND --------------------------------------

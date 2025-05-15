--send a request to spawn a sound effect item health scanner
function NTEYE.PlayScannerSound(target)
	if not Game.IsMultiplayer then
		HF.GiveItem(target, NTEYE.ScannerActive and "nteye_fail" or "nteye_selfscan")
		return
	end

	local message = Networking.Start(NTEYE.ScannerActive and "PlayScannerSoundFail" or "PlayScannerSound")
	message.WriteString(target.ID)
	Networking.Send(message)
end

--send a request to spawn a sound effect item beep
function NTEYE.PlayBeepSound(target)
	if not Game.IsMultiplayer then
		HF.GiveItem(target, "nteye_beep")
		return
	end
	local message = Networking.Start("PlayBeepSound")
	message.WriteString(target.ID)
	Networking.Send(message)
end

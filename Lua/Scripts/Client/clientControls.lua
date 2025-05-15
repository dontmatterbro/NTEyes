--key to activate lenses (make this configurable)
NTEYE.LensActivationKey = Keys.F

--Medical Scanner key (make this configurable)
NTEYE.MedicalScannerKey = Keys.F

--this enables recognition of selected limb in health UI
LuaUserData.MakeFieldAccessible(Descriptors["Barotrauma.CharacterHealth"], "selectedLimbIndex")

--I dont recall what this does, probably enable keyboard input
Hook.HookMethod("Barotrauma.Character", "ControlLocalPlayer", function(instance, ptable)
	NTEYE.MedicalLensScanner()
	NTEYE.HudToggle()
end, Hook.HookMethodType.After)

--function to enable/disable HUD
function NTEYE.HudToggle()
	for _, hud in pairs(NTEYE.HUDValues) do
		if HF.HasAffliction(Character.Controlled, hud.affliction) and not CharacterHealth.OpenHealthWindow then
			if PlayerInput.KeyHit(NTEYE.LensActivationKey) then
				if NTEYE.HUDEnabled then
					print("Disabling HUD")
					NTEYE.HUDEnabled = false
					NTEYE.PlayBeepSound(Character.Controlled)
				else
					print("Enabling HUD")
					NTEYE.HUDEnabled = true
					NTEYE.PlayBeepSound(Character.Controlled)
				end
			end
		end
	end
end

--or GUI.InputBlockingMenuOpen
--or GUI.PauseMenuOpen
--or GUI.SettingsMenuOpen

--health UI scanner function for medical lens
function NTEYE.MedicalLensScanner()
	--check if the player has a medical lens
	if not HF.HasAffliction(Character.Controlled, "lt_medical") then
		return
	end
	if not CharacterHealth.OpenHealthWindow or NTEYE.ScannerActive then
		return
	end

	if PlayerInput.KeyHit(NTEYE.MedicalScannerKey) then
		local scannerUser = Character.Controlled
		local scannerTarget = Character.Controlled.SelectedCharacter or scannerUser
		local limbIndex = CharacterHealth.OpenHealthWindow.selectedLimbIndex

		-- Prevent scanning own head
		if limbIndex == 0 and scannerUser == scannerTarget then
			HF.DMClient(
				HF.CharacterToClient(scannerUser),
				"‖color:255,100,100‖You can't see your own head.‖color:end‖"
			)
			NTEYE.ScannerActive = true
			NTEYE.PlayScannerSound(scannerUser)
			Timer.Wait(function()
				NTEYE.ScannerActive = false
			end, 500)
			return
		end

		-- Map limb index to LimbType
		local limbTypes = {
			[0] = LimbType.Head,
			[1] = LimbType.Torso,
			[2] = LimbType.LeftArm,
			[3] = LimbType.RightArm,
			[4] = LimbType.LeftLeg,
			[5] = LimbType.RightLeg,
		}
		local limb = limbTypes[limbIndex]
		if not limb then
			return
		end

		-- Perform scan
		NTEYE.HealthScanner(scannerUser, scannerTarget, limb)
		NTEYE.ScannerActive = true
	end
end

--variables to set HUD values
NTEYE.HUDActive = false
NTEYE.DrawnHUD = nil
NTEYE.DisableHoverTextHUD = false

local character = Character.Controlled

--there will be a table this time instead of individual variables
NTEYE.HUDValues = {
	thermal = {
		active = false,
		item = nil,
		affliction = "lt_thermal",
	},
	medical = {
		active = false,
		item = nil,
		affliction = "lt_medical",
	},
	electrical = {
		active = false,
		item = nil,
		affliction = "lt_electrical",
	},
	zoom = {
		active = false,
		item = nil,
		affliction = "lt_magnification",
	},
}

--resets hud parameters for client when character changes (for MCM and singleplayer)
Hook.Patch("Barotrauma.Character", "set_Controlled", function(character)
	--disables all HUDs
	for _, hud in pairs(NTEYE.HUDValues) do
		hud.active = false
	end
	--sets the global variable to false
	NTEYE.HUDActive = false
	NTEYE.DrawnHUD = nil

	NTEYE.DisableHoverTextHUD = false
end)

--deletes duplicate player text from medical hud
Hook.Patch("Barotrauma.CharacterHUD", "DrawCharacterHoverTexts", function(instance, ptable)
	ptable.PreventExecution = NTEYE.DisableHoverTextHUD
	return nil
end, Hook.HookMethodType.Before)

--draws the written eye huds
Hook.Patch("Barotrauma.CharacterHUD", "Draw", function(instance, ptable)
	if NTEYE.DrawnHUD == nil then
		return
	end
	NTEYE.DrawnHUD.DrawHUD(ptable["spriteBatch"], character) --draws the huds
end)

function NTEYE.WriteHUD()
	for _, hud in pairs(NTEYE.HUDValues) do
		if HF.HasAffliction(character, hud.affliction) then
			if NTEYE.DrawnHUD == nil then
				if hud.item == nil or hud.item.Removed then
					NTEYE.ResetHUDValues()
					NTEYE.GetHUDItemValues()
					NTEYE.SendItemSpawnRequest()
					return
				end
				hud.active = true
				hud.item.Equip(character)
				NTEYE.DrawnHUD = hud.item.GetComponentString("StatusHUD") --get hud component
				NTEYE.HUDActive = true

				--check to disable hover text if medical hud
				if hud.affliction == "lt_medical" then
					NTEYE.DisableHoverTextHUD = true
				end
			end
		else
			NTEYE.DisableHUDs()
		end
	end
end

--get the item values for the HUDs
function NTEYE.GetHUDItemValues()
	for item in Item.ItemList do
		for _, hud in pairs(NTEYE.HUDValues) do
			if item.Prefab.Identifier == hud.item then
				hud.item = item
			end
		end
	end
end

function NTEYE.DisableHUDs()
	for _, hud in pairs(NTEYE.HUDValues) do
		if hud.active then
			hud.item.Unequip(character)
			hud.active = false
			if hud.affliction == "lt_medical" then
				NTEYE.DisableHoverTextHUD = false
			end
			NTEYE.DrawnHUD = nil
			NTEYE.HUDActive = false
		end
	end
end

--sends a request for HUD items to spawn in case lua fucks up
function NTEYE.SendItemSpawnRequest()
	if not Game.IsMultiplayer then
		NTEYE.SpawnEffectItems()
		return
	end --singleplayer comp

	local message = Networking.Start("SendItemSpawnRequest")

	message.WriteString("")

	Networking.Send(message)
end

--resets HUD values to prevent bugs
function NTEYE.ResetHUDValues()
	for _, hud in pairs(NTEYE.HUDValues) do
		hud.active = false
		hud.item = nil
		NTEYE.DrawnHUD = nil
		NTEYE.HUDActive = false
		DisableHoverTextHUD = false
	end
end

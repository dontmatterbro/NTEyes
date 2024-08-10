--timer values
NTEYE.ClientUpdateCooldown = 0
NTEYE.ClientUpdateInterval = 120

--HUD values
thermalHUDActive = nil
medicalHUDActive = nil
electricalHUDActive = nil
eyeHUD = nil
DisableHoverTextHUD = false

-- updates client effects every 0.5 seconds
Hook.Add("think", "NTEYE.updatetriggerclient", function()
    if HF.GameIsPaused() or not Level.Loaded then return end
    NTEYE.ClientUpdateCooldown = NTEYE.ClientUpdateCooldown-4
    if (NTEYE.ClientUpdateCooldown <= 0) then
        NTEYE.ClientUpdateCooldown = NTEYE.ClientUpdateInterval
        NTEYE.UpdateHumanEyeEffect(character)
    end
end)


--deletes player text for medical hud
Hook.Patch("Barotrauma.CharacterHUD", "DrawCharacterHoverTexts", function(instance, ptable)
	ptable.PreventExecution = DisableHoverTextHUD
	return nil
end, Hook.HookMethodType.Before)


-- infrared eye thermal hud
Hook.Patch("Barotrauma.GUI", "Draw", function(instance, ptable)

		if not HF.HasAffliction(Character.Controlled, "eyeinfrared") then return end

		if eyeHUD==nil then
			for item in Item.ItemList do --make this global, when adding more eyes
				if item.Prefab.Identifier == "eyethermalHUDitem" then
					item.Equip(Character.Controlled)
					eyeHUD = item.GetComponentString("StatusHUD")
					thermalHUDActive = 1
					break
				end
			end
		end

		eyeHUD.DrawHUD(ptable["spriteBatch"], Character.Controlled)

end)


--medical eye hud
Hook.Patch("Barotrauma.GUI", "Draw", function(instance, ptable)

		if not HF.HasAffliction(Character.Controlled, "medicallens") then return end

		if eyeHUD==nil then
			for item in Item.ItemList do
				if item.Prefab.Identifier == "eyemedicalHUDitem" then
					item.Equip(Character.Controlled)
					eyeHUD = item.GetComponentString("StatusHUD")
					medicalHUDActive = 1
					DisableHoverTextHUD = true --disables text hud
					break
				end
			end
		end
		
		
		eyeHUD.DrawHUD(ptable["spriteBatch"], Character.Controlled)

end)


--electrical eye hud
Hook.Patch("Barotrauma.GUI", "Draw", function(instance, ptable)

		if not HF.HasAffliction(Character.Controlled, "electricallens") then return end

		if eyeHUD==nil then
			for item in Item.ItemList do
				if item.Prefab.Identifier == "eyeelectricalHUDitem" then
					item.Equip(Character.Controlled)
					eyeHUD = item.GetComponentString("StatusHUD")
					electricalHUDActive = 1
					break
				end
			end
		end

		eyeHUD.DrawHUD(ptable["spriteBatch"], Character.Controlled)

end)

--checks if any HUDs are enabled
function NTEYE.checkHUDs()

	if 
		   thermalHUDActive == 1
		or medicalHUDActive == 1
		or electricalHUDActive == 1
	
	then return true end
end

--disables HUDs if they are enabled
function NTEYE.disableHUDs(character)

	if NTEYE.checkHUDs() then 
	
		for item in Item.ItemList do
			
			if item.Prefab.Identifier == "eyethermalHUDitem" then
				item.Unequip(Character.Controlled)
				thermalHUDActive = nil
			end
			
			if item.Prefab.Identifier == "eyemedicalHUDitem" then
				item.Unequip(Character.Controlled)	
				medicalHUDActive = nil
				DisableHoverTextHUD = false
			end
			
			if item.Prefab.Identifier == "eyeelectricalHUDitem" then
				item.Unequip(Character.Controlled)	
				electricalHUDActive = nil
			end

			eyeHUD = nil
			
			--break
		end
	
	end

end		


--Eye Effect Check Functions only runs on client
function NTEYE.UpdateHumanEyeEffect(character)

local parameters = Level.Loaded.LevelData.GenerationParams

if HF.HasAffliction(Character.Controlled, "eyebionic") then

		parameters.AmbientLightColor = Color(50, 50, 25, 35)
		
		for k, hull in pairs(Hull.HullList) do
			hull.AmbientLight = Color(60, 60, 30, 75) 
		end
		
		if HF.HasAffliction(Character.Controlled, "medicallens") then
			
			parameters.AmbientLightColor = Color(50, 0, 0, 35)
		
			for k, hull in pairs(Hull.HullList) do
				hull.AmbientLight = Color(60, 0, 0, 75)
			end

		elseif HF.HasAffliction(Character.Controlled, "electricallens") then
			
			parameters.AmbientLightColor = Color(50, 50, 0, 35)
		
			for k, hull in pairs(Hull.HullList) do
				hull.AmbientLight = Color(60, 60, 0, 75)
			end
		
		else
			NTEYE.disableHUDs()
		end
  
  
elseif HF.HasAffliction(Character.Controlled, "eyenight") then

		parameters.AmbientLightColor = Color(20, 160, 30, 200)
		
		for k, hull in pairs(Hull.HullList) do
			hull.AmbientLight = Color(20, 160, 20, 150) 
        end
 
elseif HF.HasAffliction(Character.Controlled, "eyeinfrared") then

		parameters.AmbientLightColor = Color(25, 0, 75, 40)
		
		for k, hull in pairs(Hull.HullList) do
			hull.AmbientLight = Color(50, 0, 200, 75) 
        end

elseif HF.HasAffliction(Character.Controlled, "eyeplastic") then

		parameters.AmbientLightColor = Color(0, 0, 255, 5)
		
		for k, hull in pairs(Hull.HullList) do
			hull.AmbientLight = Color(0, 0, 255, 5) 
        end
 
elseif HF.HasAffliction(Character.Controlled, "eyemonster") then

		if Game.IsMultiplayer then Character.Controlled.TeamID = 0 end

		parameters.AmbientLightColor = Color(50, 0, 50, 5)
		
		for k, hull in pairs(Hull.HullList) do
			hull.AmbientLight = Color(160, 160, 70, 25) 
        end
 
elseif HF.HasAffliction(Character.Controlled, "eyehusk") then

		if Game.IsMultiplayer then Character.Controlled.TeamID = 4 end
		
		
		parameters.AmbientLightColor = Color(115, 115, 20, 5)
		
		for k, hull in pairs(Hull.HullList) do
			hull.AmbientLight = Color(115, 115, 30, 30) 
        end
 
elseif HF.HasAffliction(Character.Controlled, "eyeterror") then

		if Game.IsMultiplayer then Character.Controlled.TeamID = 2 end
		
		parameters.AmbientLightColor = Color(255, 0, 0, 125)
		
		for k, hull in pairs(Hull.HullList) do
			hull.AmbientLight = Color(255, 0, 0, 125) 
        end

else
		parameters.AmbientLightColor = Color(10, 10, 10, 25)
		
		for k, hull in pairs(Hull.HullList) do
			hull.AmbientLight = Color(20, 20, 20, 35) 
        end
		
		NTEYE.disableHUDs() --disable eye HUDs
		
		if Character.Controlled ~= nil then 
			if(Character.Controlled.IsHuman and not Character.Controlled.IsDead) then Character.Controlled.TeamID = 1 end
		end

		
	end
end



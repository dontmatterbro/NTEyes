NTEYE.UpdateCooldown = 0
NTEYE.UpdateInterval = 120
NTEYE.Deltatime = NTEYE.UpdateInterval/60 -- Time in seconds that transpires between updates


-- This Hook triggers function updates.
Hook.Add("think", "NTEYE.update", function()
    if HF.GameIsPaused() then return end

    NTEYE.UpdateCooldown = NTEYE.UpdateCooldown-1
    if (NTEYE.UpdateCooldown <= 0) then
        NTEYE.UpdateCooldown = NTEYE.UpdateInterval
        NTEYE.Update() 
		NTEYE.UpdateHumanEye(character)
    end
end)

-- Gets to run once every two seconds.
function NTEYE.Update()
if CLIENT and Game.IsMultiplayer then return end -- so it doesnt run on client
	print("eyeupdatetest")
		local updateHumanEyes = {}
		local amountHumanEyes = 0
		
		
	--fetch character for update
	for key, character in pairs(Character.CharacterList) do
		if not character.IsDead then
			if character.IsHuman then
				table.insert(updateHumanEyes, character)
				amountHumanEyes = amountHumanEyes + 1
			end
		end
	end
	
	--spread the characters out over the duration of an update so that the load isnt done all at once
    for key, value in pairs(updateHumanEyes) do
        -- make sure theyre still alive and human
        if (value ~= nil and not value.Removed and value.IsHuman and not value.IsDead) then
            Timer.Wait(function ()
                if (value ~= nil and not value.Removed and value.IsHuman and not value.IsDead) then
                NTEYE.UpdateHumanEye(value) end
            end, ((key + 1) / amountHumanEyes) * NTEYE.Deltatime * 1000)
        end
    end
end

--checks if character is in diving gear on demand
function NTEYE.IsInDivingGear(character)
  local outerSlot = character.Inventory.GetItemInLimbSlot(InvSlotType.OuterClothes)
  local headSlot = character.Inventory.GetItemInLimbSlot(InvSlotType.Head)

  if outerSlot and outerSlot.HasTag("diving") or outerSlot and outerSlot.HasTag("deepdiving") or headSlot and headSlot.HasTag("diving") or headSlot and headSlot.HasTag("deepdiving") then
    return true
  end
  return false
end

function NTEYE.GetItemInSlot(character, slot)
  if character and slot then
    return character.Inventory.GetItemInLimbSlot(slot)
  end
end

function NTEYE.UpdateHumanEye(character)
if Game.IsMultiplayer and CLIENT then return end
print("debug:UpdateHumanEye")
print(character)
  if HF.HasAffliction(character, "cerebralhypoxia", 60) and not HF.HasAffliction(character, "eyebionic") then
    HF.AddAfflictionLimb(character, "eyedamage", 11, 0.1)
  end
  if HF.HasAffliction(character, "hypoxemia", 40) and not HF.HasAffliction(character, "eyebionic") then
    HF.AddAfflictionLimb(character, "eyedamage", 11, 0.2)
  end
  if HF.HasAffliction(character, "stroke", 5) and not HF.HasAffliction(character, "eyebionic") then
    HF.AddAfflictionLimb(character, "eyedamage", 11, 0.3)
  end
  if HF.HasAffliction(character, "sepsis", 40) then
    HF.AddAfflictionLimb(character, "eyedamage", 11, 0.1)
  end
  if HF.HasAffliction(character, "eyeshock") then
    HF.AddAfflictionLimb(character, "eyeshock", 11, 0.5)
    if HF.HasAffliction(character, "eyeshock", 80) then
      HF.AddAfflictionLimb(character, "eyedamage", 11, 0.8)
    end
  end
  if HF.HasAffliction(character, "eyedamage", 40) then
    NTC.SetSymptomTrue(character, "sym_blurredvision", 2)
    HF.AddAfflictionLimb(character, "eyedamage", 11, 0.05)
    if HF.HasAffliction(character, "eyedamage", 50) and not HF.HasAffliction(character, "eyeone") then
      HF.AddAfflictionLimb(character, "eyeone", 11, 2)
    end
    if HF.HasAffliction(character, "eyedamage", 99) then
      ClearCharacterEyeAfflictions(character)
      HF.AddAfflictionLimb(character, "noeye", 11, 2)
    end
  end
  if HF.Chance(0.0005) and HF.HasAffliction(character, "eyedamage", 20) then
    HF.AddAfflictionLimb(character, "eyecataract", 11, 1)
  end
  if HF.HasAffliction(character, "eyecataract") then
    HF.AddAfflictionLimb(character, "eyecataract", 11, 0.4)
  end
  if HF.HasAffliction(character, "eyehusk") and HF.Chance(0.001) then
    HF.AddAffliction(character, "huskinfection", 1)
  end
  if HF.HasAffliction(character, "eyecataract", 50) then
    NTC.SetSymptomTrue(character, "sym_blurredvision", 2)
  end
  if NTEYE.GetItemInSlot(character, InvSlotType.Head) and GetItemInSlot(character, InvSlotType.Head).Prefab.identifier == "eyeglasses" then
    NTC.SetSymptomFalse(character, "sym_blurredvision", 2)
  end
  if character.AnimController.HeadInWater and not NTEYE.IsInDivingGear(character) and not HF.HasAffliction(character, "eyemonster") and not HF.HasAffliction(character, "eyehusk") then
    HF.AddAfflictionLimb(character, "eyedamage", 11, 0.34)
  elseif HF.HasAffliction(character, "eyedamage") and not HF.HasAffliction(character, "eyedamage", 45) or HF.HasAffliction(character, "eyedamage", 50) and not HF.HasAffliction(character, "eyedamage", 95) then
    HF.AddAfflictionLimb(character, "eyedamage", 11, -0.1)
    if HF.HasAffliction(character, "eyedrop") then
      HF.AddAfflictionLimb(character, "eyedamage", 11, -0.2)
    end
  end
  HF.AddAfflictionLimb(character, "eyedrop", 11, -0.8)
end


function NTEYE.UpdateHumanEyeEffect(character)
if SERVER then return end -- this part only runs of client
print("debug:UpdateHumanEyeEffect")
if HF.HasAffliction(Character.Controlled, "eyebionic") then
		local parameters = Level.Loaded.LevelData.GenerationParams
		parameters.AmbientLightColor = Color(50, 50, 0, 65)
		for k, hull in pairs(Hull.HullList) do
        hull.AmbientLight = Color(60, 60, 0, 75) 
        end
  
elseif HF.HasAffliction(Character.Controlled, "eyenight") then
		local parameters = Level.Loaded.LevelData.GenerationParams
		parameters.AmbientLightColor = Color(0, 150, 30, 200)
		for k, hull in pairs(Hull.HullList) do
        hull.AmbientLight = Color(0, 150, 0, 200) 
        end
 
elseif HF.HasAffliction(Character.Controlled, "eyeinfrared") then
		local parameters = Level.Loaded.LevelData.GenerationParams
		parameters.AmbientLightColor = Color(50, 0, 200, 50)
		for k, hull in pairs(Hull.HullList) do
        hull.AmbientLight = Color(50, 0, 200, 75) 
        end
 
elseif HF.HasAffliction(Character.Controlled, "eyeplastic") then
		local parameters = Level.Loaded.LevelData.GenerationParams
		parameters.AmbientLightColor = Color(0, 0, 255, 0)
		for k, hull in pairs(Hull.HullList) do
        hull.AmbientLight = Color(0, 0, 255, 0) 
        end
 
elseif HF.HasAffliction(Character.Controlled, "eyemonster") then
		local parameters = Level.Loaded.LevelData.GenerationParams
		parameters.AmbientLightColor = Color(50, 0, 50, 0)
		for k, hull in pairs(Hull.HullList) do
        hull.AmbientLight = Color(160, 160, 70, 0) 
        end
 
elseif HF.HasAffliction(Character.Controlled, "eyehusk") then
		local parameters = Level.Loaded.LevelData.GenerationParams
		parameters.AmbientLightColor = Color(115, 0, 115, 0)
		for k, hull in pairs(Hull.HullList) do
        hull.AmbientLight = Color(115, 0, 115, 0) 
        end
 
elseif HF.HasAffliction(Character.Controlled, "eyeterror") then
		local parameters = Level.Loaded.LevelData.GenerationParams
		parameters.AmbientLightColor = Color(255, 0, 0, 125)
		for k, hull in pairs(Hull.HullList) do
        hull.AmbientLight = Color(255, 0, 0, 125) 
        end

else	local parameters = Level.Loaded.LevelData.GenerationParams
		parameters.AmbientLightColor = Color(10, 10, 10, 10)
		for k, hull in pairs(Hull.HullList) do
        hull.AmbientLight = Color(20, 20, 20, 20) 
        end
	end
end


























	

	
	
	
--[[


	NTEYE.Afflictions = {
	
	}

function NTEYE.UpdateHuman(character)

	-- pre humanupdate hooks
    for key, val in pairs(NTC.PreHumanUpdateHooks) do
        val(character)
    end

    local charData = {character=character,afflictions={},stats={}}

    -- fetch all the current affliction data
    for identifier,data in pairs(NT.Afflictions) do
        local strength = HF.GetAfflictionStrength(character,identifier,data.default or 0)
        charData.afflictions[identifier] = {prev=strength,strength=strength}
    end
end
--]]
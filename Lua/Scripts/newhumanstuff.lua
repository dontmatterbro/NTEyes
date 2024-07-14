NTCBE.UpdateCooldown = 0
NTCBE.UpdateInterval = 120
NTCBE.Deltatime = NT.UpdateInterval/60 -- Time in seconds that transpires between updates


-- This Hook triggers function updates.
Hook.Add("think", "NTCBE.update", function()
    if HF.GameIsPaused() then return end

    NT.UpdateCooldown = NT.UpdateCooldown-1
    if (NTCBE.UpdateCooldown <= 0) then
        NTCBE.UpdateCooldown = NT.UpdateInterval
        NTCBE.Update()
    end
end)

-- Gets to run once every two seconds.
function NTCBE.Update()

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
                NTCBE.UpdateHuman(value) end
            end, ((key + 1) / amountHumans) * NT.Deltatime * 1000)
        end
    end
end



	NTCBE.Afflictions = {
	
	}
	
	
	
function NTCBE.UpdateHuman(character)

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
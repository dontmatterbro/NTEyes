Hook.Add("character.applyDamage", "eyeOnDamage", function (characterHealth, attackResult, hitLimb)

local character = characterHealth.Character

if -- invalid attack data or no eyes, don't do anything (from neurotrauma)
	characterHealth == nil or 
	characterHealth.Character == nil or 
	characterHealth.Character.IsDead or
	not characterHealth.Character.IsHuman or 
	attackResult == nil or 
	attackResult.Afflictions == nil or
	#attackResult.Afflictions <= 0 or
	hitLimb == nil or
	hitLimb.IsSevered or
	not NTEYE.HasEyes(character)
then return end


	for i, v in pairs(attackResult.Afflictions) do
		if hitLimb.type == LimbType.Head then
		
			--gunshot eye
			if v.Identifier == "gunshotwound" then
				
				--bullet hit both eyes (lmao)
				if HF.Chance(0.002 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(500,1000)/1000 * v.Strength)
				
				--bullet hit eye
				elseif HF.Chance(0.004 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(250,500)/1000 * v.Strength)
				
				--bullet grazed eye
				elseif HF.Chance(0.007 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(100,250)/1000 * v.Strength)
				end
			end
			
			
			--laceration eye
			if v.Identifier == "lacerations" then
				
				--blade hit both eyes (lmao x2)
				if HF.Chance(0.001 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(500,1000)/1000 * v.Strength)
				
				
				--blade hit eye
				elseif HF.Chance(0.003 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(250,500)/1000 * v.Strength)
				
				
				--blade grazed eye
				elseif HF.Chance(0.009 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(100,250)/1000 * v.Strength)
				end
			end
			
			
			--bite eye (yummy)
			if v.Identifier == "bitewounds" then
				
				--bite bit both eyes (lmao x3)
				if HF.Chance(0.004 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(500,1000)/1000 * v.Strength)
				end
				
				--bite bit eye
				if HF.Chance(0.006 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(250,500)/1000 * v.Strength)
				end
				
				--bite grazed eye
				if HF.Chance(0.01 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(100,250)/1000 * v.Strength)
				end
			end
			
			
			--blunttrauma eye
			if v.Identifier == "blunttrauma" then
				
				--object hit both eyes (lmao x4)
				if HF.Chance(0.003 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(500,1000)/1000 * v.Strength)
				end
				
				--object hit eye
				if HF.Chance(0.006 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(250,500)/1000 * v.Strength)
				end
				
				--object grazed eye
				if HF.Chance(0.01 * v.Strength) then
					HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(100,250)/1000 * v.Strength)
				end
			end
		
			--burn eyes (old code made sense, kept it)
			if 
				v.Identifier == "burn" 
			then
				if 
					HF.HasAffliction(character, "eyeplastic")
				then
					HF.AddAfflictionLimb(character, "eyedamage", 11, v.Strength*4)
				
				elseif
					HF.HasAffliction(character, "eyebionic")
				then
					HF.AddAfflictionLimb(character, "eyedamage", 11, v.Strength*0.5)
				
				else
					HF.AddAfflictionLimb(character, "eyedamage", 11, v.Strength)
				end
			end

			--explode eyes (old code made sense, enhanced it)
			if v.Identifier == "explosiondamage" then
				HF.AddAfflictionLimb(character, "eyedamage", 11, math.random(100,1000)/1000 * v.Strength)
			end
		
		end
	end
end)
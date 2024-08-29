local ScannerActive = 0

LuaUserData.MakeFieldAccessible(
Descriptors["Barotrauma.CharacterHealth"], "selectedLimbIndex")

Hook.HookMethod("Barotrauma.Character","ControlLocalPlayer",function(instance,ptable)

	if not HF.HasAffliction(Character.Controlled, "medicallens") then return end

	if 
		CharacterHealth.OpenHealthWindow ~= nil
		and ScannerActive==0
	then
		if --Decrease Zoom
			PlayerInput.KeyDown(Keys.F) 
		then
			local limb = nil
			
			local scannerTarget = nil
			
			local scannerUser = Character.Controlled
			
			local limbIndex = CharacterHealth.OpenHealthWindow.selectedLimbIndex

			if --Which Character to scan
				Character.Controlled.SelectedCharacter ~= nil
			then
				scannerTarget = Character.Controlled.SelectedCharacter

			else
				scannerTarget = Character.Controlled
			end

			if --client can't scan own head
				limbIndex == 0
				and (scannerUser == scannerTarget)
			then 
			    HF.DMClient(HF.CharacterToClient(usingCharacter), "‖color:255,100,100‖".."You can't see your own head.".."‖color:end‖")
				ScannerActive = 1
				NTEYE.PlayScannerSound(scannerTarget)
				Timer.Wait(function() ScannerActive = 0 end, 500)
			return end
			
			if --limb index, there probably an easier way to do this
				limbIndex == 0
			then
				limb = LimbType.Head

			elseif
				limbIndex == 1
			then
				limb = LimbType.Torso
			
			elseif
				limbIndex == 2
			then
				limb = LimbType.LeftArm
			
			elseif
				limbIndex == 3
			then
				limb = LimbType.RightArm
			
			elseif
				limbIndex == 4
			then
				limb = LimbType.LeftLeg
			
			elseif
				limbIndex == 5
			then
				limb = LimbType.RightLeg
			else
			return end
			
			
			
			
			NTEYE.HealthScanner(scannerUser, scannerTarget, limb)
			
			ScannerActive = 1
		end
	
	end

end,Hook.HookMethodType.After) 

function NTEYE.HealthScanner(usingCharacter, targetCharacter, limb) 

		local limbtype = HF.NormalizeLimbType(limb)
		NTEYE.PlayScannerSound(targetCharacter)
		
        -- print readout of afflictions
		
        local readoutstringstart = "‖color:100,100,200‖".."Affliction readout for ".."‖color:end‖".."‖color:125,125,225‖"..targetCharacter.Name.."‖color:end‖".."‖color:100,100,200‖".." on limb "..HF.LimbTypeToString(limbtype)..":\n".."‖color:end‖"
        local readoutstringplow = ""
        local readoutstringphigh = ""
        local readoutstringlow = ""
        local readoutstringmid = ""
        local readoutstringhigh = ""
        local readoutstringvital = ""
        local readoutstringremoved = ""
        local readoutstringgenes = ""
		
        local afflictionlist = targetCharacter.CharacterHealth.GetAllAfflictions()
        local afflictionsdisplayed = 0
		
        for value in afflictionlist do
		
            local strength = HF.Round(value.Strength)
            local prefab = value.Prefab
            local limb = targetCharacter.CharacterHealth.GetAfflictionLimb(value)
            local afflimbtype = LimbType.Torso
            
            if(not prefab.LimbSpecific) then afflimbtype = prefab.IndicatorLimb 
            elseif(limb~=nil) then afflimbtype=limb.type end
            
            afflimbtype = HF.NormalizeLimbType(afflimbtype)

			--there probably is a better way to define these, I'll look into it later on
			--vital afflictions
			ScannerVital = {

				"cardiacarrest",
				"ll_arterialcut",
				"rl_arterialcut",
				"la_arterialcut",
				"ra_arterialcut",
				"t_arterialcut",
				"h_arterialcut",
				"tra_amputation",
				"tla_amputation",
				"trl_amputation",
				"tll_amputation",
				"th_amputation", --ouch
				"eyesdead"
				
			}

			--organ removals
			ScannerRemoved = {
			
				"heartremoved",
				"brainremoved",
				"lungremoved",
				"kidneyremoved",
				"liverremoved",
				"noeye",
				"sra_amputation",
				"sla_amputation",
				"srl_amputation",
				"sll_amputation",
				"sh_amputation"

			}
			
			--blood pressure
			ScannerPressure = {
			
				"bloodpressure"
			
			}
		
			--genes
			ScannerGenes = {
			
				"husktransformimmunity",
				"increasedmeleedamageondamage",
				"hyperactivityondamage",
				"vigorondamage",
				"healdamage",
				"increasedmeleedamage",
				"increasedwalkingspeed",
				"decreasedoxygenconsumption",
				"damageresistance",
				"naturalrangedweapon",
				"naturalmeleeweapon",
				"increasedswimmingspeed",
				"inflamedlung",
				"musculardystrophy",
				"decrepify",
				"glassjaw",
				"outsideinfluence",
				"increasedswimmingspeed",
				"xenobiology",
				"hypersensitivity",
				"rigidjoints",
				"tunnelvision"
			
			}
		
            if (strength >= prefab.ShowInHealthScannerThreshold and afflimbtype==limbtype) then
                -- add the affliction to the readout


				if --low
					(strength < 25) 
					and not HF.TableContains(ScannerVital, value.Identifier) 
					and not HF.TableContains(ScannerRemoved, value.Identifier) 
					and not HF.TableContains(ScannerPressure, value.Identifier) 
					and not HF.TableContains(ScannerGenes, value.Identifier) 
				then
					readoutstringlow = readoutstringlow.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
				
				
				if --mid
					strength >= 25 and (strength < 65) 
					and not HF.TableContains(ScannerVital, value.Identifier) 
					and not HF.TableContains(ScannerRemoved, value.Identifier) 
					and not HF.TableContains(ScannerPressure, value.Identifier) 
					and not HF.TableContains(ScannerGenes, value.Identifier) 
				then
					readoutstringmid = readoutstringmid.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
				
				
				if --high
					strength >= 65 
					and not HF.TableContains(ScannerVital, value.Identifier) 
					and not HF.TableContains(ScannerRemoved, value.Identifier) 
					and not HF.TableContains(ScannerPressure, value.Identifier) 
					and not HF.TableContains(ScannerGenes, value.Identifier) 
				then 
					readoutstringhigh = readoutstringhigh.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
						
						
				if --vital
					HF.TableContains(ScannerVital, value.Identifier) 
				then 
					readoutstringvital = readoutstringvital.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
				
				
				if --removed
					HF.TableContains(ScannerRemoved, value.Identifier) 
				then
					readoutstringremoved = readoutstringremoved.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
				
				if --genes
					HF.TableContains(ScannerGenes, value.Identifier) 
				then
					readoutstringgenes = readoutstringgenes.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
				
				if --pressure
					HF.TableContains(ScannerPressure, value.Identifier) 
					and ((strength > 130) or (strength < 70)) 
				then 
					readoutstringphigh = readoutstringphigh.."\n"..value.Prefab.Name.Value..": "..strength.."%"
				
				elseif 
					HF.TableContains(ScannerPressure, value.Identifier) 
				then
					readoutstringplow = readoutstringplow.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
				
				afflictionsdisplayed = afflictionsdisplayed + 1
            
			end
        end

        -- add a message in case there is nothing to display
        if afflictionsdisplayed <= 0 then
            readoutstringlow = readoutstringlow.."\nNo afflictions! Good work!" 
        end

        Timer.Wait(function()
            HF.DMClient(
			
			HF.CharacterToClient(usingCharacter),
			  readoutstringstart --color values defined up there
			.."‖color:120,200,120‖"..readoutstringplow.."‖color:end‖"
			.."‖color:255,100,100‖"..readoutstringphigh.."‖color:end‖"
			.."‖color:100,200,100‖"..readoutstringlow.."‖color:end‖" 
			.."‖color:200,200,100‖"..readoutstringmid.."‖color:end‖"
			.."‖color:250,100,100‖"..readoutstringhigh.."‖color:end‖" 
			.."‖color:255,0,0‖"..readoutstringvital.."‖color:end‖" 
			.."‖color:0,255,255‖"..readoutstringremoved.."‖color:end‖" 
			.."‖color:180,50,200‖"..readoutstringgenes.."‖color:end‖"
			
					) 
		ScannerActive = 0
        end, 1000)
		
end 

--send info to server to play scanner sound
function NTEYE.PlayScannerSound(soundTarget)

	if ScannerActive==1 then
	
		local message = Networking.Start("PlayScannerSoundFail")

		message.WriteString(soundTarget.ID)

		Networking.Send(message)
	else
		local message = Networking.Start("PlayScannerSound")

		message.WriteString(soundTarget.ID)

		Networking.Send(message)
	end


end
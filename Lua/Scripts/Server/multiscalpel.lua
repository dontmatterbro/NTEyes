--compatibility for multiscalpel
local modeFunctions = modeFunctions
local originalMultiscalpel = NT.ItemMethods.multiscalpel
NT.ItemMethods.multiscalpel = function(item, usingCharacter, targetCharacter, limb)
	if originalMultiscalpel then
		originalMultiscalpel(item, usingCharacter, targetCharacter, limb)
	end
	-- Add the new mode function for "eye"
	if modeFunctions then
		modeFunctions.eye = NT.ItemMethods.it_scalpel_eye
	else
		-- Initialize modeFunctions if it doesn't exist
		modeFunctions = {
			eye = NT.ItemMethods.it_scalpel_eye,
		}
	end
end

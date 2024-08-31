function NTEYE.RobotraumaClientPatch(LevelLight)

	if 
		Character.Controlled ~= nil 
	then
		if 
			not (Character.Controlled.IsFemale or Character.Controlled.IsMale)
		then
			
			LevelLight.AmbientLightColor = Color(55, 55, 55, 55)
			
			for k, HullLight in pairs(Hull.HullList) do
				HullLight.AmbientLight = Color(65, 65, 65, 75) 
			end
			
		end
	end
end
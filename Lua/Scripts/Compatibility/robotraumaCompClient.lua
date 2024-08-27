function NTEYE.RobotraumaClientPatch()

	if 
		Character.Controlled ~= nil 
	then
		if 
			not (Character.Controlled.IsFemale or Character.Controlled.IsMale)
		then
		
			local parameters = Level.Loaded.LevelData.GenerationParams
			
			parameters.AmbientLightColor = Color(75, 75, 75, 100)
			
			for k, hull in pairs(Hull.HullList) do
				hull.AmbientLight = Color(65, 65, 65, 100) 
			end
		
		end
	end
end
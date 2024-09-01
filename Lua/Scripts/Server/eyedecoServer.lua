--[[
function doStuffEye(unknown)
  return unknown.SpeciesName
end

Hook.Add('eyeDecomposition', 'eyedeco', function(effect, dt, item, targets, worldpos)
  if not pcall(doStuffEye, item.ParentInventory.Owner) then
    -- its item
    if item.ParentInventory.Owner.identifier == "medicalfabricator" then
      return true
    end
  end
end)
--]]
--don't know what this does exactly, kept it anyway because https://www.youtube.com/shorts/4BxLoV3xXyM
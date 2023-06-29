local Conveyor = {}
Conveyor.__index = Conveyor

local Placeable = require(script.Parent.Placeable)

export type Conveyor = typeof(setmetatable({}, Conveyor)) & Placeable.Placeable

export type ConveyorInformation = {
	ConveyorSpeed: number
} & Placeable.PlaceableInformation

setmetatable(Conveyor, {__index = Placeable})
function Conveyor.new(ConveyorInformation: ConveyorInformation)
	local self = setmetatable(Placeable.new(ConveyorInformation), Conveyor)
	
	self.ConveyorSpeed = ConveyorInformation.ConveyorSpeed

	return self
end

function Conveyor:Place(player: Player, plot: Model, cf: CFrame) : (Conveyor?, Model?)
	local placeable, model = Placeable.Place(self, player, plot, cf)
	
	if not placeable then 
		return nil, nil 
	end

	for _, part in ipairs(model:GetDescendants()) do
		if part.Name == "Conv" then
			part.Velocity = part.CFrame.LookVector * self.ConveyorSpeed
		end
	end

	return placeable, model
end

return Conveyor
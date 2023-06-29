local Furnace = {}
Furnace.__index = Furnace

local Placeable = require(script.Parent.Placeable)

export type Furnace = typeof(setmetatable({}, Furnace)) & Placeable.Placeable

export type FurnaceInformation = {
	SellMultiplier: number,
	SellCallback: (BasePart, Player)->()
} & Placeable.PlaceableInformation

setmetatable(Furnace, {__index = Placeable})
function Furnace.new(placeableInformation: FurnaceInformation)
	local self = setmetatable(Placeable.new(placeableInformation), Furnace)

	self.SellMultiplier = placeableInformation.SellMultiplier
	self.SellCallback = placeableInformation.SellCallback
	
	return self
end

function Furnace:Place(player: Player, plot: Model, cf: CFrame) : (Furnace?, Model?)
	local placeable, model = Placeable.Place(self, player, plot, cf)
	
	if not placeable then 
		return nil, nil 
	end

	for _, part in ipairs(model:GetDescendants()) do
		if part.Name == "Lava" then
			part.Touched:Connect(function(hit)
				self:SellCallback(hit, player)
			end)
		end
	end

	return placeable, model
end


return Furnace
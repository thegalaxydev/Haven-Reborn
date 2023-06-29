local Dropper = {}
Dropper.__index = Dropper

local Placeable = require(script.Parent.Placeable)

export type Dropper = typeof(setmetatable({}, Dropper)) & Placeable.Placeable

export type DropperInformation = {
	DropRate: number,
	DropSize: number,
	DropWorth: number,
	DropCallback: (BasePart, Player, number, number, number)->()
} & Placeable.PlaceableInformation


setmetatable(Dropper, {__index = Placeable})
function Dropper.new(dropperInformation: DropperInformation)
	local self = setmetatable(Placeable.new(dropperInformation), Dropper)

	self.DropRate = dropperInformation.DropRate
	self.DropSize = dropperInformation.DropSize
	self.DropWorth = dropperInformation.DropWorth

	self.DropCallback = dropperInformation.DropCallback

	return self
end

function Dropper:Place(player: Player, plot: Model, cf: CFrame) : (Dropper?, Model?)
	local placeable, model = Placeable.Place(self, player, plot, cf)
	
	if not placeable then 
		return nil, nil 
	end

	for _, part in ipairs(model:GetDescendants()) do
		if part.Name == "Drop" then
			self:DropCallback(part, player)
		end
	end

	return placeable, model
end

return Dropper
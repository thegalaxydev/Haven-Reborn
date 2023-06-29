local Upgrader = {}
Upgrader.__index = Upgrader

local Conveyor = require(script.Parent.Conveyor)

export type Upgrader = typeof(setmetatable({}, Upgrader)) & Conveyor.Conveyor

export type UpgraderInformation = {
	UpgradeCallback: (BasePart, Player)->()
} & Conveyor.ConveyorInformation

setmetatable(Upgrader, {__index = Conveyor})
function Upgrader.new(placeableInformation: UpgraderInformation)
	local self = setmetatable(Conveyor.new(placeableInformation), Upgrader)

	self.UpgradeCallback = placeableInformation.UpgradeCallback

	return self
end

function Upgrader:Place(player: Player, plot: Model, cf: CFrame) : (Upgrader?, Model?)
	local placeable, model = Conveyor.Place(self, player, plot, cf)
	
	if not placeable then 
		return nil, nil 
	end

	for _, part in ipairs(model:GetDescendants()) do
		if part.Name == "Upgrade" then

			part.Touched:Connect(function(hit)
				self:UpgradeCallback(model, hit, player)
			end)

		end
	end

	return placeable, model
end

return Upgrader
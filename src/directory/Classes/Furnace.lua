local Furnace = {}
Furnace.__index = Furnace

local Placeable = require(script.Parent.Placeable)

export type Furnace = typeof(setmetatable({}, Furnace)) & Placeable.Placeable


function Furnace.new(name:string, model: Model)
	local self = setmetatable(Placeable.new(name, model), Furnace)


	return self
end

return Furnace
local Dropper = {}
Dropper.__index = Dropper

local Placeable = require(script.Parent.Placeable)

export type Dropper = typeof(setmetatable({}, Dropper)) & Placeable.Placeable

function Dropper.new(name:string, model: Model)
	local self = setmetatable(Placeable.new(name, model), Dropper)


	return self
end

return Dropper
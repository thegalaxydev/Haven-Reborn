local Upgrader = {}
Upgrader.__index = Upgrader

local Placeable = require(script.Parent.Placeable)

export type Upgrader = typeof(setmetatable({}, Upgrader)) & Placeable.Placeable

function Upgrader.new(name:string, model: Model)
	local self = setmetatable(Placeable.new(name, model), Upgrader)


	return self
end

return Upgrader
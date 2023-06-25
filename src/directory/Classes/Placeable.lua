local Placeable = {}
Placeable.__index = Placeable

export type Placeable = typeof(setmetatable({}, Placeable))

-- A placeable is any object that can be placed in the gridspace.
function Placeable.new(name: string, model: Model)
	local self = setmetatable({}, Placeable)

	self.Model = model
	self.Name = name

	self.Owner = nil
	
	return self
end

function isColliding(part1: BasePart, position: Vector3, size: Vector3)
	return part1.Position.X < position.X + size.X and
		part1.Position.X + part1.Size.X > position.X and
		part1.Position.Z < position.Z + size.Z and
		part1.Size.Z + part1.Position.Z > position.Z
end

function Placeable:Place(player: Player, plot: Model, gridPosition: Vector2, gridRotation: number) : (Placeable?, Model?)
	local items = plot:FindFirstChild("Items")
	local base = plot:FindFirstChild("Base")

	if gridPosition.X < 0 then
		gridPosition = Vector2.new(0, gridPosition.Y)
	end

	if gridPosition.Y < 0 then
		gridPosition = Vector2.new(gridPosition.X, 0)
	end

	if gridPosition.X > base.Size.X / 3 then
		gridPosition = Vector2.new(base.Size.X / 3, gridPosition.Y)
	end

	if gridPosition.Y > base.Size.Z / 3 then
		gridPosition = Vector2.new(gridPosition.X, base.Size.Z / 3)
	end
	
	local hitbox = self.Model:FindFirstChild("Hitbox")

	local posX = base.Position.X + (gridPosition.X * 3) - (base.Size.X / 2) + (hitbox.Size.X / 2)
	local posY = base.Position.Y + (hitbox.Size.Y / 2)
	local posZ = base.Position.Z + (gridPosition.Y * 3) - (base.Size.Z / 2) + (hitbox.Size.Z / 2)


	for _, child in pairs(items:GetChildren()) do
		if isColliding(child.Hitbox, Vector3.new(posX, posY, posZ), hitbox.Size) then
			return
		end
	end

	local newModel = self.Model:Clone()
	newModel.Parent = items

	local newPlaceable = Placeable.new(self.Name, newModel)

	newPlaceable.Owner = player
	
	newModel:PivotTo(CFrame.new(Vector3.new(posX, posY, posZ)) * CFrame.Angles(0, math.rad(gridRotation * 90), 0))

	return newPlaceable, newModel
end

return Placeable
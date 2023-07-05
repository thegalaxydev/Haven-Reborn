local Placeable = {}
Placeable.__index = Placeable

export type Placeable = typeof(setmetatable({}, Placeable))

export type PlaceableInformation = {
	Name: string,
	Model: Model,
	ID: number,
	Image: string,
	Description: string,
	Tier: number,
	Cost: number | string,
	SellPrice: number | string,
	ShopCategory: string?,
}

-- A placeable is any object that can be placed in the gridspace.
function Placeable.new(placeableInformation: PlaceableInformation)
	local self = setmetatable({}, Placeable)

	self.Name = placeableInformation.Name
	self.Model = placeableInformation.Model
	self.ID = placeableInformation.ID
	self.Image = placeableInformation.Image or ""
	self.Description = placeableInformation.Description or ""
	self.Tier = placeableInformation.Tier or 1
	self.Cost = placeableInformation.Cost or 0
	self.SellPrice = placeableInformation.SellPrice or 0
	self.ShopCategory = placeableInformation.ShopCategory
	
	self.Owner = nil

	return self
end

function Placeable:Clone()
	return Placeable.new({
		Name = self.Name, 
		Model = self.Model:Clone(),
		ID = self.ID,
		Image = self.Image,
		Description = self.Description,
		Tier = self.Tier,
		Cost = self.Cost,
		SellPrice = self.SellPrice
	})
end

function Placeable:IsColliding()
	local isColliding = false

	local primaryPart = self.Model.PrimaryPart or self.Model:FindFirstChild("Hitbox")

	local touch = primaryPart.Touched:Connect(function() end)
	local touching = primaryPart:GetTouchingParts()
	
	for i = 1, #touching do
		if (not touching[i]:IsDescendantOf(self.Model) and touching[i].Name == "Hitbox") then
			isColliding = true
			break
		end
	end

	-- cleanup and return
	touch:Disconnect()
	return isColliding
end

function Placeable:Place(player: Player, plot: Model, cf: CFrame) : (Placeable?, Model?)
	local items = plot:FindFirstChild("Items")
	local base = plot:FindFirstChild("Base")

	if plot:GetAttribute("Owner") ~= player.UserId then
		return nil, nil
	end

	local newPlaceable = self:Clone()
	newPlaceable.Model.Parent = items

	newPlaceable.Owner = player
	
	newPlaceable.Model:PivotTo(cf)

	if self:IsColliding() then
		newPlaceable.Model:Destroy()
		return nil, nil
	end

	return newPlaceable, newPlaceable.Model
end

return Placeable
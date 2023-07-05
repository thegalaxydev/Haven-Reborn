local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Directory = require(ReplicatedStorage.Directory)
local Placeable = Directory.Retrieve("Classes/Placeable")

local Storage = ReplicatedStorage:FindFirstChild("ModelStorage")
local Model = Storage:FindFirstChild(script.Name)

local TestPlaceable = Placeable.new{
	Name = "Test", 
	Model = Model,
	ID = 1,
	Image = "rbxassetid://0",
	Description = "This is a test item.",
	Tier = 1,
	Cost = 0,
	ShopCategory = "Misc",
	SellPrice = 0
}

return TestPlaceable

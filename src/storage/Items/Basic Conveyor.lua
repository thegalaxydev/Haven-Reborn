local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Directory = require(ReplicatedStorage.Directory)
local Conveyor = Directory.Retrieve("Classes/Conveyor")

local Storage = ReplicatedStorage:FindFirstChild("ModelStorage")
local Model = Storage:FindFirstChild("Basic Conveyor")

return Conveyor.new{
	Name = "Basic Conveyor", 
	Model = Model,
	ID = 2,
	Image = "rbxassetid://1611321834",
	Description = "Basic Conveyor Test",
	Tier = 2,
	Cost = 100,
	ConveyorSpeed = 25,
	SellPrice = 50
}

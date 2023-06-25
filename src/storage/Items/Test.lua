local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Directory = require(ReplicatedStorage.Directory)
local Placeable = Directory.Retrieve("Classes/Placeable")

local Storage = ReplicatedStorage:FindFirstChild("ModelStorage")
local Model = Storage:FindFirstChild(script.Name)

local TestPlaceable = Placeable.new("Test", Model)

return TestPlaceable

local ItemDirectory = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Storage = ReplicatedStorage:FindFirstChild("Storage")
local Items = Storage:FindFirstChild("Items")

for _, item in ipairs(Items:GetChildren()) do
	local itemModule = require(item)
	ItemDirectory[itemModule.ID] = itemModule
end

return ItemDirectory
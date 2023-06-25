local Services = script.Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Directory = require(ReplicatedStorage:FindFirstChild("Directory"))

local DataService = require(Services.DataService)
local BigNumber = Directory.Retrieve("Classes/BigNumber")

local ChatService = Directory.Retrieve("Services/ChatService")

local PlayerService = require(Services.PlayerService)


game.Players.PlayerAdded:Connect(PlayerService.PlayerAdded)
game.Players.PlayerRemoving:Connect(PlayerService.PlayerRemoving)

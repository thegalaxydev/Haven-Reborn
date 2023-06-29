local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Directory = require(ReplicatedStorage:FindFirstChild("Directory"))

local ChatService = Directory.Retrieve("Services/ChatService")
local UIService = require(script.Services.UIService)

local ControlService = require(script.Services.ControlService)
ControlService.InitializeKeybinds()
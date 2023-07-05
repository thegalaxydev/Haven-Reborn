local ChatService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Directory = require(ReplicatedStorage:FindFirstChild("Directory"))

local ChatMessage = require(script.Parent.Parent.Classes.ChatMessage)
type ChatMessage = ChatMessage.ChatMessage


if RunService:IsServer() then
	require(script.Server)
end

local UIHolder = ReplicatedStorage:WaitForChild("UIHolder")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local ClientReplicator = Remotes:WaitForChild("ClientReplicator")
local ServerReplicator = Remotes:WaitForChild("ServerReplicator")

function ChatService.SendMessage(msg: ChatMessage, recipients: {Player})
	if RunService:IsServer() then
		for _ , player in pairs(recipients) do
			local filteredText
			local success, result = pcall(function()
				filteredText = TextService:FilterStringAsync(msg.Message, player.UserId)
			end)

			if not success then
				warn("Error filtering message: " .. result)
				msg.Message = ""
			else
				msg.Message = filteredText:GetNonChatStringForBroadcastAsync()
			end

			ClientReplicator:FireClient(player, "ReceiveMessage", msg)
		end
	else
		ServerReplicator:InvokeServer("SendMessage", msg, recipients)
	end
end

function ChatService.SendMessageString(str: string, recipients: {Player})
	local msg = ChatMessage.new(str)

	ChatService.SendMessage(msg, recipients)
end









return ChatService
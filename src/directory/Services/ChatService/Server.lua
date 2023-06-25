local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Directory = require(ReplicatedStorage:FindFirstChild("Directory"))

local ChatMessage = Directory.Retrieve("Classes/ChatMessage")
local Remotes = Instance.new("Folder")
Remotes.Name = "Remotes"
Remotes.Parent = ReplicatedStorage

local ServerReplicator = Instance.new("RemoteFunction")
ServerReplicator.Name = "ServerReplicator"
ServerReplicator.Parent = Remotes

local ClientReplicator = Instance.new("RemoteEvent")
ClientReplicator.Name = "ClientReplicator"
ClientReplicator.Parent = Remotes

local CommandService = Directory.Retrieve("Services/CommandService")
local NameColorService = Directory.Retrieve("Services/NameColorService")

local ServerScriptService = game:GetService("ServerScriptService")

local PlayerService = require(ServerScriptService.Galaxy_Server.Services.PlayerService)

local UIHolder = Instance.new("Folder")
UIHolder.Name = "UIHolder"
UIHolder.Parent = ReplicatedStorage

local Chat = Instance.new("ScreenGui")
local Holder = Instance.new("Frame")
local ChatGui = Instance.new("ScrollingFrame")
local ChatPadding = Instance.new("UIPadding")
local ChatCorners = Instance.new("UICorner")
local BoxHolder = Instance.new("Frame")
local TextBox = Instance.new("TextBox")
local TextBoxPadding = Instance.new("UIPadding")
local BoxCorners = Instance.new("UICorner")
local Send = Instance.new("TextButton")
local BoxHolderPadding = Instance.new("UIPadding")
local BoxListLayout = Instance.new("UIListLayout")
local ChatListLayout = Instance.new("UIListLayout")

local GuiService = game:GetService("GuiService")


Chat.Name = "Chat"
Chat.IgnoreGuiInset = true
Chat.Parent = UIHolder
Chat.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if GuiService:IsTenFootInterface() then
	Chat.Enabled = false
end

Holder.Name = "Holder"
Holder.Parent = Chat
Holder.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
Holder.BackgroundTransparency = 0.699999988079071
Holder.Position = UDim2.new(0,15,0, 40)
Holder.Size = UDim2.new(0.25, 0, 0.363000005, 0)

ChatGui.Name = "ChatGui"
ChatGui.Parent = Holder
ChatGui.Active = true
ChatGui.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatGui.CanvasPosition = Vector2.new(0, ChatGui.CanvasSize.Y.Offset)
ChatGui.AutomaticCanvasSize = Enum.AutomaticSize.Y
ChatGui.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
ChatGui.BackgroundTransparency = 1
ChatGui.BorderColor3 = Color3.new(0.156863, 0.156863, 0.156863)
ChatGui.BorderSizePixel = 0
ChatGui.Size = UDim2.new(1, 0, 1, 0)

ChatListLayout.Parent = ChatGui
ChatListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ChatListLayout.Padding = UDim.new(0, 5)
ChatListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

ChatPadding.Parent = ChatGui
ChatPadding.PaddingLeft = UDim.new(0.0199999996, 0)
ChatPadding.PaddingRight = UDim.new(0.0199999996, 0)

ChatCorners.Parent = Holder

local ChatMessageTemplate = Instance.new("TextLabel")
ChatMessageTemplate.Name = "ChatMessageTemplate"
ChatMessageTemplate.BackgroundColor3 = Color3.new(1, 1, 1)
ChatMessageTemplate.BackgroundTransparency = 1
ChatMessageTemplate.Size = UDim2.new(1,0, 0,15)
ChatMessageTemplate.Font = Enum.Font.SourceSansBold
ChatMessageTemplate.TextColor3 = Color3.new(1, 1, 1)
ChatMessageTemplate.TextScaled = false
ChatMessageTemplate.TextWrapped = true
ChatMessageTemplate.TextSize = 14
ChatMessageTemplate.TextStrokeTransparency = 0.5
ChatMessageTemplate.TextWrapped = true
ChatMessageTemplate.TextXAlignment = Enum.TextXAlignment.Left
ChatMessageTemplate.TextYAlignment = Enum.TextYAlignment.Top
ChatMessageTemplate.RichText = true
ChatMessageTemplate.Parent = UIHolder

BoxHolder.Name = "BoxHolder"
BoxHolder.Parent = Holder
BoxHolder.AnchorPoint = Vector2.new(0.5, 0)
BoxHolder.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
BoxHolder.BackgroundTransparency = 0.6000000238418579
BoxHolder.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
BoxHolder.Position = UDim2.new(0.5, 0, 1.01, 0)
BoxHolder.Size = UDim2.new(0.949999988, 0, 0.135000005, 0)

TextBox.Parent = BoxHolder
TextBox.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
TextBox.BackgroundTransparency = 1
TextBox.BorderSizePixel = 0
TextBox.Size = UDim2.new(0.9, 0, 1, 0)
TextBox.Font = Enum.Font.SourceSansBold
TextBox.Text = ""
TextBox.RichText = true
TextBox.TextColor3 = Color3.new(1, 1, 1)
TextBox.TextSize = 14
TextBox.TextWrapped = true
TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.ClearTextOnFocus = false

local HighlightLabel = Instance.new("TextLabel")
HighlightLabel.Name = "HighlightLabel"
HighlightLabel.BackgroundTransparency = 1
HighlightLabel.Size = UDim2.new(1,0,1,0)
HighlightLabel.Parent = TextBox
HighlightLabel.RichText = true
HighlightLabel.TextColor3 = Color3.new(1, 1, 1)
HighlightLabel.TextSize = 14
HighlightLabel.Text = ""
HighlightLabel.TextWrapped = true
HighlightLabel.TextStrokeTransparency = 0.5
HighlightLabel.TextXAlignment = Enum.TextXAlignment.Left
HighlightLabel.Font = Enum.Font.SourceSansBold

TextBoxPadding.Parent = TextBox
TextBoxPadding.PaddingLeft = UDim.new(0.0199999996, 0)
TextBoxPadding.PaddingRight = UDim.new(0.0199999996, 0)

BoxCorners.Parent = BoxHolder

Send.Parent = BoxHolder
Send.Name = "Send"
Send.AnchorPoint = Vector2.new(1, 0.5)
Send.BackgroundColor3 = Color3.new(1, 1, 1)
Send.BackgroundTransparency = 1
Send.Position = UDim2.new(1, 0, 0.5, 0)
Send.Size = UDim2.new(0.1, 0, 0.9, 0)
Send.Font = Enum.Font.SourceSansBold
Send.Text = "[SEND]"
Send.TextStrokeTransparency = 0
Send.TextColor3 = Color3.new(0.372549, 0.756863, 0.266667)
Send.TextSize = 14

BoxHolderPadding.Parent = BoxHolder
BoxHolderPadding.PaddingLeft = UDim.new(0.0199999996, 0)
BoxHolderPadding.PaddingRight = UDim.new(0.0299999993, 0)

BoxListLayout.Parent = BoxHolder
BoxListLayout.FillDirection = Enum.FillDirection.Horizontal
BoxListLayout.SortOrder = Enum.SortOrder.LayoutOrder
BoxListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local ReplicationFunctions = {
	["SendMessage"] = function(player: Player, message: string, recipient: Player?)
		if message == "" then return end
		 
		local messageObject = ChatMessage.new(message)
		messageObject:AddSender(player, NameColorService.GetNameColor(player))

		messageObject.Prefixes = PlayerService.GetPrefixesForPlayer(player)

		if recipient then
			local success, result = pcall(function()
				return TextService:FilterStringAsync(message, player.UserId)
			end)

			if not success then
				warn("Error filtering message: " .. result)
				messageObject.Message = ""
			else
				messageObject.Message = result:GetChatForUserAsync(recipient.UserId)
			end


			messageObject.Message = result:GetChatForUserAsync(recipient.UserId)

		
			ClientReplicator:FireClient(recipient, "ReceiveMessage", messageObject)
		else
			for _, recipient in pairs(game.Players:getPlayers()) do
				local filteredMessage = ""
				local success, result = pcall(function()
					filteredMessage = TextService:FilterStringAsync(message, player.UserId):GetChatForUserAsync(recipient.UserId)
				end)
	
				if not success then
					warn("Error filtering message: " .. result)
				else
					messageObject.Message = filteredMessage
				end
				
				print(message)
				ClientReplicator:FireClient(recipient, "ReceiveMessage", messageObject)
			end
			
		end
	end,

	["GetCommands"] = function(player: Player)
		local cmds = {}
	
		for command, _ in pairs(CommandService.Commands) do
			table.insert(cmds, command)
		end

		return cmds
	end,

	["ExecuteCommand"] = function(player: Player, command: string, args: {any})
		CommandService.ExecuteCommand(player, command, args)
	end
}

ServerReplicator.OnServerInvoke = function(player: Player, func: string, ...)
	if ReplicationFunctions[func] then
		return ReplicationFunctions[func](player, ...)
	end
	
	return nil
end

return true
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

local Directory = require(ReplicatedStorage:FindFirstChild("Directory"))

local ChatMessage = require(script.Parent.Parent.Parent.Classes.ChatMessage)
type ChatMessage = ChatMessage.ChatMessage

local CommandService = Directory.Retrieve("Services/CommandService")

local TextService = game:GetService("TextService")
local ContextActionService = game:GetService("ContextActionService")
local Replicator = Remotes:WaitForChild("ClientReplicator")
local ServerReplicator = Remotes:WaitForChild("ServerReplicator")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local UserInputService = game:GetService("UserInputService")

local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer

local UIHolder = ReplicatedStorage:WaitForChild("UIHolder")

local PlayerGui = Player:WaitForChild("PlayerGui")

local Chat = UIHolder:WaitForChild("Chat"):Clone()
Chat.Parent = PlayerGui


local Holder = Chat.Holder
local BoxHolder = Holder.BoxHolder
local ChatGui:ScrollingFrame = Holder.ChatGui
local TextBox:TextBox = BoxHolder.TextBox
local Send:TextButton = BoxHolder.Send
local HighlightLabel : TextLabel = TextBox:FindFirstChild("HighlightLabel") :: TextLabel

local function splitString(inputString: string)
    local arguments = {}
    local currentArgument = ""
    local isInQuotes = false
    
    for i = 1, #inputString do
        local char = inputString:sub(i, i)
        
        if char == " " and not isInQuotes then
            table.insert(arguments, currentArgument)
            currentArgument = ""
        elseif char == "\"" then
            isInQuotes = not isInQuotes
        else
            currentArgument = currentArgument .. char
        end
    end
    
    table.insert(arguments, currentArgument)
    
    return arguments
end

TextBox.PlaceholderText = "To chat press here or press \"/\" key."
TextBox.RichText = true
BoxHolder.Size = UDim2.new(1,0, 0, TextBox.TextBounds.Y + 20)

CommandService.Commands = ServerReplicator:InvokeServer("GetCommands")

function escapeText(str: string) : string
	return str:gsub("[<>\"'&]",{
		["<"] = "&lt;",
		[">"] = "&gt;",
		["\""] = "&quot;",
		["'"] = "&apos;",
		["&"] = "&amp;"
	})
end

TextBox:GetPropertyChangedSignal("Text"):Connect(function()
	BoxHolder.Size = UDim2.new(1,0, 0, TextBox.TextBounds.Y + 20)

	TextBox.Text = TextBox.Text:sub(1, 350)
	HighlightLabel.Text = escapeText(TextBox.Text)

	local args = splitString(TextBox.Text)

	if table.find(CommandService.Commands, args[1]) then
		local command = `<font color="rgb(66, 165, 222)">{args[1]}</font>`
		HighlightLabel.Text = string.gsub(HighlightLabel.Text, args[1], command, 1)
	end
end)

function formatMessage(message: ChatMessage) : string
	local prefixes = message.Prefixes
	local suffixes = message.Suffixes
	local senderSuffixes = message.SenderSuffixes

	local messageText = message.Message
	local messageColor = message.Color
	local messageSender = ""

	if message.Sender then
		local senderColor = message.Sender[2]
		local senderName = message.Sender[1].Name

		messageSender = `<font color="rgb({math.round(senderColor.R * 255)}, {math.round(senderColor.G*255)}, {math.round(senderColor.B*255)})">{senderName}</font>`
	end

	local messagePrefix = ""

	for _, prefix in ipairs(prefixes) do
		local text = prefix[1]
		local color = prefix[2]

		messagePrefix = messagePrefix .. `<font color="rgb({math.round(color.R * 255)}, {math.round(color.G * 255)}, {math.round(color.B * 255)})">{text}</font>`
	end

	local messageSuffix = ""

	for _, suffix in ipairs(suffixes) do
		local text = suffix[1]
		local color = suffix[2]

		messageSuffix = messageSuffix .. `<font color="rgb({math.round(color.R * 255)}, {math.round(color.G * 255)}, {math.round(color.B * 255)})">{text}</font>`
	end

	local senderSuffix = ""

	for _, suffix in ipairs(senderSuffixes) do
		local text = suffix[1]
		local color = suffix[2]

		senderSuffix = senderSuffix .. `<font color="rgb({math.round(color.R * 255)}, {math.round(color.G * 255)}, {math.round(color.B * 255)})">{text}</font>`
	end

	local finalMessage = `<font color="rgb({math.round(messageColor.R * 255)}, {math.round(messageColor.G * 255)}, `..
		`{math.round(messageColor.B * 255)})">{escapeText(messageText)}</font>`

	local final = messagePrefix .. finalMessage.. messageSuffix

	if messageSender ~= "" then
		final = messagePrefix .. messageSender .. ": " .. finalMessage .. messageSuffix
	end

	if senderSuffix ~= "" then
		final = messagePrefix .. messageSender .. senderSuffix .. ": " .. finalMessage .. messageSuffix
	end
	

	return final
end
local ReplicationFunctions = {
	["ReceiveMessage"] = function(message : ChatMessage)
		local chatMessage : TextLabel = UIHolder.ChatMessageTemplate:Clone()
		chatMessage.Text = formatMessage(message)
		chatMessage.Parent = ChatGui

		if not chatMessage.TextFits then
			chatMessage.Size = UDim2.new(1, 0, 0, chatMessage.TextBounds.Y)
		end

		if message.Sender then
			chatMessage.Name = message.Sender[1].UserId.."-"..HttpService:GenerateGUID()
			local senderName = message.Sender[1].Name
			local prefix = ""
			for _, prefixInfo in ipairs(message.Prefixes) do
				prefix = prefix..prefixInfo[1]
			end

			local messageSender = Instance.new("TextButton")
			messageSender.Parent = chatMessage
			messageSender.Text = prefix..senderName
			messageSender.TextTransparency = 1
			messageSender.BackgroundTransparency = 1
			messageSender.Size = UDim2.new(0, messageSender.TextBounds.X, 0, messageSender.TextBounds.Y)
			messageSender.Position = UDim2.new(0, 0, 0, 0)

			if #ChatGui:GetChildren() > 25 then
				local oldestMessage = ChatGui:GetChildren()[2]
				if oldestMessage then
					oldestMessage:Destroy()
				end
			end

			messageSender.MouseButton1Click:Connect(function()
				TextBox.Text = `/w {senderName} `
				TextBox:CaptureFocus()
				TextBox.CursorPosition = string.len(TextBox.Text) + 1
			end)	
			ChatGui.CanvasPosition = Vector2.new(0, ChatGui.AbsoluteCanvasSize.Y)
		end
	end,

	["ShowItem"] = function(message : ChatMessage, itemName: string)
		local chatMessage : TextLabel = UIHolder.ChatMessageTemplate:Clone()
		
		if message.Sender then
			chatMessage.Name = message.Sender[1].UserId.."-"..HttpService:GenerateGUID()
		end

		chatMessage.Text = formatMessage(message)
		chatMessage.Parent = ChatGui

		if not chatMessage.TextFits then
			chatMessage.Size = UDim2.new(1, 0, 0, chatMessage.TextBounds.Y)
		end

		local itemInfo = Instance.new("TextLabel")
		itemInfo.Parent = chatMessage
		itemInfo.Text = itemName
		itemInfo.TextTransparency = 1
		itemInfo.BackgroundTransparency = 1
		itemInfo.Size = UDim2.new(0, itemInfo.TextBounds.X, 0, itemInfo.TextBounds.Y)
		itemInfo.Position = UDim2.new(0,chatMessage.TextBounds.X-itemInfo.TextBounds.X, 0, 0)

		
		local showFrame = Instance.new("Frame")
		showFrame.Parent = Chat
		showFrame.Size = UDim2.new(0, 200, 0, 100)
		showFrame.Position = UDim2.new(0,itemInfo.AbsolutePosition.X,0,itemInfo.AbsolutePosition.Y + 15)
		showFrame.Visible = false

		ChatGui.CanvasPosition = Vector2.new(0, ChatGui.AbsoluteCanvasSize.Y)

		if #ChatGui:GetChildren() > 25 then
			local oldestMessage = ChatGui:GetChildren()[2]
			if oldestMessage then
				oldestMessage:Destroy()
			end
		end

		itemInfo.MouseEnter:Connect(function()
			showFrame.Visible = true
		end)		
		itemInfo.MouseLeave:Connect(function()
			showFrame.Visible = false
		end)
	end,

	["ClearChat"] = function()
		for _, chatMsg in  pairs(ChatGui:GetChildren()) do
			if chatMsg:IsA("TextLabel") then
				chatMsg:Destroy()
			end
		end
	end
}

Replicator.OnClientEvent:Connect(function(func: string, ...)
	if ReplicationFunctions[func] then
		ReplicationFunctions[func](...)
	end
	
	return nil
end)

function sendChat()
	if TextBox.Text == "" then
		return
	end

	local split = splitString(TextBox.Text)
	local command = split[1]
	local args = {}
	for i = 2, #split do
		args[i-1] = split[i]
	end
	 if table.find(CommandService.Commands, command) then
		ServerReplicator:InvokeServer("ExecuteCommand", command, args)

		TextBox.Text = ""


		return
	end

	ServerReplicator:InvokeServer("SendMessage", TextBox.Text)
	TextBox.Text = ""	
end

TextBox.FocusLost:Connect(function(enterPressed: boolean)
	if enterPressed then
		sendChat()
	end
end)

Send.MouseButton1Click:Connect(function()
	sendChat()
end)

ContextActionService:BindAction("FocusTextBox", function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
	if inputState == Enum.UserInputState.End then
		TextBox:CaptureFocus()
		TextBox.Text = ""
	end
end, false, Enum.KeyCode.Slash)

local fadeTimer = 0
local shouldFade = false

local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
local BoxFade = TweenService:Create(BoxHolder, tweenInfo, {BackgroundTransparency = 1})
local HolderFade = TweenService:Create(Holder, tweenInfo, {BackgroundTransparency = 1})
local SendFade = TweenService:Create(Send, tweenInfo, {TextTransparency = 1})
local TextBoxFade = TweenService:Create(TextBox, tweenInfo, {TextTransparency = 1})

function IsInBox(box: GuiObject)
	local MouseLocation = UserInputService:GetMouseLocation()
	local tx = box.AbsolutePosition.X
    local ty = box.AbsolutePosition.Y
    local bx = tx + box.AbsoluteSize.X
    local by = ty + box.AbsoluteSize.Y

    return MouseLocation.X >= tx and MouseLocation.Y >= ty and MouseLocation.X <= bx and MouseLocation.Y <= by
end

function fadeChat(shouldFade: boolean)
	if shouldFade then
		BoxFade:Play()
		HolderFade:Play()
		SendFade:Play()
		TextBoxFade:Play()
	else
		BoxFade:Cancel()
		HolderFade:Cancel()
		SendFade:Cancel()
		TextBoxFade:Cancel()
		BoxHolder.BackgroundTransparency = 0.5
		Holder.BackgroundTransparency = 0.5
		Send.TextTransparency = 0
		TextBox.TextTransparency = 0
	end
end

RunService:BindToRenderStep("ChatSleep", 1, function(dt: number)
	if not IsInBox(BoxHolder) and not IsInBox(Holder) and not TextBox:IsFocused() and not IsInBox(HighlightLabel) then
		fadeTimer += dt

		if fadeTimer >= 5 then
			fadeTimer = 0
			fadeChat(true)
		end

	else
		fadeTimer = 0
		fadeChat(false)
	end	
end)



return true
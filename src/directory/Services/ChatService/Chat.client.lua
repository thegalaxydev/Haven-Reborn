local ReplicatedStorage = game:GetService("ReplicatedStorage")
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

local Directory = require(ReplicatedStorage:FindFirstChild("Directory"))

local ChatMessage = require(ReplicatedStorage.Directory.Classes.ChatMessage)
type ChatMessage = ChatMessage.ChatMessage

local CommandService = Directory.Retrieve("Services/CommandService")

local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local NetworkService = Directory.Retrieve("Services/NetworkService")

local UserInputService = game:GetService("UserInputService")

local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer
local GuiService = game:GetService("GuiService")

local UIHolder = ReplicatedStorage:WaitForChild("UIHolder")

local PlayerGui = Player:WaitForChild("PlayerGui")

local Chat = script.Parent

if GuiService:IsTenFootInterface() then
	Chat.Visible = false
end

local function getScale()
	local viewportSize = workspace.CurrentCamera.ViewportSize

	return math.min(1- ((1-math.min((viewportSize.X * (viewportSize.X / viewportSize.Y)) / 1920, viewportSize.Y / 1080)) * 0.5), 1)
end

local Holder = Chat.Holder
local ChatToggle = Chat.ChatToggle
local BoxHolder = Holder.BoxHolder
local ChatGui:ScrollingFrame = Holder.ChatGui
local TextBox:TextBox = BoxHolder.TextBox
local Send:ImageButton = BoxHolder.Send
local HighlightLabel : TextLabel = TextBox:FindFirstChild("HighlightLabel") :: TextLabel

ChatToggle.Button.MouseButton1Click:Connect(function()
	Holder.Visible = not Holder.Visible
end)

Player.CharacterAdded:Connect(function()
	Chat = PlayerGui:WaitForChild("Chat")
	Holder = Chat.Holder
	BoxHolder = Chat.Holder.BoxHolder
	ChatGui = Chat.Holder.ChatGui
	TextBox = Chat.Holder.BoxHolder.TextBox
	Send = Chat.Holder.BoxHolder.Send
	HighlightLabel = Chat.Holder.BoxHolder.TextBox:FindFirstChild("HighlightLabel") :: TextLabel	
end)

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
BoxHolder.Size = UDim2.new(0, BoxHolder.Size.X.Offset, 0, TextBox.TextBounds.Y + (10 / getScale()))

CommandService.Commands = NetworkService.Fire("GetCommands")

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

	TextBox.Text = TextBox.Text:sub(1, 350)
	HighlightLabel.Text = escapeText(TextBox.Text)

	if not TextBox.TextFits then
		BoxHolder.Size = UDim2.new(0, BoxHolder.Size.X.Offset, 0, TextBox.TextBounds.Y + (10 / getScale()))
	end


	local args = splitString(TextBox.Text)

	if table.find(CommandService.Commands, args[1]) then
		local command = `<font color="rgb(66, 165, 222)">{args[1]}</font>`
		HighlightLabel.Text = string.gsub(HighlightLabel.Text, args[1], command, 1)
	end
end)

function formatName(message: ChatMessage) : string
	local prefixes = message.Prefixes
	local senderSuffixes = message.SenderSuffixes
	
	local messageSender = ""

	if message.Sender then
		print (message.Sender)
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

	local senderSuffix = ""

	for _, suffix in ipairs(senderSuffixes) do
		local text = suffix[1]
		local color = suffix[2]

		senderSuffix = senderSuffix .. `<font color="rgb({math.round(color.R * 255)}, {math.round(color.G * 255)}, {math.round(color.B * 255)})">{text}</font>`
	end

	local final = messagePrefix .. messageSender .. senderSuffix

	return final
end

function formatMessage(message: ChatMessage) : string
	local suffixes = message.Suffixes

	local messageText = message.Message
	local messageColor = message.Color

	local messageSuffix = ""

	for _, suffix in ipairs(suffixes) do
		local text = suffix[1]
		local color = suffix[2]

		messageSuffix = messageSuffix .. `<font color="rgb({math.round(color.R * 255)}, {math.round(color.G * 255)}, {math.round(color.B * 255)})">{text}</font>`
	end

	local finalMessage = `<font color="rgb({math.round(messageColor.R * 255)}, {math.round(messageColor.G * 255)}, `..
		`{math.round(messageColor.B * 255)})">{escapeText(messageText)}</font>`

	local final = finalMessage.. messageSuffix
	
	return final
end

ChatGui.ChildAdded:Connect(function()
	local YSize = 0
	for _, child in ipairs(ChatGui:GetChildren()) do
		if not child:IsA("GuiObject") then continue end
		YSize += child.Size.Y.Offset + 5
	end

	ChatGui.CanvasSize = UDim2.new(0, 0, 0, YSize + 50)
end)

function createChatText(message)
	local chatMessage = UIHolder.ChatMessageTemplate:Clone()
	chatMessage.ChatMessage.Text = ""
	chatMessage.PlayerName.Text = formatName(message)
	chatMessage.Parent = ChatGui

	chatMessage.ChatMessage.Size = UDim2.new(1, 0, 0, chatMessage.ChatMessage.TextBounds.Y + (20 / getScale()))
	chatMessage.Size = UDim2.new(1, 0, 0, chatMessage.ChatMessage.Size.Y.Offset + chatMessage.PlayerName.TextBounds.Y + (20 / getScale()))

	return chatMessage
end

local ReplicationFunctions = {
	["ReceiveMessage"] = function(message : ChatMessage)
		local chatMessage = createChatText(message)

		if message.Sender and message.Sender[1] ~= Player then
			chatMessage.Name = message.Sender[1].UserId.."-"..HttpService:GenerateGUID()
			local senderName = message.Sender[1].Name
			local prefix = ""
			for _, prefixInfo in ipairs(message.Prefixes) do
				prefix = prefix..prefixInfo[1]
			end

			local messageSender = chatMessage.PlayerName

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
		elseif message.Sender and message.Sender[1] == Player then
			chatMessage.Name = message.Sender[1].UserId.."-"..HttpService:GenerateGUID()
			chatMessage.PlayerName.TextXAlignment = Enum.TextXAlignment.Right
			chatMessage.ChatMessage.TextXAlignment = Enum.TextXAlignment.Right
		end
	
		
	end,

	["BubbleChat"] = function(player: Player, str: string)
		if not player.Character then return end

		game:GetService("Chat"):Chat(player.Character, str, Enum.ChatColor.White)
	end,

	["ClearChat"] = function()
		for _, chatMsg in  pairs(ChatGui:GetChildren()) do
			if chatMsg:IsA("TextLabel") then
				chatMsg:Destroy()
			end
		end
	end
}

for name, func in pairs(ReplicationFunctions) do
	NetworkService.Create(name, func)
end

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
		NetworkService.Fire("ExecuteCommand", command, args)
		TextBox.Text = ""

		return
	end

	NetworkService.Fire("SendMessage", TextBox.Text)
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


local FadeTweens = {
	TweenService:Create(BoxHolder, tweenInfo, {BackgroundTransparency = 0.9}),
	TweenService:Create(Holder, tweenInfo, {BackgroundTransparency = 0.9}),
	TweenService:Create(Send, tweenInfo, {ImageTransparency = 0.9}),
	TweenService:Create(TextBox, tweenInfo, {TextTransparency = 0.9}),
}

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
		for _, tween in pairs(FadeTweens) do
			tween:Play()
		end

		for _, message in pairs(ChatGui:GetChildren()) do
			if message:IsA("Frame") then
				TweenService:Create(message.ChatMessage, tweenInfo, {BackgroundTransparency = 0.9}):Play()
			end
		end
	else
		for _, tween in pairs(FadeTweens) do
			tween:Cancel()
		end

		for _, message in pairs(ChatGui:GetChildren()) do
			if message:IsA("Frame") then
				message.ChatMessage.BackgroundTransparency = 0.75
			end
		end
		BoxHolder.BackgroundTransparency = 0.5
		Holder.BackgroundTransparency = 0.25
		Send.ImageTransparency = 0
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
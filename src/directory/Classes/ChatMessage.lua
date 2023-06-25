local ChatMessage = {}
ChatMessage.__index = ChatMessage


function ChatMessage.new(message: string?, font: Enum.Font?, color: Color3?)
	local self = setmetatable({}, ChatMessage)
	
	self.Font = font or Enum.Font.SourceSansBold
	self.Color = color or Color3.new(1, 1, 1)
	self.Message = message or ""
	self.Sender = nil
	self.Prefixes = {}
	self.Suffixes = {}
	self.SenderSuffixes = {}

	return self
end

export type ChatMessage = typeof(ChatMessage.new())

function ChatMessage:AppendPrefix(message: string, color: Color3)
	table.insert(self.Prefixes, {message, color})
end

function ChatMessage:AddSender(sender: Player, color: Color3)
	self.Sender = {sender, color}
end

function ChatMessage:AppendSuffix(message: string, color: Color3)
	table.insert(self.Suffixes, {message, color})
end

function ChatMessage:AppendSenderSuffix(message: string, color: Color3)
	table.insert(self.SenderSuffixes, {message, color})
end


return ChatMessage

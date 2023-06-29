local NetworkService = {}

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

NetworkService.ClientCallbacks = {}
NetworkService.ServerCallbacks = {}

if RunService:IsServer() then
	local Remotes = Instance.new("Folder")
	Remotes.Name = "Remotes"
	Remotes.Parent = ReplicatedStorage

	local ServerReplicator = Instance.new("RemoteFunction")
	ServerReplicator.Name = "ServerReplicator"
	ServerReplicator.Parent = Remotes

	ServerReplicator.OnServerInvoke = function(player: Player, name: string, ...)
		if not NetworkService.ServerCallbacks[name] then return nil end
		
		return NetworkService.ServerCallbacks[name](player, ...)
	end

	local ClientReplicator = Instance.new("RemoteEvent")
	ClientReplicator.Name = "ClientReplicator"
	ClientReplicator.Parent = Remotes
end

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ServerReplicator = Remotes:WaitForChild("ServerReplicator")
local ClientReplicator = Remotes:WaitForChild("ClientReplicator")

if RunService:IsClient() then
	ClientReplicator.OnClientEvent:Connect(function(name: string, ...)
		if NetworkService.ClientCallbacks[name] then
			NetworkService.ClientCallbacks[name](...)
		end
	end)
end


function NetworkService.Create(name: string, callback: (any) -> any)
	if RunService:IsServer() then
		NetworkService.ServerCallbacks[name] = callback
	else
		NetworkService.ClientCallbacks[name] = callback
	end
end

function NetworkService.Fire(name: string, ...) : any?
	if RunService:IsServer() then
		local args = {...}
		ClientReplicator:FireClient(args[1], name, table.unpack(args, 2))

		return nil
	else
		return ServerReplicator:InvokeServer(name, ...)
	end
end



return NetworkService
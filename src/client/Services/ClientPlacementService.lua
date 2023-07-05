local PlacementService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Directory = require(ReplicatedStorage:FindFirstChild("Directory"))
local Placeable = require(ReplicatedStorage.Directory.Classes.Placeable)
local Event = Directory.Retrieve("Classes/Event")

local NetworkService = Directory.Retrieve("Services/NetworkService")

local Player = game.Players.LocalPlayer

local RunService = game:GetService("RunService")

local ClientInformation = require(script.Parent.ClientInformation)

local ContextActionService = game:GetService("ContextActionService")

local PlayerGui = Player.PlayerGui


PlacementService.PlacementEnded = Event.new()

local ghost = nil

function PlacementService.CalculateGrid() : (CFrame, Vector2)
	local back = Vector3.new(0,-1,0)
	local top = Vector3.new(0,0,-1)
	local right = Vector3.new(-1,0,0)
	
	local base = Player.PlayerPlot.Value.Base
	local baseSize = base.Size
	local cf = base.CFrame * CFrame.fromMatrix(-back*baseSize/2, right, top, back)

	local size = Vector2.new((baseSize * right).Magnitude, (baseSize * top).Magnitude)

	return cf, size
end

function PlacementService.CalculatePlacementCFrame(model, position, rotation)
	local cf, size = PlacementService.CalculateGrid()

	local primaryPart =  model.PrimaryPart or model:FindFirstChild("Hitbox")

	local modelSize = CFrame.fromEulerAnglesYXZ(0, math.rad(rotation*90), 0) * primaryPart.Size
	modelSize = Vector3.new(math.abs(modelSize.X), math.abs(modelSize.Y), math.abs(modelSize.Z))

	local lpos = cf:PointToObjectSpace(position);
	local size2 = (size - Vector2.new(modelSize.X, modelSize.Z))/2

	local x = math.clamp(lpos.X, -size2.X, size2.X);
	local y = math.clamp(lpos.Y, -size2.Y, size2.Y);

	x = math.sign(x)*((math.abs(x) - math.abs(x) % 3) + (size2.x % 3))
	y = math.sign(y)*((math.abs(y) - math.abs(y) % 3) + (size2.y % 3))

	return cf * CFrame.new(x, y, -modelSize.Y/2) * CFrame.Angles(-math.pi/2, math.rad(rotation * 90), 0)
end

function PlacementService.IsColliding(model)
	local isColliding = false

	local primaryPart = model.PrimaryPart or model:FindFirstChild("Hitbox")

	if not primaryPart then return end

	-- must have a touch interest for the :GetTouchingParts() method to work
	local touch = primaryPart.Touched:Connect(function() end)
	local touching = primaryPart:GetTouchingParts()
	
	-- if intersecting with something that isn't part of the model then can't place
	for i = 1, #touching do
		if (not touching[i]:IsDescendantOf(model) and touching[i].Name == "Hitbox") then
			isColliding = true
			break
		end
	end

	-- cleanup and return
	touch:Disconnect()
	return isColliding
end

function PlacementService.CancelPlacement()
	ClientInformation.IsPlacing = false

	local base = Player.PlayerPlot.Value.Base
	base.Grid.Transparency = 1

	if ghost then
		ghost:Destroy()
	end

	for _, item in pairs(base.Parent.Items:GetChildren()) do
		local itemSelectionBox = item.Hitbox:FindFirstChild("SelectionBox")
		if not itemSelectionBox then continue end
		itemSelectionBox:Destroy()
	end

	RunService:UnbindFromRenderStep("PlaceItem")
	ContextActionService:UnbindAction("Place")
	ContextActionService:UnbindAction("Rotate")
	ContextActionService:UnbindAction("Cancel")

	PlacementService.PlacementEnded:Fire()
end

NetworkService.Create("CancelPlaceItem", function()
	PlacementService.CancelPlacement()
end)

function PlacementService.BeginPlacement(item: Placeable.Placeable)
	if ClientInformation.IsPlacing then return end

	ClientInformation.IsPlacing = true

	ghost = item.Model:Clone()
	ghost.Parent = workspace

	for _, part in pairs(ghost.Model:GetChildren()) do
		part.Transparency = 0.5
	end

	local hitbox : BasePart = ghost.Hitbox

	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Name = "SelectionBox"
	selectionBox.LineThickness = 0.15
	selectionBox.Parent = hitbox
	selectionBox.Adornee = hitbox
	selectionBox.Transparency = 0
	selectionBox.SurfaceTransparency= 0.8

	local base = Player.PlayerPlot.Value.Base

	for _, item in pairs(base.Parent.Items:GetChildren()) do
		local itemSelectionBox = Instance.new("SelectionBox")
		itemSelectionBox.Name = "SelectionBox"
		itemSelectionBox.LineThickness = 0.15
		itemSelectionBox.Parent = item.Hitbox
		itemSelectionBox.Adornee = item.Hitbox
		itemSelectionBox.Transparency = 0
		itemSelectionBox.SurfaceTransparency= 0.8
	end

	if not base then 
		PlacementService.CancelPlacement()
		base.Grid.Transparency = 1
		return 
	end

	base.Grid.Transparency = 0

	local gridRotation = 0

	local placed = false

	local mouse = Player:GetMouse()


	ContextActionService:BindAction("Rotate", function(actionName: string, userInputState: Enum.UserInputState, input: InputObject)
		if (userInputState == Enum.UserInputState.Begin) then
			gridRotation += 1
			if gridRotation > 3 then
				gridRotation = 0
			end
		end	
	end, false, Enum.KeyCode.R)

	ContextActionService:BindAction("Place", function(actionName: string, userInputState: Enum.UserInputState, input: InputObject)
		if (userInputState == Enum.UserInputState.Begin) then
			if PlacementService.IsColliding(ghost) then 
				print("Collided")
				return 
			end

			for _, item in pairs(base.Parent.Items:GetChildren()) do
				local itemSelectionBox = item.Hitbox:FindFirstChild("SelectionBox")
				itemSelectionBox.Adornee = item.Hitbox
				itemSelectionBox.Transparency = 0
				itemSelectionBox.SurfaceTransparency= 0.8
			end

			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Include
			rayParams.FilterDescendantsInstances = {base}
			local mousePosition = mouse.Hit.Position
			local cameraPosition = workspace.CurrentCamera.CFrame.Position
			local ray  = workspace:Raycast(cameraPosition, (mousePosition - cameraPosition).Unit * 1000, rayParams)

			if ray then
				local cf = PlacementService.CalculatePlacementCFrame(ghost, ray.Position, gridRotation)

				NetworkService.Fire("PlaceItem", item.Name,  cf)
			end
		end		
	end, false, Enum.UserInputType.MouseButton1)

	ContextActionService:BindAction("Cancel", function(actionName: string, userInputState: Enum.UserInputState, input: InputObject)
		if (userInputState == Enum.UserInputState.Begin) then
			PlacementService.CancelPlacement()
		end
	end, false, Enum.KeyCode.Q)

	RunService:BindToRenderStep("PlaceItem", 1, function()
		if PlacementService.IsColliding(ghost) then 
			selectionBox.Color3 = Color3.fromRGB(255, 0, 0)
			selectionBox.SurfaceColor3 = Color3.fromRGB(255, 0, 0)
		else
			selectionBox.Color3 = Color3.fromRGB(13, 105, 172)
			selectionBox.SurfaceColor3 = Color3.fromRGB(13, 105, 172)
		end

		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Include
		rayParams.FilterDescendantsInstances = {base}
		local mousePosition = mouse.Hit.Position
		local cameraPosition = workspace.CurrentCamera.CFrame.Position
		local ray  = workspace:Raycast(cameraPosition, (mousePosition - cameraPosition).Unit * 1000, rayParams)

		if ray then
			local cf = PlacementService.CalculatePlacementCFrame(ghost, ray.Position, gridRotation)
			ghost:PivotTo(cf)
		end
		
	end)
end


return PlacementService

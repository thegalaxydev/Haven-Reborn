local CharacterService = {}

local UIService = require(script.Parent.UIService)
local SoundService = require(script.Parent.SoundService)

CharacterService.IsAwayFromBase = false

local Player = game.Players.LocalPlayer
local Base = Player:WaitForChild("PlayerPlot").Value.Base

function CharacterService.CheckBaseDistance()
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

	if (HumanoidRootPart.Position - Base.Position).Magnitude > ((Base.Size.X / 2) + 10) then
		if not CharacterService.IsAwayFromBase then
			SoundService.MuteMusic()
			UIService.ToggleHUD(false)
			CharacterService.IsAwayFromBase = true
		end
	else
		if CharacterService.IsAwayFromBase then
			SoundService.UnmuteMusic()
			UIService.ToggleHUD(true)
			CharacterService.IsAwayFromBase = false
		end
	end
end

game:GetService("RunService").RenderStepped:Connect(function()
	CharacterService.CheckBaseDistance()
end)




return CharacterService
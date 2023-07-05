local SoundService = {}

local SoundDirectory = game:GetService("SoundService")
local Music = SoundDirectory:WaitForChild("Music")

local TweenService = game:GetService("TweenService")

SoundService.CurrentSong = nil

SoundService.IsMuted = false

function SoundService.MuteMusic()
	if SoundService.IsMuted or not SoundService.CurrentSong then return end
	
	SoundService.IsMuted = true
	TweenService:Create(SoundService.CurrentSong, TweenInfo.new(0.5), {PlaybackSpeed = 0}):Play()
	task.wait(0.5)
	TweenService:Create(SoundDirectory.AwayFromBase, TweenInfo.new(0.5), {PlaybackSpeed = 1}):Play()
end

function SoundService.UnmuteMusic()
	if not SoundService.IsMuted or not SoundService.CurrentSong then return end

	SoundService.IsMuted = false
	TweenService:Create(SoundService.CurrentSong, TweenInfo.new(0.5), {PlaybackSpeed = 1}):Play()
	task.wait(0.5)
	TweenService:Create(SoundDirectory.AwayFromBase, TweenInfo.new(0.5), {PlaybackSpeed = 0}):Play()
end

function SoundService.Play(song: Sound)
	SoundService.CurrentSong = song
	song:Play()
	SoundService.UnmuteMusic()
end

function SoundService.LoopMusic(songName: string)
	local song = Music:FindFirstChild(songName)
	if not song then return end

	SoundService.CurrentSong = song
	song:Play()
	SoundService.UnmuteMusic()

	song.Ended:Connect(function()
		local songQueue = {}
		for i,v in pairs(Music:GetChildren()) do
			if v:IsA("Sound") and v ~= song then
				table.insert(songQueue, v)
			end
		end

		if #songQueue == 0 then 
			SoundService.LoopMusic(songName)
			return 
		end

		local song = songQueue[math.random(1, #songQueue)]

		SoundService.LoopMusic(song.Name)
	end)
end

return SoundService
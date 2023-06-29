type Rarity = {
	Name : string,
	BackgroundColor : Color3,
	TextColor: Color3
}


return {
	{['Name'] = "Common", ['BackgroundColor'] = Color3.fromRGB(158, 155, 155), ['TextColor'] = Color3.fromRGB(25,25,25)},
	{['Name'] = "Uncommon", ['BackgroundColor'] = Color3.fromRGB(0, 255, 0), ['TextColor'] = Color3.fromRGB(25,25,25)},
	{['Name'] = "Rare", ['BackgroundColor'] = Color3.fromRGB(0, 0, 255), ['TextColor'] = Color3.fromRGB(255,255,255)},
	{['Name'] = "Mythical", ['BackgroundColor'] = Color3.fromRGB(255, 0, 255), ['TextColor'] = Color3.fromRGB(25,25,25)},
	{['Name'] = "Legendary", ['BackgroundColor'] = Color3.fromRGB(255, 170, 0), ['TextColor'] = Color3.fromRGB(25,25,25)},
	{['Name'] = "Godly", ['BackgroundColor'] = Color3.fromRGB(255, 0, 0), ['TextColor'] = Color3.fromRGB(255,255,255)},
	{['Name'] = "Special", ['BackgroundColor'] = Color3.fromRGB(255, 255, 0), ['TextColor'] = Color3.fromRGB(25,25,25)},
	{['Name'] = "Unique", ['BackgroundColor'] = Color3.fromRGB(0, 255, 255), ['TextColor'] = Color3.fromRGB(25,25,25)},
	{['Name'] = "Custom", ['BackgroundColor'] = Color3.fromRGB(255, 255, 255), ['TextColor'] = Color3.fromRGB(25,25,25)},
}
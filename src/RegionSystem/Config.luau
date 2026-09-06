return {
	CheckInterval = 0.1,
	FadeTime = 0.35,
	LightingTransition = 0.7,

	Defaults = {
		Name = "Region",
		Description = "",
		Priority = 0,
		Intro = { Enabled = true, Duration = 2.4 },
		Outro = { Enabled = true, Duration = 1.6 },
		IntroMusic = { Enabled = true },
		OutroMusic = { Enabled = true },
		Theme = { Enabled = false },
		Lighting = { Enabled = false },
	},

	Regions = {
		Green = {
			Name = "Green Region",
			Description = "A quiet corner beneath the trees.",
			Priority = 0,
			Intro = { Enabled = true, Duration = 2.4 },
			Outro = { Enabled = true, Duration = 1.6 },
			IntroMusic = { Enabled = true },
			OutroMusic = { Enabled = true },
			Theme = { Enabled = false },
			Lighting = {
				Enabled = true,
				ClockTime = 9,
				Brightness = 2,
				Ambient = Color3.fromRGB(90, 115, 95),
				OutdoorAmbient = Color3.fromRGB(110, 140, 115),
			},
		},

		Yellow = {
			Name = "Yellow Region",
			Description = "The last light of the sun shines here.",
			Priority = 0,
			Intro = { Enabled = true, Duration = 2.4 },
			Outro = { Enabled = true, Duration = 1.6 },
			IntroMusic = { Enabled = true },
			OutroMusic = { Enabled = true },
			Theme = { Enabled = true },
			Lighting = {
				Enabled = true,
				ClockTime = 17,
				Brightness = 2.5,
				Ambient = Color3.fromRGB(135, 105, 65),
				OutdoorAmbient = Color3.fromRGB(165, 140, 95),
			},
		},

		Red = {
			Name = "Red Region",
			Description = "Step into the crimson shadows.",
			Priority = 0,
			Intro = { Enabled = true, Duration = 2.4 },
			Outro = { Enabled = true, Duration = 1.6 },
			IntroMusic = { Enabled = true },
			OutroMusic = { Enabled = true },
			Theme = { Enabled = false },
			Lighting = {
				Enabled = true,
				ClockTime = 20,
				Brightness = 1.5,
				Ambient = Color3.fromRGB(110, 65, 75),
				OutdoorAmbient = Color3.fromRGB(90, 70, 100),
			},
		},
	},
}

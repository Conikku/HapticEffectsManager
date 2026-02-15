--!strict

--[[
	Example Usage Script for HapticEffectsManager
	
	This script demonstrates various ways to use the HapticEffects module
	for creating haptic feedback in your game.
]]

-- Require the module (adjust path to where you place the module)
local HapticEffects = require(script.Parent.HapticEffectsManager)

-- Wait for player
local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== HapticEffects Module Examples ===")

-- EXAMPLE 1: Simple UI Hover Effect
print("\n1. UI Hover Effect Example")
-- This would typically be in a UI button script
local function onButtonHover()
	local hoverEffect = HapticEffects.CreateUIHover()
	hoverEffect:Play()
	-- Auto-destroys after playing since it's not looped
	task.wait(0.5)
	hoverEffect:Destroy()
end

-- EXAMPLE 2: UI Click Effect (One-Shot)
print("2. UI Click One-Shot Example")
-- One-shot effects automatically clean up after playing
HapticEffects.PlayOneShot({
	Type = "UIClick",
})

-- EXAMPLE 3: Gameplay Explosion
print("3. Gameplay Explosion Example")
local explosionEffect = HapticEffects.CreateGameplayExplosion(
	Vector3.new(0.5, 0.5, 0), -- Center of controller
	1.0 -- Full radius
)
explosionEffect:Play()

-- Wait for it to finish
task.wait(1)

-- EXAMPLE 4: Custom Waveform Effect
print("4. Custom Waveform Example")
local customWaveform: {{Time: number, Intensity: number}} = {
	{ Time = 0, Intensity = 0.2 },
	{ Time = 100, Intensity = 0.5 },
	{ Time = 200, Intensity = 0.8 },
	{ Time = 300, Intensity = 1.0 },
	{ Time = 500, Intensity = 0.3 },
	{ Time = 600, Intensity = 0 },
}

local customEffect = HapticEffects.CreateCustomEffect(customWaveform, {
	Type = "Custom",
	Looped = false,
})
customEffect:Play()

task.wait(1)

-- EXAMPLE 5: Looping Effect
print("5. Looping Effect Example")
local loopingEffect = HapticEffects.CreateLoopingEffect({
	Type = "GameplayCollision",
})
loopingEffect:Play()

-- Stop after 2 seconds
task.wait(2)
HapticEffects.StopAndDestroy(loopingEffect)
print("   Stopped looping effect")

-- EXAMPLE 6: Directional Haptic Effect
print("6. Directional Effect Example")
if player.Character then
	local character = player.Character
	local rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart

	-- Create explosion effect from a point 20 studs away
	local explosionPos = rootPart.Position + Vector3.new(20, 0, 0)

	local directionalEffect = HapticEffects.CreateDirectionalEffect(
		explosionPos,
		rootPart.Position,
		50, -- Max distance
		{ Type = "GameplayExplosion" }
	)
	directionalEffect:Play()
end

task.wait(1)

-- EXAMPLE 7: Effect Sequence
print("7. Haptic Sequence Example")
local notificationSequence = {
	{ delay = 0, effect = { Type = "UINotification" } },
	{ delay = 0.3, effect = { Type = "UINotification" } },
	{ delay = 0.3, effect = { Type = "UINotification" } },
} :: any

HapticEffects.PlaySequence(notificationSequence)()
print("   Playing notification sequence")

task.wait(1.5)

-- EXAMPLE 8: Pattern-Based Custom Waveforms
print("8. Waveform Pattern Example")

-- Ramp up pattern
local rampUpWaveform: {{Time: number, Intensity: number}} = HapticEffects.CreateWaveformPattern("rampUp", 400, 1.0)
local rampUpEffect = HapticEffects.CreateCustomEffect(rampUpWaveform, {
	Type = "Custom",
	Looped = false,
})
rampUpEffect:Play()

task.wait(0.6)

-- Pulse pattern
local pulseWaveform: {{Time: number, Intensity: number}} = HapticEffects.CreateWaveformPattern("pulse", 600, 0.8)
local pulseEffect = HapticEffects.CreateCustomEffect(pulseWaveform, {
	Type = "Custom",
	Looped = false,
})
pulseEffect:Play()

task.wait(0.8)

-- EXAMPLE 9: Await Effect Completion
print("9. Await Effect Completion Example")
local awaitEffect = HapticEffects.CreateGameplayCollision()
awaitEffect:Play()
print("   Playing collision effect...")

-- Wait for effect to finish
HapticEffects.AwaitEnd(awaitEffect)()
print("   Effect completed!")

-- EXAMPLE 10: Complex UI Feedback System
print("10. UI Feedback System Example")

-- Simulate a UI button with complete feedback
local function simulateButtonInteraction()
	-- Hover feedback
	local hover = HapticEffects.CreateUIHover()
	hover:Play()
	task.wait(0.2)
	hover:Destroy()

	-- Click feedback
	HapticEffects.PlayOneShot({ Type = "UIClick" })

	-- Success notification after click
	task.wait(0.5)
	HapticEffects.PlayOneShot({ Type = "UINotification" })
end

simulateButtonInteraction()

print("\n=== All Examples Complete ===")

--[[
	ADDITIONAL NOTES:
	
	Supported Devices:
	- iOS and Android phones with haptic support (iPhone, Pixel, Samsung Galaxy)
	- PlayStation gamepads
	- Xbox gamepads
	- Meta Quest Touch controllers
	
	Best Practices:
	1. Use predefined effect types when possible - they're optimized for each device
	2. Keep custom waveforms short (< 1 second) for best performance
	3. Don't overuse haptics - they should enhance, not overwhelm
	4. Test on actual devices as haptic feedback varies by hardware
	5. Always clean up looping effects when no longer needed
	6. Consider player settings/preferences for haptic feedback
	
	Position and Radius:
	- Position is relative to the input device in 0-1 range
	- Position.X: left (0) to right (1)
	- Position.Y: bottom (0) to top (1)
	- Position.Z: affects motor selection on gamepads
	- Radius: how broadly the effect impacts nearby motors (0-1)
	
	Note: Some gamepads only have a single motor, so complex position/radius
	configurations may not have the expected effect on all devices.
]]
--!strict

--[[
	HapticEffectsManager - A comprehensive module for managing haptic feedback in Roblox
	
	This module provides a simple interface for creating and managing haptic effects across
	various devices including mobile phones (iOS/Android), console gamepads (Xbox/PlayStation),
	and VR controllers (Quest Touch).
	
	@class HapticEffectsManager
	@author Conikku
	@version 1.0.0
]]

local HapticEffectsManager = {}
HapticEffectsManager.__index = HapticEffectsManager

--[=[
	@type HapticEffectType "Custom" | "UIHover" | "UIClick" | "UINotification" | "GameplayExplosion" | "GameplayCollision"
	The type of haptic effect to play:
	- **Custom**: Allows custom waveform definition via SetWaveformKeys
	- **UIHover**: Subtle feedback for hovering over UI elements
	- **UIClick**: Crisp feedback for clicking/selecting UI elements
	- **UINotification**: Attention-grabbing alert for notifications
	- **GameplayExplosion**: Large rumble that decays (for explosions)
	- **GameplayCollision**: Sharp immediate rumble (for impacts)
]=]
export type HapticEffectType = 
"Custom" | 
"UIHover" | 
"UIClick" | 
"UINotification" | 
"GameplayExplosion" | 
"GameplayCollision"

--[=[
	@interface HapticEffectConfig
	@within HapticEffectsManager
	Configuration for creating a haptic effect.
	
	@field Type HapticEffectType -- The type of haptic effect
	@field Looped boolean? -- Whether the effect should loop continuously (default: false)
	@field Position Vector3? -- Position relative to input device (0-1 range, default: Vector3.new(0.5, 0.5, 0))
	@field Radius number? -- How broadly the effect affects nearby motors (default: 1.0)
	@field Parent Instance? -- Parent instance for the effect (default: Workspace)
]=]
export type HapticEffectConfig = {
	Type: HapticEffectType,
	Looped: boolean?,
	Position: Vector3?,
	Radius: number?,
	Parent: Instance?,
}

--[=[
	@interface WaveformKey
	@within HapticEffectsManager
	A single key in a haptic waveform curve.
	
	@field Time number -- Time in milliseconds
	@field Intensity number -- Intensity value (0.0 to 1.0)
]=]
export type WaveformKey = {
	Time: number,
	Intensity: number,
}

-- Private helper function to convert string type to enum
local function getHapticEffectTypeEnum(typeString: HapticEffectType): Enum.HapticEffectType
	local enumMap = {
		Custom = Enum.HapticEffectType.Custom,
		UIHover = Enum.HapticEffectType.UIHover,
		UIClick = Enum.HapticEffectType.UIClick,
		UINotification = Enum.HapticEffectType.UINotification,
		GameplayExplosion = Enum.HapticEffectType.GameplayExplosion,
		GameplayCollision = Enum.HapticEffectType.GameplayCollision,
	}

	return enumMap[typeString] or Enum.HapticEffectType.Custom
end

--[=[
	Creates a new haptic effect with the specified configuration.
	
	@param config HapticEffectConfig -- Configuration table for the haptic effect
	@return HapticEffect -- The created HapticEffect instance
	
	@tag Constructor
	
	**Example Usage:**
	```lua
	local HapticEffects = require(path.to.HapticEffectsModule)
	
	-- Create a simple explosion effect
	local explosionEffect = HapticEffects.CreateEffect({
		Type = "GameplayExplosion",
		Looped = false,
	})
	explosionEffect:Play()
	```
]=]
function HapticEffectsManager.CreateEffect(config: HapticEffectConfig): HapticEffect
	assert(config.Type, "HapticEffectConfig.Type is required")

	local effect = Instance.new("HapticEffect")

	-- Set the effect type
	effect.Type = getHapticEffectTypeEnum(config.Type)

	-- Set optional properties
	effect.Looped = config.Looped or false
	effect.Position = config.Position or Vector3.new(0.5, 0.5, 0)
	effect.Radius = config.Radius or 1.0

	-- Parent the effect
	effect.Parent = config.Parent or workspace

	return effect
end

--[=[
	Creates a haptic effect and plays it immediately, then destroys it when finished.
	Ideal for one-shot effects like button clicks or explosions.
	
	@param config HapticEffectConfig -- Configuration table for the haptic effect
	@return HapticEffect -- The created HapticEffect instance (will be destroyed after playback)
	
	@tag QuickPlay
	
	**Example Usage:**
	```lua
	local HapticEffects = require(path.to.HapticEffectsModule)
	
	-- Play a quick UI click feedback
	HapticEffects.PlayOneShot({
		Type = "UIClick",
	})
	```
]=]
function HapticEffectsManager.PlayOneShot(config: HapticEffectConfig): HapticEffect
	local effect = HapticEffectsManager.CreateEffect(config)

	-- Connect to Ended event to destroy after playback
	effect.Ended:Connect(function()
		effect:Destroy()
	end)

	effect:Play()
	return effect
end

--[=[
	Creates a custom haptic effect with a user-defined waveform.
	
	@param waveformKeys {WaveformKey} -- Array of waveform keys defining the haptic pattern
	@param config HapticEffectConfig? -- Optional configuration (Type will be set to Custom automatically)
	@return HapticEffect -- The created HapticEffect instance with custom waveform
	
	@tag Custom
	
	**Note:** Keys are interpolated using Linear interpolation by default for smooth transitions.
	
	**Example Usage:**
	```lua
	local HapticEffects = require(path.to.HapticEffectsModule)
	
	-- Create a custom ramp-up effect
	local customEffect = HapticEffects.CreateCustomEffect({
		{ Time = 0, Intensity = 0.3 },
		{ Time = 100, Intensity = 0.5 },
		{ Time = 300, Intensity = 0.8 },
		{ Time = 400, Intensity = 1.0 },
	}, {
		Type = "Custom", -- Required in strict mode
		Looped = false,
	})
	customEffect:Play()
	```
	
	**Note:** While the function sets Type to "Custom" internally, in strict Luau mode 
	you should include `Type = "Custom"` in the config to satisfy the type checker.
]=]
function HapticEffectsManager.CreateCustomEffect(
	waveformKeys: {WaveformKey},
	config: HapticEffectConfig?
): HapticEffect
	assert(#waveformKeys > 0, "waveformKeys must contain at least one key")

	-- Create config with Custom type, preserving any provided config options
	local effectConfig: HapticEffectConfig = {
		Type = "Custom",
		Looped = if config then config.Looped else nil,
		Position = if config then config.Position else nil,
		Radius = if config then config.Radius else nil,
		Parent = if config then config.Parent else nil,
	}

	local effect = HapticEffectsManager.CreateEffect(effectConfig)

	-- Convert waveform keys to FloatCurveKey instances
	local curveKeys = {}
	for _, key in ipairs(waveformKeys) do
		table.insert(curveKeys, FloatCurveKey.new(key.Time, key.Intensity, Enum.KeyInterpolationMode.Linear))
	end

	-- Apply the waveform
	effect:SetWaveformKeys(curveKeys)

	return effect
end

--[=[
	Creates a UI hover effect - subtle feedback for browsing over UI elements.
	
	@param parent Instance? -- Optional parent instance (default: Workspace)
	@return HapticEffect -- The created haptic effect
	
	@tag Preset
	
	**Example Usage:**
	```lua
	local HapticEffects = require(path.to.HapticEffectsModule)
	
	local button = script.Parent
	button.MouseEnter:Connect(function()
		HapticEffects.CreateUIHover():Play()
	end)
	```
]=]
function HapticEffectsManager.CreateUIHover(parent: Instance?): HapticEffect
	return HapticEffectsManager.CreateEffect({
		Type = "UIHover",
		Parent = parent,
	})
end

--[=[
	Creates a UI click effect - crisp feedback for selecting UI elements.
	
	@param parent Instance? -- Optional parent instance (default: Workspace)
	@return HapticEffect -- The created haptic effect
	
	@tag Preset
	
	**Example Usage:**
	```lua
	local HapticEffects = require(path.to.HapticEffectsModule)
	
	local button = script.Parent
	button.Activated:Connect(function()
		HapticEffects.CreateUIClick():Play()
	end)
	```
]=]
function HapticEffectsManager.CreateUIClick(parent: Instance?): HapticEffect
	return HapticEffectsManager.CreateEffect({
		Type = "UIClick",
		Parent = parent,
	})
end

--[=[
	Creates a UI notification effect - attention-grabbing feedback for alerts.
	
	@param parent Instance? -- Optional parent instance (default: Workspace)
	@return HapticEffect -- The created haptic effect
	
	@tag Preset
	
	**Example Usage:**
	```lua
	local HapticEffects = require(path.to.HapticEffectsModule)
	
	-- Notify player of achievement
	HapticEffects.CreateUINotification():Play()
	```
]=]
function HapticEffectsManager.CreateUINotification(parent: Instance?): HapticEffect
	return HapticEffectsManager.CreateEffect({
		Type = "UINotification",
		Parent = parent,
	})
end

--[=[
	Creates a gameplay explosion effect - large rumble that decays over time.
	
	@param position Vector3? -- Position relative to device (0-1 range)
	@param radius number? -- Effect radius (default: 1.0)
	@param parent Instance? -- Optional parent instance (default: Workspace)
	@return HapticEffect -- The created haptic effect
	
	@tag Preset
	
	**Example Usage:**
	```lua
	local HapticEffects = require(path.to.HapticEffectsModule)
	
	-- Create explosion at center of controller
	local explosion = HapticEffects.CreateGameplayExplosion(
		Vector3.new(0.5, 0.5, 0),
		1.0
	)
	explosion:Play()
	```
]=]
function HapticEffectsManager.CreateGameplayExplosion(
	position: Vector3?,
	radius: number?,
	parent: Instance?
): HapticEffect
	return HapticEffectsManager.CreateEffect({
		Type = "GameplayExplosion",
		Position = position,
		Radius = radius,
		Parent = parent,
	})
end

--[=[
	Creates a gameplay collision effect - sharp immediate rumble for impacts.
	
	@param position Vector3? -- Position relative to device (0-1 range)
	@param radius number? -- Effect radius (default: 1.0)
	@param parent Instance? -- Optional parent instance (default: Workspace)
	@return HapticEffect -- The created haptic effect
	
	@tag Preset
	
	**Example Usage:**
	```lua
	local HapticEffects = require(path.to.HapticEffectsModule)
	
	-- Create collision effect when player hits wall
	part.Touched:Connect(function(hit)
		if hit.Parent:FindFirstChild("Humanoid") then
			HapticEffects.CreateGameplayCollision():Play()
		end
	end)
	```
]=]
function HapticEffectsManager.CreateGameplayCollision(
	position: Vector3?,
	radius: number?,
	parent: Instance?
): HapticEffect
	return HapticEffectsManager.CreateEffect({
		Type = "GameplayCollision",
		Position = position,
		Radius = radius,
		Parent = parent,
	})
end

--[=[
	Plays a haptic effect and returns a promise-like object that resolves when the effect ends.
	Useful for chaining haptic feedback or waiting for completion.
	
	@param effect HapticEffect -- The haptic effect to play
	@return () -> () -- Function that yields until the effect ends
	
	@tag Utility
	
	**Example Usage:**
	```lua
	local HapticEffects = require(path.to.HapticEffectsModule)
	
	local effect = HapticEffects.CreateGameplayExplosion()
	effect:Play()
	
	-- Wait for effect to finish
	HapticEffects.AwaitEnd(effect)()
	print("Effect finished!")
	```
]=]
function HapticEffectsManager.AwaitEnd(effect: HapticEffect): () -> ()
	return function()
		if not effect or not effect.Parent then
			return
		end

		if effect.Looped then
			warn("AwaitEnd called on looped effect - will never complete")
			return
		end

		effect.Ended:Wait()
	end
end

--[=[
	Stops and destroys a haptic effect.
	
	@param effect HapticEffect -- The haptic effect to stop and destroy
	
	@tag Utility
	
	**Example Usage:**
	```lua
	local HapticEffects = require(path.to.HapticEffectsModule)
	
	local effect = HapticEffects.CreateEffect({ Type = "UIHover", Looped = true })
	effect:Play()
	
	-- Later, stop the effect
	task.wait(2)
	HapticEffects.StopAndDestroy(effect)
	```
]=]
function HapticEffectsManager.StopAndDestroy(effect: HapticEffect): ()
	if effect and effect.Parent then
		effect:Stop()
		effect:Destroy()
	end
end

--[=[
	Creates a looping haptic effect that continues until manually stopped.
	
	@param config HapticEffectConfig -- Configuration for the haptic effect
	@return HapticEffect -- The created looping haptic effect
	
	@tag Utility
	
	**Example Usage:**
	```lua
	local HapticEffects = require(path.to.HapticEffectsModule)
	
	-- Create a looping engine rumble
	local engineRumble = HapticEffects.CreateLoopingEffect({
		Type = "GameplayCollision",
	})
	engineRumble:Play()
	
	-- Stop when player exits vehicle
	exitEvent:Connect(function()
		HapticEffects.StopAndDestroy(engineRumble)
	end)
	```
]=]
function HapticEffectsManager.CreateLoopingEffect(config: HapticEffectConfig): HapticEffect
	local loopingConfig = table.clone(config) :: any
	loopingConfig.Looped = true
	return HapticEffectsManager.CreateEffect(loopingConfig)
end

--[=[
	Creates a directional haptic effect based on a position in 3D space.
	The position is automatically normalized to the 0-1 range expected by HapticEffect.
	
	@param worldPosition Vector3 -- Position in world space
	@param referencePosition Vector3 -- Reference position (usually player position)
	@param maxDistance number -- Maximum distance for haptic effect
	@param config HapticEffectConfig -- Configuration for the haptic effect
	@return HapticEffect -- The created directional haptic effect
	
	@tag Advanced
	
	**Example Usage:**
	```lua
	local HapticEffects = require(path.to.HapticEffectsModule)
	
	local player = game.Players.LocalPlayer
	local character = player.Character
	local explosionPosition = Vector3.new(100, 0, 100)
	
	if character then
		local effect = HapticEffects.CreateDirectionalEffect(
			explosionPosition,
			character.HumanoidRootPart.Position,
			50,
			{ Type = "GameplayExplosion" }
		)
		effect:Play()
	end
	```
]=]
function HapticEffectsManager.CreateDirectionalEffect(
	worldPosition: Vector3,
	referencePosition: Vector3,
	maxDistance: number,
	config: HapticEffectConfig
): HapticEffect
	-- Calculate direction and distance
	local direction = (worldPosition - referencePosition)
	local distance = direction.Magnitude

	-- Normalize to 0-1 range
	local normalizedDistance = math.clamp(distance / maxDistance, 0, 1)

	-- Calculate position relative to reference (0.5, 0.5, 0) is center
	local relativePosition = Vector3.new(0.5, 0.5, 0)
	if distance > 0 then
		local normalizedDirection = direction.Unit
		relativePosition = Vector3.new(
			0.5 + normalizedDirection.X * 0.5,
			0.5 + normalizedDirection.Y * 0.5,
			normalizedDirection.Z * 0.5
		)
	end

	-- Create effect with calculated position and radius
	local effectConfig = table.clone(config) :: any
	effectConfig.Position = relativePosition
	effectConfig.Radius = 1 - normalizedDistance -- Closer = larger radius

	return HapticEffectsManager.CreateEffect(effectConfig)
end

--[=[
	Plays a sequence of haptic effects with delays between them.
	
	@param sequence {{effect: HapticEffectConfig, delay: number}} -- Array of effects and delays
	@return () -> () -- Function that plays the sequence
	
	@tag Advanced
	
	**Example Usage:**
	```lua
	local HapticEffects = require(path.to.HapticEffectsModule)
	
	-- Create a three-pulse notification sequence
	local sequence = {
		{ delay = 0, effect = { Type = "UINotification" } },
		{ delay = 0.2, effect = { Type = "UINotification" } },
		{ delay = 0.2, effect = { Type = "UINotification" } },
	} :: any -- Cast to 'any' in strict mode to avoid literal type conflicts
	
	HapticEffects.PlaySequence(sequence)()
	```
	
	**Note:** In strict Luau mode, you may need to cast the sequence to `any` (with `:: any`) 
	to avoid type conflicts between literal string types and the HapticEffectType union.
]=]
function HapticEffectsManager.PlaySequence(
	sequence: {{effect: HapticEffectConfig, delay: number}}
): () -> ()
	return function()
		for _, step in ipairs(sequence) do
			task.wait(step.delay)
			HapticEffectsManager.PlayOneShot(step.effect)
		end
	end
end

--[=[
	Helper function to create common waveform patterns.
	
	@param pattern "rampUp" | "rampDown" | "pulse" | "constant" -- Waveform pattern type
	@param duration number -- Duration in milliseconds
	@param intensity number -- Maximum intensity (0.0 to 1.0)
	@return {WaveformKey} -- Array of waveform keys
	
	@tag Utility
	
	**Example Usage:**
	```lua
	local HapticEffects = require(path.to.HapticEffectsModule)
	
	-- Create a 500ms ramp-up effect
	local waveform = HapticEffects.CreateWaveformPattern("rampUp", 500, 1.0)
	local effect = HapticEffects.CreateCustomEffect(waveform)
	effect:Play()
	```
]=]
function HapticEffectsManager.CreateWaveformPattern(
	pattern: "rampUp" | "rampDown" | "pulse" | "constant",
	duration: number,
	intensity: number
): {WaveformKey}
	intensity = math.clamp(intensity, 0, 1)

	if pattern == "rampUp" then
		return {
			{ Time = 0, Intensity = 0 },
			{ Time = duration * 0.25, Intensity = intensity * 0.25 },
			{ Time = duration * 0.5, Intensity = intensity * 0.5 },
			{ Time = duration * 0.75, Intensity = intensity * 0.75 },
			{ Time = duration, Intensity = intensity },
		}
	elseif pattern == "rampDown" then
		return {
			{ Time = 0, Intensity = intensity },
			{ Time = duration * 0.25, Intensity = intensity * 0.75 },
			{ Time = duration * 0.5, Intensity = intensity * 0.5 },
			{ Time = duration * 0.75, Intensity = intensity * 0.25 },
			{ Time = duration, Intensity = 0 },
		}
	elseif pattern == "pulse" then
		return {
			{ Time = 0, Intensity = 0 },
			{ Time = duration * 0.1, Intensity = intensity },
			{ Time = duration * 0.2, Intensity = 0 },
			{ Time = duration * 0.3, Intensity = intensity },
			{ Time = duration * 0.4, Intensity = 0 },
		}
	elseif pattern == "constant" then
		return {
			{ Time = 0, Intensity = intensity },
			{ Time = duration, Intensity = intensity },
		}
	end

	error("Invalid pattern type: " .. tostring(pattern))
end

return HapticEffectsManager
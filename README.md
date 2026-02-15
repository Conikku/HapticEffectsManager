# HapticEffects Manager for Roblox

A comprehensive, fully-documented module for managing haptic feedback in Roblox games. This module provides an easy-to-use interface for creating haptic effects across mobile devices, console gamepads, and VR controllers.

## Features

- Fully Documented: IntelliSense/autocomplete support in Roblox Studio
- Type-Safe: Written in strict Luau with complete type annotations
- Comprehensive: Covers all HapticEffect functionality
- Easy to Use: Simple API with preset functions for common effects
- Advanced Features: Custom waveforms, directional effects, sequences
- Well-Tested: Includes example usage script

## Supported Devices

- iOS and Android phones (iPhone, Pixel, Samsung Galaxy)
- PlayStation gamepads
- Xbox gamepads
- Meta Quest Touch controllers

## Installation

1. Create a **ModuleScript** in `ReplicatedStorage` or `StarterPlayer.StarterPlayerScripts`
2. Rename it to `HapticEffectsManager`
3. Copy the contents of `Init.lua` into it
4. Require it from your LocalScripts

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HapticEffects = require(ReplicatedStorage.HapticEffectsManager)
```

## Quick Start

### Basic UI Feedback

```lua
local HapticEffects = require(path.to.HapticEffectsManager)

-- Button hover
button.MouseEnter:Connect(function()
    HapticEffects.PlayOneShot({ Type = "UIHover" })
end)

-- Button click
button.Activated:Connect(function()
    HapticEffects.PlayOneShot({ Type = "UIClick" })
end)

-- Notification
HapticEffects.PlayOneShot({ Type = "UINotification" })
```

### Gameplay Effects

```lua
-- Explosion effect
local explosion = HapticEffects.CreateGameplayExplosion()
explosion:Play()

-- Collision/impact effect
local collision = HapticEffects.CreateGameplayCollision()
collision:Play()
```

### Custom Waveforms

```lua
-- Define a custom vibration pattern
local customWaveform = {
    { Time = 0, Intensity = 0.3 },
    { Time = 100, Intensity = 0.6 },
    { Time = 300, Intensity = 1.0 },
    { Time = 500, Intensity = 0 },
}

local effect = HapticEffects.CreateCustomEffect(customWaveform, {
    Type = "Custom", -- Required in strict mode
    Looped = false,
})
effect:Play()
```

**Note:** Custom waveforms use linear interpolation between keyframes for smooth haptic transitions. In strict Luau mode, include `Type = "Custom"` in the config parameter.

## API Reference

### Effect Types

- **`Custom`**: Create your own waveform pattern
- **`UIHover`**: Subtle feedback for hovering over UI elements
- **`UIClick`**: Crisp feedback for button clicks
- **`UINotification`**: Attention-grabbing alert
- **`GameplayExplosion`**: Large rumble that decays (for explosions)
- **`GameplayCollision`**: Sharp immediate rumble (for impacts)

### Main Functions

#### `CreateEffect(config: HapticEffectConfig)`
Creates a new haptic effect with custom configuration.

```lua
local effect = HapticEffects.CreateEffect({
    Type = "GameplayExplosion",
    Looped = false,
    Position = Vector3.new(0.5, 0.5, 0),
    Radius = 1.0,
    Parent = workspace,
})
effect:Play()
```

#### `PlayOneShot(config: HapticEffectConfig)`
Creates and plays a haptic effect, automatically cleaning it up when finished.

```lua
HapticEffects.PlayOneShot({ Type = "UIClick" })
```

#### `CreateCustomEffect(waveformKeys, config?)`
Creates a custom haptic effect with a user-defined waveform.

```lua
local waveform = {
    { Time = 0, Intensity = 0.5 },
    { Time = 200, Intensity = 1.0 },
    { Time = 400, Intensity = 0 },
}
local effect = HapticEffects.CreateCustomEffect(waveform, {
    Type = "Custom", -- Required in strict mode
    Looped = false,
})
effect:Play()
```

**Note:** Keys are interpolated using linear interpolation (`Enum.KeyInterpolationMode.Linear`) by default, creating smooth transitions between intensity values. In strict Luau mode, include `Type = "Custom"` in the config parameter to satisfy the type checker.

### Preset Functions

#### `CreateUIHover(parent?)`
Creates a subtle hover effect for UI elements.

#### `CreateUIClick(parent?)`
Creates a crisp click effect for UI buttons.

#### `CreateUINotification(parent?)`
Creates an attention-grabbing notification effect.

#### `CreateGameplayExplosion(position?, radius?, parent?)`
Creates a large rumble effect for explosions.

#### `CreateGameplayCollision(position?, radius?, parent?)`
Creates a sharp impact effect for collisions.

### Utility Functions

#### `CreateLoopingEffect(config)`
Creates a haptic effect that loops continuously until stopped.

```lua
local engineRumble = HapticEffects.CreateLoopingEffect({
    Type = "GameplayCollision",
})
engineRumble:Play()

-- Stop when done
HapticEffects.StopAndDestroy(engineRumble)
```

#### `StopAndDestroy(effect)`
Stops and destroys a haptic effect.

#### `AwaitEnd(effect)`
Returns a function that yields until the effect completes.

```lua
local effect = HapticEffects.CreateGameplayExplosion()
effect:Play()
HapticEffects.AwaitEnd(effect)()
print("Effect finished!")
```

#### `PlaySequence(sequence)`
Plays multiple haptic effects in sequence with delays.

```lua
local sequence = {
    { delay = 0, effect = { Type = "UINotification" } },
    { delay = 0.2, effect = { Type = "UINotification" } },
    { delay = 0.2, effect = { Type = "UINotification" } },
} :: any -- Cast to 'any' in strict mode
HapticEffects.PlaySequence(sequence)()
```

**Note:** In strict Luau mode, cast the sequence to `any` with `:: any` to avoid type conflicts between literal strings and the HapticEffectType union.

#### `CreateWaveformPattern(pattern, duration, intensity)`
Helper function to create common waveform patterns.

Patterns: `"rampUp"`, `"rampDown"`, `"pulse"`, `"constant"`

```lua
local waveform = HapticEffects.CreateWaveformPattern("rampUp", 500, 1.0)
local effect = HapticEffects.CreateCustomEffect(waveform)
effect:Play()
```

### Advanced Functions

#### `CreateDirectionalEffect(worldPosition, referencePosition, maxDistance, config)`
Creates a directional haptic effect based on 3D positions.

```lua
local player = game.Players.LocalPlayer
local character = player.Character
local explosionPos = Vector3.new(100, 0, 100)

if character then
    local effect = HapticEffects.CreateDirectionalEffect(
        explosionPos,
        character.HumanoidRootPart.Position,
        50, -- max distance
        { Type = "GameplayExplosion" }
    )
    effect:Play()
end
```

## Configuration Types

### HapticEffectConfig

```lua
type HapticEffectConfig = {
    Type: HapticEffectType,
    Looped: boolean?,
    Position: Vector3?,
    Radius: number?,
    Parent: Instance?,
}
```

### WaveformKey

```lua
type WaveformKey = {
    Time: number,    -- Time in milliseconds
    Intensity: number, -- Intensity from 0.0 to 1.0
}
```

**Note:** When creating custom waveforms, keys are automatically interpolated using `Enum.KeyInterpolationMode.Linear` for smooth haptic transitions between defined points.

## Best Practices

1. **Use Predefined Types**: The preset effect types (`UIClick`, `GameplayExplosion`, etc.) are optimized for each device
2. **Keep It Short**: Custom waveforms should be < 1 second for best performance
3. **Don't Overuse**: Haptics enhance experiences but can overwhelm if overused
4. **Test on Devices**: Haptic feedback varies by hardware - test on real devices
5. **Clean Up**: Always destroy looping effects when no longer needed
6. **Respect Preferences**: Consider adding user settings for haptic intensity

### Working with Strict Luau Mode

When using `--!strict` mode, you may need to apply type workarounds:

**For `CreateCustomEffect`**: Include `Type = "Custom"` in the config parameter, even though the function sets it internally:
```lua
local effect = HapticEffects.CreateCustomEffect(waveform, {
    Type = "Custom", -- Required for type checker
    Looped = false,
})
```

**For `PlaySequence`**: Cast the sequence array to `any` to avoid literal string vs union type conflicts:
```lua
local sequence = {
    { delay = 0, effect = { Type = "UINotification" } },
} :: any
```

These workarounds satisfy the type checker while maintaining runtime correctness.

## Position and Radius

- **Position**: Relative to the input device in 0-1 range
  - X: left (0) to right (1)
  - Y: bottom (0) to top (1)
  - Z: affects motor selection on gamepads
- **Radius**: How broadly the effect impacts nearby motors (0-1)

**Note**: Some gamepads only have a single motor, so complex position/radius configurations may not work as expected on all devices.

## Examples

See `ExampleUsage.lua` for comprehensive examples including:
- UI feedback system
- Gameplay effects
- Custom waveforms
- Looping effects
- Directional effects
- Effect sequences
- Pattern-based waveforms

## HapticEffect Properties (Native)

The underlying `HapticEffect` instance has these properties:

- **Type** (HapticEffectType): The type of haptic effect
- **Looped** (boolean): Whether the effect loops continuously
- **Position** (Vector3): Position relative to input device (0-1 range)
- **Radius** (number): Effect radius affecting nearby motors

## HapticEffect Methods (Native)

- **:Play()**: Starts the haptic effect
- **:Stop()**: Stops the haptic effect
- **:SetWaveformKeys(keys)**: Sets custom waveform for Custom type effects

## HapticEffect Events (Native)

- **Ended**: Fires when the effect completes (not for looped effects)

## Technical Details

### Waveform Interpolation

When creating custom haptic effects, the module uses `FloatCurveKey` objects with linear interpolation:

```lua
FloatCurveKey.new(time, intensity, Enum.KeyInterpolationMode.Linear)
```

This provides smooth transitions between keyframes. The available interpolation modes are:
- **Linear**: Smooth straight-line transitions (default, recommended)
- **Constant**: Instant changes with no interpolation
- **Cubic**: Smooth curved transitions

Linear interpolation is used by default as it provides the best balance of smoothness and predictability for haptic feedback.

### Device-Specific Behavior

Different devices have different haptic capabilities:
- **Mobile phones**: Usually have a single vibration motor with varying intensity
- **Console gamepads**: May have dual motors (left/right) for positional effects
- **VR controllers**: Often have multiple haptic actuators for precise feedback

The `Position` and `Radius` properties work best on devices with multiple motors. On single-motor devices, these properties have minimal effect.

## Troubleshooting

**Q: Haptics not working?**
- Ensure you're testing on a supported device
- Check that the script is running on the client (LocalScript)
- Verify that haptic feedback is enabled in device settings

**Q: Effect too weak/strong?**
- Adjust the `Intensity` values in custom waveforms (0.0 to 1.0)
- Try different effect types - some are naturally stronger
- Use `Radius` to control effect spread

**Q: Script editor not showing documentation?**
- Make sure the module is saved properly
- Roblox Studio should automatically detect the `--[=[]=]` documentation comments
- Try reloading the script or restarting Studio

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0).

This means you are free to use, modify, and distribute this software, but any derivative works must also be licensed under GPL-3.0. For more details, see the [GNU GPL-3.0 License](https://www.gnu.org/licenses/gpl-3.0.en.html).

## Credits

Created based on Roblox's official HapticEffect documentation and best practices.

---

For issues or feature requests, please refer to the Roblox Developer Forum or create documentation feedback on the official Roblox Creator Hub.
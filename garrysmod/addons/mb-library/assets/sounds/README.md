# Sounds Directory

Place sound assets for the MB Library here, such as:
- UI sounds (clicks, notifications)
- Ambience
- Effect sounds
- Voice lines

## Supported Sound Formats
- WAV
- MP3
- OGG

## Usage
To play a sound in Garry's Mod:
```lua
-- Client-side sound
surface.PlaySound("mb_library/your_sound.wav")

-- 3D sound in world
EmitSound("mb_library/your_sound.wav", position, entity)
``` 
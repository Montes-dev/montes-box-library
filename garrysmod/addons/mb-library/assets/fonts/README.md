# Fonts Directory

Place font assets for the MB Library here.

## Supported Font Formats
- TTF (TrueType Fonts)
- OTF (OpenType Fonts)

## Usage
To register a font in Garry's Mod:
```lua
surface.CreateFont("MB.Font.Example", {
    font = "Your Font Name",
    size = 24,
    weight = 500,
    antialias = true,
    shadow = false
})
``` 
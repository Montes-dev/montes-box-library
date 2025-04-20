# Textures Directory

Place texture assets for the MB Library here, such as:
- Material textures
- Surface textures
- Normal maps
- Specular maps
- Environmental textures

## Supported Formats
- VTF (Valve Texture Format)
- TGA, PNG, JPG (for imports)

## Usage
To use textures in Garry's Mod:
```lua
-- Creating a material
local material = Material("mb_library/your_texture")

-- Drawing with a material
surface.SetMaterial(material)
surface.DrawTexturedRect(x, y, width, height)

-- 3D model textures should be compiled into .vmt files
``` 
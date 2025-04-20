# Materials Directory

Place material definition files for the MB Library here, such as:
- .vmt files (Valve Material Type)
- Material scripts
- Shader definitions

## Structure
Materials typically consist of:
- .vmt - Material definition file (text-based script)
- Associated textures (referenced in the VMT)

## Example VMT
```
"VertexLitGeneric"
{
    "$basetexture" "mb_library/textures/example_texture"
    "$surfaceprop" "metal"
    "$envmap" "env_cubemap"
    "$envmaptint" "[0.5 0.5 0.5]"
}
```

## Usage
To use materials in Garry's Mod:
```lua
-- Apply material to entity
entity:SetMaterial("mb_library/your_material")

-- Create a material reference
local material = Material("mb_library/your_material")
``` 
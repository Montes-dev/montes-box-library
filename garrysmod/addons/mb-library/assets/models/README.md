# Models Directory

Place 3D model assets for the MB Library here, such as:
- Props
- Characters
- Weapons
- Vehicles
- Environment objects

## Supported Formats
- MDL (Valve Model Format)
- SMD (Source Model Format)
- OBJ (for imports)

## Model Structure
Models typically require several accompanying files:
- .mdl - Compiled model file
- .vvd - Vertex data
- .vtx - Vertex indices
- .phy - Physics data (collision)

## Usage
To use models in Garry's Mod:
```lua
-- Entity model
entity:SetModel("models/mb_library/your_model.mdl")

-- Client-side model
local modelEntity = ClientsideModel("models/mb_library/your_model.mdl")
``` 
# MB Library Assets

This directory contains all media and resource files for the MB Library framework. Assets are organized into subdirectories by type for easy management.

## Directory Structure

- **fonts/** - Typography resources
- **icons/** - UI and interface icons
- **images/** - General image assets
- **materials/** - Material definition files (.vmt)
- **models/** - 3D model assets
- **sounds/** - Audio files
- **textures/** - Texture files for materials

## Guidelines

1. **Naming Convention**: Use lowercase names with underscores, prefixed with `mb_` (e.g., `mb_button_icon.png`)
2. **Organization**: Place files in the appropriate subdirectory based on asset type
3. **Optimization**: Compress and optimize assets before adding them
4. **Licensing**: Ensure all assets have proper licensing for use

## File Paths

When referencing assets in Lua code, use the following pattern:

```lua
-- For models:
"models/mb_library/your_model.mdl"

-- For materials:
"materials/mb_library/your_material"

-- For sounds:
"mb_library/your_sound.wav"
``` 
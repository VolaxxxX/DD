# Ground textures — credits (all CC0, polyhaven.com)

Per biome: diffuse + GL normal + roughness (1k JPG).

| Biome | Polyhaven asset |
|---|---|
| forest | forest_ground_04 |
| city | cobblestone_floor_04 |
| ruins | rocky_trail |
| corrupted | brown_mud_dry |
| anomaly | rocky_terrain_02 |
| swamp | brown_mud_leaves_01 |
| highland | aerial_grass_rock |
| crypt | cobblestone_floor_08 |
| coast | coast_sand_01 |

Wired in render/backdrop_3d.gd _build_ground: albedo + normal + roughness
texture + AO (from the roughness map).

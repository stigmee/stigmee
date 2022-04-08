# Stigmee

This [repo](https://github.com/stigmee/stigmee) contains all the Godot script code making possible the Stigmee application. It uses other repos inside the Stigmee [workspace](https://github.com/stigmee/manifest), compiled as libraries to be used as gdnative code:
- Chromium Embedded Framework: https://github.com/stigmee/gdnative-cef
- Stigmark: https://github.com/stigmee/gdnative-stigmark

The Stigmee project is compiled by the following repo:
- https://github.com/stigmee/install

The Stigmee binary, assets and artifacts are compiled inside the created `build/` folder.

## Camera Bindings

- `W` or `UP`: forward translation the camera.
- `S` or `DOWN`: backward translation the camera.
- `D` or `RIGHT`: right translation the camera.
- `A` or `LEFT`: left translation the camera.
- `R`: zoom in.
- `F`: zoom out.
- `O`: camera CCW rotation.
- `I`: camera CW rotation.
- left mouse button pressed: camera translation.
- middle mouse button pressed: camera rotation.
- mouse scroll: zoom (not fonctional).
- double left button click on the moving cube: track the cube.
- `SHIFT`: allows to increase the camera displacement.
- `ESCAPE`: stop tracking the cube.

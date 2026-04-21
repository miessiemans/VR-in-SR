# Thames Final Project – Unity VR Simulation

This folder contains the complete working Unity VR simulation project prepared for the Thames scene.

The project already includes:

- The Thames building and river model
- All textures and materials
- Main scene setup
- 360 environment / sky setup
- Water animation
- Automatic forward camera movement
- Infinite loop system so the river does not feel like it ends

This project is intended to be the **base simulation**.  
The remaining task is for the relativistic effects scripts to be added and connected to this scene.

---

# 1. Important overview

This project is already prepared as a Unity project.

That means the main files are already inside:

- `Assets`
- `Packages`
- `ProjectSettings`

So **do not** try to import random files one by one into another empty Unity project unless absolutely necessary.

The correct way is to open this folder directly in Unity Hub.

---

# 2. What has already been done

The following has already been completed in this project:

## Scene and environment
- A working main scene has been created
- The Thames model is already placed into the scene
- Building materials and textures are already assigned
- The sky / 360 environment has already been added

## Water
- A working water material has already been created
- Water tiling has already been adjusted
- Water movement script has already been added

## Movement
- A forward movement script has already been added to the camera
- The project can auto-move through the scene

## Infinite river loop
- A loop system has already been added
- When the camera reaches the end trigger, it returns to the start so the simulation continues

---

# 3. Project structure

The important structure is:

```text
Thames_Final_Project/
│
├── Assets/
│   ├── Material/
│   │   ├── M_skybox_main.mat
│   │   ├── M_skyline.mat
│   │   └── M_water.mat
│   │
│   ├── Models/
│   │   └── final Thames building (1).fbx
│   │
│   ├── Scenes/
│   │   └── MainScene.unity
│   │
│   ├── Scripts/
│   │   ├── Core/
│   │   │   ├── Loop/
│   │   │   │   └── LoopTeleport.cs
│   │   │   ├── Movement/
│   │   │   │   └── AutoMove.cs
│   │   │   └── Water/
│   │   │       └── waterscroll.cs
│   │   │
│   │   └── Relativistic_Affects/
│   │       └── (This is where relativistic scripts should go)
│   │
│   ├── Textures/
│   │   └── (all textures used by the model, sky, skyline, and water)
│   │
│   └── Settings/
│       └── (render pipeline and scene settings)
│
├── Packages/
│
└── ProjectSettings/

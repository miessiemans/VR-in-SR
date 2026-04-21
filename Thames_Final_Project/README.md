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

> **IMPORTANT**
>
> Anyone uploading scripts for the relativistic effects must place them inside:
>
> `Assets/Scripts/Relativistic_Effects/`
>
> If this folder does not already exist, create it and upload all relativistic scripts there.
>
> Do **not** upload these scripts into random folders.

---

# 5. WARNING – LOOPTELEPORT IS CURRENTLY LINKED TO THE MAIN CAMERA

> **CRITICAL**
>
> The current `LoopTeleport.cs` setup uses the **Main Camera** as the player/user object.
>
> This is extremely important.
>
> If you are using a different player object instead of the Main Camera, you must change the assigned player object in the `LoopTeleport` component inside Unity.
>
> In the Inspector, the player reference is currently assigned to the **Main Camera**.
>
> If you are using your own player object, replace that reference with your own object.
>
> If you do not change this, the looping system may not work correctly.

---

# 6. WARNING – `AutoMove.cs` MAY CLASH WITH YOUR OWN MOVEMENT SCRIPTS

> **CRITICAL**
>
> `AutoMove.cs` currently moves the **camera** forward automatically.
>
> This means that if you add your own player movement script while `AutoMove.cs` is still enabled, the two scripts may conflict with each other.

## What to do

### If you are using your own movement/player controller
- Disable or untick `AutoMove.cs` in the Inspector

### If you are still using the Main Camera as the moving object
- You may keep `AutoMove.cs` enabled only if that is intentional

### If you are not using the Main Camera as the player object
- Go to the `LoopTeleport` component
- Find the assigned player/user reference
- Replace **Main Camera** with your own player object

This is extremely important for correct testing.

---

# 7. Important scene note

You may notice a **large sphere** in the scene.

This is intentional.

The river model/environment is placed inside it as part of the scene setup and background system.

So if you see a large sphere surrounding the environment, that is expected and not necessarily a mistake.

---

# 8. How to use this project on your own PC

## Recommended method

This project should be opened as a full Unity project.

### Steps
1. Clone or download the repository from GitHub
2. Make sure the correct Unity version is installed
3. Open **Unity Hub**
4. Click **Add project** or **Open**
5. Select the folder that contains:
   - `Assets`
   - `Packages`
   - `ProjectSettings`
6. Open the project in Unity
7. Open

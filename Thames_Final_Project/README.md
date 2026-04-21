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
```
---

# 🚨 WARNING – FOR ANYONE ADDING RELATIVISTIC EFFECTS 🚨

> [!IMPORTANT]
> Anyone uploading scripts for the relativistic effects **must place them inside**:
>
> `Assets/Scripts/Relativistic_Effects/`
>
> If this folder does not already exist, **create it first** and then upload all relativistic scripts there.
>
> **Do not** upload these scripts into random folders.

---

# 🚨 WARNING – `LoopTeleport.cs` IS CURRENTLY LINKED TO THE MAIN CAMERA 🚨

> [!WARNING]
> The current `LoopTeleport.cs` setup uses the **Main Camera** as the player/user object.
>
> This is extremely important.

## If you are using the Main Camera as the player
You can leave this as it is.

## If you are using a different player object
You **must** change the assigned player object in the `LoopTeleport` component inside Unity.

### What to check
- Open the object that has the `LoopTeleport` component
- In the Inspector, find the assigned player/user reference
- It is currently assigned to the **Main Camera**
- Replace that reference with **your own player object**

> [!CAUTION]
> If you do not change this, the loop/teleport system may not work correctly.

---

# 🚨 WARNING – `AutoMove.cs` MAY CLASH WITH YOUR OWN MOVEMENT SCRIPTS 🚨

> [!WARNING]
> `AutoMove.cs` currently moves the **camera** forward automatically.
>
> If you add your own movement/controller script while `AutoMove.cs` is still enabled, the two scripts may conflict with each other.

## What to do

### If you are using your own movement/player controller
- Disable or untick `AutoMove.cs` in the Inspector

### If you are still using the Main Camera as the moving object
- You may keep `AutoMove.cs` enabled only if that is intentional

### If you are not using the Main Camera as the player object
- Go to the `LoopTeleport` component
- Find the assigned player/user reference
- Replace **Main Camera** with your own player object

> [!CAUTION]
> This is a critical step before testing.

---

# 🌐 Important Scene Note

You may notice a **large sphere** in the scene.

This is intentional.

The river/environment setup is placed inside it as part of the background / surrounding scene structure.

> [!NOTE]
> If you see a large sphere around the river environment, that is expected and not necessarily a mistake.

---

# 💻 How to Use This Project on Your Own PC

## Recommended method

This project should be opened as a **full Unity project**.

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
7. Open the main scene:
   - `Assets/Scenes/MainScene.unity`

> [!IMPORTANT]
> Do **not** create a new empty Unity project and drag files in randomly unless absolutely necessary.

---

# 📦 If You Need to Import This Into Another Unity Project

This is **not the preferred method**, but if it becomes necessary, import at minimum:

- `Assets`
- `Packages`
- `ProjectSettings`

> [!WARNING]
> If only selected scene files or scripts are moved without the correct dependencies, materials, settings, references, or scripts may break.

---

# 🔄 How to Upload Your Own Changes Safely

If you make changes to the project, use GitHub properly so the main project is not overwritten by mistake.

## Basic workflow

### 1. Pull the latest changes
```bash
git pull origin main

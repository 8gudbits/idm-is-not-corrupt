# idm-is-not-corrupt

Fix "IDM is corrupt" - **forever**.

## Overview

If you have downloaded the **Internet Download Manager** from your favourite website, and now you get this annoying popup all the time -

![](/idm-is-corrupt.jpg)

**This is the time to fix it** using **IDM-INC** (`IDM IS NOT CORRUPT`).

## Download & Usage

You have two options depending on how you want to fix the **"IDM is corrupt"** issue:

1. **Download** [idm-inc-for-taskbar.exe]()

This is the manual trigger version.

- Pin it to your taskbar (make it the first item)
- When the error popup appears, press `Win + 1`

Perfect if you want quick control without background monitoring.

2. **Download** [idm-inc-watchdog.exe]()

This is the automatic watchdog version.

- Press Win + R and type `shell:startup` in the run box
  ![](/run-box.jpg)
- `Right-click` → `New` → `Shortcut` and point it to `idm-inc-watchdog.exe`
- It will run silently every time your system starts, watching for the error and fixing it automatically

**Note:** This version checks for the error every 3 seconds so it might take a moment to go away after popup appears.

## Custom IDM path (if not installed in default location)

If IDM isn’t installed in the default path (`C:\Program Files (x86)\Internet Download Manager\`):

- Run any version of the tool once
  A file called **`idman-path.txt`** will be auto-created next to the `.exe`
- Open it and paste your actual IDM install path
- From then on, the tool will use that path automatically

## For the tech people

- These `.exe` files are compiled using [VBS2CPP](https://github.com/8gudbits/VBS2CPP) which is a C++ wrapper for VBS.


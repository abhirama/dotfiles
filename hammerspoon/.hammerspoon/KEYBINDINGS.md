# Hammerspoon Keybindings

> **Note:** This is a human-readable reference guide. The actual code in `init.lua` and `hyper_vim.lua` is the source of truth. If there's a discrepancy, the code is correct.

**Hyper Key:** `Ctrl + Alt + Cmd + Shift` (typically mapped to CapsLock via Karabiner or Raycast)

---

## Context-Aware Vim Navigation (hyper_vim.lua)

### In Raycast
When Raycast overlay is visible:
- `Hyper + h` → `Ctrl + h` (navigate left in list)
- `Hyper + j` → `Ctrl + j` (navigate down in list)
- `Hyper + k` → `Ctrl + k` (navigate up in list)
- `Hyper + l` → `Ctrl + l` (navigate right in list)

### Global Navigation
When Raycast is NOT visible:
- `Hyper + h` → Left arrow
- `Hyper + j` → Down arrow
- `Hyper + k` → Up arrow
- `Hyper + l` → Right arrow

> **Note:** These keybindings use an eventtap (high-priority interception) which runs before regular hotkey bindings. This means hjkl are currently intercepted by hyper_vim and converted to arrows, preventing other bindings from seeing the original hjkl keypresses.

---

## Window Management (MiroWindowsManager Spoon)

- `Hyper + ↑` → Snap window to top half
- `Hyper + ↓` → Snap window to bottom half
- `Hyper + ←` → Snap window to left half
- `Hyper + →` → Snap window to right half
- `Hyper + f` → Fullscreen window

---

## Multi-Monitor Management

- `Hyper + Space` → Move window to next monitor (maintains size and position)

---

## Application Launcher

- `Hyper + Return` → Toggle Raycast spotlight
  - If Raycast is running: triggers `Alt + Space` (Raycast hotkey)
  - If Raycast is not running: launches Raycast

---

## Utilities

- `Hyper + v` → Force paste (bypasses paste restrictions by typing clipboard character-by-character)
- `Hyper + r` → Reload Hammerspoon configuration

---

## Configuration Status

**Active Modules:**
- `hyper_vim.lua` - Context-aware Vim navigation
  - `enableGlobalVimArrows = true`
- `MiroWindowsManager.spoon` - Window management (via SpoonInstall)

---

## Technical Notes

### Hyper Key Definition
```lua
hyper = { "ctrl", "alt", "cmd", "shift" }
```

### Event Priority
1. **Eventtaps** (hyper_vim) - Highest priority, intercepts before hotkeys
2. **Hotkey bindings** (hs.hotkey.bind) - Standard priority
3. **Spoon hotkeys** (MiroWindowsManager) - Standard priority

This explains why hyper_vim's hjkl interception prevents MiroWindowsManager from seeing those keys.

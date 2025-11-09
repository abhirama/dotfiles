--------------------------------------------------
-- Basic Hammerspoon init.lua
-- Sets up Hyper key (CapsLock → ⌃⌥⌘⇧)
-- and loads the hyper_vim.lua module
--------------------------------------------------

-- Define Hyper key combination
-- (must match how your CapsLock/Hyper is configured in Karabiner or Raycast)
hyper = { "ctrl", "alt", "cmd", "shift" }

--------------------------------------------------
-- Load custom Hyper+Vim navigation module
--------------------------------------------------

-- Safely require the module; show an alert if something goes wrong
local ok, hyperVim = pcall(require, "hyper_vim")
if not ok then
  hs.alert.show("Failed to load hyper_vim.lua: " .. tostring(hyperVim))
else
  -- Start context-aware Vim-style navigation
  hyperVim.start({
    hyperMods = hyper,          -- use the Hyper key defined above
    enableGlobalVimArrows = true  -- set false to limit to Raycast only
  })
end

--------------------------------------------------
-- Hyper + Space: move window to next monitor AND focus/raise it
--------------------------------------------------

hs.hotkey.bind(hyper, "space", function()
  local win = hs.window.focusedWindow()
  if not win then
    hs.alert.show("No active window")
    return
  end

  local currentScreen = win:screen()
  local nextScreen = currentScreen:next()
  if not nextScreen then return end

  -- Move to next screen, keep relative position & size
  win:moveToScreen(nextScreen, false, true)

  -- Explicitly bring it to the front & keep focus
  win:raise()
  win:focus()
end)

--------------------------------------------------
-- Optional: simple reload hotkey for development
--------------------------------------------------
hs.hotkey.bind(hyper, "r", function()
  hs.reload()
  hs.alert.show("Hammerspoon reloaded")
end)

--------------------------------------------------
-- Miro Windows Manager: Hyper + Arrows to snap
-- and Hyper + Return to fullscreen
--------------------------------------------------

hs.loadSpoon("MiroWindowsManager")

spoon.MiroWindowsManager:bindHotkeys({
  up         = { hyper, "up" },     -- top half
  down       = { hyper, "down" },   -- bottom half
  left       = { hyper, "left" },   -- left half
  right      = { hyper, "right" },  -- right half
  fullscreen = { hyper, "f" },      -- full screen
})


--------------------------------------------------
-- Confirmation on load
--------------------------------------------------
hs.alert.show("Hammerspoon config loaded")

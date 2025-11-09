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
-- Optional: simple reload hotkey for development
--------------------------------------------------
hs.hotkey.bind(hyper, "r", function()
  hs.reload()
  hs.alert.show("Hammerspoon reloaded")
end)

--------------------------------------------------
-- Confirmation on load
--------------------------------------------------
hs.alert.show("Hammerspoon config loaded")

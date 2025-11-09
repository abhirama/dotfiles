-- hyper_vim.lua
-- Context-aware Hyper+h/j/k/l navigation:
--  * In Raycast: Hyper+hjkl -> Ctrl+hjkl (Vim-style list nav)
--  * Elsewhere: optional Vim-style arrows (hjkl -> ←↓↑→)

local eventtap  = require("hs.eventtap")
local event     = eventtap.event
local keycodes  = require("hs.keycodes")
local types     = eventtap.event.types

local M = {}
local tap

local function makeIsHyper(hyperMods)
  local want = { ctrl=false, alt=false, cmd=false, shift=false }
  for _, m in ipairs(hyperMods) do
    want[m] = true
  end
  return function(flags)
    return flags.ctrl  == (want.ctrl  or false)
       and flags.alt   == (want.alt   or false)
       and flags.cmd   == (want.cmd   or false)
       and flags.shift == (want.shift or false)
  end
end

local function isRaycastVisible()
  local app = hs.application.find("Raycast")
  if not app then return false end
  for _, win in ipairs(app:allWindows()) do
    if win:isVisible() then
      return true
    end
  end
  return false
end

local function sendCtrlKey(key)
  return {
    event.newKeyEvent({ "ctrl" }, key, true),
    event.newKeyEvent({ "ctrl" }, key, false),
  }
end

local function sendArrow(name)
  local code = keycodes.map[name]
  if not code then return nil end
  return {
    event.newKeyEvent({}, code, true),
    event.newKeyEvent({}, code, false),
  }
end

function M.start(opts)
  if tap then
    tap:stop()
    tap = nil
  end

  opts = opts or {}

  -- use passed-in hyperMods, or global `hyper`, or default
  local hyperMods = opts.hyperMods or _G.hyper or { "ctrl", "alt", "cmd", "shift" }
  local enableGlobalVimArrows = (opts.enableGlobalVimArrows ~= false)

  local isHyper = makeIsHyper(hyperMods)

  tap = eventtap.new({ types.keyDown }, function(e)
    local flags = e:getFlags()
    local code  = e:getKeyCode()
    local key   = keycodes.map[code]

    if not isHyper(flags) then
      return false
    end

    if key ~= "h" and key ~= "j" and key ~= "k" and key ~= "l" then
      return false
    end

    -- Raycast context: Hyper+hjkl → Ctrl+hjkl
    if isRaycastVisible() then
      local events = sendCtrlKey(key)
      if events then return true, events end
      return true
    end

    -- Global context: optional Vim-style arrows
    if enableGlobalVimArrows then
      local arrow =
        (key == "h" and "left")
        or (key == "j" and "down")
        or (key == "k" and "up")
        or (key == "l" and "right")

      local events = sendArrow(arrow)
      if events then return true, events end
      return true
    end

    return false
  end)

  tap:start()
end

function M.stop()
  if tap then
    tap:stop()
    tap = nil
  end
end

return M


-- hyper_vim.lua
-- Context-aware Hyper+h/j/k/l navigation:
--  * In Raycast: Hyper+hjkl -> Ctrl+hjkl (Vim-style list nav)
--  * Elsewhere: optional Vim-style arrows (hjkl -> ←↓↑→)
--
-- HISTORY & RATIONALE:
-- This evolved after several debugging rounds:
--   • Initially we tried detecting Raycast using frontmostApplication(),
--     but that failed because Raycast behaves like Spotlight—its overlay
--     can be visible while macOS still reports another app (like Chrome)
--     as frontmost.  Solution: detect Raycast via any *visible* window.
--   • We once used hs.eventtap.keyStroke to send keys, but that was flaky
--     in transient apps like Raycast. Returning new key events directly
--     from an eventtap callback is more reliable.
--   • Early Hyper detection was too loose—when misconfigured, it matched
--     plain 'j/k' with no modifiers, hijacking typing. We now check for an
--     exact match to the defined Hyper modifiers.
--   • Browser Vim extensions like Vimium also map j/k for scrolling; this
--     script never touches plain hjkl, so any scroll behavior there is
--     from the extension, not Hammerspoon.
--   • The design now cleanly separates logic: Hyper detection, context
--     check (Raycast visible or not), and event transformation.

local eventtap  = require("hs.eventtap")  -- For intercepting key events
local event     = eventtap.event          -- For creating synthetic events
local keycodes  = require("hs.keycodes")  -- Map between key names and codes
local types     = eventtap.event.types    -- Key event type constants

local M = {}     -- Module table to export start() / stop()
local tap        -- Active eventtap instance reference

-- Create a function that checks if currently pressed modifiers
-- exactly match the desired Hyper combo.
-- The need for exact matching came from earlier bugs where empty
-- or incorrect Hyper definitions matched plain keys.
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

-- Detect if Raycast is visible.
-- We switched from frontmostApplication() to this visibility check
-- after discovering that Raycast can appear on top even when the
-- OS still reports another app as active.
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

-- Terminal app detection for context-aware shortcuts.
-- B/W/D use Karabiner's frontmost_application_if for the same purpose;
-- U/X are handled here in Hammerspoon and need this Lua-side check.
local terminalBundleIDs = {
  ["com.googlecode.iterm2"] = true,
  ["com.apple.Terminal"] = true,
}

local function isTerminalApp()
  local app = hs.application.frontmostApplication()
  if not app then return false end
  local bid = app:bundleID()
  return bid ~= nil and terminalBundleIDs[bid] == true
end

-- iTerm2-specific detection for tab management shortcuts.
-- These use iTerm2's AppleScript API and only apply when iTerm2 is frontmost.
local function isITerm()
  local app = hs.application.frontmostApplication()
  if not app then return false end
  return app:bundleID() == "com.googlecode.iterm2"
end

-- Chrome detection for tab management shortcuts.
-- Chrome has a clean AppleScript API with direct `active tab index` access.
local function isChrome()
  local app = hs.application.frontmostApplication()
  if not app then return false end
  return app:bundleID() == "com.google.Chrome"
end

-- Cycle iTerm2 tabs with wrap-around (circular buffer).
-- Uses AppleScript because native Cmd+Shift+]/[ doesn't wrap at boundaries.
-- Deferred via hs.timer.doAfter(0, ...) to avoid blocking the eventtap callback.
local function iTermCycleTab(direction)
  local delta = direction == "next" and 1 or -1
  local script = string.format([[
    tell application "iTerm2"
      if (count of windows) is 0 then return
      tell current window
        set tabCount to count of tabs
        if tabCount is less than or equal to 1 then return
        set curTab to current tab
        set curIdx to 1
        repeat with i from 1 to tabCount
          if tab i is curTab then
            set curIdx to i
            exit repeat
          end if
        end repeat
        set nextIdx to curIdx + (%d)
        if nextIdx < 1 then set nextIdx to tabCount
        if nextIdx > tabCount then set nextIdx to 1
        select tab nextIdx
      end tell
    end tell
  ]], delta)
  hs.osascript.applescript(script)
end

-- Cycle Chrome tabs with wrap-around (circular buffer).
-- Chrome's AppleScript API exposes `active tab index` directly,
-- making this simpler than iTerm2's tab cycling.
local function chromeCycleTab(direction)
  local delta = direction == "next" and 1 or -1
  local script = string.format([[
    tell application "Google Chrome"
      if (count of windows) is 0 then return
      tell front window
        set tabCount to count of tabs
        if tabCount is less than or equal to 1 then return
        set curIdx to active tab index
        set nextIdx to curIdx + (%d)
        if nextIdx < 1 then set nextIdx to tabCount
        if nextIdx > tabCount then set nextIdx to 1
        set active tab index to nextIdx
      end tell
    end tell
  ]], delta)
  hs.osascript.applescript(script)
end

-- Helper to synthesize Ctrl+key press/release events.
-- We use explicit newKeyEvent instead of keyStroke for finer control
-- and to avoid focus/timing issues seen in early attempts.
local function sendCtrlKey(key)
  return {
    event.newKeyEvent({ "ctrl" }, key, true),
    event.newKeyEvent({ "ctrl" }, key, false),
  }
end

-- Helper to synthesize Cmd+key press/release events.
-- Used for macOS-native text editing shortcuts (e.g. Cmd+Backspace).
local function sendCmdKey(key)
  return {
    event.newKeyEvent({ "cmd" }, key, true),
    event.newKeyEvent({ "cmd" }, key, false),
  }
end

-- Helper to synthesize arrow key presses.
-- Used when global Vim-like navigation is enabled.
local function sendArrow(name)
  local code = keycodes.map[name]
  if not code then return nil end
  return {
    event.newKeyEvent({}, code, true),
    event.newKeyEvent({}, code, false),
  }
end

-- Main entry point: starts the eventtap.
function M.start(opts)
  -- Ensure we don't end up with duplicate taps on reload.
  if tap then
    tap:stop()
    tap = nil
  end

  opts = opts or {}

  -- Use the passed-in Hyper definition, or fallback to global `_G.hyper`
  -- (if defined in init.lua), or finally to the default full Hyper chord.
  -- This flexible chain was added so you can define Hyper once globally.
  local hyperMods = opts.hyperMods or _G.hyper or { "ctrl", "alt", "cmd", "shift" }

  -- Optional flag that enables global arrow-key behavior.
  -- If false, the module will only affect Raycast.
  local enableGlobalVimArrows = (opts.enableGlobalVimArrows ~= false)

  -- Compile our Hyper-checker function.
  local isHyper = makeIsHyper(hyperMods)

  -- Core eventtap: listens for all keyDown events and selectively rewrites them.
  tap = eventtap.new({ types.keyDown }, function(e)
    local flags = e:getFlags()
    local code  = e:getKeyCode()
    local key   = keycodes.map[code]

    -- Ignore all events that aren't Hyper combos.
    if not isHyper(flags) then
      return false
    end

    -- Hyper+A/E: line navigation (Ctrl+A/E) — always, regardless of context.
    if key == "a" or key == "e" then
      local events = sendCtrlKey(key)
      if events then return true, events end
      return true
    end

    -- Hyper+B/W/D: word navigation and deletion.
    -- These are handled by Karabiner at the HID level (not Hammerspoon),
    -- which outputs Left Option+key events with proper device flags.
    -- iTerm2's Esc+ setting then translates them into Meta escape sequences
    -- (\eb, \ef, \ed) that work in both zsh and TUI apps like Claude Code.

    -- Hyper+U: delete to beginning of line (context-aware).
    -- Terminal: Ctrl+U (zsh backward-kill-line).
    -- Other apps: Cmd+Backspace (macOS delete-to-line-start).
    if key == "u" then
      local events
      if isTerminalApp() then
        events = sendCtrlKey("u")
      else
        events = sendCmdKey("delete")
      end
      if events then return true, events end
      return true
    end

    -- Hyper+X: delete to end of line.
    -- Ctrl+K works in both terminals (zsh kill-line) and Cocoa text fields
    -- (deleteToEndOfParagraph:), so no context switch is needed.
    if key == "x" then
      local events = sendCtrlKey("k")
      if events then return true, events end
      return true
    end

    -- Hyper+': app switching (Cmd+Tab) — switch to most recently used app.
    if key == "'" then
      local events = sendCmdKey("tab")
      if events then return true, events end
      return true
    end

    -- Hyper+T/N/P/Q: Tab management for iTerm2 and Chrome.
    -- T = new tab, N = next tab (wrap), P = previous tab (wrap), Q = close tab.
    -- Context-aware: only activates when iTerm2 or Chrome is frontmost.
    -- These pass through to other apps so their default Hyper bindings
    -- (if any) are preserved.
    if key == "t" then
      if isITerm() or isChrome() then
        local events = sendCmdKey("t")
        if events then return true, events end
        return true
      end
      return false
    end

    if key == "q" then
      if isITerm() or isChrome() then
        local events = sendCmdKey("w")
        if events then return true, events end
        return true
      end
      return false
    end

    if key == "n" or key == "p" then
      local dir = key == "n" and "next" or "prev"
      if isITerm() then
        hs.timer.doAfter(0, function() iTermCycleTab(dir) end)
        return true
      end
      if isChrome() then
        hs.timer.doAfter(0, function() chromeCycleTab(dir) end)
        return true
      end
      return false
    end

    -- Ignore keys other than h/j/k/l.
    if key ~= "h" and key ~= "j" and key ~= "k" and key ~= "l" then
      return false
    end

    -- CASE 1: Raycast is visible → send Ctrl+h/j/k/l
    -- Earlier we verified this path works even when Raycast overlay
    -- is active but not technically the frontmost application.
    if isRaycastVisible() then
      local events = sendCtrlKey(key)
      if events then return true, events end
      return true  -- Swallow the original
    end

    -- CASE 2: Global fallback → optional Vim-style arrows.
    -- If Raycast isn’t visible, and global arrows are enabled, we map
    -- Hyper+h/j/k/l to ←↓↑→ respectively.
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

    -- Otherwise, let the keypress pass through untouched.
    return false
  end)

  tap:start()  -- Start listening.
end

-- Stops the tap cleanly.
-- This is helpful when reloading config or debugging.
function M.stop()
  if tap then
    tap:stop()
    tap = nil
  end
end

-- Export the module.
return M


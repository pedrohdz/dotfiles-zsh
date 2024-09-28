local wezterm = require 'wezterm'
local action = wezterm.action

local _M = {}

function _M.apply(config)
  config.disable_default_mouse_bindings = false
  -- config.mouse_bindings = {
  --   -- SHIFT | ALT    Down { streak: 1, button: Left } ->   ExtendSelectionToMouseCursor(Block)
  --   {
  --     event = { Down = { streak = 1, button = 'Left' } },
  --     mods = 'SHIFT|ALT',
  --     action = action.DisableDefaultAssignment,
  --   },
  --   -- SHIFT | ALT    Up { streak: 1, button: Left } ->   CompleteSelectionOrOpenLinkAtMouseCursor(PrimarySelection)
  --   {
  --     event = { Up = { streak = 1, button = 'Left' } },
  --     mods = 'SHIFT|ALT',
  --     action = action.DisableDefaultAssignment,
  --   },
  -- }
end

return _M

-- ----------------------------------------------------------------------------
-- NOTE - Original (stock) Mouse bindings:
--
--  ```
--  wezterm show-keys
--  ```
--
-- ----------------------------------------------------------------------------

-- Mouse
-- -----
--
--                        Down { streak: 1, button: Left }           ->   SelectTextAtMouseCursor(Cell)
--         SHIFT          Down { streak: 1, button: Left }           ->   ExtendSelectionToMouseCursor(Cell)
--         ALT            Down { streak: 1, button: Left }           ->   SelectTextAtMouseCursor(Block)
--         SHIFT | ALT    Down { streak: 1, button: Left }           ->   ExtendSelectionToMouseCursor(Block)
--                        Down { streak: 1, button: Middle }         ->   PasteFrom(PrimarySelection)
--                        Down { streak: 1, button: WheelUp(1) }     ->   ScrollByCurrentEventWheelDelta
--                        Down { streak: 1, button: WheelDown(1) }   ->   ScrollByCurrentEventWheelDelta
--                        Down { streak: 2, button: Left }           ->   SelectTextAtMouseCursor(Word)
--                        Down { streak: 3, button: Left }           ->   SelectTextAtMouseCursor(Line)
--                        Drag { streak: 1, button: Left }           ->   ExtendSelectionToMouseCursor(Cell)
--         ALT            Drag { streak: 1, button: Left }           ->   ExtendSelectionToMouseCursor(Block)
--         SHIFT | CTRL   Drag { streak: 1, button: Left }           ->   StartWindowDrag
--         SUPER          Drag { streak: 1, button: Left }           ->   StartWindowDrag
--                        Drag { streak: 2, button: Left }           ->   ExtendSelectionToMouseCursor(Word)
--                        Drag { streak: 3, button: Left }           ->   ExtendSelectionToMouseCursor(Line)
--                        Up { streak: 1, button: Left }             ->   CompleteSelectionOrOpenLinkAtMouseCursor(ClipboardAndPrimarySelection)
--         SHIFT          Up { streak: 1, button: Left }             ->   CompleteSelectionOrOpenLinkAtMouseCursor(ClipboardAndPrimarySelection)
--         ALT            Up { streak: 1, button: Left }             ->   CompleteSelection(ClipboardAndPrimarySelection)
--         SHIFT | ALT    Up { streak: 1, button: Left }             ->   CompleteSelectionOrOpenLinkAtMouseCursor(PrimarySelection)
--                        Up { streak: 2, button: Left }             ->   CompleteSelection(ClipboardAndPrimarySelection)
--                        Up { streak: 3, button: Left }             ->   CompleteSelection(ClipboardAndPrimarySelection)
--
-- Mouse: alt_screen
-- -----------------
--
--                        Down { streak: 1, button: Left }     ->   SelectTextAtMouseCursor(Cell)
--         SHIFT          Down { streak: 1, button: Left }     ->   ExtendSelectionToMouseCursor(Cell)
--         ALT            Down { streak: 1, button: Left }     ->   SelectTextAtMouseCursor(Block)
--         SHIFT | ALT    Down { streak: 1, button: Left }     ->   ExtendSelectionToMouseCursor(Block)
--                        Down { streak: 1, button: Middle }   ->   PasteFrom(PrimarySelection)
--                        Down { streak: 2, button: Left }     ->   SelectTextAtMouseCursor(Word)
--                        Down { streak: 3, button: Left }     ->   SelectTextAtMouseCursor(Line)
--                        Drag { streak: 1, button: Left }     ->   ExtendSelectionToMouseCursor(Cell)
--         ALT            Drag { streak: 1, button: Left }     ->   ExtendSelectionToMouseCursor(Block)
--         SHIFT | CTRL   Drag { streak: 1, button: Left }     ->   StartWindowDrag
--         SUPER          Drag { streak: 1, button: Left }     ->   StartWindowDrag
--                        Drag { streak: 2, button: Left }     ->   ExtendSelectionToMouseCursor(Word)
--                        Drag { streak: 3, button: Left }     ->   ExtendSelectionToMouseCursor(Line)
--                        Up { streak: 1, button: Left }       ->   CompleteSelectionOrOpenLinkAtMouseCursor(ClipboardAndPrimarySelection)
--         SHIFT          Up { streak: 1, button: Left }       ->   CompleteSelectionOrOpenLinkAtMouseCursor(ClipboardAndPrimarySelection)
--         ALT            Up { streak: 1, button: Left }       ->   CompleteSelection(ClipboardAndPrimarySelection)
--         SHIFT | ALT    Up { streak: 1, button: Left }       ->   CompleteSelectionOrOpenLinkAtMouseCursor(PrimarySelection)
--                        Up { streak: 2, button: Left }       ->   CompleteSelection(ClipboardAndPrimarySelection)
--                        Up { streak: 3, button: Left }       ->   CompleteSelection(ClipboardAndPrimarySelection)

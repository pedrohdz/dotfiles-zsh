local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- config.font = wezterm.font('JetBrains Mono')
config.font_rules = {
  {
    intensity = 'Bold',
    italic = false,
    font = wezterm.font({
      family = 'JetBrains Mono',
      weight = 'ExtraBold',
      italic = false,
    }),
  },
}


-- config.color_scheme = 'Default Dark (base16)'
config.color_scheme = 'iTerm2 Default'  -- FIXME - Broken
config.colors = {
  foreground = '#00ab00',
  cursor_bg = '#00f45e'
}

config.adjust_window_size_when_changing_font_size = false
config.bold_brightens_ansi_colors = 'No'
config.font_size = 15
config.window_background_opacity = 0.85

config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE|MACOS_FORCE_ENABLE_SHADOW'



config.keys = {
  {
    action = wezterm.action.ActivateTabRelativeNoWrap(-1),
    key = 'LeftArrow',
    mods = 'CMD|OPT',
  },
  {
    action = wezterm.action.ActivateTabRelativeNoWrap(1),
    key = 'RightArrow',
    mods = 'CMD|OPT',
  },
  {
    action = wezterm.action.MoveTabRelative(-1),
    key = 'LeftArrow',
    mods = 'SHIFT|CMD',
  },
  {
    action = wezterm.action.MoveTabRelative(1),
    key = 'RightArrow',
    mods = 'SHIFT|CMD',
  },
}

return config

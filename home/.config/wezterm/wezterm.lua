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

config.window_padding = {
  left = 2,
  right = 2,
  top = 2,
  bottom = 2,
}

-- Setting `enable_csi_u_key_encoding` in hopes of fixing the `CSU U` issue
-- with NeoVim.  The hope is to allow native support for function keys with
-- modifiers (i.e. `<S-F1>`).
--   - https://neovim.io/doc/user/term.html#tui-input
--
-- > It  is not recommended to enable this option as it does change the
-- > behavior of some keys in backwards incompatible ways and there isn't a way
-- > for applications to detect or request this behavior.gq
--   - https://wezfurlong.org/wezterm/config/lua/config/enable_csi_u_key_encoding.html
config.enable_csi_u_key_encoding = true

local key_bindings = require 'pedrohdz.key_bindings'
key_bindings.apply(config)


return config

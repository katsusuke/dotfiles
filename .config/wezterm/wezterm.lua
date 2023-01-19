local wezterm = require 'wezterm'

return {
  font = wezterm.font("Cica"),
  scrollback_lines = 100000,
  color_scheme = 'Atom',
  colors = {
    foreground = 'white',
    background = 'rgba(0 0 0 / 85%)',
  },
  keys = {
    { key = 'C', mods = 'SUPER', action = wezterm.action.Copy },
  },
}

# home-manager files

Data files consumed by `home.nix` activation scripts. These are copied into the
Nix store at build time and referenced via `${./files/<name>}` in `home.nix`.

---

## wezterm.terminfo

The official WezTerm terminfo entry, compiled into `~/.terminfo` by the
`installWeztermTerminfo` activation in `home.nix`.

### Why not the ncurses version?

The `ncurses` package ships its own `wezterm` terminfo entry, but it is an
incomplete approximation. It is missing extended capabilities (requires `tic -x`)
that WezTerm actually supports:

- `RGB` — declares native 24-bit / truecolor support at the terminfo level
- `Smulx` — styled and colored underlines
- `Ms` — clipboard access via OSC 52
- `Cs` / `Cr` — cursor style and color
- Accurate key sequences for modified keys

Without the official entry, `TERM=wezterm` causes broken colors in prompts
(p10k falls back to 8 colors) and garbled input for modified keys.

### Updating

Re-download from the WezTerm source tree and re-run `home-manager switch`:

```sh
curl -o ~/.homesick/repos/dotfiles-zsh/home/.config/home-manager/files/wezterm.terminfo \
  https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo
```

### Relevant links

- [config.term documentation](https://wezterm.org/config/lua/config/term.html) — why and how to set `TERM=wezterm`
- [wezterm.terminfo source](https://github.com/wez/wezterm/blob/main/termwiz/data/wezterm.terminfo) — authoritative terminfo source
- [WezTerm shell integration](https://wezterm.org/shell-integration.html) — related terminal feature setup

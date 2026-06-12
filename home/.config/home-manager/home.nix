{ config, pkgs, lib, username, homeDirectory, ... }:

let
  treesitterGrammars = with pkgs.tree-sitter-grammars; [
    tree-sitter-bash
    tree-sitter-c
    tree-sitter-cpp
    tree-sitter-css
    tree-sitter-csv
    tree-sitter-dockerfile
    tree-sitter-dot
    tree-sitter-git-config    # → git_config
    tree-sitter-git-rebase    # → git_rebase
    tree-sitter-gitcommit
    tree-sitter-gitignore
    tree-sitter-go
    tree-sitter-groovy
    tree-sitter-hcl
    tree-sitter-html
    tree-sitter-java
    tree-sitter-javascript
    tree-sitter-json
    tree-sitter-latex
    tree-sitter-lua
    tree-sitter-make
    tree-sitter-markdown
    tree-sitter-markdown-inline
    tree-sitter-nix
    tree-sitter-python
    tree-sitter-regex
    tree-sitter-rst
    tree-sitter-rust
    tree-sitter-toml
    tree-sitter-tsx
    tree-sitter-typescript
    tree-sitter-vim
    tree-sitter-yaml
    # Not in nixpkgs 26.05: terraform, tmux, vimdoc
  ];

  nvimParsers = pkgs.runCommand "nvim-treesitter-parsers" { } (
    "mkdir -p $out/parser\n" +
    lib.concatMapStrings
      (grammar:
        let
          lang = builtins.replaceStrings [ "-" ] [ "_" ]
            (lib.removePrefix "tree-sitter-" grammar.pname);
          ext = pkgs.stdenv.hostPlatform.extensions.sharedLibrary;
        in
          "cp ${grammar}/parser $out/parser/${lang}${ext}\n"
      )
      treesitterGrammars
  );

in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = homeDirectory;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; lib.flatten [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    # proxytunnel
    # bcrypt
    # cryptcat
    # makepasswd
    # netcat
    # netcat-gnu
    # flake8

    # ignr
    asciidoc
    aspell
    aspellDicts.en
    aspellDicts.es
    aspellDicts.sv
    awscli2
    bash
    bash-completion
    bat
    bump2version
    cmake
    coreutils
    curl
    cvs
    diceware
    fd
    findutils
    fzf
    gawk
    gh
    git
    git-secret
    gnugrep
    gnumake
    gnused
    gnutar
    graphviz
    grepcidr
    haskellPackages.argon2
    haskellPackages.hopenpgp-tools
    htop
    imagemagick
    inetutils
    isort
    jira-cli-go
    jq
    kubectl
    kubectx
    ldns
    less
    lftp
    lima
    minicom
    mtools
    ncurses
    neovim
    nmap
    nodejs
    openssh
    p7zip
    pandoc
    paperkey
    pass
    proxychains-ng
    pv
    pwgen
    python314
    python314Packages.flake8
    python314Packages.netaddr
    python314Packages.pipdeptree
    python314Packages.pygments
    python314Packages.pylint
    python314Packages.sqlparse
    python314Packages.tabulate
    python314Packages.tox
    qrencode
    ripgrep
    scrypt
    silver-searcher
    smbclient-ng
    socat
    ssh-audit
    sshpass
    stunnel
    tenv
    thc-secure-delete
    time
    tmux
    tor
    tree
    universal-ctags
    unrar
    unzip
    util-linux
    vim
    watch
    wget
    xkcdpass
    xmlstarlet
    yamllint
    yarn
    yq
    yubikey-manager
    yubikey-personalization
    zbar
    zip
    zsh
    zsh-completions

    # GNU Privacy Guard
    gnupg
    (lib.optionals pkgs.stdenv.isDarwin [
      pinentry_mac # Broken!!!  Use the one from MacPorts
    ])
    # pinentry-qt

    # LLMs
    claude-code
    aider-chat

    # Linters & code analysis
    ansible-lint
    gitleaks
    lua51Packages.luacheck
    shellcheck
    yamllint

    # ----
    # NeoVim specific
    # ----
    tree-sitter

    # NeoVim/Lazy - Lua
    lua51Packages.lua
    lua51Packages.luarocks

    # LSPs
    bash-language-server
    dockerfile-language-server
    helm-ls
    lua-language-server
    nixd
    prettierd
    pyright
    rust-analyzer
    solargraph
    terraform-ls
    vim-language-server
    vscode-langservers-extracted
    yaml-language-server

    # ----
    # Linux only packages
    # ----
    (lib.optionals pkgs.stdenv.isLinux [
      helm
      kbd
      netcat-openbsd
      podman
      podman-tui
      rng-tools
      siege
      traceroute
      tsocks
    ])

    # ----
    # MacOS only packages
    # ----
    (lib.optionals pkgs.stdenv.isDarwin [
      obsidian
      wezterm
    ])

    # ----
    # TODO - Checking these tools out
    # ----
    btop
    entr
    eza
    gdu
    git-extras
    glow
    jid
    lsd
    ncdu
    pay-respects  # Replaces `thefuck`
    rclone
    rmlint
    tldr
  ];

  programs.man = {
    enable = true;
    generateCaches = true;
    package = pkgs.man-db;
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    # Pre-compiled tree-sitter parsers; ~/.local/share/nvim/site is on neovim's
    # default runtimepath and neovim scans parser/ subdirs for <lang>.so files.
    ".local/share/nvim/site/parser" = {
      source = "${nvimParsers}/parser";
      recursive = true;
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/pedro/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.activation.installWeztermTerminfo = config.lib.dag.entryAfter ["writeBoundary"] ''
    run ${pkgs.ncurses}/bin/tic -x -o "$HOME/.terminfo" \
      ${./files/wezterm.terminfo}
  '';
}

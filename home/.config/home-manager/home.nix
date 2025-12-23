{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "pedro";
  home.homeDirectory = "/home/pedro.linux";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
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
    gnupg
    gnused
    gnutar
    graphviz
    grepcidr
    haskellPackages.argon2
    haskellPackages.hopenpgp-tools
    helm
    htop
    # ignr
    imagemagick
    inetutils
    isort
    jq
    kbd
    kubectl
    kubectx
    ldns
    less
    lftp
    minicom
    mtools
    neovim
    netcat-openbsd
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
    python313Packages.flake8
    python313Packages.netaddr
    python313Packages.pipdeptree
    python313Packages.pygments
    python313Packages.pylint
    python313Packages.sqlparse
    python313Packages.tabulate
    python313Packages.tox
    python314
    qrencode
    ripgrep
    rng-tools
    scrypt
    siege
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
    traceroute
    tree
    tsocks
    universal-ctags
    unrar
    unzip
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

    # LLMs
    aider-chat-full
    codex
    codex-acp

    # Linters & code analysis
    gitleaks
    shellcheck

    # NeoVim specific
    # ansible-language-server # TODO - No longer supported by Nix
    bash-language-server
    dockerfile-language-server-nodejs
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
}

{ config, lib, pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    stdlib = ''
      use_flake() {
          watch_file flake.nix
          watch_file flake.lock
          eval "$(nix print-dev-env)"
      }
    '';
  };
  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "exa";
      j = "just";
      sv = "systemctl --user";
      psme = "ps xf -o pid,%mem,%cpu,stat,rss,args | less -S";
    };
    interactiveShellInit = ''
      set fish_color_normal normal
      set fish_color_command brblue
      set fish_color_args blue
      set fish_color_quote bryellow
      set fish_color_redirection brgreen
      set fish_color_end white
      set fish_color_error red --bold
      set fish_color_comment green
      set fish_color_match magenta
      set fish_color_selection cyan
      set fish_color_search_match brwhite
      set fish_color_operator brcyan
      set fish_color_escape yellow
      set fish_color_autosuggestion brblack

      # start blink
      export LESS_TERMCAP_mb=(set_color magenta)
      # start bold
      export LESS_TERMCAP_md=(set_color blue)
      # start standout (reverse)
      export LESS_TERMCAP_so=(set_color yellow)
      # start underline
      export LESS_TERMCAP_us=(set_color -i red)

      # stop bold
      export LESS_TERMCAP_me=(set_color normal)
      # stop standout (reverse)
      export LESS_TERMCAP_se=(set_color normal)
      # stop underline
      export LESS_TERMCAP_ue=(set_color normal)

      export EDITOR=edit
    '';
  };
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$directory"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];
      scan_timeout = 6;
      cmd_duration.min_time = 10;
      cmd_duration.show_milliseconds = true;
      character.success_symbol = "[➜](green)";
      character.error_symbol = "[➜](red)";
      directory.truncation_length = 1;
      directory.fish_style_pwd_dir_length = 1;
    };
  };
  programs.git = {
    enable = true;
    aliases = {
      ds = "diff --staged";
      ap = "add -p";
    };
    extraConfig = {
      core.editor = "edit";
      pull.rebase = true;
    };
    ignores = [ ".direnv.d" ".envrc" "shell.nix" ];
    userEmail = "theotherjimmy@gmail.com";
    userName = "Jimmy Brisson";
  };
  programs.jq.enable = true;
  programs.man.enable = true;
  programs.skim = {
    enable = true;
    changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d";
    defaultCommand = "fd --type f || git ls-tree -r --name-only HEAD || rg --files || find .";
  };
  services.lorri.enable = true;
  home.packages = with pkgs // rec {
    edit = pkgs.writers.writeBashBin "edit" ''
      if [[ -v INSIDE_EMACS ]] ; then
        exec emacsclient $@
      else
        exec emacsclient -c $@
      fi
    '';
    git-ip-review = pkgs.writeShellScriptBin "git-ip-review" ''
      rev=$(git rev-parse --abbrev-ref HEAD)
      if [ "HEAD" == $rev ] ; then
        echo "Error: detached HEAD; Refusing to push an ip review"
        exit 1
      else
        git push arm $rev:refs/for/master/$rev
      fi
    '';
  }; [
    aspell
    aspellDicts.en
    acpilight
    apitrace
    linuxPackages.bpftrace
    cargo-flamegraph
    direnv
    edit
    entr
    exa
    fd
    file
    firefox
    fractal
    git
    gnumake
    git-hub
    git-ip-review
    git-review
    git-series
    just
    keepass
    libnotify
    mupdf
    networkmanagerapplet
    niv
    nixpkgs-fmt
    nix-top
    nix-index
    nix-prefetch-scripts
    neovim
    neovim-remote
    hack-font
    openconnect
    patchelf
    procs
    pv
    usbutils
    ripgrep
    screen
    tmux
    wl-clipboard
    xclip
    xe
    xh
    xmlstarlet
    xwayland
    xorg.xdpyinfo
  ];
}

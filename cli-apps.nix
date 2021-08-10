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
  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "exa";
      j = "just";
      sv = "systemctl --user";
      psme = "pstree -h -C age -U -T $USER";
    };
    sessionVariables.EDITOR = "edit";
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
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
  programs.kakoune = {
    enable = true;
    config = {
      numberLines = {
        enable = true;
        highlightCursor = true;
        relative = true;
      };
      showMatching = true;
      showWhitespace.enable = true;
      ui.assistant = "none";
      wrapLines = {
        enable = true;
        indent = true;
        marker = "⏎";
        word = true;
      };
      keyMappings = [
        {
          key = "<space>";
          mode = "normal";
          effect = ",";
          docstring = "leader";
        }
        {
          key = "<backspace>";
          mode = "normal";
          effect = "<space>";
          docstring = "clear selection to only keep the main one";
        }
        {
          key = "<a-backspace>";
          mode = "normal";
          effect = "<a-space>";
          docstring = "clear the main selection";
        }
        {
          key = "<space>";
          mode = "user";
          effect = ":fzf-mode<ret>f";
          docstring = "open a file with a fuzzy finder";
        }
        {
          key = "b";
          mode = "user";
          effect = ":enter-user-mode buffer<ret>";
          docstring = "Buffer actions";
        }
        {
          key = "s";
          mode = "user";
          effect = ":enter-user-mode spell<ret>";
          docstring = "Spell check actions";
        }
        {
          key = "b";
          mode = "buffer";
          effect = ":fzf-mode<ret>b";
          docstring = "fuzzy jump to a buffer";
        }
        {
          key = "d";
          mode = "buffer";
          effect = ":db<ret>";
          docstring = "delete the current buffer";
        }
        {
          key = "n";
          mode = "buffer";
          effect = ":bn<ret>";
          docstring = "move to the next buffer";
        }
        {
          key = "p";
          mode = "buffer";
          effect = ":bp<ret>";
          docstring = "move to the previous buffer";
        }
        {
          key = "f";
          mode = "buffer";
          effect = ":format-buffer<ret>";
          docstring = "auto-format the current buffer";
        }
        {
          key = "s";
          mode = "spell";
          effect = ":spell<ret>";
          docstring = "spell check the current buffer";
        }
        {
          key = "n";
          mode = "spell";
          effect = ":spell-next<ret>";
          docstring = "jump to the next spelling mistake";
        }
        {
          key = "c";
          mode = "spell";
          effect = ":spell-clear<ret>";
          docstring = "clear spell check highlighting";
        }
      ];
    };
    plugins = with pkgs.kakounePlugins; [
      kak-fzf
    ];
    extraConfig = let
      inherit (config.colors.fn "rgb:") normal primary bright;
      fg_alpha = (config.colors.fn "rgba:").primary.foreground + "a0";
      bg_alpha = (config.colors.fn "rgba:").primary.background + "a0";
    in ''
        face global value         ${normal.magenta}
        face global type          ${normal.yellow}
        face global variable      ${normal.blue}
        face global module        ${normal.green}
        face global function      ${primary.foreground}
        face global string        ${normal.green}
        face global keyword       ${normal.red}
        face global operator      ${primary.foreground}
        face global attribute     ${normal.cyan}
        face global comment       ${normal.blue}+i
        face global documentation comment
        face global meta          ${normal.cyan}
        face global builtin       ${primary.foreground}+b

        face global title              ${normal.green}+b
        face global header             ${normal.orange}
        face global mono               ${primary.fg4}
        face global block              ${normal.cyan}
        face global link               ${normal.blue}+u
        face global bullet             ${normal.yellow}
        face global list               ${primary.foreground}
        face global Default            ${primary.foreground},${primary.background}
        face global PrimarySelection   ${fg_alpha},${normal.blue}+g
        face global SecondarySelection ${bg_alpha},${normal.blue}+g
        face global PrimaryCursor      ${primary.background},${primary.foreground}+fg
        face global SecondaryCursor    ${primary.background},${primary.bg4}+fg
        face global PrimaryCursorEol   ${primary.background},${primary.fg4}+fg
        face global SecondaryCursorEol ${primary.background},${primary.bg2}+fg
        face global LineNumbers        ${primary.bg4}
        face global LineNumberCursor   ${normal.yellow},${primary.bg1}
        face global LineNumbersWrapped ${primary.bg1}
        face global MenuForeground     ${primary.bg2},${normal.blue}
        face global MenuBackground     ${primary.foreground},${primary.bg2}
        face global MenuInfo           ${primary.background}
        face global Information        ${primary.background},${primary.foreground}
        face global Error              ${primary.background},${normal.red}
        face global StatusLine         ${primary.foreground},${primary.background}
        face global StatusLineMode     ${normal.yellow}+b
        face global StatusLineInfo     ${normal.magenta}
        face global StatusLineValue    ${normal.red}
        face global StatusCursor       ${primary.background},${primary.foreground}
        face global Prompt             ${normal.yellow}
        face global MatchingChar       ${primary.foreground},${primary.bg3}+b
        face global BufferPadding      ${primary.bg2},${primary.background}
        face global Whitespace         ${primary.bg2}+f
    '';
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
      ws=$(${pkgs.wmctrl}/bin/wmctrl -d | awk '$2 == "*" {print $9}')
      if [[ $ws != "" ]] ; then
        if [[ -e $XDG_RUNTIME_DIR/kakoune/$ws ]] ; then
          exec kak -c $ws $@
        else
          exec kak -s $ws $@
        fi
      else
        exec kak $@
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
    linuxPackages.bpftrace
    cargo-flamegraph
    direnv
    edit
    entr
    exa
    fd
    file
    git
    git-hub
    git-ip-review
    git-review
    git-series
    just
    libnotify
    nixpkgs-fmt
    nix-top
    patchelf
    procs
    pv
    psmisc
    usbutils
    ripgrep
    rpn-c
    screen
    tmux
    xe
  ];
}

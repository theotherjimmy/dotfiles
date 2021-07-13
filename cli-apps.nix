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
  programs.kakoune = {
    enable = true;
    config = {
      colorScheme = "gruvbox";
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
    extraConfig = ''
      set-option global fzf_implementation 'sk'
      set-option global fzf_file_command 'fd'
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
    usbutils
    ripgrep
    rpn-c
    screen
    tmux
    xe
  ];
}

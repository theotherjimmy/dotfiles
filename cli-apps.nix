{ config, lib, pkgs, ... }:

{
  programs.kakoune = {
    enable = true;
    config = {
      numberLines = {
        enable = true;
        highlightCursor = true;
        relative = true;
      };
      showMatching = true;
      showWhitespace = {
        enable = true;
        space = " ";
      };
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
          effect = ":peneira-files<ret>";
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
          key = "l";
          mode = "user";
          effect = ":peneira-lines<ret>";
          docstring = "Spell check actions";
        }
        {
          key = "b";
          mode = "buffer";
          effect = ":peneira-buffers<ret>";
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
    plugins = [
      (pkgs.kakouneUtils.buildKakounePlugin rec {
        pname = "peneira";
        version = "2022-02-13";
        src = pkgs.fetchFromGitHub {
          owner = "gustavo-hms";
          repo = pname;
          rev = "429f0422f4395564811d9c73d51a78b772dbd4e4";
          hash = "sha256-kO1kZr8U214qJxP0txUpzUl1/nJadknXDSTEfLKlaPI=";
        };
      })
      (pkgs.kakouneUtils.buildKakounePlugin rec {
        pname = "luar";
        version = "2022-02-28";
        src = pkgs.fetchFromGitHub {
          owner = "gustavo-hms";
          repo = pname;
          rev = "2f430316f8fc4d35db6c93165e2e77dc9f3d0450";
          hash = "sha256-vHn/V3sfzaxaxF8OpA5jPEuPstOVwOiQrogdSGtT6X4=";
        };
      })
    ];
    extraConfig = 
      with (config.colors.fn "rgb:"); ''
        face global value ${base09}
        face global type ${base0A}+b
        face global identifier ${base08}
        face global string ${base0B}
        face global keyword ${base0E}+b
        face global operator ${base05}
        face global attribute ${base0C}
        face global comment ${base03}
        face global meta ${base0D}
        face global builtin ${base0D}+b
        face global title ${base0D}+b
        face global header ${base0D}+b
        face global bold ${base0A}+b
        face global italic ${base0E}
        face global mono ${base0B}
        face global block ${base0C}
        face global link ${base09}
        face global bullet ${base08}
        face global list ${base08}
        face global Default ${base05},${base00}
        face global PrimarySelection ${base06},${base0D}
        face global SecondarySelection ${base06},${base0F}
        face global PrimaryCursor ${base00},${base05}
        face global SecondaryCursor ${base06},${base0C}
        face global LineNumbers ${base02},${base00}
        face global LineNumberCursor ${base0A},${base00}
        face global MenuForeground ${base00},${base0D}
        face global MenuBackground ${base00},${base0C}
        face global MenuInfo ${base02}
        face global Information ${base00},${base0A}
        face global Error ${base00},${base08}
        face global StatusLine ${base04},${base01}
        face global StatusLineMode ${base0B}
        face global StatusLineInfo ${base0D}
        face global StatusLineValue ${base0C}
        face global StatusCursor ${base00},${base05}
        face global Prompt ${base0D},${base01}
        face global MatchingChar ${base06},${base02}+b
        face global BufferPadding ${base03},${base00}
        require-module luar
        set-option global luar_interpreter ${pkgs.luajit}/bin/luajit
        require-module peneira
        define-command peneira-buffers %{
            peneira 'buffers: ' %{ printf '%s\n' $kak_quoted_buflist } %{
                        buffer %arg{1}
            }
        }
    '';
  };
  programs.helix = {
    enable = true;
    settings = {
      theme = "nix-generated";
      editor.line-number = "relative";
      keys.normal.backspace = "keep_primary_selection";
    };
    themes = {
       nix-generated = let
          colors = config.colors.fn "#";
        in {
          "ui.background" = { bg = colors.base00; };
          "ui.menu" = colors.base01;
          "ui.menu.selected" = { fg = colors.base04; bg = colors.base01;};
          "ui.linenr" = { fg = colors.base04; };
          "ui.popup" = { bg = colors.base01; };
          "ui.window" = { bg = colors.base01; };
          "ui.selection" = { modifiers = ["underlined"]; };
          "comment" = colors.base03;
          "ui.statusline" = {fg = colors.base04; bg = colors.base01;};
          "ui.cursor" = { fg = colors.base05; modifiers = ["reversed" "underlined"]; };
          "ui.text" = { fg = colors.base05; };
          "operator" = colors.base05;
          "ui.text.focus" = { fg = colors.base05; };
          "variable" = colors.base08;
          "constant.numeric" = colors.base09;
          "constant" = colors.base09;
          "attributes" = colors.base09;
          "type" = colors.base0A;
          "ui.cursor.match" = { fg = colors.base0A; modifiers = ["underlined"]; };
          "strings"  = colors.base0B;
          "variable.other.member" = colors.base0B;
          "constant.character.escape" = colors.base0C;
          "function" = colors.base0D;
          "constructor" = colors.base0D;
          "special" = colors.base0D;
          "keyword" = colors.base0E;
          "label" = colors.base0F;
          "namespace" = colors.base0F;
          "ui.help" = { bg = colors.base01; fg = colors.base06; };
          "info" = colors.base03;
          "hint" = colors.base03;
          "debug" = colors.base03;
          "diagnostic" = colors.base03;
          "error" = colors.base0E;
        };
    };
  };
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
      c = "cargo";
      sv = "systemctl --user";
      psme = "pstree -h -C age -U -T $USER";
      icat = "wezterm imgcat";
      isvg = "rsvg-convert | icat";
      idot = let inherit (config.colors.fn "#") base00 base05; in
        ''dot -T bmp \
          -Gbgcolor="${base00}" \
          -Gcolor="${base05}" \
          -Ncolor="${base05}" \
          -Nfontcolor="${base05}" \
          -Ecolor="${base05}" \
          -Efontcolor="${base05}" \
          | icat
        '';
    };
    sessionVariables.EDITOR = "edit";
    bashrcExtra = ''
      export PS1='    ; \[$(tput sgr0)\]'
      export PROMPT_COMMAND='if [[ $? != 0 ]] ; then echo -e -n "\001$(tput setaf 2)\002"; fi'
      export LESS_TERMCAP_mb=$(tput setaf 6) # cyan
      export LESS_TERMCAP_md=$(tput setaf 2) # green
      export LESS_TERMCAP_me=$(tput sgr0)
      export LESS_TERMCAP_so=$(tput bold; tput setaf 3) # yellow
      export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
      export LESS_TERMCAP_us=$(tput sitm; tput setaf 5) # magenta
      export LESS_TERMCAP_ue=$(tput ritm; tput sgr0)
      export LESS_TERMCAP_mr=$(tput rev)
      export LESS_TERMCAP_mh=$(tput dim)
    '';
  };
  programs.git = {
    package = pkgs.gitAndTools.gitFull;
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
  home.packages = let
    edit = pkgs.writers.writeBashBin "edit" ''
      if [[ $# > 0 ]]; then
        files=$@
      else
        files=$(sk -m)
        if [[ $? != 0 ]] ; then
          exit 1
        fi
      fi
      ws=$(${pkgs.wmctrl}/bin/wmctrl -d | awk -F '(::| *)' '$2 == "*" {print $9}')
      if [[ $ws != "" ]] ; then
        if [[ -e $XDG_RUNTIME_DIR/kakoune/$ws ]] ; then
          exec kak -c $ws $files
        else
          exec kak -s $ws $files
        fi
      else
        exec kak $files
      fi
    '';
    rgl = pkgs.writers.writeBashBin "rgl" ''
      rg -p $@ | less -RF
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
  in [
    edit
    rgl
    git-ip-review
    pkgs.aspell
    pkgs.aspellDicts.en
    pkgs.bashInteractive
    pkgs.cargo-flamegraph
    pkgs.direnv
    pkgs.entr
    pkgs.exa
    pkgs.fd
    pkgs.file
    pkgs.git-hub
    pkgs.git-review
    pkgs.git-series
    pkgs.graphviz
    pkgs.just
    pkgs.libnotify
    pkgs.nixpkgs-fmt
    pkgs.nix-top
    pkgs.patchelf
    pkgs.procs
    pkgs.pv
    pkgs.psmisc
    pkgs.usbutils
    pkgs.ripgrep
    pkgs.rpn-c
    pkgs.screen
    pkgs.tmux
    pkgs.xe
    pkgs.xdg-user-dirs
    pkgs.xdotool
    pkgs.xorg.xwininfo
    pkgs.yad
    pkgs.bc
    pkgs.wget
    pkgs.unzip
    pkgs.innoextract
    pkgs.steam-run
  ];
}

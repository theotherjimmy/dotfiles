{ config, lib, pkgs, ... }:

{
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
      hx $@
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

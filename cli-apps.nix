{ config, lib, pkgs, ... }:

{
  imports = [ ./modules/helix.nix ];
  programs.helix = {
    enable = true;
    config = {
      theme = "nix-generated";
      editor.line-numbers = "relative";
      keys.normal.backspace = "keep_primary_selection";
    };
    theme =
      let
        inherit (config.colors.fn "#") primary normal bright;
      in {
        attribute = bright.cyan;
        keyword = normal.blue;
        "keyword.directive" = normal.red;
        namespace = normal.cyan;
        punctuation = primary.fg4;
        operator = bright.magenta;
        special = normal.magenta;
        variable = primary.fg1;
        "variable.builtin" = normal.orange;
        "variable.parameter" = primary.fg2;
        "variable.other.member" = bright.blue;
        constructor = { fg = bright.magenta; modifiers = ["bold"]; };
        function = { fg = bright.green; modifiers = ["bold"]; };
        "function.macro" = bright.cyan;
        "function.builtin" = bright.yellow;
        comment = normal.grey;
        constant = bright.magenta;
        "constant.builtin" = { fg = bright.magenta; modifiers = ["bold"]; };
        "constant.numeric" = bright.magenta;
        "constant.character.escape" = { fg = primary.fg2; modifiers =["bold"]; };
        string = bright.green;
        label = bright.cyan;
        module = bright.cyan;
        warning = { fg = bright.orange; bg = primary.bg1; };
        error = { fg = bright.red; bg = primary.bg1; };
        info = { fg = bright.cyan; bg = primary.bg1; };
        hint = { fg = bright.blue; bg = primary.bg1; };
        "ui.background" = { bg = primary.background; };
        "ui.linenr" = primary.bg4;
        "ui.linenr.selected" = bright.yellow;
        "ui.statusline" = {fg = primary.fg1; bg = primary.bg2; };
        "ui.statusline.inactive" = { fg = primary.fg4; bg = primary.bg1; };
        "ui.popup" = { bg = primary.bg1; };
        "ui.window" = { bg = primary.bg1; };
        "ui.help" = { fg = primary.fg1; bg = primary.bg1; };
        "ui.text" = primary.fg1;
        "ui.text.focus" = primary.fg1;
        "ui.selection" = { bg = primary.bg3; modifiers = ["reversed"]; };
        "ui.cursor.primary" = { modifiers = ["reversed"]; };
        "ui.cursor.match" = { modifiers = ["reversed"]; };
        "ui.menu" = { fg = primary.fg1; bg = primary.bg2; };
        "ui.menu.selected" = { fg = primary.bg2; bg = bright.blue; modifiers = ["bold"]; };
        diagnostic = { modifiers = ["underline"]; };
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
      idot = let inherit (config.colors.fn "#") primary; in
        ''dot -T bmp \
          -Gbgcolor="${primary.background}" \
          -Gcolor="${primary.foreground}" \
          -Ncolor="${primary.foreground}" \
          -Nfontcolor="${primary.foreground}" \
          -Ecolor="${primary.foreground}" \
          -Efontcolor="${primary.foreground}" \
          | icat
        '';
    };
    sessionVariables.EDITOR = "edit";
    bashrcExtra = ''
      export PS1='    ; \[$(tput sgr0)\]'
      export PROMPT_COMMAND='if [[ $? != 0 ]] ; then echo -e -n "\001$(tput setaf 5)\002"; fi'
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
    pkgs.git
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
  ];
}

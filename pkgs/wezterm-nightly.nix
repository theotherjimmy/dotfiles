{ stdenv
, rustPlatform
, lib
, fetchFromGitHub
, ncurses
, pkg-config
, python3
, fontconfig
, openssl
, libGL
, libX11
, libxcb
, libxkbcommon
, xcbutil
, xcbutilimage
, xcbutilkeysyms
, xcbutilwm
, wayland
, zlib
}:

rustPlatform.buildRustPackage rec {
  pname = "wezterm";
  version = "20211004-68418b8-nightly";

  outputs = [ "out" "terminfo" ];

  src = fetchFromGitHub {
    owner = "wez";
    repo = pname;
    rev = "d461c1c0b6bfc016e24308737810a511bc52ff91";
    fetchSubmodules = true;
    sha256 = "sha256-jjmzwRhgTJOftJrL8sXbC5NCAnw6aBHigMwHCfhFJI4=";
  };

  postPatch = ''
    echo ${version} > .tag
  '';

  cargoSha256 = "sha256-CGk/kv+OuNUhLNu+jkEMrGil6nhGp2ESv8EcF0LDbYg=";
  doCheck = false;

  nativeBuildInputs = [
    pkg-config
    python3
    ncurses # tic for terminfo
  ];

  buildInputs = [
    fontconfig
    zlib
  ] ++ lib.optionals stdenv.isLinux [
    libX11
    libxcb
    libxkbcommon
    openssl
    wayland
    xcbutil
    xcbutilimage
    xcbutilkeysyms
    xcbutilwm # contains xcb-ewmh among others
  ];

  postInstall = ''
    # terminfo
    mkdir -p $terminfo/share/terminfo/w $out/nix-support
    tic -x -o $terminfo/share/terminfo termwiz/data/wezterm.terminfo
    echo "$terminfo" >> $out/nix-support/propagated-user-env-packages

    # desktop icon
    install -Dm644 assets/icon/terminal.png $out/share/icons/hicolor/128x128/apps/org.wezfurlong.wezterm.png
    install -Dm644 assets/wezterm.desktop $out/share/applications/org.wezfurlong.wezterm.desktop
    install -Dm644 assets/wezterm.appdata.xml $out/share/metainfo/org.wezfurlong.wezterm.appdata.xml

    # helper scripts
    install -Dm644 assets/shell-integration/wezterm.sh -t $out/etc/profile.d
  '';

  preFixup = lib.optionalString stdenv.isLinux ''
    patchelf --add-needed "${libGL}/lib/libEGL.so.1" $out/bin/wezterm-gui
  '' + lib.optionalString stdenv.isDarwin ''
    mkdir -p "$out/Applications"
    OUT_APP="$out/Applications/WezTerm.app"
    cp -r assets/macos/WezTerm.app "$OUT_APP"
    rm $OUT_APP/*.dylib
    cp -r assets/shell-integration/* "$OUT_APP"
    ln -s $out/bin/{wezterm,wezterm-mux-server,wezterm-gui,strip-ansi-escapes} "$OUT_APP"
  '';

  meta = {
    description = "A GPU-accelerated cross-platform terminal emulator and multiplexer written by @wez and implemented in Rust";
    homepage = "https://wezfurlong.org/wezterm";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.SuperSandro2000 ];
    platforms = lib.platforms.unix;
  };
}

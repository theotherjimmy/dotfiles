{ config, lib, pkgs, ... } : let
  orcaslicer-version = "2.3.0";
  orcaslicer-src = pkgs.fetchurl rec {
    version = orcaslicer-version;
    url = "https://github.com/SoftFever/OrcaSlicer/releases/download/v${version}/OrcaSlicer_Linux_AppImage_Ubuntu2404_V${version}.AppImage";
    hash = "sha256-E+QL8nTwAS6DIlOfwIw2fIboPm3jrCBJaNoOMmNLMnA=";
  };
  orcaslicer = pkgs.appimageTools.wrapType2 {
    pname = "orcaSlicer";
    version = orcaslicer-version;
    src = orcaslicer-src;
    extraPkgs = (pkgs: with pkgs; [ webkitgtk_4_1 ]);
  };
in {
  options.home.entertainment = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };
  config = lib.mkIf config.home.entertainment {
    home.packages = with pkgs; [
      orcaslicer
      freecad-wayland
      freetube
      gamescope
      r2modman
      protontricks
      r2modman
      gamescope
      (steam.override {
        extraProfile = ''
          unset VK_ICD_FILENAMES
          export VK_ICD_FILENAMES=`realpath /run/opengl-driver/share`/vulkan/icd.d/radeon_icd.x86_64.json:`realpath /run/opengl-driver-32/share`/vulkan/icd.d/radeon_icd.i686.json
        '';
      })
    ];
  };
}

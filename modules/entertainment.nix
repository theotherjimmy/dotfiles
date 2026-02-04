{ config, lib, pkgs, ... } : let
in {
  options.home.entertainment = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };
  config = lib.mkIf config.home.entertainment {
    home.packages = with pkgs; [
      freetube
      gamescope
      r2modman
      protontricks
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

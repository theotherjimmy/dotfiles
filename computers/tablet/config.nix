# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostId = "dab81574";
    networkmanager.enable = true;
    hostName = "tablet";
    useDHCP = false;
  };

  services.tailscale.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  services.fwupd.enable = true;
  services.getty.autologinUser = "jimbri01";

  programs.steam.enable = true;
  programs.dconf.enable = true;

  users.users.jimbri01 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "input" ];
  };
  programs.niri.enable = true;

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}


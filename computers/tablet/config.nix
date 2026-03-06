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
    firewall.enable = false;
  };

  services.fluidd.enable = true;
  services.moonraker = {
    enable = true;
    group = "klipper";
    address = "0.0.0.0";
    settings = {
      octoprint_compat = { };
      history = { };
      authorization = {
        force_logins = true;
        cors_domains = [
          "*.local"
        ];
        trusted_clients = [
          "127.0.0.0/8"
          "192.168.0.0/24"
          "FE80::/10"
          "::1/128"
        ];
      };
    };
  };

  services.tailscale.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  services.fwupd.enable = true;
  services.getty.autologinUser = "klipper";

  programs.steam.enable = true;
  programs.dconf.enable = true;

  programs.bash.shellInit = ''
    if [[ $USER == "klipper" ]] && [[ $(tty) = /dev/tty1 ]]; then
       cage -ds start-klipper-screen;
    fi
  '';
  users.groups.klipper = { };
  users.users.klipper = {
    isNormalUser = true;
    group = "klipper";
  };
  services.klipper = {
    enable = true;
    user = "klipper";
    group = "klipper";
    configFile = ./kalico.cfg;
    package = pkgs.kalico;
    logFile = "/var/lib/klipper/klipper.log";
  };
  # Totally a server, not some ewaste laptop.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleSuspendKey = "ignore";
  };
  services.nginx.enable = true;
  environment.systemPackages = with pkgs; let
    start-klipper-screen = writers.writeBashBin "start-klipper-screen" ''
      wlr-randr --output LVDS-1 --rotate 90
      exec KlipperScreen
    '';
  in
  [
    cage
    start-klipper-screen
    wlr-randr
    klipperscreen
  ];

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDN4DprQ3N9S9lo6AID+Bdykp4O8GBgK0MZ14kXRMo5fXQ+LGqRegAWcI/7PaGsT6mR2ev3gKY0n2wzrkLmMmUv1bgTFWvYDie7mmJB5hCRLB0no//31oqkWcat6SV2XNXFB4/FSKw4gA6a9YKKtrZ+AgikVEVYMJOIbkdLlH79W9cbVQFwMXJesFfrkFDaXSiXQwcyvn71bu96ZuHd+GLR09GXI/+lCSDAB65bEjsEMsan4atP1+Ao5UQ51IRX78OV9B5dDnq01bM1jlKnBbkhSmA7NKV+mocMwjItQybpstIHCJmlBJCYoZaVmMvMU3LcaGSHd/Y9FZovGiWPQS/R jimbri01@u200990-lin"
  ];

  users.users.jimbri01 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "input" ];
  };
  programs.niri.enable = true;
  system.stateVersion = "23.11"; # Did you read the comment?

}


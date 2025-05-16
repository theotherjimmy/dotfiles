{ config, pkgs, lib, ... }:
{
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "dvorak-programmer";
    useXkbConfig = true;
  };
  networking.firewall.enable = false;
  networking.networkmanager.enable = true;
  services.openssh.enable = true;
  services.fluidd.enable = true;
  services.moonraker = {
    enable = true;
    group = "klipper";
    address = "0.0.0.0";
    settings = {
      octoprint_compat = {};
      history = {};
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
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
    };
  };
  services.getty.autologinUser = "klipper";
  programs.bash.shellInit = ''
    if [[ $USER == "klipper" ]] && [[ $(tty) = /dev/tty1 ]]; then
       cage -ds start-klipper-screen;
    fi
  '';
  users.groups.klipper = {};
  users.users.klipper = {
    isNormalUser = true;
    group = "klipper";
  };
  services.klipper = {
    enable = true;
    user = "klipper";
    group = "klipper";
    configFile = ./kalico.cfg;
    package = pkgs.callPackage ./pkgs/kalico.nix {} ;
  };
  services.avahi = {
    enable = true;
    openFirewall = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
  # Totally a server, not some ewaste laptop.
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };
  services.nginx = {
    enable = true;
  };
  environment.systemPackages = with pkgs; let
    start-klipper-screen = writers.writeBashBin "start-klipper-screen" ''
      wlr-randr --output LVDS-1 --rotate 90
      exec KlipperScreen
    '';
  in[
    kakoune
    cage
    start-klipper-screen
    wlr-randr
    klipperscreen
  ];

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDN4DprQ3N9S9lo6AID+Bdykp4O8GBgK0MZ14kXRMo5fXQ+LGqRegAWcI/7PaGsT6mR2ev3gKY0n2wzrkLmMmUv1bgTFWvYDie7mmJB5hCRLB0no//31oqkWcat6SV2XNXFB4/FSKw4gA6a9YKKtrZ+AgikVEVYMJOIbkdLlH79W9cbVQFwMXJesFfrkFDaXSiXQwcyvn71bu96ZuHd+GLR09GXI/+lCSDAB65bEjsEMsan4atP1+Ao5UQ51IRX78OV9B5dDnq01bM1jlKnBbkhSmA7NKV+mocMwjItQybpstIHCJmlBJCYoZaVmMvMU3LcaGSHd/Y9FZovGiWPQS/R jimbri01@u200990-lin"
  ];
  system.stateVersion = "23.11";
}

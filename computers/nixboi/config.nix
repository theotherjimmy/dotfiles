# Help is available in the configuration.nix(5) man page and in the
# NixOS manual, accessible by running ‘nixos-help’.
{ config, pkgs, lib, ... }: {
  # boot from zfs
  boot.initrd.supportedFilesystems = [ "zfs" ];
  boot.supportedFilesystems = [ "zfs" ];

  nix.settings.trusted-users = [ "@wheel" ];
  nix.package = pkgs.nixVersions.stable;
  nix.extraOptions = "experimental-features = nix-command flakes";

  nixpkgs.config.allowUnfree = true;

  virtualisation.waydroid.enable = true;

  #boot.loader.grub.enable = true;
  #boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

  networking = {
    hostName = "nixboi";
    useDHCP = false;
    networkmanager = {
      enable = true;
    };
    firewall.enable = false;
    hostId = "ab74eca9";
  };
  services.tailscale.enable = true;
  console.keyMap = "dvorak-programmer";
  console.font = "Lat2-Terminus16";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Chicago";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    linuxPackages.bpftrace
  ];
  hardware = {
    graphics.enable = true;
    graphics.extraPackages = [
      pkgs.vulkan-loader
      pkgs.amdvlk
      pkgs.vaapiVdpau
      pkgs.libvdpau-va-gl
    ];
    #graphics.package = (pkgs.enableDebugging pkgs.mesa).drivers;
    acpilight.enable = true;
    steam-hardware.enable = true;
    bluetooth.enable = true;
  };
  services.avahi = {
    enable = true;
    openFirewall = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  services.fwupd.enable = true;

  services.earlyoom.enable = true;
  services.openssh.enable = true;
  services.lorri.enable = true;
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "dvp";
    videoDrivers = [ "modesetting" "amdgpu" ];
  };
  # zfs already has its own scheduler. without this my(@Artturin) computer
  # froze for a second when i nix build something.
  services.udev.extraRules = ''
    ATTRS{idVendor}=="1209" ATTRS{idProduct}=="da42", ENV{ID_MM_DEVICE_IGNORE}="1", GROUP="users"
    ATTRS{idVendor}=="0d28" ATTRS{idProduct}=="0204", ENV{ID_MM_DEVICE_IGNORE}="1", GROUP="users"
    ATTRS{idVendor}=="0403" ATTRS{idProduct}=="6011", ENV{ID_MM_DEVICE_IGNORE}="1", GROUP="users"
    ATTRS{idVendor}=="1fc9" ATTRS{idProduct}=="0090", ENV{ID_MM_DEVICE_IGNORE}="1", GROUP="users"
    ATTRS{idVendor}=="1fc9" ATTRS{idProduct}=="000c", ENV{ID_MM_DEVICE_IGNORE}="1", GROUP="users"
    ATTRS{idVendor}=="1fc9" ATTRS{idProduct}=="0083", ENV{ID_MM_DEVICE_IGNORE}="1", GROUP="users"
    ATTRS{idVendor}=="1366" ATTRS{idProduct}=="0105", ENV{ID_MM_DEVICE_IGNORE}="1", GROUP="users"
    # rules for OpenHantek6022 (DSO program) as well as Hankek6022API (python tools)

    ACTION!="add|change", GOTO="openhantek_rules_end"
    SUBSYSTEM!="usb|usbmisc|usb_device", GOTO="openhantek_rules_end"
    ENV{DEVTYPE}!="usb_device", GOTO="openhantek_rules_end"

    # Hantek DSO-6022BE, without FW, with FW
    ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="6022", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
    ATTRS{idVendor}=="04b5", ATTRS{idProduct}=="6022", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

    # Hantek DSO-6022BL, without FW, with FW
    ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="602a", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
    ATTRS{idVendor}=="04b5", ATTRS{idProduct}=="602a", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

    # Voltcraft DSO-2020, without FW (becomes DSO-6022BE when FW is uploaded)
    ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="2020", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

    # BUUDAI DDS120, without FW, with FW
    ATTRS{idVendor}=="8102", ATTRS{idProduct}=="8102", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
    ATTRS{idVendor}=="04b5", ATTRS{idProduct}=="0120", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

    # Hantek DSO-6021, without FW, with FW
    ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="6021", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
    ATTRS{idVendor}=="04b5", ATTRS{idProduct}=="6021", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

    # YiXingDianZiKeJi MDSO, without FW, with FW
    ATTRS{idVendor}=="d4a2", ATTRS{idProduct}=="5660", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"
    ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="608e", TAG+="uaccess", TAG+="udev-acl", MODE="660", GROUP="plugdev"

    LABEL="openhantek_rules_end"
  '';
  users.users.jimbri01 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "input" ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.11"; # Did you read the comment?

  programs.steam.enable = true;
  programs.dconf.enable = true;

  services.getty.autologinUser = "jimbri01";

  # Zram is fast
  zramSwap = {
    enable = true;
    swapDevices = 1;
  };
}


{ pkgs, ... }: {
  nix.optimise = {
    automatic = true;
    dates = [ "03:45" ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    kakoune
    linuxPackages.bpftrace
  ];
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
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak-programmer";
  };
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Chicago";
  services.openssh.enable = true;
  zramSwap = {
    enable = true;
    swapDevices = 1;
  };
}

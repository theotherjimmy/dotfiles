{ config, lib, pkgs, ... }:

{
  accounts.email.accounts.personal = {
    address = "theotherjimmy@gmail.com";
    flavor = "gmail.com";
    realName = "Jimmy Brisson";
    lieer.enable = true;
    lieer.sync.enable = true;
    lieer.sync.frequency = "*-*-* 8,11,14,17,20:00:00";
    notmuch.enable = true;
    primary = true;
  };
  programs.lieer.enable = true;
  services.lieer.enable = true;
  programs.notmuch.enable = true;
  programs.notmuch.new.tags = [ ];
}

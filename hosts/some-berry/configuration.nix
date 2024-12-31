{
  pkgs,
  lib,
  ...
}: {
  users.users = {
    patrick = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      initialPassword = "changeme";
    };
  };

  system.stateVersion = "25.05";
  # networking.networkmanager.enable = true;
  networking.wireless.enable = true;
  networking.wireless.networks = {
    "fake" = {
      # SSID with spaces and/or special characters
      psk = "fake";
    };
  };

  # allows to run python via uv
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    mpv
    libGL
    vim
    fontconfig
    xorg.libX11
    xorg.xcbutil
    xorg.libxcb
    xorg.libSM
    xorg.libICE
    xcb-util-cursor
    glib
    libxkbcommon
    freetype
    dbus
    glibc
    xorg.xcbutilwm
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xcb-util-cursor
  ];

  services.openssh.enable = true;

  services.xserver.enable = true;

  #  services.displayManager.sddm.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  environment.systemPackages = with pkgs; [
    mpv
    gh
    uv
    git
    libGL
    xorg.xcbutil
    xorg.libxcb
    xorg.libSM
    xorg.libICE
    xcb-util-cursor
    fontconfig
    xorg.xcbutilwm
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xcb-util-cursor
    libraspberrypi
  ];

  time.timeZone = lib.mkDefault "Europe/Rome";

  nix.settings = {
    experimental-features = lib.mkDefault "nix-command flakes";
    trusted-users = ["root" "@wheel"];
  };
}

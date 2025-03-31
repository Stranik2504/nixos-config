{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Stranik2504";
    userEmail = "rund2504@mail.ru";
  };

  home.packages = with pkgs;
    [
      gwenview
      xournalpp
      webcord
      (wrapOBS {
        plugins = [obs-studio-plugins.wlrobs];
      })
      okular
      libreoffice-fresh
      gimp
      (mpv.override {
        scripts = [mpvScripts.mpris];
      })
      vlc
      xfce.thunar
      xfce.tumbler
      gnome.cheese
      ark
      spotify
      firefox
      opera
      corefonts
      vistafonts
      telegram-desktop
      (obsidian.overrideAttrs {
        meta.priority = 10;
      })
      (pkgs.makeDesktopItem {
        name = "obsidian";
        desktopName = "Obsidian";
        comment = "Knowledge base";
        exec = "bash -c \"unset NIXOS_OZONE_WL && exec obsidian\"";
        icon = "obsidian";
        categories = ["Office"];
        mimeTypes = ["x-scheme-handler/obsidian"];
      })


      # utils
      unzip
      zip
      file
      wget
      bat
      htop
      usbutils
    ];
}

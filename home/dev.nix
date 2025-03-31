{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.file =
    builtins.listToAttrs (
      map
      (vmoptionsPath: {
        name = ".config/JetBrains/${vmoptionsPath}";
        value = {
          text = ''
            -Xmx4096m
            -Dsun.java2d.uiScale=1
          '';
        };
      })
      ["IntelliJIdea2024.1/idea64.vmoptions" "Rider2024.1/clion64.vmoptions"]
    )
    // {
      ".config/JetBrains/IntelliJIdea2024.2/idea64.vmoptions".text = ''
        -Xmx4096m
        -Dawt.toolkit.name=WLToolkit
      '';
    };

  programs.zsh.completionInit = ''
    if [[ $(stat -c '%U' /nix) = nobody ]]; then
      # running in distrobox
      autoload -U compinit && compinit -u
    else
      autoload -U compinit && compinit
    fi
  '';

  home.packages = with pkgs; [
    temurin-bin-21 # default java
    (python3.withPackages (
      ps:
        with ps;
          [
            black
            dbus-python
            ipython
            httpx
            pip
            pipreqs
          ]
          ++ black.optional-dependencies.d
    ))
    (poetry.withPlugins (ps: with ps; [poetry-plugin-export]))
    pipenv
    gnumake
    clang
    vscode
    # jetbrains.rider
    # (pkgs-unstable.jetbrains.idea-ultimate.overrideAttrs {
    #   src = fetchurl {
    #     url = "https://download.jetbrains.com/idea/ideaIU-242.20224.91.tar.gz";
    #     hash = "sha256-TltiejsfR6F37pr8o2O8jT+bx0tlMmKrtxFUCq4DsUE=";
    #   };
    # })
    jetbrains-toolbox
    (with dotnetCorePackages;
      combinePackages [
        sdk_7_0
        sdk_8_0
      ])
    nuget
  ];
  
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    SDL
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    SDL_image
    SDL_mixer
    SDL_ttf
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    bzip2
    cairo
    cups
    curlWithGnuTls
    dbus
    dbus-glib
    desktop-file-utils
    e2fsprogs
    expat
    flac
    fontconfig
    freeglut
    freetype
    fribidi
    fuse
    fuse3
    gdk-pixbuf
    glew110
    glib
    gmp
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-ugly
    gst_all_1.gstreamer
    gtk2
    harfbuzz
    icu
    keyutils.lib
    libGL
    libGLU
    libappindicator-gtk2
    libcaca
    libcanberra
    libcap
    libclang.lib
    libdbusmenu
    libdrm
    libgcrypt
    libgpg-error
    libidn
    libjack2
    libjpeg
    libmikmod
    libogg
    libpng12
    libpulseaudio
    librsvg
    libsamplerate
    libthai
    libtheora
    libtiff
    libudev0-shim
    libusb1
    libuuid
    libvdpau
    libvorbis
    libvpx
    libxcrypt-legacy
    libxkbcommon
    libxml2
    mesa
    nspr
    nss
    openssl
    p11-kit
    pango
    pixman
    python3
    speex
    stdenv.cc.cc
    tbb
    udev
    vulkan-loader
    wayland
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXft
    xorg.libXi
    xorg.libXinerama
    xorg.libXmu
    xorg.libXrandr
    xorg.libXrender
    xorg.libXt
    xorg.libXtst
    xorg.libXxf86vm
    xorg.libpciaccess
    xorg.libxcb
    xorg.xcbutil
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    xorg.xkeyboardconfig
    xz
    zlib
  ];
}

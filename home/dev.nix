{
  pkgs,
  pkgs-unstable,
  nix-ld,
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
    if [[ $(stat -c '%U' /nix) = nobody ]]; then22
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
}

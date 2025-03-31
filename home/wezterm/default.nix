{
  config,
  pkgs,
  ...
}: {
  programs.wezterm = {
    enable = true;
    extraConfig = (
      builtins.replaceStrings
      ["@font@"]
      [config.preferences.font.monospace]
      (builtins.readFile ./wezterm.lua)
    );
    package = pkgs.wezterm.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./5264.patch
        ];
      # src = pkgs.fetchFromGitHub {
      #   owner = "wezterm";
      #   repo = "wezterm";
      #   rev = "20240203-110809-5046fc22";
      #   hash = "sha256-hhuzs89wWKc7n6HMKriWvV+pLhfLvO06XRWtmdCQ0rs=";
      # };
    });
  };
}

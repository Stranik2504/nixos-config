{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    # cli
    yt-dlp
    httpie
    ffmpeg-full

    # de
    lm_sensors
    xorg.xhost
    grim
    wev
    wl-clipboard
    grimblast
    satty
    brightnessctl
    playerctl
    copyq
    hyprpaper
    hyprpicker
    pavucontrol
    # needed for thunar and other xfce apps to be able to save settings
    xfce.xfconf
  ];
}

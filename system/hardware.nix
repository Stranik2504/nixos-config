{pkgs, ...}: {
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          FastConnectable = true;
        };
      };
    };
    opengl.enable = true;
  };

  services = {
    printing = {
      enable = true;
    };
    blueman.enable = true;
    upower.enable = true;
    power-profiles-daemon.enable = true;
    fwupd.enable = true;
  };
}

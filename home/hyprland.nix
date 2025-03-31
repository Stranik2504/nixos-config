{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: let
    toggle-touchpad = pkgs.writeShellScript "toggle-touchpad" ''
        export STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"

        enable_touchpad() {
            printf "enabled" > "$STATUS_FILE"
            dunstify "Touchpad enabled"
            hyprctl keyword "\$TOUCHPAD_ENABLED" true
            hyprctl keyword device:a '''
        }

        disable_touchpad() {
            printf "disabled" > "$STATUS_FILE"
            dunstify "Touchpad disabled"
            hyprctl keyword "\$TOUCHPAD_ENABLED" false
            hyprctl keyword device:a '''
        }

        if ! [ -f "$STATUS_FILE" ]; then
            disable_touchpad
        else
            if [ $(cat "$STATUS_FILE") = "enabled" ]; then
                disable_touchpad
            elif [ $(cat "$STATUS_FILE") = "disabled" ]; then
                enable_touchpad
            fi
        fi
    '';
in {
  # imports = [
  #   inputs.hyprland.homeManagerModules.default
  # ];

  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ${config.preferences.wallpaper}
    wallpaper = ,${config.preferences.wallpaper}
    splash = false
  '';

  services.network-manager-applet.enable = true;

  services.dunst = {
    enable = true;
    settings = {
      global = {
        frame_color = "#89B4FA";
        separator_color = "frame";
        corner_radius = 5;
      };

      urgency_low = {
        background = "#1E1E2E";
        foreground = "#CDD6F4";
      };

      urgency_normal = {
        background = "#1E1E2E";
        foreground = "#CDD6F4";
      };

      urgency_critical = {
        background = "#1E1E2E";
        foreground = "#CDD6F4";
        frame_color = "#FAB387";
      };
    };
  };

  programs.tofi = {
    enable = true;
    settings = {
      font = config.preferences.font.monospace-path;
      font-size = 13;
      hint-font = false;
      width = 640;
      height = 360;
      text-color = "#cdd6f4";
      prompt-color = "#f38ba8";
      selection-color = "#f9e2af";
      background-color = "#1e1e2e";
      border-width = 2;
      border-color = "#74c7ec";
      outline-width = 0;
      corner-radius = 5;
      padding-left = 16;
      padding-right = 16;
      prompt-text = "\"\"";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.variables = ["--all"];
    package = pkgs-unstable.hyprland;
    # plugins = [
    #    inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
    # ];
    settings = {
      #touchpad
      "$TOUCH_ENABLED" = true;

      device = {
        name = "ftcs1000:00-2808:0101-touchpad";
        enabled = "$TOUCH_ENABLED";
      };
      #------


      monitor = [
        "eDP-1,2560x1600@165,0x0,1.6"
        # НЕ 1706
        # "DP-1,1920x1080@60,1536x0,1.25"
        # "HDMI-A-1,1920x1080@60,1536x0,1.25"
      ];

      xwayland.force_zero_scaling = true;

      exec-once = [
        "hyprpaper"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "copyq --start-server"
        "playerctld daemon"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORM,wayland"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "GTK_USE_PORTAL,1" # make gtk applications use portal instead of builtin gtk file picker
        "NIXOS_OZONE_WL,1"
        "NIX_LD_LIBRARY_PATH,${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.libz}/lib"
      ];

      input = {
        kb_layout = "us,ru";
        kb_options = "grp:caps_toggle";

        follow_mouse = 1;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgb(cba6f7) rgb(f5c2e7) 45deg";
        "col.inactive_border" = "rgb(313244)";

        layout = "dwindle";

        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;
      };

      group = {
        "col.border_active" = "rgb(cba6f7) rgb(f5c2e7) 45deg";
        "col.border_inactive" = "rgb(313244)";

        groupbar = {
          font_family = config.preferences.font.monospace;
          render_titles = false;
          height = 1;
          "col.active" = "rgb(f5c2e7)";
          "col.inactive" = "rgb(313244)";
        };
      };

      decoration = {
        rounding = 5;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };

        drop_shadow = false;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      animations = {
        enabled = true;
        bezier = [
          "windows, 0.05, 0.9, 0.1, 1.05"
          "linear, 1, 1, 1, 1"
        ];

        animation = [
          "workspaces, 1, 2, default"
          "windows, 1, 3, windows, slide"
          "border, 1, 1, linear"
          "borderangle, 1, 30, linear, loop"
          "fade, 1, 10, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      gestures = {
        workspace_swipe = false;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        allow_session_lock_restore = true;
        enable_swallow = true;
        swallow_regex = ".*wezterm$";
        swallow_exception_regex = ".*noswallow.*";
        vrr = 2;
	no_direct_scanout=true;
      };

      # render = {
      #   direct_scanout = false;
      # };

      windowrulev2 =
        [
          "suppressevent maximize, class:.*"
          "size 500 700, class:com.github.hluk.copyq"
          # Chrome screen sharing popups
          "move 67% 100%-70, title:is sharing a window.$"
          "move 67% 100%-70, title:is sharing your screen.$"
          # VSCode confirmation popups
          "stayfocused, class:code, floating:1"
          "noborder, class:code, floating:1"

          # allow idea to move windows
          # "windowdance,class:^(jetbrains-.*)$,floating:1"
          # "stayfocused,class:^(jetbrains-.*)$,title:^$,floating:1"
          "noborder,class:^(jetbrains-.*)$,title:^$,floating:1"
        ]
        ++ (builtins.concatMap (class: [
            "float, class:${class}"
            "center 1, class:${class}"
          ]) [
            "com.github.hluk.copyq"
            ".blueman-manager-wrapped"
            "pavucontrol"
          ]);

      layerrule = [
        # tofi
        "noanim, launcher"
      ];

      bind = let
        binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
        resize = binding "SUPER ALT" "resizeactive";
      in
        [
          "SUPER, Return, exec, wezterm start --always-new-process"
          "SUPER, M, exit,"
          "SUPER, E, exec, thunar"
          "ALT, Space, exec, tofi-drun --drun-launch=true"
          "SUPER, V, exec, copyq toggle"

          "SUPER, Escape, exec, loginctl lock-session"

          # Screenshots
          "SUPER SHIFT, S, exec, grimblast --freeze copy area"
          ", XF86Launch2, exec, grimblast --freeze copy area"
          "SUPER CTRL, S`, exec, grimblast --freeze copy output"
          # "SUPER SHIFT, S, exec, sleep 3 && grimblast --freeze copy area"
          "SUPER CTRL, S, exec, GRIMBLAST_EDITOR=\"satty --copy-command wl-copy --filename\" grimblast --freeze edit area"
          # "SUPER, O, exec, hyprpicker --autocopy"

          # Misc window management
          "SUPER SHIFT, Q, killactive,"
          "SUPER SHIFT, Space, togglefloating,"
          "SUPER, J, togglesplit,"
          "SUPER, P, pin"
          "SUPER, F, fullscreen, 0"

          # Resize window
          (resize "left" "-20 0")
          (resize "right" "20 0")
          (resize "up" "0 20")
          (resize "down" "0 -20")

          # Grouping
          "SUPER, G, togglegroup,"
          "SUPER, Tab, changegroupactive, f"
          "SUPER SHIFT, Tab, changegroupactive, b"

          "SUPER, mouse_down, workspace, e-1"
          "SUPER, mouse_up, workspace, e+1"

          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

          # Mute mic
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ]
        ++ (builtins.concatMap (x: let
          arg = builtins.substring 0 1 x;
        in [
          (binding "SUPER" "movefocus" x arg)
          (binding "SUPER SHIFT" "swapwindow" x arg)
          (binding "SUPER CTRL" "moveintogroup" x arg)
          (binding "SUPER CTRL SHIFT" "moveoutofgroup" x arg)
        ]) ["left" "right" "up" "down"])
        ++ (builtins.concatMap (i: [
          (binding "SUPER" "workspace" i i)
          (binding "SUPER SHIFT" "movetoworkspace" i i)
        ]) (map toString [1 2 3 4 5 6 7 8 9]));

      bindl = [
        "SUPER SHIFT, Pause, exec, systemctl suspend"
      ];

      bindle = [
        ", XF86MonBrightnessUp, exec, brightnessctl s +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"

        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl pause"
        ", XF86AudioStop, exec, playerctl pause"
        ", XF86AudioPlayPause, exec, playerctl play-pause"
        ", XF86Go, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", Cancel, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86Messenger, exec, playerctl previous"
        ", XF86TouchpadToggle, exec, ${toggle-touchpad}"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };
  };
}

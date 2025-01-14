{
  pkgs,
  lib,
  config,
  ...
}: {
  services.blueman-applet.enable = true;

  programs.waybar = let
    fans = with pkgs; (writeShellScript "fans" ''
      set -e
      fan_speed=$(cat /sys/class/hwmon/hwmon5/fan1_input)
      if [[ $fan_speed != 0 ]]; then
        fan_speed=$(printf '%-4s' $fan_speed)
      fi
      text="󰈐 $fan_speed"
      echo '{"text": "'"$text"'", "alt": "", "tooltip": "", "class": "", "percentage": 0 }'
    '');
    dconf = lib.getExe pkgs.dconf;
    theme = pkgs.writers.writePython3 "theme" {flakeIgnore = ["E501"];} ''
      import sys
      import json
      import subprocess
      SIGRTMIN = 34
      ICONS = {
          'prefer-light': '\uf522 ',
          'prefer-dark': '\uf4ee ',
      }
      color_scheme = subprocess.check_output(['${dconf}', 'read', '/org/gnome/desktop/interface/color-scheme']).decode().strip("\n'")
      if sys.argv[1] == 'get':
          print(json.dumps({'text': ICONS.get(color_scheme, 'unknown theme')}))
      elif sys.argv[1] == 'toggle':
          if color_scheme == 'prefer-light':
              color_scheme = 'prefer-dark'
          else:
              color_scheme = 'prefer-light'
          subprocess.check_call(['${dconf}', 'write', '/org/gnome/desktop/interface/color-scheme', f'"{color_scheme}"'])
          subprocess.check_call(f'kill -{SIGRTMIN + 1} $(pgrep waybar)', shell=True)
      else:
          raise ValueError()
    '';
  in {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        "layer" = "top";
        "position" = "top";
        "height" = 30;
        "spacing" = 10;
        "modules-left" = ["hyprland/workspaces" "hyprland/submap"];
        "modules-center" = [];
        "modules-right" = [
          "tray"
          "custom/theme"
          "pulseaudio"
          "temperature"
          "custom/fans"
          "hyprland/language"
          "battery"
          "clock"
          "clock#date"
        ];
        "custom/theme" = {
          "exec" = "${theme} get";
          "on-click" = "${theme} toggle";
          "interval" = "once";
          "signal" = 1;
          "return-type" = "json";
        };
        "temperature" = {
          "format" = "{temperatureC}°C ";
        };
        "custom/fans" = {
          "exec" = fans;
          "interval" = 5;
          "return-type" = "json";
        };
        "hyprland/workspaces" = {
          "format" = "{icon}";
          "on-scroll-up" = "hyprctl dispatch workspace e-1";
          "on-scroll-down" = "hyprctl dispatch workspace e+1";
          "format-icons" = {
            "default" = "";
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "11" = "1";
            "12" = "2";
            "13" = "3";
            "14" = "4";
            "15" = "5";
            "16" = "6";
            "17" = "7";
            "18" = "8";
            "19" = "9";
            "active" = "󱓻";
            "urgent" = "󱓻";
          };
          "persistent-workspaces" = {
            "eDP-1" = [1 2 3 4 5];
            "DP-1" = [11 12 13 14 15];
            "HDMI-A-1" = [11 12 13 14 15];
          };
        };
        "hyprland/window" = {
          "max-length" = 200;
          "rewrite" = {
            "(.*) - Google Chrome" = "$1";
            "(.*) @ [^@]*$" = "$1";
          };
          "separate-outputs" = true;
        };
        "tray" = {
          "spacing" = 10;
        };
        "hyprland/language" = {
          "format" = "{}";
          "format-de" = "en";
          "format-ru" = "ru";
        };
        "mpris" = {
          "format" = "{status_icon} {player} {title} — {artist}";
          "status-icons" = {
            "playing" = "";
            "paused" = "";
          };
        };
        "clock" = {
          "tooltip-format" = "<big>{:%e %B %Y}</big>\n<tt><small>{calendar}</small></tt>";
          "locale" = "ru_RU.UTF-8";
          "interval" = 1;
          "format" = "{:%H:%M:%S}";
        };
        "clock#date" = {
          "tooltip-format" = "<big>{:%e %B %Y}</big>\n<tt><small>{calendar}</small></tt>";
          "locale" = "ru_RU.UTF-8";
          "interval" = 60;
          "format" = "{:%e.%m.%Y}";
        };
        "battery" = {
          "bat" = "BAT0";
          "format" = "{capacity}% {icon}";
          "format-full" = "";
          "format-icons" = {
            "charging" = ["󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅"];
            "default" = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          };
          "interval" = 5;
          "states" = {
            "warning" = 30;
            "critical" = 10;
          };
          "tooltip" = false;
        };
        "pulseaudio" = {
          "format" = "{icon} {volume}%";
          "format-bluetooth" = "󰂰 {volume}%";
          "format-source" = "{volume}% ";
          "format-source-muted" = "";
          "nospacing" = 1;
          "tooltip-format" = "{format_source}";
          "format-muted" = "󰝟";
          "format-icons" = {
            "headphone" = "";
            "default" = ["󰖀" "󰕾" ""];
          };
          "scroll-step" = 1;
          "on-click" = lib.getExe pkgs.pavucontrol;
        };
      };
    };
    style = ''
      * {
        border: none;
        border-radius: 0;
        min-height: 0;
        font-family: ${config.preferences.font.monospace};
        font-size: 13px;
      }

      window#waybar {
        background-color: transparent;
        transition-property: background-color;
        transition-duration: 0.5s;
      }

      window#waybar.hidden {
        opacity: 0.5;
      }

      #workspaces {
        background-color: transparent;
      }

      #workspaces button {
        all: initial; /* Remove GTK theme values (waybar #1351) */
        min-width: 0; /* Fix weird spacing in materia (waybar #450) */
        box-shadow: inset 0 -3px transparent; /* Use box-shadow instead of border so the text isn't offset */
        padding: 4px 18px;
        margin-top: 5px;
        margin-left: 10px;
        margin-bottom: 0;
        border-radius: 4px;
        background-color: #1e1e2e;
        color: #cdd6f4;
      }

      #workspaces button.active {
        color: #1e1e2e;
        background-color: #cdd6f4;
      }

      #workspaces button:hover {
        box-shadow: inherit;
        text-shadow: inherit;
        color: #1e1e2e;
        background-color: #cdd6f4;
      }

      #workspaces button.urgent {
        background-color: #f38ba8;
      }

      #custom-vpns,
      #custom-theme,
      #language,
      #temperature,
      #custom-fans,
      #battery,
      #pulseaudio,
      #clock,
      clock.date,
      #tray {
        border-radius: 4px;
        margin-top: 5px;
        margin-bottom: 0;
        padding: 4px 12px;
        background-color: #1e1e2e;
        color: #181825;
      }

      #temperature {
        background-color: #94e2d5;
      }
      #battery {
        background-color: #89b4fa;
      }
      @keyframes blink {
        to {
          background-color: #f38ba8;
          color: #181825;
        }
      }

      #battery.warning,
      #battery.critical,
      #battery.urgent {
        background-color: #ff0048;
        color: #181825;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }
      #battery.charging {
        background-color: #a6e3a1;
      }

      #pulseaudio {
        background-color: #a6e3a1;
      }

      #clock {
        background-color: #b4befe;
      }

      clock.date {
        background-color: #b4befe;
        margin-right: 10px;
      }

      #language {
        background-color: #74c7ec;
        min-width: 16px;
      }

      tooltip {
        border-radius: 8px;
        padding: 15px;
        background-color: #131822;
      }

      tooltip label {
        padding: 5px;
        background-color: #131822;
      }

      #custom-vpns {
        background-color: #fab387;
      }

      #custom-theme {
        padding: 4px 7px 4px 10px;
        background-color: #f9e2af;
      }

      #custom-fans {
        background-color: #89dceb;
      }
    '';
  };
}

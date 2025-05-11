{pkgs, ...}: {
    programs.fastfetch = {
        enable = true;
        settings = {
            # logo = {
            #     source = pkgs.fetchurl {
            #         url = "https://daiderd.com/nix-darwin/images/nix-darwin.png";
            #         hash = "sha256-CeA0LbC3q6HMZuqJ9MHncI5z8GZ/EMAn7ULjiIX0wH4=";
            #     };
            #     type = "kitty-direct";
            #     padding = {
            #         right = 3;
            #         top = 2;
            #         bottom = 2;
            #     };
            # };
            display = {
                color = {
                    keys = "blue";
                    title = "red";
                };
                constants = [
                    "──────────────────────────"
                ];
            };
            modules = [
                {
                    type = "custom";
                    format = "┌{$1} {#1}Hardware{#} ─{$1}┐";
                }
                {
                    type = "title";
                    format = "{1}@{2}";
                    key = "  {#cyan}{icon} Title";
                    color = "blue";
                }
                {
                    type = "host";
                    key = "  {#cyan}{icon} Host";
                }
                {
                    type = "display";
                    key = " {#cyan} {icon} Display";
                }
                {
                    type = "cpu";
                    key = "  {#cyan}{icon} CPU";
                    showPeCoreCount = true;
                    temp = true;
                    format = "{name}  {#2}[C:{core-types}] [{freq-max}]";
                }
                {
                    type = "gpu";
                    key = "  {#cyan}{icon} GPU";
                    detectionMethod = "auto";
                    driverSpecific = true;
                    format = "{name}  {#2}[C:{core-count}]{?frequency} [{frequency}]{?} [{type}]";
                }
                {
                    type = "memory";
                    key = "  {#cyan}{icon} Memory";
                    format = "{used} / {total} ({percentage})";
                }

                {
                    type = "disk";
                    key = "  {#cyan}{icon} Disk";
                    format = "{size-used} / {size-total} ({size-percentage})";
                    folders = ["/" "/home"];
                }

                {
                    type = "custom";
                    format = "├{$1} {#1}System ───{#}{$1}┤";
                }
                {
                    type = "os";
                    key = "  {#green}{icon} OS";
                    format = "{?pretty-name}{pretty-name}{?}{/pretty-name}{name}{/} {codename}  {#2}[v{version}] [{arch}]";
                }
                {
                    type = "kernel";
                    key = "  {#green}{icon} Kernel";
                    format = "{sysname}  {#2}[v{release}]";
                }
                {
                    type = "de";
                    key = "  {#green}{icon} DE";
                }
                {
                    type = "wm";
                    key = "  {#green}{icon} WM";
                }
                {
                    type = "uptime";
                    key = "  {#green}{icon} Uptime";
                    format = "{?days}{days} Days + {?}{hours}:{minutes}:{seconds}";
                }

                {
                    type = "custom";
                    format = "├{$1} {#1}Software{#} ─{$1}┤";
                }
                {
                    type = "packages";
                    key = "  {#yellow}{icon} Packages";
                    # format = "{9} total ({1} pkg, {2} cask, {3} flatpak, {6} snap)";
                }
                {
                    type = "shell";
                    key = "  {#yellow}{icon} Shell";
                    format = "{pretty-name}  {#2}[v{version}] [PID:{pid}]";
                }
                {
                    type = "terminal";
                    key = "  {#yellow}{icon} Terminal";
                    format = "{pretty-name}  {#2}[{version}] [PID:{pid}]";
                }
                {
                    type = "font";
                    key = "  {#yellow}{icon} Font";
                }

                {
                    type = "custom";
                    format = "├{$1} {#1}Network{#} ──{$1}┤";
                }
                {
                    type = "localip";
                    key = "  {#magenta}{icon} Local IP";
                    showPrefixLen = true;
                    showIpv4 = true;
                    showIpv6 = false;
                    showMtu = true;
                    format = "{ifname}: {ipv4}  {#2}[MTU:{mtu}]";
                }
                {
                    type = "publicip";
                    key = "  {#magenta}{icon} Public IPv4";
                    ipv6 = false;
                    format = "{ip}  {#2}[{location}]";
                }
                {
                    type = "publicip";
                    key = "  {#magenta}{icon} Public IPv6";
                    ipv6 = true;
                    format = "{ip}  {#2}[{location}]";
                }
                {
                    type = "wifi";
                    key = "  {#magenta}{icon} Wifi";
                    format = "{ssid}";
                }

                {
                    type = "custom";
                    key = "{#}└─{$1}──────────{$1}┘";
                    format = "";
                }
                "break"
                "colors"
            ];
            palette = "supply";
        };
    };
}

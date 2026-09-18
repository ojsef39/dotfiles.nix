{containers, ...}: let
  spaces = {
    "JHC" = {
      id = "41b9ce21-3927-483f-9173-e3919191c528";
      icon = "chrome://browser/skin/zen-icons/selectable/cloud.svg";
      container = containers."Personal".id;
      position = 2000;
      theme = {
        type = "gradient";
        colors = [
          {
            red = 138;
            green = 173;
            blue = 244;
            algorithm = "floating";
            type = "explicit-lightness";
          }
        ];
        opacity = 0.5;
        texture = 0.5;
      };
    };
  };

  pins = {
    "GitHub PRs" = {
      id = "bd9ab8c6-bd49-4765-b776-3cd0360c4284";
      url = "https://github.com/pulls?max_pr_age=none";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      position = 201;
    };
    "Fleet" = {
      id = "5ebc16a8-6e75-4a35-883e-4857642b2b91";
      url = "https://github.com/JHOFER-Cloud/fleet";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      position = 202;
    };
    "Slack" = {
      id = "15319ac1-5fa8-4a89-b68f-78d7753c155c";
      url = "https://jhofer.slack.com";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      position = 203;
    };
    "Pushover" = {
      id = "7995040d-7e29-4fa9-b2a5-3219d7407101";
      url = "https://client.pushover.net/";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      position = 204;
    };
    "BetterStack" = {
      id = "a569ad92-804d-47ce-9bd4-5e3055836642";
      url = "https://uptime.betterstack.com/team/t459242/status-pages/225777/reports";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      position = 205;
    };
    "Status" = {
      id = "7c80133f-2841-4230-bc49-bd293e6255d0";
      url = "https://status.jhofer.org";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      position = 206;
    };
    "Renovate" = {
      id = "165ff60e-6815-4c80-8c6b-26aa35174b33";
      url = "https://renovate.jhofer.org/?filter=running";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      position = 207;
    };

    # --- START HLA1 folder ---
    "HLA1" = {
      id = "9baf02c7-f996-4186-91a3-a93a23acdaa9";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      isGroup = true;
      isFolderCollapsed = true;
      position = 208;
    };
    "deskvms" = {
      id = "e59e2f2b-6478-42c7-8bb0-1b932d0a43c0";
      url = "https://deskvms.hla1.jhofer.lan/";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      folderParentId = pins."HLA1".id;
      position = 209;
    };
    "ups-a" = {
      id = "298b2ac7-dd3d-48fd-b571-f9bb91dc86db";
      url = "http://ups-a.hla1.jhofer.lan/";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      folderParentId = pins."HLA1".id;
      position = 210;
    };
    "pve" = {
      id = "5b1cbe14-77a8-4a3c-af51-2b7da420b111";
      url = "https://pve.hla1.jhofer.lan/";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      folderParentId = pins."HLA1".id;
      position = 211;
    };
    "kube-radar-dev" = {
      id = "f48d7302-f312-4383-9bb5-c933a8d7923f";
      url = "https://kube-radar.dev.k8.hla1.jhofer.lan";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      folderParentId = pins."HLA1".id;
      position = 212;
    };
    "kube-radar-live" = {
      id = "329d19d4-cde0-484e-8291-81e8399df48c";
      url = "https://kube-radar.live.k8.hla1.jhofer.lan";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      folderParentId = pins."HLA1".id;
      position = 213;
    };
    "pve-1-kvm" = {
      id = "ac1a9ea1-0135-496c-a7c9-5c2982e3be58";
      url = "https://pve-1-kvm.hla1.jhofer.lan";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      folderParentId = pins."HLA1".id;
      position = 214;
    };
    "bc1-cmc" = {
      id = "2cf2c1f8-889d-4db1-8828-e86e3e8202cb";
      url = "https://bc1-cmc.hla1.jhofer.lan";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      folderParentId = pins."HLA1".id;
      position = 215;
    };
    "bc1-b1-p2-idrac" = {
      id = "690393bf-d699-4d06-be69-8426fde6f373";
      url = "https://bc1-b1-p2-idrac.hla1.jhofer.lan/restgui/start.html";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      folderParentId = pins."HLA1".id;
      position = 216;
    };
    "bc1-b2-p3-idrac" = {
      id = "f344e89a-140c-472d-9ed7-5862c67b35cc";
      url = "https://bc1-b2-p3-idrac.hla1.jhofer.lan/restgui/start.html";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      folderParentId = pins."HLA1".id;
      position = 217;
    };
    # --- END HLA1 folder ---
    "Energy Watchdog" = {
      id = "2e07fe68-3d8d-44ed-8b16-d38526614779";
      url = "https://grafana.hla1.jhofer.lan/d/energy-watchdog/energy-watchdog?from=now-12h&to=now&refresh=1m";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      position = 218;
    };
    "Nut Dog" = {
      id = "2a1e9dd9-a47d-43b8-8a4c-88855d4d827e";
      url = "https://grafana.hla1.jhofer.lan/d/nut-dog/nut-dog?from=now-6h&to=now&refresh=1m";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      position = 219;
    };
    "Rack Temps" = {
      id = "10bdc242-5fb3-459f-ae32-aa711c297a86";
      url = "https://grafana.hla1.jhofer.lan/d/rack_temps/rack-temps?from=now-6h&to=now&refresh=1m";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      position = 220;
    };
    "Misc Overview" = {
      id = "950825df-59e8-4d51-a491-bb4226aecda2";
      url = "https://grafana.hla1.jhofer.lan/d/dcf5mhzhh7gyyoc/misc-overview?from=now-6h&to=now&refresh=1m";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      position = 221;
    };

    # --- START Satisfactory folder ---
    "Satisfactory" = {
      id = "6a6d21ee-9ef3-456f-a4f2-78a82814ac75";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      isGroup = true;
      isFolderCollapsed = true;
      position = 222;
    };
    "satisfaction01-p1" = {
      id = "7b85e9fd-4b33-4321-bb5b-f747945cb0a7";
      url = "https://satisfaction01-p1.hla1.jhofer.lan/map";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      folderParentId = pins."Satisfactory".id;
      position = 223;
    };
    "Satisfactory (Grafana)" = {
      id = "dbddfbf3-fe78-4122-a64a-bfbf87a7ddec";
      url = "https://grafana.hla1.jhofer.lan/d/satisfactory-savegame-exporter/?from=now-6h&to=now";
      container = containers.Personal.id;
      workspace = spaces."JHC".id;
      folderParentId = pins."Satisfactory".id;
      position = 224;
    };
    # --- END Satisfactory folder ---
  };

  joinedTabs = {
    "BetterStack + Status" = {
      id = "betterstack-status-split";
      gridType = "vsep";
      tabs = [
        pins."BetterStack".id
        pins."Status".id
      ];
      sizes = [
        70
        30
      ];
    };
    "Energy Watchdog + Nut Dog" = {
      id = "energy-watchdog-nut-dog-split";
      gridType = "vsep";
      tabs = [
        pins."Energy Watchdog".id
        pins."Nut Dog".id
      ];
      sizes = [
        50
        50
      ];
    };
    "Rack Temps + Misc Overview" = {
      id = "rack-temps-misc-overview-split";
      gridType = "vsep";
      tabs = [
        pins."Rack Temps".id
        pins."Misc Overview".id
      ];
      sizes = [
        65
        35
      ];
    };
  };
in {inherit spaces pins joinedTabs;}

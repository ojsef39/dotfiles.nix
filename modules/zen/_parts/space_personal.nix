{containers, ...}: let
  spaces = {
    "Personal" = {
      id = "cf13a859-8f2f-4af2-b563-d8a456cc917d";
      icon = "chrome://browser/skin/zen-icons/selectable/planet.svg";
      container = containers."Personal".id;
      position = 1000;
      theme = {
        type = "gradient";
        colors = [
          {
            red = 183;
            green = 189;
            blue = 248;
            algorithm = "floating";
            type = "explicit-lightness";
          }
        ];
        opacity = 0.8;
        texture = 0.1;
      };
    };
  };

  pins = {
    "JustWatch" = {
      id = "9ebdef2c-6c7c-467a-9d81-28bebdb17654";
      url = "https://www.justwatch.com/de/lists/tv-show-tracking";
      container = containers.Personal.id;
      workspace = spaces."Personal".id;
      position = 201;
    };
    "Reddit" = {
      id = "6134667a-3c74-4f69-8f6b-a694a7664fb9";
      url = "https://www.reddit.com/";
      container = containers.Personal.id;
      workspace = spaces."Personal".id;
      position = 202;
    };
    "Mastodon" = {
      id = "6f859dea-2aff-41ea-9d41-ba3b99ff38c4";
      url = "https://mastodon.de/home";
      container = containers.Personal.id;
      workspace = spaces."Personal".id;
      position = 203;
    };
    "Chaos Social" = {
      id = "7455a4ec-c165-47da-87dc-11c8499539bd";
      url = "https://chaos.social/home";
      container = containers.Personal.id;
      workspace = spaces."Personal".id;
      position = 204;
    };

    # --- START Trivia folder ---
    "Trivia" = {
      id = "82631586-8f23-450c-a2b3-48b1c490b3f6";
      container = containers.Personal.id;
      workspace = spaces."Personal".id;
      isGroup = true;
      isFolderCollapsed = true;
      position = 205;
    };
    "JetPunk" = {
      id = "56cee429-97ce-4933-b78e-155dbdb16e92";
      url = "https://www.jetpunk.com/";
      container = containers.Personal.id;
      workspace = spaces."Personal".id;
      folderParentId = pins."Trivia".id;
      position = 206;
    };
    "WikiTrivia" = {
      id = "7256579c-4d81-46ae-aa1d-4ab046264c87";
      url = "https://wikitrivia.tomjwatson.com/";
      container = containers.Personal.id;
      workspace = spaces."Personal".id;
      folderParentId = pins."Trivia".id;
      position = 207;
    };
    # --- END Trivia folder ---
  };
in {inherit spaces pins;}

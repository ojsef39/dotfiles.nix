# Pins for this space are defined in the nix-work repo.
{containers, ...}: let
  spaces = {
    "ToDo" = {
      id = "574b2a07-ae22-4df7-8a7c-31e28a7e707a";
      icon = "chrome://browser/skin/zen-icons/selectable/checkbox.svg";
      container = containers."Personal".id;
      position = 3000;
      theme = {
        type = "gradient";
        colors = [
          {
            red = 47;
            green = 21;
            blue = 26;
            algorithm = "floating";
            type = "explicit-lightness";
          }
        ];
        opacity = 0.5;
        texture = 0.5;
      };
    };
  };
in {
  inherit spaces;
  pins = {};
  joinedTabs = {};
}

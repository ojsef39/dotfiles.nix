# Pins for this space are defined in the nix-work repo.
{containers, ...}: let
  spaces = {
    "Work" = {
      id = "450c7d65-0b3f-41ca-8dca-7b46638bfe96";
      icon = "chrome://browser/skin/zen-icons/selectable/briefcase.svg";
      container = containers."Work".id;
      position = 3000;
      theme = {
        type = "gradient";
        colors = [
          {
            red = 30;
            green = 30;
            blue = 27;
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
}

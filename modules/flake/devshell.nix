_: {
  perSystem = {pkgs, ...}: let
    md-build = pkgs.writeShellScriptBin "md-build" ''
      ${pkgs.mdbook}/bin/mdbook build wiki
    '';

    md-serve = pkgs.writeShellScriptBin "md-serve" ''
      ${pkgs.mdbook}/bin/mdbook serve wiki
    '';
  in {
    formatter = pkgs.alejandra;

    apps = {
      md-build = {
        type = "app";
        program = "${md-build}/bin/md-build";
      };
      md-serve = {
        type = "app";
        program = "${md-serve}/bin/md-serve";
      };
    };

    devShells.default = pkgs.mkShell {
      packages = [
        pkgs.mdbook
        md-build
        md-serve
      ];
    };
  };
}

{
  pkgs,
  inputs,
  vars ? {},
}:
{
  kubectl-debug = pkgs.callPackage ./kubectl-debug {inherit vars;};
  jhcode = pkgs.callPackage ./jhcode {};
  archive-linear-issue = pkgs.callPackage ./archive-linear-issue {inherit inputs;};
  hypr-kinetic-scroll = pkgs.callPackage ./hypr-kinetic-scroll {inherit inputs;};
  # Future packages can be added here...
}
// import ./notify {inherit pkgs;}

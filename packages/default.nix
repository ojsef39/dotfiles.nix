{
  pkgs,
  vars ? {},
}:
{
  kubectl-debug = pkgs.callPackage ./kubectl-debug {inherit vars;};
  jhcode = pkgs.callPackage ./jhcode {};
  # Future packages can be added here...
}
// import ./notify {inherit pkgs;}

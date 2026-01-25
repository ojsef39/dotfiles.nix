{
  pkgs,
  vars ? {},
}: {
  kubectl-debug = pkgs.callPackage ./kubectl-debug {inherit vars;};
  cachix-hook = pkgs.callPackage ./cachix-hook {};
  # Future packages can be added here...
}

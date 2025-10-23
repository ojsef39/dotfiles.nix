{
  pkgs,
  vars,
}: {
  kubectl-debug = pkgs.callPackage ./kubectl-debug {inherit vars;};
  # Future packages can be added here...
}

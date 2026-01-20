#TODO: https://github.com/bennypowers/nvim-regexplainer
#TODO: https://github.com/yazi-rs/plugins/tree/main/diff.yazi
{pkgs, ...}: {
  # Import nvf configuration
  imports = [./nvf];

  # Packages you also want to use outside of nvim
  home.packages = with pkgs; [
    fd
    fzf
    git
    jc
    maple-mono.NF
    nixfmt
    ripgrep
    yq-go
  ];
}

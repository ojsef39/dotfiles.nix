{
  flake.modules.homeManager.base =
    #TODO: https://github.com/bennypowers/nvim-regexplainer
    #Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/401
    #TODO: https://github.com/yazi-rs/plugins/tree/main/diff.yazi
    #Issue URL: https://github.com/ojsef39/dotfiles.nix/issues/400
    {pkgs, ...}: {
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
    };
}

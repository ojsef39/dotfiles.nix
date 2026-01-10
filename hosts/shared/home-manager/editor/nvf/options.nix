_: {
  # Complete vim options migrated from your config
  options = {
    # Line numbers
    number = true;
    relativenumber = true;
    numberwidth = 3;

    # Tabs and indentation
    tabstop = 4;
    shiftwidth = 4;
    softtabstop = 4;
    expandtab = true;
    smartindent = true;
    breakindent = true;

    # Search
    ignorecase = true;
    smartcase = true;
    hlsearch = true;
    incsearch = true;

    # UI
    termguicolors = true;
    signcolumn = "yes:1";
    showmode = false;
    cmdheight = 1;
    laststatus = 2;
    scrolloff = 8;
    colorcolumn = "0";
    textwidth = 160;

    # Whitespace display
    list = true;
    listchars = "space: ,trail:⋅,tab:  ↦";

    # Folding
    foldmethod = "expr";
    foldexpr = "nvim_treesitter#foldexpr()";
    foldlevel = 99;
    foldcolumn = "1";

    # File settings
    clipboard = "unnamedplus";
    fileencoding = "utf-8";
    wrap = false;
    swapfile = false;
    backup = false;
    undofile = true;
    exrc = true; # Per-project config
    secure = true;
    fixendofline = true;
    endofline = true;

    # Splits
    splitright = true;

    # Mouse
    mouse = "a";

    # Diff
    diffopt = "filler,closeoff,vertical,algorithm:histogram,indent-heuristic";

    # Other
    switchbuf = "usetab";
    winborder = "rounded";
    statuscolumn = "";
    wildignore = "append:.DS_Store";
  };
}

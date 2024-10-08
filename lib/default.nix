{inputs}: let
  inherit (inputs.nixpkgs) legacyPackages;
in rec {
  mkVimPlugin = {system}: let
    inherit (pkgs) vimUtils;
    inherit (vimUtils) buildVimPlugin;
    pkgs = legacyPackages.${system};
  in
    buildVimPlugin {
      name = "astasko";
      postInstall = ''
        rm -rf $out/.envrc
        rm -rf $out/.gitignore
        rm -rf $out/LICENSE
        rm -rf $out/README.md
        rm -rf $out/flake.lock
        rm -rf $out/flake.nix
        rm -rf $out/justfile
        rm -rf $out/lib
      '';
      src = ../.;
    };

  mkNeovimPlugins = {system}: let
    inherit (pkgs) vimPlugins;
    pkgs = legacyPackages.${system};
    astasko-nvim = mkVimPlugin {inherit system;};
  in [
    # languages
    vimPlugins.nvim-lspconfig
    vimPlugins.nvim-treesitter.withAllGrammars
    vimPlugins.rust-tools-nvim
    vimPlugins.vim-just

    # telescope
    vimPlugins.plenary-nvim
    vimPlugins.telescope-nvim

    # theme
    vimPlugins.catppuccin-nvim

    # floaterm
    vimPlugins.vim-floaterm

    # extras
    vimPlugins.cmp-buffer
    vimPlugins.cmp-cmdline
    vimPlugins.cmp-nvim-lsp
    vimPlugins.cmp-path

    vimPlugins.cmp_luasnip
    vimPlugins.comment-nvim
    vimPlugins.conform-nvim
    vimPlugins.gitsigns-nvim
    vimPlugins.indent-blankline-nvim
    vimPlugins.lualine-nvim
    vimPlugins.luasnip
    vimPlugins.lspkind-nvim
    vimPlugins.noice-nvim
    vimPlugins.nui-nvim
    vimPlugins.nvim-cmp
    vimPlugins.nvim-colorizer-lua
    vimPlugins.nvim-notify
    vimPlugins.nvim-treesitter-context
    vimPlugins.nvim-web-devicons
    vimPlugins.omnisharp-extended-lsp-nvim
    vimPlugins.rainbow-delimiters-nvim
    vimPlugins.trouble-nvim

    # configuration
    astasko-nvim
  ];

  mkExtraPackages = {system}: let
    inherit (pkgs) nodePackages python3Packages;
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in [
    # language servers
    nodePackages.bash-language-server
    nodePackages.diagnostic-languageserver
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    pkgs.gopls
    pkgs.jsonnet-language-server
    pkgs.lua-language-server
    pkgs.nil
    pkgs.pyright
    pkgs.rust-analyzer
    pkgs.terraform-ls

    # formatters
    pkgs.alejandra
    pkgs.gofumpt
    pkgs.golines
    pkgs.rustfmt
    pkgs.terraform
    python3Packages.black
  ];

  mkExtraConfig = ''
    lua << EOF
      require 'astasko'.init()
    EOF
  '';

  mkNeovim = {system}: let
    inherit (pkgs) lib neovim;
    extraPackages = mkExtraPackages {inherit system;};
    pkgs = legacyPackages.${system};
    start = mkNeovimPlugins {inherit system;};
  in
    neovim.override {
      configure = {
        customRC = mkExtraConfig;
        packages.main = {inherit start;};
      };
      extraMakeWrapperArgs = ''--suffix PATH : "${lib.makeBinPath extraPackages}"'';
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
    };

  mkHomeManager = {system}: let
    extraConfig = mkExtraConfig;
    extraPackages = mkExtraPackages {inherit system;};
    plugins = mkNeovimPlugins {inherit system;};
  in {
    inherit extraConfig extraPackages plugins;
    defaultEditor = true;
    enable = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
  };
}

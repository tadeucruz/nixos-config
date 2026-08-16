-- Java + Go, the two languages this setup is meant to cover.
--
-- LSP servers (jdtls, gopls) are installed by Mason, LazyVim's default —
-- not by nix. jdtls in particular is tightly coupled to Mason's install
-- layout inside LazyVim's java extra, so forcing a nix-provided binary in
-- there is fragile. Mason installs into ~/.local/share/nvim/mason, outside
-- the nix store, so there's no read-only conflict either.
return {
  -- lang.java/lang.go only *configure* debug adapters if nvim-dap is
  -- already loaded — they don't load it themselves. dap.core is what
  -- actually provides nvim-dap/nvim-dap-ui and the <leader>d keymaps.
  { import = "lazyvim.plugins.extras.dap.core" },
  { import = "lazyvim.plugins.extras.lang.java" },
  { import = "lazyvim.plugins.extras.lang.go" },
}

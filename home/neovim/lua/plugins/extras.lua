-- Java + Go, the two languages this setup is meant to cover.
--
-- LSP servers (jdtls, gopls) are installed by Mason, LazyVim's default —
-- not by nix. jdtls in particular is tightly coupled to Mason's install
-- layout inside LazyVim's java extra, so forcing a nix-provided binary in
-- there is fragile. Mason installs into ~/.local/share/nvim/mason, outside
-- the nix store, so there's no read-only conflict either.
return {
  { import = "lazyvim.plugins.extras.lang.java" },
  { import = "lazyvim.plugins.extras.lang.go" },
}

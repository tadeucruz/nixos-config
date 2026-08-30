-- Show dotfiles (`.github`, etc.) in the Snacks file explorer and picker so
-- repo-scoped files like CI workflows are reachable. LazyVim 16 uses the
-- Snacks picker/explorer by default — do NOT add a neo-tree spec here, that
-- pulls in a second, competing sidebar.
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          -- Find files (<leader>ff): fd hides dotfiles by default, so hidden
          -- must be enabled explicitly for .github/workflows etc. to show up.
          files = {
            hidden = true,
          },
          -- File explorer (<leader>e): same dotfile treatment.
          explorer = {
            hidden = true,
          },
        },
      },
    },
  },
}
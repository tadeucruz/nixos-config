-- Show dotfiles (`.github`, etc.) in the file explorer and file picker so
-- repo-scoped files like CI workflows are reachable.
return {
  -- File tree: always list hidden files, but keep .git and junk out.
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          never_show = { ".git", ".DS_Store" },
        },
      },
    },
  },
  -- Find files (<leader>ff): fd hides dotfiles by default, so hidden must be
  -- enabled explicitly for .github/workflows etc. to show up.
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        files = {
          hidden = true,
        },
      },
    },
  },
}
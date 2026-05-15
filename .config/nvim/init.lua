vim.opt.termguicolors = true
vim.opt.background = "dark"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    dir = vim.fn.stdpath("data") .. "/site/pack/themes/start/komau.vim",
    name = "komau",
    lazy = false,
    priority = 1000,
    config = function()
      require("komau").setup({
        style = "dark",
        transparent = false,
        dim_inactive = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { bold = true },
        },
        integrations = {
          treesitter = true,
          lsp = true,
          telescope = true,
          cmp = true,
          gitsigns = true,
          which_key = true,
          indent_blankline = true,
          mini = true,
          statusline = {
            lightline = true,
            lualine = true,
          },
        },
      })

      vim.cmd.colorscheme("komau")
    end,
  },
})

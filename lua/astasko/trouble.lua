local function init()
  require("trouble").setup()
  vim.api.nvim_set_keymap("n", "<leader>hh", "<cmd>Trouble<cr>",
    {
      silent = true,
      noremap = true
    }
  )
end

return {
  init = init,
}

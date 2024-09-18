local function FileName()
  return {
    {
      'filename',
      file_status = true,
      newfile_status = true,
      path = 1,
      shorting_target = 40,
      symbols = {
        modified = ' ',
        readonly = ' ',
        unnamed = ' ',
        newfile = ' ',
      },
    },
  }
end

local function init()
  require('lualine').setup {
    options = {
      extensions = { 'fzf', 'quickfix', 'trouble' },
      theme = 'catppuccin',
      globalstatus = true,
    },
    sections = {
      lualine_c = FileName(),
    },
    inactive_sections = {
      lualine_c = FileName(),
    },
  }
end

return {
  init = init,
}

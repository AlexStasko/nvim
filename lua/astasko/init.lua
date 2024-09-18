local function init()
    require 'astasko.vim'.init()
    require 'astasko.remap'.init()
    require 'astasko.theme'.init()
    require 'astasko.telescope'.init()
    require 'astasko.trouble'.init()
    require 'astasko.lualine'.init()
    require 'astasko.extra'.init()
    require 'astasko.lsp'.init()
end

return {
    init = init,
}

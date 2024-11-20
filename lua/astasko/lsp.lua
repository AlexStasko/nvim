local lspconfig = require 'lspconfig'
local telescope = require('telescope.builtin')
local rust_tools = require 'rust-tools'
local treesitter = require 'nvim-treesitter.configs'
local treesitter_context = require 'treesitter-context'

-- local function getSnykToken()
--     local handle = assert(io.popen("doppler secrets get SNYK_TOKEN --plain --config-dir ~/.doppler"))
--
--     local result = handle:read("*a")
--     handle:close()
--
--     result = result:match("^%s*(.-)%s*$")
--
--     if result == "" then
--         error("Snyk token is empty")
--     end
--
--     return result
-- end

local function init()
    local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
    lsp_capabilities = vim.tbl_deep_extend('force', lsp_capabilities, require('cmp_nvim_lsp').default_capabilities())

    -- Rust specific setup
    rust_tools.setup {
        server = {
            settings = {
                ['rust-analyzer'] = {
                    cargo = {
                        buildScripts = {
                            enable = true,
                        },
                    },
                    diagnostics = {
                        enable = false,
                    },
                    files = {
                        excludeDirs = { ".direnv", ".git" },
                        watcherExclude = { ".direnv", ".git" },
                    },
                },
            },
            capabilities = lsp_capabilities,
        },
    }
    local language_servers = {
        bashls = {},
        cssls = {},
        diagnosticls = {
            filetypes = { "python" },
            init_options = {
                filetypes = {
                    python = "black"
                },
                formatFiletypes = {
                    python = { "black" }
                },
                formatters = {
                    black = {
                        command = "black",
                        args = { "--quiet", "-" },
                        rootPatterns = { "pyproject.toml" },
                    },
                },
            }
        },
        dockerls = {},
        gopls = {
            settings = {
                gopls = {
                    gofumpt = true,
                },
            },
        },
        html = {},
        jsonls = {},
        jsonnet_ls = {},
        lua_ls = {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { 'vim' }
                    },
                    runtime = {
                        version = 'LuaJIT',
                    },
                    telemetry = {
                        enable = false,
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                    },
                },
            }
        },
        nil_ls = {
            settings = {
                ['nil'] = {
                    formatting = { command = { "alejandra" } },
                },
            }
        },
        pyright = {
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        diagnosticMode = "workspace",
                        useLibraryCodeForTypes = true
                    },
                },
            },
        },
        -- snyk_ls = {
        --     init_options = {
        --         activateSnykOpenSource = "true",
        --         activateSnykCode = "true",
        --         activateSnykIac = "true",
        --         automaticAuthentication = "true",
        --         token = getSnykToken(),
        --         enableTrustedFoldersFeature = "false",
        --     }
        -- },
        terraformls = {},
        tsserver = {},
        yamlls = {
            settings = {
                yaml = {
                    keyOrdering = false,
                    customTags = { "!reference sequence" },
                },
            },
        },
    }

    for server, server_config in pairs(language_servers) do
        local config = { capabilities = lsp_capabilities }

        if server_config then
            for k, v in pairs(server_config) do
                config[k] = v
            end
        end

        lspconfig[server].setup(config)
    end

    local cmp = require("cmp")
    local lspkind = require('lspkind')
    cmp.setup({
        view = {
            entries = { name = 'custom', selections_order = 'near_cursor' }
        },
        formatting = {
            format = lspkind.cmp_format(),
        },
        snippet = {
            expand = function(args)
                require('luasnip').lsp_expand(args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<Tab>"] = vim.schedule_wrap(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                else
                    fallback()
                end
            end),
            ["<S-Tab>"] = vim.schedule_wrap(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                else
                    fallback()
                end
            end),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'path' },
        }, {
            { name = 'buffer' },
        }),
    })
    -- Set configuration for specific filetype.
    -- cmp.setup.filetype('gitcommit', {
    --   sources = cmp.config.sources({
    --     { name = 'git' },     -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
    --     { name = 'buffer' },
    --   })
    -- })

    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = 'buffer' }
        }
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = 'path' },
            { name = 'cmdline' },
        })
    })

    -- Treesitter syntax highlight
    treesitter.setup {
        auto_install = false,
        ensure_installed = {},
        highlight = { enable = true },
        ignore_install = {},
        indent = { enable = true },
        modules = {},
        rainbow = { enable = true },
        sync_install = false,
    }

    treesitter_context.setup()
    -- End Treesitter

    local augroup = vim.api.nvim_create_augroup
    local AStaskoGroup = augroup('AStasko', {})

    local autocmd = vim.api.nvim_create_autocmd


    autocmd('LspAttach', {
        group = AStaskoGroup,
        callback = function(e)
            local opts = { buffer = e.buf }
            vim.keymap.set('n', 'gd', telescope.lsp_definitions, opts)
            vim.keymap.set('n', 'gr', telescope.lsp_references, opts)
            vim.keymap.set('n', 'gi', telescope.lsp_implementations, opts)
            vim.keymap.set('n', '<space>D', telescope.lsp_type_definitions, opts)
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
            vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
            vim.keymap.set('n', '<space>wl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, opts)
            vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
            vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', '<space>f', function() require('conform').format() end, opts)
            vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, opts)
        end
    })
end

return {
    init = init,
}

-- compiling + debugging + lsp + autocomplete

vim.pack.add {
    "https://codeberg.org/mfussenegger/nvim-dap",
    "https://github.com/civitasv/cmake-tools.nvim",
    "https://github.com/stevearc/overseer.nvim",
    "https://github.com/akinsho/toggleterm.nvim",
    "https://github.com/Zeioth/compiler.nvim",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/mason-org/mason-lspconfig.nvim"
}


-- cmake-tools
require("cmake-tools").setup {
    cmake_build_directory = "build",
    cmake_kits_path = "~/.config/nvim/lua/custom/cmake/kits.json",
    cmake_build_options =  { "--parallel" }
}


-- overseer
require("overseer").setup {}


-- toggleterm
require("toggleterm").setup {}


-- compiler
require("compiler").setup {}


-- keybinds
vim.api.nvim_set_keymap('n', '<F6>', "<cmd>CompilerOpen<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-F6>', "<cmd>CompilerStop<cr>" .. "<cmd>CompilerRedo<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-F7>', "<cmd>CompilerToggleResults<cr>", { noremap = true, silent = true })


-- nvim-dap
local dap = require('dap')
dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
}

dap.configurations.cpp = {
    {
        name = 'Launch',
        type = 'gdb',
        request = 'launch',
        program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
    },
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint() end)
vim.keymap.set('n', '<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
vim.keymap.set({'n', 'v'}, '<Leader>dh',
    function()
        require('dap.ui.widgets').hover()
    end
)
vim.keymap.set({'n', 'v'}, '<Leader>dp',
    function()
        require('dap.ui.widgets').preview()
    end
)
vim.keymap.set('n', '<Leader>df',
    function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.frames)
    end
)
vim.keymap.set('n', '<Leader>ds',
    function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.scopes)
    end
)

-- lsp
vim.lsp.enable("clangd")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("zls")
vim.lsp.enable("gopls")
vim.lsp.enable("copilot")
vim.lsp.enable("sourcekit-lsp")

vim.lsp.config.clangd = {
    keys = {
        { "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
    },
    root_markers = {
        "compile_commands.json",
        "compile_flags.txt",
        "configure.ac", -- AutoTools
        "Makefile",
        "configure.ac",
        "configure.in",
        "config.h.in",
        "meson.build",
        "meson_options.txt",
        "build.ninja",
        ".git",
    },
    capabilities = {
        offsetEncoding = { "utf-16" },
    },
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=never",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
    },
    init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
    }
}

vim.lsp.config.sourcekit_lsp = {
    filetypes = { 'swift', 'objc', 'objcpp'}
}

vim.lsp.codelens.enable(true)
vim.lsp.inlay_hint.enable(true)

vim.cmd[[set completeopt+=menuone,popup,noinsert,fuzzy]]

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufnr = args.buf
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

        if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
            vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

            vim.keymap.set(
                'i',
                '<C-F>',
                vim.lsp.inline_completion.get,
                { desc = 'LSP: accept inline completion', buffer = bufnr }
            )
            vim.keymap.set(
                'i',
                '<C-G>',
                vim.lsp.inline_completion.select,
                { desc = 'LSP: switch inline completion', buffer = bufnr }
            )

            vim.lsp.completion.enable(true, args.data.client_id, args.buf, {
                autotrigger = true,
                convert = function(item)
                return { abbr = item.label:gsub('%b()', '') }
                end,
            })
        end
    end,
})

local opts = { noremap=true, silent=true }

vim.keymap.set('n', '<leader>qf', function() vim.lsp.buf.code_action() end, opts)
vim.keymap.set('n', '<leader>F', function() vim.lsp.buf.format { async = true } end, opts)

-- mason
require("mason").setup {}
require("mason-lspconfig").setup {}

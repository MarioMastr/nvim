-- compiling + debugging + lsp

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
dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-dap', -- adjust as needed, must be absolute path
    name = 'lldb'
}

dap.configurations.cpp = {
    {
        name = 'Launch',
        type = 'lldb',
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

-- lsp
vim.lsp.enable("clangd")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("zls")
vim.lsp.enable("gopls")

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

vim.lsp.codelens.enable(true)
vim.lsp.inlay_hint.enable(true)

vim.cmd[[set completeopt+=menuone,noselect,popup]]

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        vim.lsp.completion.enable(true, args.data.client_id, args.buf, {
            autotrigger = true,
            convert = function(item)
            return { abbr = item.label:gsub('%b()', '') }
            end,
        })
    end,
})

-- mason
require("mason").setup {}
require("mason-lspconfig").setup {
    ensure_installed = {"rust_analyzer"}
}

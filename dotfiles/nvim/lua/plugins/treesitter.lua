return {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter').setup({
            ensure_installed = {
                'lua', 'vim', 'vimdoc',
                'javascript', 'typescript', 'tsx',
                'html', 'css', 'json',
                'php',
                'bash',
            },
        })

        -- Highlighting is now provided by Neovim's built-in treesitter
        vim.api.nvim_create_autocmd('FileType', {
            callback = function()
                pcall(vim.treesitter.start)
            end,
        })
    end
}

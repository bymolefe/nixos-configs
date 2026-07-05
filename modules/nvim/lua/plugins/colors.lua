local function reload_colors()
    -- Unload the matugen module to force reload
    package.loaded['colors.matugen'] = nil

    -- Load matugen colors
    local matugen_ok, matugen = pcall(require, "colors.matugen")
    if matugen_ok then
        matugen.setup()
    end

    return matugen_ok and matugen.colors or {}
end

local function setup_lualine(colors)
    local custom_theme = {
        normal = {
            a = { fg = colors.on_primary or '#000000', bg = colors.primary or '#ffffff', gui = 'bold' },
            b = { fg = colors.on_surface or '#ffffff', bg = colors.surface_container or '#000000' },
            c = { fg = colors.on_surface_variant or '#ffffff', bg = colors.surface_container_low or '#000000' },
        },
        insert = {
            a = { fg = colors.on_secondary or '#000000', bg = colors.secondary or '#ffffff', gui = 'bold' },
        },
        visual = {
            a = { fg = colors.on_tertiary or '#000000', bg = colors.tertiary or '#ffffff', gui = 'bold' },
        },
        replace = {
            a = { fg = colors.on_error or '#000000', bg = colors.error or '#ffffff', gui = 'bold' },
        },
        command = {
            a = { fg = colors.on_primary_container or '#000000', bg = colors.primary_container or '#ffffff', gui = 'bold' },
        },
        inactive = {
            a = { fg = colors.outline or '#808080', bg = colors.surface_dim or '#000000' },
            b = { fg = colors.outline or '#808080', bg = colors.surface_dim or '#000000' },
            c = { fg = colors.outline or '#808080', bg = colors.surface_dim or '#000000' },
        },
    }

    require('lualine').setup({
        options = {
            theme = custom_theme,
        },
    })
end

return {
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            -- Initial load
            local colors = reload_colors()
            setup_lualine(colors)

            -- Auto-reload when matugen.lua changes
            vim.api.nvim_create_autocmd("Signal", {
                pattern = "SIGUSR1",
                callback = function()
                    local new_colors = reload_colors()
                    setup_lualine(new_colors)
                    vim.notify("Theme reloaded!", vim.log.levels.INFO)
                end,
            })

            -- Also watch the file for changes (fallback method)
            local matugen_path = vim.fn.stdpath('config') .. '/lua/colors/matugen.lua'
            vim.api.nvim_create_autocmd({"BufWritePost"}, {
                pattern = matugen_path,
                callback = function()
                    local new_colors = reload_colors()
                    setup_lualine(new_colors)
                    vim.notify("Theme reloaded!", vim.log.levels.INFO)
                end,
            })
        end,
    },
}

return {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("bufferline").setup({
            options = {
                mode = "buffers",
                numbers = "ordinal",
                separator_style = "thin",
                show_buffer_close_icons = false,
                show_close_icon = false,
                always_show_bufferline = true,
            },
        })

        vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>")
        vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>")
        vim.keymap.set("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Close buffer" })

        for i = 1, 9 do
            vim.keymap.set("n", "<C-" .. i .. ">", "<cmd>BufferLineGoToBuffer " .. i .. "<cr>")
        end
        vim.keymap.set("n", "<C-0>", "<cmd>BufferLineGoToBuffer 10<cr>")
    end,
}

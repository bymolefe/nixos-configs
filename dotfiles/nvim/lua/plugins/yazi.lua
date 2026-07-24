return {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
        { "<leader>e", "<cmd>Yazi<cr>",     desc = "File browser" },
        { "<leader>E", "<cmd>Yazi cwd<cr>", desc = "File browser (cwd)" },
    },
    opts = {
        open_for_directories = true,
    },
}

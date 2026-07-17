vim.g.mapleader = " "
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)

local function copy_ref(opts)
    local path = vim.fn.expand("%:.")
    local ref = path

    if opts.visual then
        local start_line = vim.fn.line("v")
        local end_line = vim.fn.line(".")
        if start_line > end_line then
            start_line, end_line = end_line, start_line
        end
        ref = path .. ":" .. start_line .. ":" .. end_line
    end

    local note = vim.fn.input("Prompt (optional): ")
    if note ~= "" then
        ref = ref .. " " .. note
    end

    vim.fn.setreg("+", ref)
    vim.notify("Copied: " .. ref)
end

vim.keymap.set("n", "<leader>cp", function() copy_ref({}) end, { desc = "Copy file path" })
vim.keymap.set("v", "<leader>cp", function() copy_ref({ visual = true }) end, { desc = "Copy file path with line range" })

local harpoon = require("harpoon")

harpoon.setup({
    settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
        key = function()
            return vim.loop.cwd()
        end,
    },
})

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<leader>j", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>k", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>l", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<leader>;", function() harpoon:list():select(4) end)
vim.keymap.set("n", "<leader>'", function() harpoon:list():select(5) end)

-- Toggle previous & next buffers stored within Harpoon list
-- vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end)
-- vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end)

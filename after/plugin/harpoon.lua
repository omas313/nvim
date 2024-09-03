local harpoon = require("harpoon")


harpoon:setup()

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<leader>j", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>k", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>l", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<leader>;", function() harpoon:list():select(4) end)
vim.keymap.set("n", "<leader>'", function() harpoon:list():select(5) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end)
vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end)



--
-- -- basic telescope configuration
-- local conf = require("telescope.config").values
-- local function toggle_telescope(harpoon_files)
--     local file_paths = {}
--     for _, item in ipairs(harpoon_files.items) do
--         table.insert(file_paths, item.value)
--     end
--
--     require("telescope.pickers").new({}, {
--         prompt_title = "Harpoon",
--         finder = require("telescope.finders").new_table({
--             results = file_paths,
--         }),
--         previewer = conf.file_previewer({}),
--         sorter = conf.generic_sorter({}),
--     }):find()
-- end
--
-- vim.keymap.set("n", "<C-e>", function() toggle_telescope(harpoon:list()) end,
--     { desc = "Open harpoon window" })


--
-- harpoon.setup({
--  global_settings = {
--         -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
--         save_on_toggle = false,
--
--         -- saves the harpoon file upon every change. disabling is unrecommended.
--         save_on_change = true,
--
--         -- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
--         enter_on_sendcmd = false,
--
--         -- closes any tmux windows harpoon that harpoon creates when you close Neovim.
--         tmux_autoclose_windows = false,
--
--         -- filetypes that you want to prevent from adding to the harpoon list menu.
--         excluded_filetypes = { "harpoon" },
--
--         -- set marks specific to each git branch inside git repository
--         -- Each branch will have it's own set of marked files
--         mark_branch = true,
--
--         -- enable tabline with harpoon marks
--         tabline = false,
--         tabline_prefix = "   ",
--         tabline_suffix = "   ",
--     }
-- })
--
--
-- -- Harpoon telescope extension
-- require('telescope').load_extension('harpoon')
--
-- vim.keymap.set("n", "<leader>a", harpoon.mark.add_file)
-- vim.keymap.set("n", "<C-e>", harpoon.ui.toggle_quick_menu)
--
-- vim.keymap.set("n", "<leader>j", function()
--     harpoon.ui.nav_file(1)
-- end)
-- vim.keymap.set("n", "<leader>k", function()
--     harpoon.ui.nav_file(2)
-- end)
-- vim.keymap.set("n", "<leader>l", function() harpoon.ui.nav_file(3) end)
-- vim.keymap.set("n", "<leader>;", function() harpoon.ui.nav_file(4) end)
-- vim.keymap.set("n", "<leader>'", function() harpoon.ui.nav_file(5) end)
--

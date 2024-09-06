--[[

- https://learnxinyminutes.com/docs/lua/

And then you can explore or search through `:help lua-guide`
- https://neovim.io/doc/user/lua-guide.html

I have left several `:help X` comments throughout the init.lua

--]]

local function fileExists(filename)
  local file = io.open(filename, "r")
  if file then
    file:close()
    return true
  else
    return false
  end
end

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.scrolloff = 8
vim.opt.isfname:append("@-@")

-- vim.opt.colorcolumn = "100"
--
---- Default options

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- check if project.godot file exists and run a server called godothost to listen
-- to events coming from godot
-- on godot's side, we have the command set as:
--   --server ./godothost --remote-send "<C-\><C-N>:n {file}<CR>{line}G(col)|"
local godotProjectFile = vim.fn.getcwd() .. '/project.godot'
if fileExists(godotProjectFile) then
  vim.fn.serverstart './godothost'
end

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  { "sindrets/diffview.nvim" },

  -- connecint eslint without null-ls
  -- {
  --   'mfussenegger/nvim-lint',
  --   event = 'VeryLazy',
  --   config = function()
  --     require('lint').linters_by_ft = {
  --       javascript = { 'eslint' },
  --       typescript = { 'eslint' },
  --       typescriptreact = { 'eslint' },
  --       javascriptreact = { 'eslint' },
  --     }
  --
  --     vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  --       pattern = { '*.js', '*.ts', '*.jsx', '*.tsx' },
  --       callback = function()
  --         require('lint').try_lint()
  --       end,
  --     })
  --   end,
  -- },
  -- {
  --   'mhartington/formatter.nvim',
  --   event = 'VeryLazy',
  --   opts = function()
  --     vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  --       command = "FormatWriteLock",
  --     })
  --
  --     return {
  --       filetype = {
  --         javascript = {
  --           function()
  --             return {
  --               exe = 'eslint',
  --               args = { '--fix', '--stdin' },
  --               stdin = true,
  --             }
  --           end,
  --         },
  --         typescript = {
  --           function()
  --             return {
  --               exe = 'eslint',
  --               args = { '--fix', '--stdin' },
  --               stdin = true,
  --             }
  --           end,
  --         },
  --         typescriptreact = {
  --           function()
  --             return {
  --               exe = 'eslint',
  --               args = { '--fix', '--stdin' },
  --               stdin = true,
  --             }
  --           end,
  --         },
  --         javascriptreact = {
  --           function()
  --             return {
  --               exe = 'eslint',
  --               args = { '--fix', '--stdin' },
  --               stdin = true,
  --             }
  --           end,
  --         },
  --       },
  --     }
  --   end,
  -- },

  { 'echasnovski/mini.nvim', version = '*' },

  {
    'jose-elias-alvarez/null-ls.nvim',
    event = 'VeryLazy',
    opts = function()
      return require 'custom.configs.null-ls'
    end,
  },

  { "nvim-neotest/nvim-nio" },

  {
    'mfussenegger/nvim-dap',
    dependencies = {
      "rcarriga/nvim-dap-ui",
      'nvim-neotest/nvim-nio',
      'theHamsta/nvim-dap-virtual-text',
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
    },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require 'dapui'

      require('mason-nvim-dap').setup {
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_installation = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        -- You'll need to check that you have the required things installed
        -- online, please don't ask me how to install them :)
        ensure_installed = {
          -- Update this to ensure that you have the debuggers for the langs you want
          'delve',
          'gdscript'
        },
      }

      -- Dap UI setup
      -- For more information, see |:help nvim-dap-ui|
      dapui.setup {
        -- Set icons to characters that are more likely to work in every terminal.
        --    Feel free to remove or use ones that you like more! :)
        --    Don't feel like these are good choices.
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      }

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.attach['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      vim.keymap.set("n", "<leader>dv", function() require("dapui").eval(nil, { enter = true }) end)

      -- Godot DAP setup
      dap.adapters.godot = {
        type = "server",
        host = '127.0.0.1',
        port = 6007,
      }
      dap.configurations.gdscript = {
        {
          type = "godot",
          request = "launch",
          name = "Launch scene",
          project = "${workspaceFolder}",
          launch_scene = true,
        }
      }
    end,
    keys = function(_, keys)
      local dap = require 'dap'
      local dapui = require 'dapui'
      return {
        -- Basic debugging keymaps, feel free to change to your liking!
        { '<F5>',      dap.continue,          desc = 'Debug: Start/Continue' },
        { '<F1>',      dap.step_into,         desc = 'Debug: Step Into' },
        { '<F2>',      dap.step_over,         desc = 'Debug: Step Over' },
        { '<F3>',      dap.step_out,          desc = 'Debug: Step Out' },
        { '<leader>b', dap.toggle_breakpoint, desc = 'Debug: Toggle Breakpoint' },
        {
          '<leader>B',
          function()
            dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
          end,
          desc = 'Debug: Set Breakpoint',
        },
        -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
        { '<F7>', dapui.toggle, desc = 'Debug: See last session result.' },
        unpack(keys),
      }
    end,
  },

  {
    'mfussenegger/nvim-dap-python',
    ft = { "python" },
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    config = function(_, opts)
      local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
      require('dap-python').setup(path)
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end
  },

  {
    'leoluz/nvim-dap-go',
    ft = 'go',
    dependencies = {
      'mfussenegger/nvim-dap',
    },
    config = function()
      require('dap-go').setup()
    end,
  },

  {
    'olexsmir/gopher.nvim',
    ft = 'go',
    config = function(_, opts)
      require('gopher').setup(opts)
    end,
    build = function()
      vim.cmd [[silent! GoInstallDeps]]
    end,
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false }
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  -- Useful plugin to show you pending keybinds.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        "<leader>w?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>hb', function()
          gs.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>hD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },

  {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    opts = {
      width = 90,
      buffers = {
        setNames = false,
        wo = {
          fillchars = "eob: ",
          -- relativenumber = true,
          -- number = true,
          wrap = true,
        },
        scratchPad = {
          -- set to `false` to
          -- disable auto-saving
          enabled = false,
          -- set to `nil` to default
          -- to current working directory
          location = nil,
        },
        bo = {
          filetype = "md",
          buftype = ""
        },
        right = {
          enabled = false,
        },
      },
    }
  },

  { "mbbill/undotree" },

  { 'nvim-tree/nvim-web-devicons' },

  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup {
        columns = { "icon", "size" },
        keymaps = {
          ["<C-h>"] = false,
          ["<C-p>"] = false,
          ["<C-;>"] = "actions.preview",
        },
        view_options = {
          show_hidden = true,
        },
        win_options = {
          winbar = "%{v:lua.require('oil').get_current_dir()}",
        },
      }

      -- Open parent directory in current window
      vim.keymap.set("n", "<leader>oi", "<CMD>Oil<CR>", { desc = "Open parent directory" })

      -- Open parent directory in floating window
      vim.keymap.set("n", "<space>-", require("oil").toggle_float)
    end,
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        style = "night",    -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
        transparent = true, -- Enable this to disable setting the background color
        styles = {
          -- Style to be applied to different syntax groups
          -- Value is any valid attr-list value for `:help nvim_set_hl`
          comments = { italic = false },
          keywords = { italic = false },
        },
        dim_inactive = false, -- dims inactive windows
        lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold

        --- You can override specific color groups to use other groups or a hex color
        --- function will be called with a ColorScheme table
        ---@param colors ColorScheme
        on_colors = function(colors) end,

        --- You can override specific highlights to use other groups or a hex color
        --- function will be called with a Highlights and ColorScheme table
        ---@param highlights Highlights
        ---@param colors ColorScheme
        on_highlights = function(highlights, colors) end,
      })

      vim.cmd.colorscheme 'tokyonight-night'
      vim.cmd 'highlight Keyword gui=NONE'
      vim.cmd 'highlight Comment gui=NONE'

      -- theme already has transparent background, we don't need these
      -- vim.api.nvim_set_hl(0, "Normal", { bg = "none" });
      -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" });
      -- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" });
      -- vim.api.nvim_set_hl(0, "NormalNCFloat", { bg = "none" });
      -- vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" });
    end,
  },

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" }
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'tokyonight',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim',  opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    "windwp/nvim-ts-autotag",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  {
    -- vim-fugitive git stuff
    'tpope/vim-fugitive',
  },

  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },


  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  { import = 'custom.plugins' },
}, {})


local configs = require 'lspconfig.configs'
configs.ast_grep = {
  default_config = {
    cmd = { 'ast-grep', 'lsp' },
    single_file_support = false,
  },
}

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false
vim.o.incsearch = true
--
-- Make line numbers default
vim.wo.number = true

-- Relative line numbers
vim.o.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.o.guifont = "monospace"

-- my custom keymaps
-- vim.keymap.set("n", "<leader>er", vim.cmd.Ex)

vim.keymap.set("n", "<leader>K", "<cmd>:q<CR>")

-- toggle hightlight search
vim.keymap.set("n", "<leader>hl", "<cmd>:set hlsearch!<CR>")

-- change to alternate (previous) file
vim.keymap.set("n", "<leader>tp", "<cmd>:e #<CR>", { desc = "Go [t]o [p]revious file" })

-- open terminal
vim.keymap.set("n", "<leader>tt", "<cmd>:terminal<CR>")

vim.keymap.set("n", "<leader>np", "<cmd>:NoNeckPain<CR>")

-- moving a block of code up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- keeps search terms in the middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- moving up and down keeps cursor centered
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- searching with * and # keeps cursor centered
vim.keymap.set("n", "*", "*zz")
vim.keymap.set("n", "#", "#zz")

-- doing "J" doesn't move cursor
vim.keymap.set("n", "J", "mzJ`z")

-- greatest remap ever: keeps pasted thing in yank register
vim.keymap.set("x", "<leader>p", "\"_dP")

-- select all
vim.keymap.set("n", "<leader>sa", "ggVG")

-- next greatest remap ever : asbjornHaland,
-- yanks into system clipboard, but currently neovim is setup to use it anyways
-- vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
-- vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Q is a bad place apparently
vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set({ "n", "v" }, "<leader>dd", [["_d]])

-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- quick replace for the current selected word
vim.keymap.set("n", "<leader>sz", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Quick replace for current word" })

-- close current buffer
vim.keymap.set("n", "<leader>cb", "<cmd>:bd<CR>", { desc = "Close current buffer" })

-- close all buffers
vim.keymap.set("n", "<leader>cB", "<cmd>%bd|e#|bd#<CR>", { desc = "Close all buffers" })

-- restart lsp
vim.keymap.set("n", "<leader>rl", "<cmd>:LspRestart<CR>")

-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- ctrl+q <C-q> send to quickfix
vim.keymap.set("n", "<leader>fo", "<cmd>:copen<CR>", { desc = "Open quickfix" })
vim.keymap.set("n", "<leader>fn", "<cmd>:cnext<CR>", { desc = "Next quickfix" })
vim.keymap.set("n", "<leader>fp", "<cmd>:cprev<CR>", { desc = "Previous quickfix" })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>dp', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', '<leader>dn', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- trouble
vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle() end, { desc = "Toggle Trouble" })
vim.keymap.set("n", "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end,
  { desc = "Toggle Workspace Trouble" })
vim.keymap.set("n", "<leader>xd", function() require("trouble").toggle("document_diagnostics") end,
  { desc = "Toggle Document Trouble" })
vim.keymap.set("n", "<leader>xq", function() require("trouble").toggle("quickfix") end,
  { desc = "Toggle Quickfix Trouble" })
vim.keymap.set("n", "<leader>xl", function() require("trouble").toggle("loclist") end,
  { desc = "Toggle Loclist Trouble" })
vim.keymap.set("n", "gR", function() require("trouble").toggle("lsp_references") end,
  { desc = "Toggle LSP References Trouble" })

-- makes current file executable
vim.keymap.set("n", "<leader>xo", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })

-- add current file to git
vim.keymap.set("n", "<leader>ga", "<cmd>!git add %<CR>", { silent = true, desc = "Track current file in git" })

-- undo history
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

-- gdscript format
vim.keymap.set("n", "<leader>fg", "<cmd>silent !gdformat %<CR>", { silent = true, desc = "Format GDScript file" })
vim.keymap.set("n", "<leader>rgf", "<cmd>silent !gdformat %<CR>", { silent = true, desc = "Format GDScript file" })
vim.keymap.set("n", "<leader>rgt",
  "<cmd>!~/Godot/Godot_v4.2-stable_linux.x86_64 -d -s --path \"$PWD\" addons/gut/gut_cmdln.gd<CR>",
  { desc = "Run Godot tests" })

-- run dotnet project
vim.keymap.set("n", "<leader>rdr", "<cmd>!dotnet run<CR>")
vim.keymap.set("n", "<leader>rdb", "<cmd>!dotnet build<CR>")

-- run current JS file with node
vim.keymap.set("n", "<leader>rnj", "<cmd>!node %<CR>", { desc = "Run JS file" })
vim.keymap.set("n", "<leader>rns", "<cmd>!npm start<CR>", { desc = "npm start" })

vim.keymap.set("n", "<leader>w,", "<cmd>:vert res -10<CR>", { desc = "decrease width by 10" })
vim.keymap.set("n", "<leader>w.", "<cmd>:vert res +10<CR>", { desc = "increase width by 10" })

vim.keymap.set('n', '<leader>dt', function() require('dap-python').test_method() end, { desc = 'Debug Breakpoint' })

-- Godot DAP setup
local dap = require("dap")
dap.adapters.godot = {
  type = "server",
  host = '127.0.0.1',
  port = 6007,
}
dap.configurations.gdscript = {
  {
    type = "godot",
    request = "launch",
    name = "Launch scene",
    project = "${workspaceFolder}",
    launch_scene = true,
  }
}

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
    layout_strategy = 'vertical',
    layout_config = {
      height = 0.98,
      width = 0.98,
      preview_height = 0.6,
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end
vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })

vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })

vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
-- vim.keymap.set('n', '<C-p>', require('telescope.builtin').git_files, { desc = 'Search Git Files' })

-- search grep in files (also needs ripgrep installed - sudo apt install ripgrep)
vim.keymap.set('n', '<leader>se', function()
  require('telescope.builtin').grep_string({ search = vim.fn.input("Grep > ") })
end, { desc = "search grep in files" })

vim.keymap.set('n', '<leader>sw', function()
  local word = vim.fn.expand('<cword>')
  require('telescope.builtin').grep_string({ search = word, word_match = "-w" })
end, { desc = "search for this word" })

vim.keymap.set('n', '<leader>sW', function()
  local word = vim.fn.expand('<cWORD>')
  require('telescope.builtin').grep_string({ search = word })
end, { desc = "search for this WORD" })

-- replace all
-- to replace in all git files: git ls-files | xargs sed -i 's/old/new/g'

vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>ds', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

-- toggle diagnostic messages
local isLspDiagnosticsVisible = true
vim.keymap.set("n", "<leader>hx", function()
  isLspDiagnosticsVisible = not isLspDiagnosticsVisible
  vim.diagnostic.config({
    virtual_text = isLspDiagnosticsVisible,
    underline = isLspDiagnosticsVisible
  })
end)

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = {
      'c', 'cpp', 'c_sharp',
      'go', 'lua', 'python', 'rust',
      'tsx', 'javascript', 'typescript',
      'vimdoc', 'vim',
      'bash',
      'gdscript', 'godot_resource', 'gdshader',
      'gitignore',
      'html', 'css',
      'markdown', 'markdown_inline',
    },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = true,
    -- Install languages synchronously (only applied to `ensure_installed`)
    sync_install = false,
    -- List of parsers to ignore installing
    ignore_install = {},
    -- You can specify additional Treesitter modules here: -- For example: -- playground = {--enable = true,-- },
    modules = {},
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ['[n'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>tx'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>tz'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  nmap('<leader>rr', vim.lsp.buf.rename, '[R]ename')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('gt', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('gsd', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('gsw', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- nmap('gr', require('telescope.builtin').lsp_references({ fname_width = 60 }), '[G]oto [R]eferences')
  vim.keymap.set('n', 'gr', function()
    require('telescope.builtin').lsp_references({ fname_width = 60 })
  end, { buffer = bufnr, desc = '[G]oto [R]eferences' })

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-K>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  -- nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  -- nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wf', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format({ bufnr = bufnr })
  end, { desc = 'Format current buffer with LSP' })

  nmap('<leader>ff', '<cmd>:Format<CR>', 'Format current buffer with LSP')

  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end)
end

-- document existing key chains
local wk = require("which-key")
wk.add({
  { "<leader>s", group = "search" }, -- group
  { "<leader>r", group = "run" },    -- group

  --   { "<leader>f", group = "file" }, -- group
  --   { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File", mode = "n" },
  --   { "<leader>fb", function() print("hello") end, desc = "Foobar" },
  --   { "<leader>fn", desc = "New File" },
  --   { "<leader>f1", hidden = true }, -- hide this keymap
  --   { "<leader>w", proxy = "<c-w>", group = "windows" }, -- proxy to window mappings
  --   { "<leader>b", group = "buffers", expand = function()
  --       return require("which-key.extras").expand.buf()
  --     end
  --   },
  --   {
  --     -- Nested mappings are allowed and can be added in any order
  --     -- Most attributes can be inherited or overridden on any level
  --     -- There's no limit to the depth of nesting
  --     mode = { "n", "v" }, -- NORMAL and VISUAL mode
  --     { "<leader>q", "<cmd>q<cr>", desc = "Quit" }, -- no need to specify mode since it's inherited
  --     { "<leader>w", "<cmd>w<cr>", desc = "Write" },
  --   }
})

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {
  --   filetypes = { 'c', 'cpp' },
  --   settings = {
  --     cmd = { 'clangd', '--fallback-style=webkit' },
  --   },
  -- },
  -- gopls = {},
  -- pyright = {
  --   filetypes = { 'python' },
  -- },
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  omnisharp = {
    filetypes = { 'cs' },
    settings = {
      intelephense = {
        files = {
          exclude = { '**/node_modules/**', '**/bin/**', '**/obj/**' },
        },
      },
    },
  },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
  ["clangd"] = function()
    require("lspconfig").clangd.setup({
      cmd = {
        "clangd",
        "--fallback-style=webkit",
      }
    })
  end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<C-y>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
}

-- Set colorscheme (order is important here) for cursor
vim.api.nvim_set_hl(0, "nCursor", { bg = "#a5c5de", fg = "#123123", blend = 50 });
vim.api.nvim_set_hl(0, "iCursor", { bg = "#ffe49a", blend = 50 });
vim.o.guicursor = "n-v-c:block-nCursor,i-ci-ve:block-iCursor,r-cr:hor20,o:hor50"

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

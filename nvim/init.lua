-- ==============================================================================
-- 1. LAZY.NVIM
-- ==============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local home_dir = vim.fn.expand("~")
for _, p in ipairs({ home_dir .. "/.local/bin", home_dir .. "/.cargo/bin" }) do
  if not string.find(vim.env.PATH, p, 1, true) then
    vim.env.PATH = p .. ":" .. vim.env.PATH
  end
end

-- ==============================================================================
-- 2. GENERAL & AESTHETICS
-- ==============================================================================
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 300
opt.autoread = true
opt.cursorline = true
opt.splitbelow = true
opt.splitright = true
opt.clipboard = "unnamedplus"

-- ==============================================================================
-- WINDOW / SPLIT NAVIGATION (Move cursor between split panes)
-- ==============================================================================
-- Fast window navigation with Ctrl + h/j/k/l
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Focus left split window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus right split window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Focus lower split window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Focus upper split window" })

-- Window management with <leader>w
vim.keymap.set("n", "<leader>ww", "<C-w>w", { desc = "Switch to other split window" })
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Focus left window" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Focus right window" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Focus lower window" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Focus upper window" })
vim.keymap.set("n", "<leader>ws", "<cmd>split<cr>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>wd", "<cmd>close<cr>", { desc = "Close current split window" })
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Equalize split sizes" })

-- ==============================================================================
-- BUFFER & TAB NAVIGATION (Switch files within current window)
-- ==============================================================================
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer file" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer file" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close current buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer file" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer file" })
vim.keymap.set("n", "<leader>bb", "<cmd>Telescope buffers<cr>", { desc = "List open buffers" })

-- Real Vim tab navigation
vim.keymap.set("n", "<leader><tab>l", "<cmd>tabnext<cr>", { desc = "Next tab" })
vim.keymap.set("n", "<leader><tab>h", "<cmd>tabprevious<cr>", { desc = "Previous tab" })
vim.keymap.set("n", "<leader><tab>n", "<cmd>tabnew<cr>", { desc = "New tab" })
vim.keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close tab" })

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "if mode() != 'c' | checktime | endif",
})

local diagnostic_signs = {
  { name = "DiagnosticSignError", text = "" },
  { name = "DiagnosticSignWarn", text = "" },
  { name = "DiagnosticSignHint", text = "󰌵" },
  { name = "DiagnosticSignInfo", text = "" },
}
for _, sign in ipairs(diagnostic_signs) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 4,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

-- ==============================================================================
-- 3. ODIN
-- ==============================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = "odin",
  callback = function(ev)
    local b = vim.bo[ev.buf]
    b.expandtab = false   -- TABS para indentação
    b.tabstop = 4
    b.shiftwidth = 4
    b.commentstring = "// %s"
    b.makeprg = "odin check . -error-pos-style:unix"
    b.errorformat = "%f:%l:%c:\\ %m,%f(%l:%c)\\ %m"
  end,
})

-- ==============================================================================
-- 4. PLUGINS (LAZY.NVIM)
-- ==============================================================================
require("lazy").setup({
  {
    "Ferouk/bearded-nvim",
    name = "bearded",
    lazy = false,
    priority = 1000,
    config = function()
      require("bearded").setup({
        flavor = "black-&-gold",
        transparent = false,
        terminal_colors = true,
      })
      vim.cmd.colorscheme("bearded")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "Ferouk/bearded-nvim" },
    opts = function()
      local ok, bearded = pcall(require, "bearded")
      local theme = "auto"
      if ok and bearded.palette then
        theme = require("bearded.plugins.lualine").theme(bearded.palette())
      end
      return {
        options = {
          theme = theme,
          section_separators = "",
          component_separators = "",
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = {
            function()
              local msg = "No LSP"
              local buf_ft = vim.bo.filetype
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if next(clients) == nil then
                return msg
              end
              local names = {}
              for _, client in ipairs(clients) do
                table.insert(names, client.name)
              end
              return "󰌘 " .. table.concat(names, ", ")
            end,
            "encoding",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      }
    end,
  },

  { "nvim-tree/nvim-web-devicons", lazy = true },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ok_configs, configs = pcall(require, "nvim-treesitter.configs")
      if ok_configs then
        configs.setup({
          ensure_installed = { "odin", "c", "bash", "lua" },
          highlight = { enable = true },
          indent = { enable = true },
        })
      else
        local ok_ts, ts = pcall(require, "nvim-treesitter")
        if ok_ts then
          ts.setup({
            install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site"),
          })
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      vim.lsp.config("ols", {
        cmd = { "ols" },
        filetypes = { "odin" },
        root_markers = { "ols.json", ".git", "*.odin" },
        capabilities = capabilities,
        init_options = {
          enable_inlay_hints_params = true,
          enable_inlay_hints_default_params = true,
          enable_inlay_hints_implicit_return = true,
          enable_inlay_hints_optional_result = true,
          enable_semantic_tokens = true,
          enable_snippets = true,
          enable_hover = true,
          enable_document_symbols = true,
          enable_auto_import = true,
          enable_procedure_context = true,
          enable_procedure_snippet = true,
          enable_references = true,
          enable_code_action_invert_if = true,
          enable_format = false,
        },
      })
      vim.lsp.enable("ols")

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = ev.buf, silent = true, desc = desc })
          end

          if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
          end

          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gi", vim.lsp.buf.implementation, "Go to implementation")
          map("gr", "<cmd>Telescope lsp_references<cr>", "Search references")
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<leader>ck", vim.lsp.buf.signature_help, "Signature help")
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
          map("[d", vim.diagnostic.goto_prev, "Previous diagnostic")
          map("]d", vim.diagnostic.goto_next, "Next diagnostic")
          map("<leader>th", function()
            local current = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
            vim.lsp.inlay_hint.enable(not current, { bufnr = ev.buf })
            vim.notify("Inlay hints " .. (current and "disabled" or "enabled"), vim.log.levels.INFO)
          end, "Toggle inlay hints")
        end,
      })
    end,
  },

  {
    "saghen/blink.cmp",
    version = "*",
    opts = {
      keymap = {
        preset = "default",
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded" },
        },
        menu = {
          border = "rounded",
          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "kind" },
            },
          },
        },
      },
      signature = {
        enabled = true,
        window = { border = "rounded" },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        odin = { "odinfmt" },
        lua = { "stylua" },
      },
      formatters = {
        odinfmt = {
          command = "odinfmt",
          args = { "-stdin" },
          stdin = true,
        },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 1000, lsp_fallback = true }
      end,
    },
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.35 },
              { id = "breakpoints", size = 0.15 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            position = "left",
            size = 40,
          },
          {
            elements = {
              { id = "repl", size = 0.6 },
              { id = "console", size = 0.4 },
            },
            position = "bottom",
            size = 10,
          },
        },
      })

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      dap.adapters.lldb = {
        type = "executable",
        command = "/usr/bin/lldb-dap",
        name = "lldb",
      }

      dap.configurations.odin = {
        {
          name = "Debug Odin (Executável do projeto)",
          type = "lldb",
          request = "launch",
          program = function()
            local cwd = vim.fn.getcwd()
            local project_name = vim.fn.fnamemodify(cwd, ":t")
            local default_path = cwd .. "/" .. project_name
            if vim.fn.filereadable(default_path) == 1 then
              return default_path
            end
            return vim.fn.input("Caminho do executável Odin (compilado com -debug): ", default_path, "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
        {
          name = "Debug Odin (Selecionar arquivo executável)",
          type = "lldb",
          request = "launch",
          program = function()
            return vim.fn.input("Caminho do executável: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
      }
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep (Search text)" },
      { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Open buffers" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
      { "<leader>fo", function()
        require("telescope.builtin").find_files({ prompt_title = "Odin Files", find_command = { "rg", "--files", "--glob", "*.odin" } })
      end, desc = "Find Odin files" },
    },
    opts = {
      defaults = {
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
          },
        },
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      },
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle sidebar (Neo-tree)" },
      { "<leader>E", "<cmd>Neotree focus<cr>", desc = "Focus sidebar (Neo-tree)" },
      { "<leader>fe", "<cmd>Neotree reveal<cr>", desc = "Reveal current file in Neo-tree" },
      { "<leader>eb", "<cmd>Neotree toggle buffers<cr>", desc = "Toggle buffers sidebar" },
      { "<leader>eg", "<cmd>Neotree toggle git_status<cr>", desc = "Toggle Git status sidebar" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      sources = { "filesystem", "buffers", "git_status" },
      source_selector = {
        winbar = true,
        statusline = false,
        sources = {
          { source = "filesystem", display_name = " 󰉓 Files " },
          { source = "buffers", display_name = " 󰈚 Buffers " },
          { source = "git_status", display_name = " 󰊢 Git " },
        },
      },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            ".git",
          },
        },
      },
      window = {
        position = "left",
        width = 32,
        mapping_options = {
          noremap = true,
          nowait = true,
        },
        mappings = {
          ["<Tab>"] = "next_source",
          ["<S-Tab>"] = "prev_source",
          ["b"] = function() vim.cmd("Neotree focus buffers") end,
          ["B"] = function() vim.cmd("Neotree focus buffers") end,
          ["g"] = function() vim.cmd("Neotree focus git_status") end,
          ["G"] = function() vim.cmd("Neotree focus git_status") end,
          ["f"] = function() vim.cmd("Neotree focus filesystem") end,
          ["F"] = function() vim.cmd("Neotree focus filesystem") end,
        },
      },
      default_component_configs = {
        indent = {
          indent_size = 2,
          padding = 1,
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "󰜌",
          default = "󰈚",
        },
        git_status = {
          symbols = {
            added     = "✚",
            modified  = "",
            deleted   = "✖",
            renamed   = "󰁕",
            untracked = "",
            ignored   = "",
            unstaged  = "󰄱",
            staged    = "",
            conflict  = "",
          },
        },
      },
    },
  },

  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory in Oil" },
    },
    opts = {
      default_file_explorer = false,
      view_options = {
        show_hidden = true,
      },
      float = {
        padding = 2,
        max_width = 90,
        max_height = 0,
        border = "rounded",
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>e", group = "Explorer (Neo-tree)" },
        { "<leader>w", group = "Windows / Splits" },
        { "<leader>b", group = "Buffers" },
        { "<leader>o", group = "Odin" },
        { "<leader>d", group = "Debug (DAP)" },
        { "<leader>c", group = "Code / LSP" },
        { "<leader>f", group = "Find (Telescope)" },
        { "<leader>t", group = "Toggles" },
      })
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
    },
  },

  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {},
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = false,
      start_in_insert = true,
      persist_size = true,
      direction = "horizontal",
      close_on_exit = false,
      float_opts = {
        border = "curved",
        winblend = 0,
      },
    },
  },
})

-- ==============================================================================
-- 5. WORKFLOWS
-- ==============================================================================
local function run_odin_cmd(cmd, direction)
  direction = direction or "horizontal"
  local ok, toggleterm = pcall(require, "toggleterm.terminal")
  if not ok then
    vim.cmd("split | terminal " .. cmd)
    return
  end
  local term = toggleterm.Terminal:new({
    cmd = cmd,
    direction = direction,
    close_on_exit = false,
    auto_scroll = true,
    hidden = true,
  })
  term:toggle()
end

-- Odin commands available under <leader>o
vim.keymap.set("n", "<leader>or", function()
  run_odin_cmd("odin run .")
end, { desc = "Odin: Run package (odin run .)" })

vim.keymap.set("n", "<leader>of", function()
  local file = vim.fn.expand("%")
  if file == "" or vim.bo.filetype ~= "odin" then
    vim.notify("Current buffer is not a valid Odin file.", vim.log.levels.WARN)
    return
  end
  run_odin_cmd("odin run " .. vim.fn.shellescape(file) .. " -file")
end, { desc = "Odin: Run single file (odin run <file> -file)" })

vim.keymap.set("n", "<leader>ob", function()
  run_odin_cmd("odin build . -debug")
end, { desc = "Odin: Build with debug (odin build . -debug)" })

vim.keymap.set("n", "<leader>oc", function()
  run_odin_cmd("odin check .")
end, { desc = "Odin: Quick typecheck (odin check .)" })

vim.keymap.set("n", "<leader>ot", function()
  run_odin_cmd("odin test .")
end, { desc = "Odin: Run tests (odin test .)" })

-- Quickfix List error check
vim.keymap.set("n", "<leader>oq", function()
  vim.opt_local.makeprg = "odin check . -error-pos-style:unix"
  vim.opt_local.errorformat = "%f:%l:%c:\\ %m,%f(%l:%c)\\ %m"
  vim.cmd("silent make!")
  vim.cmd("copen")
end, { desc = "Odin: Check and open Quickfix" })

-- Odin Project Initializer (creates recommended main.odin and ols.json)
vim.api.nvim_create_user_command("OdinInit", function()
  local cwd = vim.fn.getcwd()
  local main_file = cwd .. "/main.odin"
  local ols_file = cwd .. "/ols.json"

  if vim.fn.filereadable(main_file) == 0 then
    local main_content = table.concat({
      "package main",
      "",
      'import "core:fmt"',
      "",
      "main :: proc() {",
      '\tfmt.println("Hellope!")',
      "}",
      "",
    }, "\n")
    local f = io.open(main_file, "w")
    if f then
      f:write(main_content)
      f:close()
      vim.notify("Created main.odin successfully!", vim.log.levels.INFO)
    end
  end

  if vim.fn.filereadable(ols_file) == 0 then
    local ols_content = table.concat({
      "{",
      '  "$schema": "https://raw.githubusercontent.com/DanielGavin/ols/master/misc/ols.schema.json",',
      '  "enable_inlay_hints": true,',
      '  "enable_inlay_hints_params": true,',
      '  "enable_inlay_hints_default_params": true,',
      '  "enable_inlay_hints_implicit_return": true,',
      '  "enable_inlay_hints_optional_result": true,',
      '  "enable_semantic_tokens": true,',
      '  "enable_document_symbols": true,',
      '  "enable_hover": true',
      "}",
      "",
    }, "\n")
    local f = io.open(ols_file, "w")
    if f then
      f:write(ols_content)
      f:close()
      vim.notify("Created ols.json successfully!", vim.log.levels.INFO)
    end
  end

  vim.cmd("edit " .. vim.fn.fnameescape(main_file))
end, { desc = "Initialize Odin project with main.odin and ols.json" })

vim.keymap.set("n", "<leader>oi", "<cmd>OdinInit<cr>", { desc = "Odin: Initialize new project" })

-- Manual format with odinfmt
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({ async = true, lsp_fallback = true })
  else
    vim.lsp.buf.format({ async = true })
  end
end, { desc = "Format code (odinfmt)" })

-- Toggle autoformat on save
vim.keymap.set("n", "<leader>tf", function()
  vim.g.disable_autoformat = not vim.g.disable_autoformat
  local status = vim.g.disable_autoformat and "disabled" or "enabled"
  vim.notify("Format on save " .. status, vim.log.levels.INFO)
end, { desc = "Toggle format on save" })

-- ==============================================================================
-- 6. DEBUGGER KEYMAPS (DAP)
-- ==============================================================================
local function with_dap(fn)
  local ok, dap = pcall(require, "dap")
  if ok then
    fn(dap)
  else
    vim.notify("nvim-dap not available. Wait for Lazy or run :Lazy sync", vim.log.levels.WARN)
  end
end

local function with_dapui(fn)
  local ok, dapui = pcall(require, "dapui")
  if ok then
    fn(dapui)
  else
    vim.notify("nvim-dap-ui not available. Wait for Lazy or run :Lazy sync", vim.log.levels.WARN)
  end
end

vim.keymap.set("n", "<F5>", function() with_dap(function(d) d.continue() end) end, { desc = "Debug: Continue / Start" })
vim.keymap.set("n", "<F10>", function() with_dap(function(d) d.step_over() end) end, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F11>", function() with_dap(function(d) d.step_into() end) end, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F12>", function() with_dap(function(d) d.step_out() end) end, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>db", function() with_dap(function(d) d.toggle_breakpoint() end) end, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
  with_dap(function(d)
    vim.ui.input({ prompt = "Breakpoint Condition: " }, function(condition)
      if condition and condition ~= "" then
        d.set_breakpoint(condition)
      end
    end)
  end)
end, { desc = "Debug: Conditional Breakpoint" })
vim.keymap.set("n", "<leader>du", function() with_dapui(function(ui) ui.toggle() end) end, { desc = "Debug: Toggle DAP UI" })
vim.keymap.set("n", "<leader>dr", function() with_dap(function(d) d.repl.open() end) end, { desc = "Debug: Open DAP REPL" })
vim.keymap.set("n", "<leader>dt", function()
  with_dap(function(d) d.terminate() end)
  with_dapui(function(ui) ui.close() end)
end, { desc = "Debug: Terminate session" })

-- Debug 1-Click: Compiles Odin project with -debug and launches LLDB
vim.keymap.set("n", "<leader>do", function()
  local cwd = vim.fn.getcwd()
  local project_name = vim.fn.fnamemodify(cwd, ":t")
  local out_bin = cwd .. "/" .. project_name

  vim.notify("Compiling Odin with debug symbols (-debug)...", vim.log.levels.INFO)
  local res = vim.system({ "odin", "build", ".", "-debug", "-out:" .. out_bin }):wait()
  if res.code ~= 0 then
    vim.notify("Compilation error:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
    return
  end

  vim.notify("Compilation successful! Launching LLDB...", vim.log.levels.INFO)
  with_dap(function(dap)
    dap.run({
      type = "lldb",
      request = "launch",
      name = "Debug 1-Click Odin",
      program = out_bin,
      cwd = cwd,
      stopOnEntry = false,
      args = {},
    })
  end)
end, { desc = "Debug: Build with -debug and start LLDB" })

local colorscheme = "kanagawa"

local config = {
  -- Set colorscheme
  colorscheme = colorscheme,

  lsp = {
    setup_handlers = {
      rust_analyzer = function(_, opts)
        require("rust-tools").setup {
          tools = {
            autoSetHints = true,
            inlay_hints = {
                -- automatically set inlay hints (type hints)
                -- default: true
                auto = true,

                -- Only show inlay hints for the current line
                only_current_line = false,

                -- whether to show parameter hints with the inlay hints or not
                -- default: true
                show_parameter_hints = true,

                -- prefix for parameter hints
                -- default: "<-"
                parameter_hints_prefix = "⬅ ",

                -- prefix for all the other hints (type, chaining)
                -- default: "=>"
                other_hints_prefix = "⇒ ",

                -- whether to align to the length of the longest line in the file
                max_len_align = false,

                -- padding from the left if max_len_align is true
                max_len_align_padding = 1,

                -- whether to align to the extreme right or not
                right_align = false,

                -- padding from the right if right_align is true
                right_align_padding = 7,

                -- The color of the hints
                highlight = "Comment",
            }
          },
          
          -- server = opts,
          
          
          server = vim.tbl_deep_extend("force", opts, { 
            settings = {
              ["rust-analyzer"] = {
		            cargo = {
			            allFeatures = true,
			            loadOutDirsFromCheck = true,
			            runBuildScripts = true,
		            },
		            -- Add clippy lints for Rust.
		            checkOnSave = {
			            allFeatures = true,
			            command = "clippy",
			            extraArgs = {
				            "--",
				            "--no-deps",
				            "-Dclippy::correctness",
				            "-Dclippy::complexity",
				            "-Wclippy::perf",
				            "-Wclippy::pedantic",
			            },
		            },
              },
            }
          })
        }
        vim.api.nvim_set_keymap('n', '<Leader>rr', ':RustRunnables<CR>', {noremap = true, silent = true})
        end
    }
  },

  plugins = {
    { "equalsraf/neovim-gui-shim" },
    { "rebelot/kanagawa.nvim" },
    { "lvimuser/lsp-inlayhints.nvim" },
    { "ray-x/lsp_signature.nvim" },
    { "ryanoasis/vim-devicons" },
    {
      "nvim-neotest/neotest",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "rouge8/neotest-rust",
        "rcasia/neotest-java",
      },
    },
    { 
      "kdheepak/lazygit.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim"
      },
    },
    {
      "simrat39/rust-tools.nvim",
      {
        "williamboman/mason-lspconfig.nvim",
        opts = {
          ensure_installed = { "rust_analyzer" }, -- automatically install lsp
        },
      },
    },
    {
        'phaazon/hop.nvim',
        config = function()
          -- require('hop').setup { keys = 'etovxqpdygfblzhckisuran' }
          require('hop').setup()
          local opts = { noremap = true, silent = true }
          local map = vim.api.nvim_set_keymap
          local set = vim.opt
          local directions = require('hop.hint').HintDirection
          local hop = require('hop')
          map('n', 'f', '<cmd>HopWordCurrentLine<cr>', opts)
          map('n', 'F', '<cmd>HopChar2<cr>', opts)
        end
    },
    {
      'tpope/vim-fugitive',
      lazy = false,
    },
  },
  polish = function()
    require('hop').setup()
    -- close terminal in terminal mode
    vim.api.nvim_set_keymap('t', '<C-t>', '<C-\\><C-n>:ToggleTerm<CR>', {noremap = true, silent = true})
    -- close terminal in normal mode
    vim.api.nvim_set_keymap('n', '<C-t>', '<C-\\><C-n>:ToggleTerm<CR>', {noremap = true, silent = true})
    -- test shortcuts
    vim.api.nvim_set_keymap(
      'n', '<Leader>mr', ':lua require("neotest").run.run()<CR>', {noremap = true, silent = true})
    vim.api.nvim_set_keymap(
      'n', '<Leader>ms', ':lua require("neotest").run.stop()<CR>', {noremap = true, silent = true})
    vim.api.nvim_set_keymap(
      'n', '<Leader>mo', ':lua require("neotest").output.open()<CR>', {noremap = true, silent = true})
    vim.api.nvim_set_keymap(
      'n', '<Leader>mO', ':lua require("neotest").output.open({ enter = true })<CR>', {noremap = true, silent = true})
    vim.api.nvim_set_keymap(
      'n', '<Leader>mi', ':lua require("neotest").summary.toggle()<CR>', {noremap = true, silent = true})
    vim.api.nvim_set_keymap(
      'n', '<Leader>mf', ':lua require("neotest").run.run(vim.fn.expand("%"))<CR>', {noremap = true, silent = true})
    vim.api.nvim_set_keymap(
      "n", "[n", "<cmd>lua require('neotest').jump.prev({ status = 'failed' })<CR>", {silent = true})
    vim.api.nvim_set_keymap(
      "n", "]n", "<cmd>lua require('neotest').jump.next({ status = 'failed' })<CR>", {silent = true})

    vim.api.nvim_set_keymap(
      'n', '<Leader>gg', ':LazyGit<CR>', {noremap = true, silent = true})
    vim.api.nvim_set_keymap(
      'n', 
      '<Leader>k', 
      ":lua require('lsp_signature').toggle_float_win()<CR>", 
      {silent = true, noremap = true, desc = "Show function hint"}
    )
    -- vim.api.nvim_set_keymap('v', '<leader>rl', ":lua require'code-sherpa'.send_to_ai()<CR>", {noremap = true, silent = true})
    -- vim.api.nvim_set_keymap('v', '<leader>rh', ":lua require'code-sherpa'.hightlight_lines()<CR>", {noremap = true, silent = true})

    require("neotest").setup({
      adapters = {
        require("neotest-rust") {
            args = { "--no-capture" },
        },
        require("neotest-java")({
          ignore_wrapper = false,
        })
      }
    })
    require("telescope").load_extension("lazygit")

    local lsp_group = vim.api.nvim_create_augroup("LspAttach_inlayhints", { clear = true })
    vim.api.nvim_create_autocmd("LspAttach", {
      group = lsp_group,
      callback = function(args)
        if not (args.data and args.data.client_id) then
          return
        end

        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        require("lsp-inlayhints").on_attach(client, bufnr)
      end,
    })

    local cfg = {
      bind = true,
      handler_opts = {
        border = "shadow",   -- double, rounded, single, shadow, none, or a table of borders
        toggle_key = "<C-n>"
      },
    } 
    require "lsp_signature".setup(cfg)
    
    -- LuaSnippets
    local ls = require("luasnip")
    local s = ls.snippet
    local sn = ls.snippet_node
    local isn = ls.indent_snippet_node
    local t = ls.text_node
    local i = ls.insert_node
    local f = ls.function_node
    local c = ls.choice_node
    local d = ls.dynamic_node
    
    -- Reusable parts
    local vis = { t("pub "), i(1), t(" "), i(2) }
    local ret = { t(" -> "), i(1), t(" ") }
    local block = { t("{\n"), i(0), t("\n}") }
    -- Snippets
    ls.add_snippets("rust", {
        s('if', {
          t { 'if ' },
          i(1, 'expr'),
          t { ' {', '\t' },
          i(0),
          t { '', '}' },
        }),

        s('else', {
          t { 'else {', '\t' },
          i(0),
          t { '', '}' },
        }),

        s({ trig = 'match', dscr = '`match` with two matching arms.' }, {
          t { 'match ' },
          i(1, 'expr'),
          t { ' {', '\t' },
          i(2, 'Some(expr)'),
          t { ' => ' },
          i(3, 'expr'),
          t { ',', '\t' },
          i(4, 'None'),
          t { ' => ' },
          i(4, 'expr'),
          t { ',', '' },
          t { '}' },
        }),
        -- test: Test function
        s('testmod', {
          t { '#[cfg(test)]', '' },
          t { 'mod ' },
          i(1, 'mod_test'),
          t { ' {', '\t' },
          t { 'use super::*;', '\t' },
          t { '', '\t' },
          t { '#[test]', '\t' },
          t { 'fn ' },
          i(2, 'test'),
          t { '() {', '\t\t' },
          t { 'assert!(' },
          i(0, 'bool'),
          t { ');', '\t' },
          t { '}', '' },
          t { '}' },
        }),
        s('test', {
          t { '#[test]', '' },
          t { 'fn ' },
          i(1, 'test'),
          t { '() {', '\t' },
          t { 'assert!(' },
          i(0, 'bool'),
          t { ');', '' },
          t { '}' },
        }),

    })
  end,
}

return config

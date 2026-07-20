-- AI agent frontend: https://github.com/sudo-tee/opencode.nvim
-- Spawns its own `opencode serve` process on demand; no global server
-- config needed (avoids fixed-port collisions across parallel sessions).
-- Keymaps live under <leader>i ("intelligence") because <leader>o/O/a are
-- taken by obsidian, outline and harpoon.
return {
  {
    "sudo-tee/opencode.nvim",
    event = "VeryLazy",
    dependencies = {
      {
        "MeanderingProgrammer/render-markdown.nvim",
        -- additionally render the opencode output buffer; regular markdown
        -- stays cmd-loaded via the existing render-markdown.lua spec
        ft = { "opencode_output" },
        opts = {
          anti_conceal = { enabled = false },
          file_types = { "markdown", "opencode_output" },
        },
      },
    },
    config = function()
      require("opencode").setup {
        keymap_prefix = "<leader>i",
        context = {
          cursor_data = { enabled = true }, -- cursor line +/- 5 lines as context
        },
      }
    end,
  },

  -- Keep blink.cmp from auto-opening completion menus while writing prose in
  -- the opencode prompt (recipe from the opencode.nvim README, inheriting the
  -- existing blink-cmp.lua behavior everywhere else).
  {
    "saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      opts.completion = opts.completion or {}
      opts.completion.menu = opts.completion.menu or {}
      opts.completion.ghost_text = opts.completion.ghost_text or {}

      local inherited_auto_show = opts.completion.menu.auto_show
      local inherited_ghost_text_enabled = opts.completion.ghost_text.enabled

      opts.completion.menu.auto_show = function(ctx, items)
        if vim.bo[ctx.bufnr].filetype == "opencode" then
          -- no auto-popup while typing prose; explicit triggers still work
          return ctx.trigger.kind == "trigger_character"
        end
        if type(inherited_auto_show) == "function" then
          return inherited_auto_show(ctx, items)
        end
        return inherited_auto_show ~= false
      end

      opts.completion.ghost_text.enabled = function()
        local ghost_text_enabled = type(inherited_ghost_text_enabled) == "function"
            and inherited_ghost_text_enabled()
          or inherited_ghost_text_enabled == true
        if vim.bo.filetype == "opencode" then
          return ghost_text_enabled and require("blink.cmp").is_menu_visible()
        end
        return ghost_text_enabled
      end

      return opts
    end,
  },
}

-- Setup mason-lspconfig
-- v2 breaking change: `automatic_installation` and `setup_handlers` were
-- removed in favor of `automatic_enable`. Servers are enabled manually in
-- configs/lspconfig (vim.lsp.config + vim.lsp.enable), so keep that off.
require("mason-lspconfig").setup {
  ensure_installed = {
    "lua_ls",
    "ts_ls",
    "biome",
    "eslint",
    "gopls",
    "ruby_lsp",
    -- "rust_analyzer", -- Handled by rustaceanvim plugin
    "pyright",
    "hyprls",
    -- "marksman",
    "markdown_oxide",
    "harper_ls",
    "angularls",
  },
  automatic_enable = false,
}

-- Diagnostic command for Mason issues
vim.api.nvim_create_user_command("MasonDiagnostics", function()
  print "=== Mason Diagnostics ==="

  -- Check if Mason is loaded
  local mason_ok, mason = pcall(require, "mason")
  if mason_ok then
    print "Mason: Loaded ✓"

    -- Check registry
    local registry_ok, registry = pcall(require, "mason-registry")
    if registry_ok then
      print "Mason Registry: Available ✓"

      -- Try to get installed packages
      local ok, installed = pcall(registry.get_installed_packages)
      if ok then
        print("Installed packages: " .. #installed)
      else
        print "Failed to get installed packages"
      end
    else
      print "Mason Registry: Not available ✗"
    end
  else
    print "Mason: Not loaded ✗"
  end

  -- Check mason-lspconfig
  local mason_lsp_ok, _ = pcall(require, "mason-lspconfig")
  if mason_lsp_ok then
    print "mason-lspconfig: Loaded ✓"
  else
    print "mason-lspconfig: Not loaded ✗"
  end

  -- Check network connectivity (simple test)
  vim.fn.jobstart({ "curl", "-s", "-o", "/dev/null", "-w", "%{http_code}", "https://api.github.com" }, {
    on_exit = function(_, exit_code, _)
      if exit_code == 0 then
        print "GitHub API: Reachable ✓"
      else
        print "GitHub API: Not reachable ✗"
      end
    end,
  })
end, { desc = "Show Mason diagnostics" })

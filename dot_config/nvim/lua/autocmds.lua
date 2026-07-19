require "nvchad.autocmds"

vim.api.nvim_create_user_command("MasonInstallFromList", function()
  local chadrc = require "chadrc"
  local packages = chadrc.mason and chadrc.mason.pkgs or {}

  if #packages == 0 then
    vim.notify("No packages configured in chadrc.mason.pkgs", vim.log.levels.WARN)
    return
  end

  if vim.fn.exists ":MasonInstall" == 2 then
    local package_string = table.concat(packages, " ")
    vim.cmd("MasonInstall " .. package_string)
  else
    vim.notify("Mason not loaded yet. Try running :Mason first", vim.log.levels.ERROR)
  end
end, { desc = "Install all packages listed in chadrc.mason.pkgs" })

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = function()
    vim.defer_fn(function()
      if vim.fn.exists ":MasonInstallAll" == 2 then
        vim.cmd "MasonInstallAll"
      end
    end, 100)
  end,
})

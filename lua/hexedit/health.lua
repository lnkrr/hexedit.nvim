local M = {}

local config = require("hexedit.config")

function M.check()
    vim.health.start("External tools")

    if vim.fn.executable(config.opts.xxd_exe) == 1 then
        vim.health.ok("`" .. config.opts.xxd_exe .. "` is present")
    else
        vim.health.error("`" .. config.opts.xxd_exe .. "` not found")
    end
end

return M

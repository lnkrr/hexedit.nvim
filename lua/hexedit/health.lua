local M = {}

local config = require("hexedit.config")

function M.check()
    vim.health.start("External tools")

    for _, exe in ipairs({ config.opts.xxd_exe, config.opts.file_exe }) do
        if vim.fn.executable(exe) == 1 then
            vim.health.ok("`" .. exe .. "` is present")
        else
            vim.health.error("`" .. exe .. "` not found")
        end
    end
end

return M

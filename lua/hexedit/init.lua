local M = {}

local buffer = require("hexedit.buffer")

function M.toggle()
    if vim.b.hexedit then
        buffer.encode()
    else
        buffer.decode()
    end
end

function M.setup(opts)
    require("hexedit.config").setup(opts)
    vim.api.nvim_create_user_command("HexeditToggle", M.toggle, {})
end

return M

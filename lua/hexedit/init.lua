local M = {}

local buffer = require("hexedit.buffer")
local config = require("hexedit.config")
local utils = require("hexedit.utils")

function M.toggle()
    if vim.b.hexedit then
        buffer.decode()
    else
        buffer.encode()
    end
end

function M.setup(opts)
    config.setup(opts)

    vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function(args)
            if not vim.b.hexedit then
                return
            end

            utils.apply_to_buffer(args.buf, config.opts.decode)
        end,
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function(args)
            if not vim.b.hexedit then
                return
            end

            utils.apply_to_buffer(args.buf, config.opts.encode)
        end,
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function()
            if not vim.b.hexedit then
                return
            end

            local line, column = utils.get_cursor()
            local new_line, new_column = config.opts.cursor.snap(line, column)

            if new_line ~= line or new_column ~= column then
                utils.set_cursor(new_line, new_column)
            end
        end,
    })

    vim.api.nvim_create_user_command("HexeditToggle", M.toggle, {})
end

return M

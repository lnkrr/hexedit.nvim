local M = {}

local config = require("hexedit.config")
local utils = require("hexedit.utils")

function M.encode(buffer)
    if vim.b.hexedit then
        return
    end

    local offset = utils.cursor_to_offset(buffer, utils.get_cursor(buffer))

    if not utils.apply_to_buffer(buffer, config.opts.encode) then
        return
    end

    local line, column = config.opts.cursor.to_encoded(offset)
    utils.set_cursor(buffer, line, column)

    utils.reset_undos(buffer)

    vim.b.hexedit_ft = vim.bo.filetype
    vim.b.hexedit = true

    vim.bo.modified = false
    vim.bo.filetype = config.opts.filetype
end

function M.decode(buffer)
    if not vim.b.hexedit then
        return
    end

    local line, column = utils.get_cursor(buffer)

    if not utils.apply_to_buffer(buffer, config.opts.decode) then
        return
    end

    local new_line, new_column = utils.offset_to_cursor(
        buffer,
        config.opts.cursor.to_decoded(line, column)
    )

    utils.set_cursor(buffer, new_line, new_column)
    utils.reset_undos(buffer)

    vim.b.hexedit = false

    vim.bo.modified = false
    vim.bo.filetype = vim.b.hexedit_ft
end

function M.goto_offset(buffer, offset)
    if not vim.b.hexedit then
        return
    end

    local line, column = config.opts.cursor.to_encoded(offset)
    utils.set_cursor(buffer, line, column)
end

return M

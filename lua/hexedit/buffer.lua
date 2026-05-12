local M = {}

local config = require("hexedit.config")
local utils = require("hexedit.utils")

function M.encode(buffer)
    if vim.b.hexedit then
        return
    end

    vim.b.hexedit_ft = vim.bo.filetype
    vim.b.hexedit = true

    local offset = utils.cursor_to_offset(buffer, utils.get_cursor(buffer))
    vim.bo.filetype = config.opts.filetype

    utils.apply_to_buffer(buffer, config.opts.encode)

    local line, column = config.opts.cursor.to_encoded(offset)
    utils.set_cursor(buffer, line, column)

    utils.reset_undos(buffer)
    vim.bo.modified = false
end

function M.decode(buffer)
    if not vim.b.hexedit then
        return
    end

    vim.b.hexedit = false

    local line, column = utils.get_cursor(buffer)

    utils.apply_to_buffer(buffer, config.opts.decode)

    local new_line, new_column = utils.offset_to_cursor(
        buffer,
        config.opts.cursor.to_decoded(line, column)
    )

    utils.set_cursor(buffer, new_line, new_column)
    vim.bo.filetype = vim.b.hexedit_ft

    utils.reset_undos(buffer)
    vim.bo.modified = false
end

function M.goto_offset(buffer, offset)
    if not vim.b.hexedit then
        return
    end

    local line, column = config.opts.cursor.to_encoded(offset)
    utils.set_cursor(buffer, line, column)
end

return M

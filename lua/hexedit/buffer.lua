local M = {}

local config = require("hexedit.config")
local utils = require("hexedit.utils")

local function reset_undos()
    local undolevels = vim.bo.undolevels
    vim.bo.undolevels = -1
    vim.cmd.execute('"normal a \\<bs>\\<esc>"')
    vim.bo.undolevels = undolevels
end

function M.encode()
    if vim.b.hexedit then
        return
    end

    vim.b.hexedit_ft = vim.bo.filetype
    vim.b.hexedit = true

    local offset = utils.cursor_to_offset(0, utils.get_cursor(0))
    vim.bo.filetype = config.opts.filetype

    utils.apply_to_buffer(0, config.opts.encode)

    local line, column = config.opts.cursor.to_encoded(offset)
    utils.set_cursor(0, line, column)

    reset_undos()
    vim.bo.modified = false
end

function M.decode()
    if not vim.b.hexedit then
        return
    end

    vim.b.hexedit = false

    local line, column = utils.get_cursor(0)

    utils.apply_to_buffer(0, config.opts.decode)

    local new_line, new_column =
        utils.offset_to_cursor(0, config.opts.cursor.to_decoded(line, column))

    utils.set_cursor(0, new_line, new_column)
    vim.bo.filetype = vim.b.hexedit_ft

    reset_undos()
    vim.bo.modified = false
end

return M

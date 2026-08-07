local M = {}

local config = require("hexedit.config")
local utils = require("hexedit.utils")

function M.encode(buffer)
    if vim.b[buffer].hexedit then
        return
    end

    local window = utils.find_window(buffer)
    local offset

    if window ~= nil then
        offset = utils.cursor_to_offset(buffer, utils.get_cursor(window))
    end

    if not utils.apply_to_buffer(buffer, config.opts.encode) then
        return
    end

    if window ~= nil then
        local line, column = config.opts.cursor.to_encoded(offset)
        utils.set_cursor(window, line, column)
    end

    utils.reset_undos(buffer)

    vim.b[buffer].hexedit_ft = vim.bo[buffer].filetype
    vim.b[buffer].hexedit = true

    vim.bo[buffer].modified = false
    vim.bo[buffer].filetype = config.opts.filetype
end

function M.decode(buffer)
    if not vim.b[buffer].hexedit then
        return
    end

    local window = utils.find_window(buffer)
    local line, column

    if window ~= nil then
        line, column = utils.get_cursor(window)
    end

    if not utils.apply_to_buffer(buffer, config.opts.decode) then
        return
    end

    if window ~= nil then
        local new_line, new_column = utils.offset_to_cursor(
            buffer,
            config.opts.cursor.to_decoded(line, column)
        )

        utils.set_cursor(window, new_line, new_column)
    end

    utils.reset_undos(buffer)

    vim.b[buffer].hexedit = false

    vim.bo[buffer].modified = false
    vim.bo[buffer].filetype = vim.b[buffer].hexedit_ft
end

function M.goto_offset(buffer, offset)
    if not vim.b[buffer].hexedit then
        return
    end

    local window = utils.find_window(buffer)

    if window ~= nil then
        local line, column = config.opts.cursor.to_encoded(offset)
        utils.set_cursor(window, line, column)
    end
end

return M

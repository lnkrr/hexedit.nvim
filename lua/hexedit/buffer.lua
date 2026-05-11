local M = {}

local config = require("hexedit.config")
local utils = require("hexedit.utils")

function M.encode()
    if vim.b.hexedit then
        return
    end

    vim.b.hexedit_ft = vim.bo.filetype
    vim.b.hexedit = true

    vim.bo.filetype = config.opts.filetype
    utils.apply_to_buffer(0, config.opts.encode)
end

function M.decode()
    if not vim.b.hexedit then
        return
    end

    vim.b.hexedit = false

    utils.apply_to_buffer(0, config.opts.decode)
    vim.bo.filetype = vim.b.hexedit_ft
end

return M

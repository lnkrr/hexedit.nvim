local M = {}

local buffer = require("hexedit.buffer")
local config = require("hexedit.config")
local utils = require("hexedit.utils")

local pre_write_view = nil

function M.encode()
    buffer.encode()
end

function M.decode()
    buffer.decode()
end

function M.toggle()
    if vim.b.hexedit then
        M.decode()
    else
        M.encode()
    end
end

function M.setup(opts)
    config.setup(opts)

    vim.api.nvim_create_autocmd("BufReadPost", {
        callback = function()
            if config.opts.should_open_with_hexedit(0) then
                buffer.encode()
            end
        end,
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function(args)
            if not vim.b.hexedit then
                return
            end

            pre_write_view = vim.fn.winsaveview()
            utils.apply_to_buffer(args.buf, config.opts.decode)
        end,
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
        callback = function(args)
            if not vim.b.hexedit then
                return
            end

            utils.apply_to_buffer(args.buf, config.opts.encode)
            vim.fn.winrestview(pre_write_view)
        end,
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function()
            if not vim.b.hexedit then
                return
            end

            local line, column = utils.get_cursor(0)
            local new_line, new_column = config.opts.cursor.snap(line, column)

            if new_line ~= line or new_column ~= column then
                utils.set_cursor(0, new_line, new_column)
            end
        end,
    })

    vim.api.nvim_create_autocmd("InsertCharPre", {
        callback = function()
            if not vim.b.hexedit then
                return
            end

            if not vim.v.char:match("[ %x]") then
                vim.v.char = ""
                return
            end

            if config.opts.xxd.uppercase then
                vim.v.char = vim.v.char:upper()
            else
                vim.v.char = vim.v.char:lower()
            end
        end,
    })

    vim.api.nvim_create_user_command("Hexedit", function(args)
        if args.fargs[2] ~= nil then
            vim.notify("Too many arguments", vim.log.levels.ERROR)
            return
        end

        local cmd = args.fargs[1]

        if cmd == "toggle" then
            M.toggle()
        elseif cmd == "encode" then
            M.encode()
        elseif cmd == "decode" then
            M.decode()
        else
            vim.notify("Unknown command", vim.log.levels.ERROR)
        end
    end, {
        nargs = "+",
        complete = function()
            return { "toggle", "encode", "decode" }
        end,
    })
end

return M

local M = {}

local buffer = require("hexedit.buffer")
local config = require("hexedit.config")
local utils = require("hexedit.utils")

local pre_write_view = nil

function M.encode()
    buffer.encode(0)
end

function M.decode()
    buffer.decode(0)
end

function M.toggle()
    if vim.b.hexedit then
        M.decode()
    else
        M.encode()
    end
end

function M.goto_offset(offset)
    buffer.goto_offset(0, offset)
end

local function to_uint(literal)
    if literal:match("^0x[%x]+$") then
        return tonumber(literal, 16)
    end

    if literal:match("^0b[01]+$") then
        return tonumber(literal:sub(3), 2)
    end

    if literal:match("^0o[0-7]+$") then
        return tonumber(literal:sub(3), 8)
    end

    if literal:match("^%d+$") then
        return tonumber(literal)
    end

    return nil
end

function M.setup(opts)
    config.setup(opts)

    vim.api.nvim_create_autocmd("BufReadPost", {
        callback = function()
            if config.opts.should_open_with_hexedit(0) then
                M.encode()
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
        local cmd = args.fargs[1]

        if cmd == "goto" then
            local offset = args.fargs[2]

            if offset == nil then
                vim.notify("Usage: Hexedit goto <offset>", vim.log.levels.ERROR)
                return
            end

            offset = to_uint(offset)

            if offset == nil then
                vim.notify("Invalid offset", vim.log.levels.ERROR)
                return
            end

            M.goto_offset(offset)
            return
        end

        if args.fargs[2] ~= nil then
            vim.notify("Too many arguments", vim.log.levels.ERROR)
            return
        end

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
            return { "toggle", "encode", "decode", "goto" }
        end,
    })
end

return M

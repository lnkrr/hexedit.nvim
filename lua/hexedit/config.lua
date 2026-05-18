local M = {}

local function to_xxd_args(opts)
    local result = {}

    if opts.groupsize then
        table.insert(result, "-g" .. opts.groupsize)
    end

    if opts.cols then
        table.insert(result, "-c" .. opts.cols)
    end

    if opts.uppercase then
        table.insert(result, "-u")
    end

    return result
end

local utils = require("hexedit.utils")

M.opts = {
    encode = function(data)
        local result = vim.system(
            { M.opts.xxd_exe, table.unpack(to_xxd_args(M.opts.xxd)) },
            { stdin = data, text = false }
        ):wait()

        return result.stdout
    end,
    decode = function(data)
        local result = vim.system({
            M.opts.xxd_exe,
            "-r",
            table.unpack(to_xxd_args(M.opts.xxd)),
        }, { stdin = data }):wait()

        return result.stdout
    end,
    should_open_with_hexedit = function(buffer)
        if vim.bo[buffer].buftype ~= "" then
            return false
        end

        local filename = vim.api.nvim_buf_get_name(buffer)

        if filename == "" then
            return false
        end

        local result = vim.system({
            M.opts.file_exe,
            "--mime-type",
            "-b",
            filename,
        }):wait()

        local stdout = result.stdout:gsub("%s+", "")

        for _, type in ipairs({
            "text/",
            "inode/",
            "javascript",
            "xml",
            "json",
        }) do
            if string.find(stdout, type) then
                return false
            end
        end

        for _, type in ipairs({
            "application/x-sh",
            "application/x-shellscript",
        }) do
            if stdout == type then
                return false
            end
        end

        return true
    end,
    cursor = {
        to_encoded = function(offset)
            local line = math.floor(offset / M.opts.xxd.cols) + 1

            local column = 11
                + offset % M.opts.xxd.cols * 2
                + math.floor(offset % M.opts.xxd.cols / M.opts.xxd.groupsize)

            return line, column
        end,
        to_decoded = function(line, column)
            local step = 2 * M.opts.xxd.groupsize + 1

            return (line - 1) * M.opts.xxd.cols
                + math.floor((column - 11) / step) * M.opts.xxd.groupsize
                + math.floor((column - 11) % step / 2)
                + 1
        end,
        snap = function(line, column)
            local step = 2 * M.opts.xxd.groupsize + 1
            return line,
                utils.clamp(
                    column,
                    11,
                    9 + math.ceil(step * M.opts.xxd.cols / M.opts.xxd.groupsize)
                )
        end,
    },
    xxd = {
        groupsize = 1,
        cols = 16,
        uppercase = true,
    },
    xxd_exe = "xxd",
    file_exe = "file",
    filetype = "hexedit",
}

function M.setup(opts)
    M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
end

return M

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

M.opts = {
    encode = function(data)
        local result = vim.system(
            { "xxd", table.unpack(to_xxd_args(M.opts.xxd)) },
            { stdin = data, text = false }
        ):wait()

        return result.stdout
    end,
    decode = function(data)
        local result = vim.system({
            "xxd",
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
            "file",
            "--mime-type",
            "-b",
            filename,
        }):wait()

        return not string.find(result.stdout, "text/")
            and not string.find(result.stdout, "inode/")
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
                math.min(
                    math.max(column, 11),
                    9 + math.ceil(step * M.opts.xxd.cols / M.opts.xxd.groupsize)
                )
        end,
    },
    xxd = {
        groupsize = 1,
        cols = 16,
        uppercase = true,
    },
    filetype = "hexedit",
}

function M.setup(opts)
    M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
end

return M

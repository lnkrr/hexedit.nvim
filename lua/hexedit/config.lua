local M = {}

M.opts = {
    encode = function(data)
        local result = vim.system(
            { "xxd", "-g" .. M.opts.xxd.groupsize },
            { stdin = data, text = false }
        ):wait()

        return result.stdout
    end,
    decode = function(data)
        local result = vim.system(
            { "xxd", "-r", "-g" .. M.opts.xxd.groupsize },
            { stdin = data }
        ):wait()

        return result.stdout
    end,
    cursor = {
        to_encoded = function(offset)
            local step = 2 * M.opts.xxd.groupsize + 1

            local line = math.floor(offset / 16) + 1
            local column = 11 + offset % 16 * step

            return line, column
        end,
        to_decoded = function(line, column)
            local step = 2 * M.opts.xxd.groupsize + 1
            return (line - 1) * 16 + math.floor((column - 11) / step) + 1
        end,
        snap = function(line, column)
            local step = 2 * M.opts.xxd.groupsize + 1
            return line,
                math.min(
                    math.max(column, 11),
                    9 + math.ceil(step * 16 / M.opts.xxd.groupsize)
                )
        end,
    },
    xxd = {
        groupsize = 1,
    },
    filetype = "xxd",
}

function M.setup(opts)
    M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
end

return M

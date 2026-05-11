local M = {}

M.opts = {
    encode = function(data)
        local result = vim.system({ "xxd" }, { stdin = data, text = false })
            :wait()

        return result.stdout
    end,
    decode = function(data)
        local result = vim.system({ "xxd", "-r" }, { stdin = data }):wait()
        return result.stdout
    end,
    filetype = "xxd",
}

function M.setup(opts)
    M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
end

return M

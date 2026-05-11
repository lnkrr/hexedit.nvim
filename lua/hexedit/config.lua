local M = {}

M.opts = {
    encode = function()
        vim.cmd("%!xxd")
    end,
    decode = function()
        vim.cmd("%!xxd -r")
    end,
    filetype = "xxd"
}

function M.setup(opts)
    M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
end

return M

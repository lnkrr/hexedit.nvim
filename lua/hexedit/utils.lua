local M = {}

function M.get_lines(buffer)
    return vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
end

function M.set_lines(buffer, lines)
    return vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
end

function M.apply_to_lines(lines, func)
    local buffer = table.concat(lines, "\n")
    return vim.split(func(buffer), "\n")
end

function M.apply_to_buffer(buffer, func)
    M.set_lines(buffer, M.apply_to_lines(M.get_lines(buffer), func))
end

return M

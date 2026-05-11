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

function M.get_cursor()
    return vim.fn.line("."), vim.fn.col(".")
end

function M.cursor_to_offset(line, column)
    return vim.fn.line2byte(line) + column - 2
end

function M.offset_to_cursor(offset)
    local line = vim.fn.byte2line(offset + 1)
    local column = offset - vim.fn.line2byte(line) + 1

    return line, column
end

function M.set_cursor(line, column)
    vim.api.nvim_win_set_cursor(0, { line, column - 1 })
end

return M

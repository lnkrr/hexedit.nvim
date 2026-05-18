local M = {}

function M.clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

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

function M.get_cursor(window)
    local result = vim.api.nvim_win_get_cursor(window)
    return result[1], result[2] + 1
end

function M.cursor_to_offset(buffer, line, column)
    return vim.api.nvim_buf_get_offset(buffer, line - 1) + column - 1
end

function M.offset_to_cursor(buffer, offset)
    local n_lines = vim.api.nvim_buf_line_count(buffer)

    local low, high = 1, n_lines
    local line = 1

    while low <= high do
        local mid = math.floor((low + high) / 2)
        local start = vim.api.nvim_buf_get_offset(buffer, mid - 1)

        if start > offset then
            high = mid - 1
        else
            line = mid
            low = mid + 1
        end
    end

    local column = offset - vim.api.nvim_buf_get_offset(buffer, line - 1)

    return line, math.max(column, 1)
end

function M.set_cursor(window, line, column)
    vim.api.nvim_win_set_cursor(window, { line, column - 1 })
end

function M.create_undo(buffer)
    vim.api.nvim_buf_call(buffer, function()
        vim.cmd.execute('"normal a \\<bs>\\<esc>"')
    end)
end

function M.reset_undos(buffer)
    local undolevels = vim.bo[buffer].undolevels
    vim.bo[buffer].undolevels = -1
    M.create_undo(buffer)
    vim.bo[buffer].undolevels = undolevels
end

function M.merge_undo_next(buffer)
    vim.api.nvim_buf_call(buffer, function()
        vim.cmd("silent! undojoin")
        M.create_undo(buffer)
        vim.cmd("undojoin")
    end)
end

return M

local UI = {}

local virtual_text_padding = 5

function UI.line_virtual_text(bufnr, ns, values, line)
    vim.api.nvim_buf_clear_namespace(bufnr, ns, line, line + 1)

    if type(values) == "string" then
        values = { values }
    end

    values = vim.tbl_map(function(val)
        return { string.rep(" ", virtual_text_padding) .. val }
    end, values)

    vim.api.nvim_buf_set_extmark(bufnr, ns, line, 0, {
        virt_text = values,
        hl_mode = "combine",
    })
end

function UI.clear_namespace(bufnr, ns, line_start, line_end)
    vim.api.nvim_buf_clear_namespace(bufnr, ns, line_start or 1, line_end or -1)
end

return UI

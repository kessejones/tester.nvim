local config = require("tester.config")
local languages = require("tester.languages")

local function attach(ctx)
    local mapping = config.mapping()

    vim.keymap.set({ "n" }, mapping.run_current, function()
        local cur_line = vim.fn.getpos(".")
        ctx:run_from_line(cur_line[2])
    end, { buffer = ctx.bufnr })

    vim.keymap.set({ "n" }, mapping.run_all, function()
        ctx:run_all()
    end, { buffer = ctx.bufnr })

    vim.api.nvim_create_autocmd({ "BufWritePost", "TextChangedI", "TextChanged" }, {
        buffer = ctx.bufnr,
        callback = function()
            ctx:update(true)
        end,
    })

    vim.api.nvim_create_autocmd("BufDelete", {
        buffer = ctx.bufnr,
        group = "tester",
        callback = function()
            ctx:flush()
        end,
    })

    ctx:update(true)
end

local M = {}

function M.setup(opts)
    config.setup(opts)

    local group = vim.api.nvim_create_augroup("tester", {})
    local ns = vim.api.nvim_create_namespace("tester")

    for _, lang in pairs(languages) do
        lang.setup({
            ns = ns,
            group = group,
            on_attach = attach,
        })
    end
end

return M

local a = vim.api

local config = require("tester.config")
local languages = require("tester.languages")

local contexts = {}

local function attach(ctx)
    table.insert(contexts, ctx.bufnr, ctx)

    a.nvim_create_autocmd({ "BufWritePost", "TextChangedI", "TextChanged" }, {
        buffer = ctx.bufnr,
        callback = function()
            ctx:update(true)
        end,
    })

    a.nvim_create_autocmd("BufDelete", {
        buffer = ctx.bufnr,
        group = "tester",
        callback = function()
            ctx:flush()
            table.remove(contexts, ctx.bufnr)
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

function M.run_current_test()
    local bufnr = a.nvim_get_current_buf()
    local ctx = contexts[bufnr]
    if ctx then
        local cur_line = vim.fn.getpos(".")
        ctx:run_from_line(cur_line[2])
    end
end

function M.run_all_tests()
    local bufnr = a.nvim_get_current_buf()
    local ctx = contexts[bufnr]
    if ctx then
        ctx:run_all()
    end
end

return M

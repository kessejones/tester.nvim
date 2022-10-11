local Context = require("tester.lib.Context")
local PyTest = require("tester.providers.pytest")

local M = {}

local function internal_attach(opts, e)
    --TODO: supports other test libraries
    local provider = PyTest.new(e.buf)
    local context = Context.new(e.buf, opts.ns, provider)

    opts.on_attach(context)
end

function M.setup(opts)
    opts = opts or {}

    vim.api.nvim_create_autocmd("BufReadPost", {
        group = opts.group,
        pattern = { "\\v(test_[^.]+|[^.]+_test|tests)\\.py$" },
        callback = function(e)
            internal_attach(opts, e)
        end,
    })
end

return M

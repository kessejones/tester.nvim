local Context = require("tester.lib.Context")
local PHPunit = require("tester.providers.phpunit")

local M = {}

local function internal_attach(opts, e)
    local provider = PHPunit.new(e.buf)
    local context = Context.new(e.buf, opts.ns, provider)

    opts.on_attach(context)
end

function M.setup(opts)
    -- TODO: use default opts from config
    opts = opts or {}

    vim.api.nvim_create_autocmd("BufReadPost", {
        group = opts.group,
        pattern = { "*.php" },
        callback = function(e)
            internal_attach(opts, e)
        end,
    })
end

return M

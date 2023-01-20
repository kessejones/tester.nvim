local default = require("tester.config.default")
local utils = require("tester.utils")

local M = {}
local config = {}

function M.setup(opts)
    config = vim.tbl_deep_extend("force", vim.deepcopy(default), opts or {})
end

function M.mapping()
    return config.mapping
end

function M.provider_config(provider)
    return config.providers[provider]
end

function M.load_tester_file()
    local tester_file = utils.find_tester_file()

    if not tester_file then
        vim.notify("[tester.nvim] Could not find tester.json")
        return
    end

    local content = {}
    for line in io.lines(tester_file) do
        table.insert(content, line)
    end

    local data = vim.json.decode(table.concat(content))
    if not config.providers[data.provider] then
        error(string.format("provider '%s' is invalid", data.provider))
        return
    end

    config.providers[data.provider] =
        vim.tbl_deep_extend("force", vim.deepcopy(config.providers[data.provider]), data or {})
end

return M

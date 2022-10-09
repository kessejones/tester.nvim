local default = require("tester.config.default")
local project = require("project_nvim.project")
local path = require("lspconfig.util").path

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
    local root = project.find_pattern_root()
    if not root then
        return
    end

    local filepath = path.join(root, ".tester.json")
    if not path.exists(filepath) then
        return
    end

    local content = {}
    for line in io.lines(filepath) do
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

local config = require("tester.config")
local treesitter = require("tester.providers.pytest.treesitter")
local utils = require("tester.utils")

local fmt = string.format

local M = {}

function M.new(bufnr)
    local instance = {
        bufnr = bufnr,
        on_success = nil,
        on_fail = nil,
    }
    setmetatable(instance, { __index = M })
    return instance
end

function M:get_test_cases()
    local definitions = treesitter.parsed_data(self.bufnr)
    if not definitions then
        return {
            class = {},
            cases = {},
        }
    end

    local test_functions = {}
    for name, data in pairs(definitions.functions) do
        if name:find("^test(.*)") then
            data.filename = vim.api.nvim_buf_get_name(self.bufnr)
            test_functions[name] = data
        end
    end

    return {
        -- FIXME: class not used
        class = {},
        cases = test_functions,
    }
end

function M:run(test)
    local pytest_config = config.provider_config("pytest")

    local command = vim.deepcopy(pytest_config.command)
    table.insert(command, test.filename)

    table.insert(command, "-k")
    if test.class_name then
        local query = fmt("%s::%s", test.class_name, test.method_name)
        table.insert(command, query)
    else
        table.insert(command, test.method_name)
    end

    utils.exec(command, test, self.on_success, self.on_fail)
end

return M

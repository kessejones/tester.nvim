local Job = require("tester.lib.Job")
local config = require("tester.config")
local treesitter = require("tester.providers.phpunit.treesitter")

local fmt = string.format

local function exec(cmd, test, on_success, on_fail)
    local output = {}
    local job = Job.new(cmd, {
        pty = true,
        stdout_buffered = true,
        on_stdout = function(_, data)
            output = data
        end,
        on_exit = function(_, code, _)
            if code == 0 then
                if on_success then
                    on_success(test, output)
                end
            else
                if on_fail then
                    on_fail(test, output)
                end
            end
        end,
    })
    job:start()
end

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

    local cases = {}
    for name, data in pairs(definitions.methods) do
        if name:find("^test(.*)") then
            cases[name] = data
        end
    end

    return {
        class = definitions.class,
        cases = cases,
    }
end

function M:run(test)
    local query = fmt("%s::%s", test.class_name, test.method_name)

    local phpunit_config = config.provider_config("phpunit")

    local command = phpunit_config.command
    table.insert(command, "--filter")
    table.insert(command, query)

    exec(command, test, self.on_success, self.on_fail)
end

return M

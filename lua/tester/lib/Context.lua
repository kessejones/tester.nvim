local UI = require("tester.lib.UI")
local config = require("tester.config")

local Context = {}

local TestStatus = {
    Success = 1,
    Failed = 2,
    NotExecuted = 3,
    Running = 4,
}

local function text_from_status(status)
    if status == TestStatus.Running then
        return "● Test Case: Running"
    elseif status == TestStatus.Success then
        return "● Test Case: Success"
    elseif status == TestStatus.Failed then
        return "● Test Case: Failed"
    elseif status == TestStatus.NotExecuted then
        return "● Test Case"
    else
        return ""
    end
end

function Context.new(bufnr, ns, provider)
    local instance = {
        bufnr = bufnr,
        ns = ns,
        provider = provider,
        _tests = {},
    }
    setmetatable(instance, { __index = Context })

    instance:_init()

    return instance
end

function Context:_init()
    self.provider.on_success = function(test, _output)
        test.status = TestStatus.Success
        test.user_data = {}

        self:update()
    end
    self.provider.on_fail = function(test, output)
        output = vim.tbl_map(function(val)
            return vim.trim(val, "\r")
        end, output)

        test.status = TestStatus.Failed
        test.user_data = {
            bufnr = self.bufnr,
            lnum = test.range[1],
            col = 0,
            severity = vim.diagnostic.severity.error,
            source = "tester",
            message = table.concat(output, "\n"),
        }

        self:update()
    end
end

function Context:_get_test_from_line(line)
    for _, case in pairs(self._tests) do
        if line >= case.range[1] + 1 and line <= case.range[3] + 1 then
            return case
        end
    end
    return nil
end

function Context:run_all()
    config.load_tester_file()

    for _, case in pairs(self._tests) do
        case.status = TestStatus.Running
        self.provider:run(case)
    end
    self:update()
end

function Context:run_from_line(line)
    if not line then
        vim.notify("line invalid")
        return
    end

    local case = self:_get_test_from_line(line)
    if not case then
        vim.notify("not found test in current line")
        return
    end

    config.load_tester_file()

    case.status = TestStatus.Running
    self:update()
    self.provider:run(case)
end

function Context:flush()
    self:_clear_namespace(0, -1)
    self:_set_diagnostics()
    self._tests = {}
end

function Context:load_tests()
    local tests = self.provider:get_test_cases()

    for name, _ in pairs(self._tests) do
        if not tests.cases[name] then
            self._tests[name].hide = true
        end
    end

    for name, case_data in pairs(tests.cases) do
        if self._tests[name] then
            if self._tests[name].status == TestStatus.Failed then
                self._tests[name].user_data.lnum = case_data.range_body[1]
            end
            self._tests[name].range = case_data.range_body
            self._tests[name].hide = false
        else
            local class_name
            if tests.class then
                class_name = tests.class.name
            end

            self._tests[name] = {
                filename = case_data.filename,
                method_name = name,
                class_name = class_name,
                status = TestStatus.NotExecuted,
                range = case_data.range_body,
                hide = false,
                user_data = {},
            }
        end
    end
end

function Context:test_from_line(line)
    local tests = self.provider:get_tests()

    for _, test in pairs(tests) do
        if line >= test.range[1] + 1 and line <= test.range[3] + 1 and test.hide == false then
            return test
        end
    end
    return nil
end

function Context:update(reload)
    if reload then
        self:load_tests()
    end

    self:_clear_namespace()
    self:_update_virtual_text()
    self:_update_diagnostics()
end

function Context:_update_virtual_text()
    for _, test in pairs(self._tests) do
        if test.status ~= TestStatus.Failed and not test.hide then
            local text = text_from_status(test.status)
            UI.line_virtual_text(self.bufnr, self.ns, text, test.range[1])
        end
    end
end

function Context:_clear_namespace(line_start, line_end)
    UI.clear_namespace(self.bufnr, self.ns, line_start or 0, line_end or -1)
end

function Context:_update_diagnostics()
    self:_set_diagnostics()

    local diagnostics = {}
    for _, case in pairs(self._tests) do
        if case.status == TestStatus.Failed and not case.hide then
            table.insert(diagnostics, case.user_data)
        end
    end
    self:_set_diagnostics(diagnostics)
end

function Context:_set_diagnostics(diagnostics, opts)
    vim.diagnostic.set(self.ns, self.bufnr, diagnostics or {}, opts or {})
end

return Context

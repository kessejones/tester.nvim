local Job = require("tester.lib.Job")

local M = {}

function M.exec(cmd, test, on_success, on_fail)
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

function M.treesitter_tree_root(bufnr, lang)
    local parser = vim.treesitter.get_parser(bufnr, lang, {})
    local tree = parser:parse()[1]
    return tree:root()
end

return M

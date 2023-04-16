local ts = vim.treesitter
local utils = require("tester.utils")

local M = {}

local function treesitter_query_parse()
    local python_query = ts.query.parse(
        "python",
        [[
        ; Function
        (function_definition name: (identifier) @function-name) @function-body
    ]]
    )

    return python_query
end

local function query_buffer(bufnr)
    local root = utils.treesitter_tree_root(bufnr, "python")
    local function_decl = {}
    local function_body = {}

    local python_query = treesitter_query_parse()
    for id, node in python_query:iter_captures(root, bufnr, 0, -1) do
        local name = python_query.captures[id]
        local range = { node:range() }
        if name == "function-name" then
            table.insert(function_decl, { range = range })
        elseif name == "function-body" then
            table.insert(function_body, { range = range })
        end
    end

    return {
        class = {},
        function_decl = function_decl,
        function_body = function_body,
    }
end

local function parse_functions(bufnr, data)
    local methods = {}
    for i, item in ipairs(data.function_decl) do
        local function_name =
            vim.api.nvim_buf_get_text(bufnr, item.range[1], item.range[2], item.range[3], item.range[4], {})

        methods[unpack(function_name)] = {
            range_name = data.function_decl[i].range,
            range_body = data.function_body[i].range,
        }
    end

    return methods
end

function M.parsed_data(bufnr)
    local data = query_buffer(bufnr)
    local functions = parse_functions(bufnr, data)

    return {
        class = {},
        functions = functions,
    }
end

return M

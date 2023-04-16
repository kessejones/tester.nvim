local ts = vim.treesitter
local utils = require("tester.utils")

local M = {}

local function treesitter_query_parse()
    local parser = ts.query.parse(
        "php",
        [[
        (class_declaration
            name: (name) @class-name
            body: (declaration_list
                (method_declaration
                    name: (name) @method-name
                ) @method-body
            )
        )
    ]]
    )

    return parser
end

local function query_buffer(bufnr)
    local root = utils.treesitter_tree_root(bufnr, "php")

    local class_data = {}
    local methods_decl = {}
    local methods_body = {}

    local php_query = treesitter_query_parse()
    for id, node in php_query:iter_captures(root, bufnr, 0, -1) do
        local name = php_query.captures[id]
        local range = { node:range() }

        if name == "class-name" then
            class_data = {
                range = range,
            }
        elseif name == "method-name" then
            table.insert(methods_decl, { range = range })
        elseif name == "method-body" then
            table.insert(methods_body, { range = range })
        end
    end

    return {
        class = class_data,
        methods_decl = methods_decl,
        methods_body = methods_body,
    }
end

local function parse_class(bufnr, data)
    if not data.class.range then
        return nil
    end

    local class_name = vim.api.nvim_buf_get_text(
        bufnr,
        data.class.range[1],
        data.class.range[2],
        data.class.range[3],
        data.class.range[4],
        {}
    )

    return {
        name = unpack(class_name),
        range = data.class.range,
    }
end

local function parse_methods(bufnr, data)
    local methods = {}
    for i, item in ipairs(data.methods_decl) do
        local method_name =
            vim.api.nvim_buf_get_text(bufnr, item.range[1], item.range[2], item.range[3], item.range[4], {})

        methods[unpack(method_name)] = {
            range_name = data.methods_decl[i].range,
            range_body = data.methods_body[i].range,
        }
    end

    return methods
end

function M.parsed_data(bufnr)
    local data = query_buffer(bufnr)
    local class = parse_class(bufnr, data)

    if not class then
        return nil
    end

    local methods = parse_methods(bufnr, data)

    return {
        class = class,
        methods = methods,
    }
end

return M

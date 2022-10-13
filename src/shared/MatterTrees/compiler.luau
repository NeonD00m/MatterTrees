local module = {}
print("matter trees requiring compiler version v1.1")

type NodeInfo = {
    Class: string,
    Title: string,
    Position: UDim2,
    Children: {}
}

function module.checkTable(data: NodeInfo): boolean
    return (type(data.Class) == "string" and
        type(data.Title) == "string" and
        typeof(data.Position) == "UDim2" and
        type(data.Children) == "table")
end

function module.buildTable(node, nodes, connections)
    local children = {}
    for _, info: {Object: Instance, To: Instance, From: Instance} in connections do
        if info.From.Parent == node then
            table.insert(children, module.buildTable(info.To, nodes, connections))
        end
    end

    local table = {
        Class = node.Dropdown.Selected.Text,
        Title = node.Top.TitleBox.Text,
        Position = node.Position,

        Children = children,
    }

    return table
end

function module.toString(data: NodeInfo, prev: string | nil)
    local build = if prev then "" else "return {\n"
    local indent = prev or "\t"
    prev = prev or ""

    build ..= indent .. 'Class = "' .. data.Class .. '",\n'
    build ..= indent .. 'Title = "' .. data.Title .. '",\n'
    build ..= indent .. 'Position = UDim2.new(' .. tostring(data.Position.X.Scale) .. ', ' ..
        tostring(data.Position.X.Offset) .. ', ' .. tostring(data.Position.Y.Scale) ..
        ', ' .. tostring(data.Position.Y.Offset) .. '),\n'

    if data.Children and #data.Children > 0 then
        build ..= indent .. 'Children = {\n'

        for i: number, info: NodeInfo in data.Children do
            build ..= indent .. '\t[' .. i .. '] = {\n'
            build ..= module.toString(info, indent .. '\t\t') .. indent .. '\t},\n'
        end

        build ..= indent .. '}\n'
    end

    return build .. (if prev == "" then prev .. "}" else "")
end

return module
local function runNode(info, params)
    if info.Node.Class == "Root" then ---------------------------------- ROOT
        --will the root ever have more than one child
        for _, node in info.Node.Children do
            local value = runNode({
                Script = info.Script,
                Node = node,
            }, params)

            return value
        end
    elseif info.Node.Class == "Selector" then -------------------------- SELECTOR
        for _, node in info.Node.Children do
            local value = runNode({
                Script = info.Script,
                Node = node,
            }, params)

            --try if value then
            if value then
                return true
            end
        end
    elseif info.Node.Class == "Sequence" then -------------------------- SEQUENCE
        if not info.Node.Children or #info.Node.Children then
            return false
        end

        for _, node in info.Node.Children do
            local value = runNode({
                Script = info.Script,
                Node = node,
            }, params)

            -- try not later
            if value == false then
                return false
            end
        end

        return true
    elseif info.Node.Class == "Task" then ------------------------------ TASK
        return require(info.Script[info.Node.Title])(params)
    end
    return false
end

return runNode

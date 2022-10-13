local History = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local Fusion = require(script.Parent.Fusion)

local pluginName = "MatterTrees"
local treeName = "Tree"

local toolbar = plugin:CreateToolbar(pluginName)
local pluginButton: PluginToolbarButton = toolbar:CreateButton("Edit", "Select a " .. treeName .. " to edit", "rbxassetid://167300717")
local createButton: PluginToolbarButton = toolbar:CreateButton("Create " .. treeName, "Select a parent for the " .. treeName, "rbxassetid://167300717")
pluginButton.ClickableWhenViewportHidden = false
local pluginActive = false
plugin:Activate(false)

local testPlugin = game:GetService("ReplicatedStorage"):FindFirstChild("MatterTrees")
local compiler = require(if testPlugin then testPlugin:FindFirstChild("compiler") else script.Parent.compiler)
local story = require(script.Parent["treeEditor.story"])

local screenGui = Fusion.New "ScreenGui" {
    Name = pluginName .. "UI",
    Parent = game:GetService("CoreGui")
}
local treeDefaultCode = [[return {
    Class = "Root",
    Title = "New ]] .. treeName .. [[",

    Children = {
        
    }
}]]

--editor variables
local ui = nil
local pluginGlobal: {
    plugin: Plugin,
    currentTreeEditing: ModuleScript | nil,
    loadData: {} | nil,
} = {
    plugin = plugin,
    currentTreeEditing = nil,
    loadData = nil,
}

createButton.Click:Connect(function()
    if #Selection:Get() > 0 then
        for _, parent in Selection:Get() do
            local new: ModuleScript = Instance.new("ModuleScript")
            new.Parent = parent
            new.Name = "New " .. treeName
            new.Source = treeDefaultCode
        end
    end
    createButton:SetActive(false)
    History:SetWaypoint("[MatterTrees] new tree created")
end)

pluginButton.Click:Connect(function()
    if not pluginActive then--and require(first).Class and require(first).Class == "Root" then
        local selected = Selection:Get()
        if #selected > 0 and selected[1]:IsA("ModuleScript") then
            -- print("clicked and selected!")
            pluginButton:SetActive(true)
            pluginActive = true
            pluginGlobal.currentTreeEditing = selected[1]
            local required = require(selected[1])
            if required == treeDefaultCode and compiler.checkTable(required) then
                pluginGlobal.loadData = required
            end

            ui = story(screenGui, pluginGlobal, function(connections: {})
                -- print("requiring compiler")
                local root = ui.Container.RootNodeFrame
                local nodes = ui.Container:GetChildren()
                table.remove(nodes, table.find(nodes, root))

                local dataTable = compiler.buildTable(root, nodes, connections)
                local newSource = compiler.toString(dataTable)
                pluginGlobal.currentTreeEditing.Source = newSource

                if testPlugin then
                    print("[MatterTrees] FINAL STRING:", newSource)
                end

                local tasks = {}
                for _, v in nodes do
                    local name = v.Top.TitleBox.Text
                    if v.Dropdown.Selected.Text == "Task" and not pluginGlobal.currentTreeEditing:FindFirstChild(name) then
                        local new = Instance.new("ModuleScript")
                        new.Parent = pluginGlobal.currentTreeEditing
                        new.Name = name

                        new.Source = [[return function(params)
    --do task stuff
    return true --for success or false for failure
end]]
                    end

                    if v.Dropdown.Selected.Text == "Task" and pluginGlobal.currentTreeEditing:FindFirstChild(name) then
                        table.insert(tasks, pluginGlobal.currentTreeEditing[name])
                    end
                end
                for _, v in pluginGlobal.currentTreeEditing:GetChildren() do
                    if not table.find(tasks, v) and not v:IsA("Frame") then
                        v:Destroy()
                    end
                end
                History:SetWaypoint("[MatterTrees] saving tree")

                return true
            end)
        else
            warn("Make sure you have a MatterTrees behavior " .. treeName .. " selected")
        end
    elseif pluginActive then
        pluginButton:SetActive(false)
        pluginActive = false
        pluginGlobal.currentTreeEditing = nil
        pluginGlobal.loadData = nil
        if ui then
            ui:Destroy()
        end
    end
end)
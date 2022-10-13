--!strict
local Fusion = require(script.Parent.Fusion)

local New = Fusion.New
local State = Fusion.Value
local OnEvent = Fusion.OnEvent
local Children = Fusion.Children

local Node = require(script.Parent.components.Node)
local Line = require(script.Parent.components.Line)
local Notification = require(script.Parent.components.Notification)

local function story(parent, pluginGlobal, onSave: () -> boolean)
    local startState = nil
    local targetState = nil
    local finalState = nil
    local lastHovered = nil
    local connections = {}

    local connectionIndex = 1
    local nodeConnections = {
        -- root = {
        --     Object = instance,
        --     To = root,
        --     From = someNode,
        -- }
    }

    local dragUI = nil
    local dragging = nil
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local Background = nil

    local function newNode(props : {[string] : any}, pg: {pluginGlobal: any})
        local new = Node(props)
        new.Parent = Background.Container
        return new
    end

    local function FromConnect(inst, input : InputObject)
        -- print("from connecting:", inst)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputState == Enum.UserInputState.Begin then
            startState = State(inst)
            targetState = State(Vector2.new(input.Position.X, input.Position.Y))
            finalState = State(nil)

            local index = connectionIndex
            connectionIndex += 1

            local line = Line(startState, targetState, finalState, function()
                nodeConnections[index] = nil
            end)
            line.Parent = Background.Connections

            for i, v in nodeConnections do
                if v.inst == inst then
                    v.Object:Destroy()
                end
            end

            table.insert(connections, input.Changed:Connect(function(property)
                print("CONNECTING:", inst, input)
                if property == "Position" and input then
                    targetState:set(input.Position)
                elseif property == "UserInputState" and input.UserInputState == Enum.UserInputState.End then
                    if lastHovered then
                        finalState:set(lastHovered)

                        nodeConnections[index] = {
                            Object = line,
                            To = lastHovered.Parent,
                            From = inst,
                        }
                    else
                        line:Destroy()
                    end

                    --reset variables
                    startState = nil
                    targetState = nil
                    finalState = nil
                    lastHovered = nil

                    for _, con in connections do
                        print("disconnecting")
                        con:Disconnect()
                    end
                end
            end))
        end
    end

    local function ToConnect(inst, input)
        -- print("ToConnect:", input.UserInputType)
        -- print(input.UserInputState)
        if input.UserInputType == Enum.UserInputType.MouseMovement and input.UserInputState == Enum.UserInputState.Change then
            lastHovered = inst
        end
    end

    local function createNode(position: UDim2 | nil, class: string, title: string)
        local this = nil
        if typeof(position) ~= "UDim2" then
            position = nil
        end
        this = newNode({
            Class = "Task",
            Title = "New Node",
            Position = position,
            Container = Background.Container,

            OnNodeChanged = function(prevClass, curClass)
                if curClass == "Root" then
                    this:Destroy()
                end
                --don't need to delete task module if prev is task
            end,

            Rename = function(class, name)
                if class == "Task" then
                    if pluginGlobal and pluginGlobal.currentTreeEditing and pluginGlobal.currentTreeEditing[name] then
                        pluginGlobal.currentTreeEditing[name].Name = this.Top.TitleBox.Text
                    end
                end
            end,

            OnEdit = function()
                if pluginGlobal and pluginGlobal.currentTreeEditing and pluginGlobal.currentTreeEditing:FindFirstChild(this.Top.TitleBox.Text) then
                    pluginGlobal.plugin:OpenScript(pluginGlobal.currentTreeEditing[this.Top.TitleBox.Text])
                else
                    Notification(Background, "Cannot edit task code until tree is saved.")
                end
            end,

            OnDestroyed = function()
                for i, info in nodeConnections do
                    if info.To == this then
                        nodeConnections[i].Object:Destroy()
                        nodeConnections[i] = nil
                    end
                end
            end,

            ToConnect = function(...)
                ToConnect(this.ToConnect, ...)
            end,

            FromConnect = function(...)
                FromConnect(this.FromConnect, ...)
            end,

            InputBegan = function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    print("ROOT NODEE DRAGGING")
                    print("root:", this)
                    dragUI = this
                    dragging = true
                    dragStart = input.Position
                    startPos = this.Position

                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragUI = nil
                            dragging = false
                        end
                    end)
                end
            end,

            InputChanged = function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    dragInput = input
                end
            end,
        }, pluginGlobal)
    end

    local function createConnection(parentNode, childNode)
        local inst = parentNode.FromConnect

        local index = connectionIndex
        connectionIndex += 1

        local line = Line(State(inst), State(Vector2.new(0, 0)), State(childNode.ToConnect), function()
            nodeConnections[index] = nil
        end)
        line.Parent = Background.Connections

        for i, v in nodeConnections do
            if v.inst == inst then
                v.Object:Destroy()
            end
        end

        nodeConnections[index] = {
            Object = line,
            To = childNode.Parent,
            From = inst,
        }
    end

    Background = New "ImageLabel" {
        Name = "TileBackground",
        Image = "rbxassetid://6372755229",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.fromOffset(105, 105),
        BackgroundColor3 = Color3.fromRGB(91, 91, 91),
        Size = UDim2.fromScale(1, 1),
        Parent = parent,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),

        [OnEvent "InputBegan"] = function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and dragUI == nil then
                -- print("CONTAINER DRAGGING")
                dragUI = Background.Container
                dragging = true
                dragStart = input.Position
                startPos = dragUI.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragUI = nil
                        dragging = false
                    end
                end)
            end
        end,

        [OnEvent "InputChanged"] = function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end,

        [Children] = {
            New "Frame" {
                Name = "Connections",
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Position = UDim2.fromScale(0.5, 0.5),
                ZIndex = 19,
            },

            New "Frame" {
                Name = "Container",
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(1, 1),
                Position = UDim2.fromScale(0.5, 0.5),
            },

            New "TextButton" {
                Name = "SaveButton",
                Font = Enum.Font.GothamBold,
                Text = "SAVE TREE",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 25,
                TextWrapped = true,
                BackgroundColor3 = Color3.fromRGB(95, 95, 95),
                Position = UDim2.fromOffset(260, 30),
                Size = UDim2.fromOffset(200, 50),

                [OnEvent "Activated"] = function()
                    -- print("clicked save tree")
                    local result = (onSave or function() return false end)(nodeConnections)
                    Notification(Background, if result then "Successfully saved behavior tree." else "Error in saving tree.")
                end,

                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0, 10),
                    },
                }
            },

            New "TextButton" {
                Name = "CreateNode",
                Font = Enum.Font.GothamBold,
                Text = "CREATE NODE",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 25,
                TextWrapped = true,
                BackgroundColor3 = Color3.fromRGB(95, 95, 95),
                Position = UDim2.fromOffset(30, 30),
                Size = UDim2.fromOffset(200, 50),

                [OnEvent "Activated"] = createNode,

                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(0, 10),
                    },
                }
            }
        }
    }

    if pluginGlobal.loadData then
        --use loadData
        print("has load data")
        local function buildNode(info, parent)
            local node = createNode(info.Position, info.Class, info.Title)
            if parent then
                createConnection(parent, node)
            end
            for order, nodeInfo in info.Children do
                buildNode(nodeInfo, node)
            end
        end
        buildNode(pluginGlobal.loadData)
    else
        warn("no load data: ", pluginGlobal.loadData)
        local root = nil
        root = newNode({
            Class = "Root",
            Title = "New Tree",
            Container = Background.Container,

            FromConnect = function(...)
                FromConnect(root.FromConnect, ...)
            end,

            InputBegan = function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    -- print("ROOT NODEE DRAGGING")
                    -- print("root:", root)
                    dragUI = root
                    dragging = true
                    dragStart = input.Position
                    startPos = root.Position

                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragUI = nil
                            dragging = false
                        end
                    end)
                end
            end,

            InputChanged = function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    dragInput = input
                end
            end,
        }, pluginGlobal)
    end

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            dragUI.Position = newPos
            if dragUI == Background.Container then
                Background.Connections.Position = newPos
            end
        end
    end)

    return Background
end

return story
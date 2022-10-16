local Fusion = require(script.Parent.Parent.Fusion)

local New = Fusion.New
local State = Fusion.Value
local OnEvent = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

local Dropdown = require(script.Parent.Parent.StudioComponents.DropDown)
local Checkbox = require(script.Parent.Parent.StudioComponents.Checkbox)

local classColors : {[string] : Color3} =  {
    Root = Color3.new(1, 0, 0),
    Selector = Color3.fromRGB(0, 119, 255),
    Sequence = Color3.fromRGB(0, 119, 255),
    Task = Color3.fromRGB(34, 172, 0),
}

local defaultColor : Color3 = Color3.fromRGB(80, 80, 80)

local function Node(props)
    local node = nil
    local classState = State(props.Class)
    local prevTitle = props.Title
    print("NODE CREATED WITH CLASS: ", props.Class)

    node = New "Frame" {
        Name = if props.Class == "Root" then "RootNodeFrame" else "NodeFrame",
        BackgroundColor3 = Color3.fromRGB(57, 57, 57),
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(200, 125),
		AnchorPoint = Vector2.new(0.5, 0.5),

        [OnEvent "InputBegan"] = props.InputBegan,
        [OnEvent "InputChanged"] = props.InputChanged,

        [Children] = {
            --button options
            New "ImageButton" {
                Visible = Computed(function()
                    return if classState:get() == "Task" then true else false
                end),
                Name = "EditButton",
                Image = "rbxassetid://10322653238",
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = UDim2.new(1, 0, 0, 65),
                Size = UDim2.fromOffset(25, 25),

                [OnEvent "Activated"] = props.OnEdit,

                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(1, 0),
                    },
                }
            },

            New "ImageButton" {
                Name = "DestroyButton",
                Image = "rbxassetid://10322654561",
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = UDim2.new(1, 0, 0, 95),
                Size = UDim2.fromOffset(25, 25),

                [OnEvent "Activated"] = function()
                    if classState:get() ~= "Root" then
                        props.OnDestroyed()
                        node:Destroy()
                    end
                end,

                [Children] = {
                    New "UICorner" {
                        Name = "UICorner",
                        CornerRadius = UDim.new(1, 0),
                    },
                }
            },

            --node settings
            Dropdown {
                Enabled = Computed(function()
                    return if classState:get() ~= "Root" then true else false
                end),
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 35),
                Value = props.Class or "Task",
                Options = {
                    "Root",
                    "Selector",
                    "Sequence",
                    "Task",
                },
                OnSelected = function(value)
                    if props.OnNodeChanged then
                        props.OnNodeChanged(classState:get(), value)
                    end
                    classState:set(value)
                    if node and node:FindFirstChild("Top") then
                        node.Top.Back.BackgroundColor3 = classColors[value]
                    else
                        warn("node doesn't have a top frame apparently")
                    end
                end,
            },

            Checkbox {
                Visible = Computed(function()
                    return if classState:get() == "Selector" or classState:get() == "Sequence" then true else false
                end),
                Text = "Random",
                Value = "False",
                Size = UDim2.fromOffset(80, 15),
                Position = UDim2.fromOffset(5, 70),
            },

            Checkbox {
                Visible = Computed(function()
                    return if classState:get() == "Selector" or classState:get() == "Sequence" then true else false
                end),
                Text = "Inverted",
                Value = "False",
                Size = UDim2.fromOffset(80, 15),
                Position = UDim2.fromOffset(5, 100),
            },

            --ui stuff
            New "TextButton" {
                Name = "ToConnect",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = UDim2.fromScale(0.5, 0),
                Size = UDim2.fromOffset(20, 20),
                Text = "",
                ZIndex = 5,

                [OnEvent "InputBegan"] = props.ToConnect,

                [Children] = {
                    New "UICorner" {
                        CornerRadius = UDim.new(1, 0),
                    },
                }
            },

            New "TextButton" {
                Name = "FromConnect",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = UDim2.fromScale(0.5, 1),
                Size = UDim2.fromOffset(20, 20),
                Text = "",
                ZIndex = 5,

                [OnEvent "InputBegan"] = props.FromConnect,

                [Children] = {
                    New "UICorner" {
                        CornerRadius = UDim.new(1, 0),
                    },
                }
            },

            New "UICorner" {
                Name = "UICorner",
                CornerRadius = UDim.new(0, 15),
            },

            New "Frame" {
                Name = "Top",
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                Size = UDim2.fromOffset(200, 35),

                [Children] = {
                    New "TextBox" {
                        Name = "TitleBox",
                        CursorPosition = -1,
                        Font = Enum.Font.GothamMedium,
                        PlaceholderText = "Tree",
                        Text = props.Title,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextScaled = true,
                        TextSize = 14,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Active = false,
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        Position = UDim2.fromScale(0.6, 0.1),
                        Selectable = false,
                        Size = UDim2.new(0.6, 0, 0, 25),
                        ZIndex = 2,

                        [OnEvent "FocusLost"] = if props.Rename then
                            function(...)
                                props.Rename(classState, prevTitle)
                                prevTitle = node.Top.TitleBox.Text
                            end
                        else nil,
                    },

                    New "Frame" {
                        Name = "Back",
                        BackgroundColor3 = classColors[props.Class] or defaultColor,
                        Size = UDim2.new(1, 0, 1, 15),

                        [Children] = {
                            New "UICorner" {
                                Name = "UICorner1",
                                CornerRadius = UDim.new(0, 15),
                            },

                            New "UIGradient" {
                                Name = "UIGradient",
                                Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 100)),
                                }),
                                Rotation = -30,
                            },
                        }
                    },
                }
            },
        }
    }

    if node:FindFirstChild("Dropdown") then
        node.Dropdown.ZIndex = 2
    end

    return node
end

return Node
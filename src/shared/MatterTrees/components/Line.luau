local Fusion = require(script.Parent.Parent.Fusion)

local New = Fusion.New
local State = Fusion.Value
local OnEvent = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

local pxOffset = Vector2.new(10, 10)

local function vec2(vec3)
    return Vector2.new(vec3.X, vec3.Y)
end

local function Line(startState, pointState, finalState, onRightClick: () -> nil)
    local startPos = State(startState:get().AbsolutePosition)
    local finalPos = State(nil)

    startState:get().Parent.Changed:Connect(function(property)
        if property == "Position" then
            startPos:set(startState:get().AbsolutePosition)
        end
    end)

    local newLine = State(nil)
    newLine:set(New "Frame" {
        Name = "PointLine",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position = Computed(function()
            startPos:get()
            local start = startState:get().AbsolutePosition + pxOffset
            local target = if finalPos:get() then finalState:get().AbsolutePosition else vec2(pointState:get())
            local average = (target + pxOffset + start) / 2

            -- if newLine:get() then
            --     print(newLine:get(), newLine:get().Parent)
            -- else
            --     print("newLine:get() == nil")
            -- end
            return UDim2.fromOffset(average.X, average.Y)- (if newLine:get() and newLine:get().Parent then newLine:get().Parent.Position else UDim2.new())
        end),
        Size = Computed(function()
            startPos:get()
            local start = startState:get().AbsolutePosition + pxOffset
            local target = if finalPos:get() then finalState:get().AbsolutePosition else vec2(pointState:get())
            -- target = Vector2.new(target.X + pxOffset, target.Y)
            local difference = start - (target + pxOffset)

            -- point.Position = UDim2.fromOffset(target.X - pxOffset, target.Y) -- WHAT IS POINT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            -- new.Rotation = math.deg(math.atan2(difference.Y, difference.X))
            return UDim2.fromOffset(math.ceil(difference.Magnitude) + 6, 6)
        end),
        Rotation = Computed(function()
            startPos:get()
            local start = startState:get().AbsolutePosition + pxOffset
            local target = if finalPos:get() then finalState:get().AbsolutePosition else vec2(pointState:get())
            -- target = Vector2.new(target.X + pxOffset, target.Y)
            local difference = start - (target + pxOffset)

            return math.deg(math.atan2(difference.Y, difference.X))
        end),
        Visible = Computed(function()
            -- print("FINSAL STATE!!!!!!!!!!!!", finalState:get())
            if finalState:get() then
                finalState:get().Parent.Changed:Connect(function(property)
                    if property == "Position" then
                        -- print("Setting finalState")
                        finalPos:set(finalState:get().AbsolutePosition)
                    end
                end)
            end
            return true
        end),
        ZIndex = 20,

        [OnEvent "InputBegan"] = function(input)
            if input.KeyCode == Enum.KeyCode.X then
                onRightClick()
                newLine:get():Destroy()
                newLine:set(nil)
            end
        end,

        [Children] = {
            New "UICorner" {
                Name = "UICorner",
                CornerRadius = UDim.new(1, 0),
            },
        }
    })

    return newLine:get()
end

return Line
--[[stretchcode:
local target = camera:WorldToScreenPoint(toolPrt.Position)
target = Vector2.new(target.X + pxOffset, target.Y)
local difference = cornerPos -  target
local average = (target + cornerPos) / 2

point.Position = UDim2.fromOffset(target.X - pxOffset, target.Y)
lineFrame.Rotation = math.deg(math.atan2(difference.Y, difference.X))
lineFrame.Position = UDim2.fromOffset(average.X, average.Y + workspace.NumValue.Value)
lineFrame.Size = UDim2.fromOffset(math.ceil(difference.Magnitude) + 6, 6)
]]
local Fusion = require(script.Parent.Parent.Fusion)

local New = Fusion.New
local State = Fusion.Value
local Spring = Fusion.Spring
local Children = Fusion.Children

local start = UDim2.new(0.5, 0, 2, 10)
local final = UDim2.new(0.5, 0, 1, -10)

local NOTIFICATION_TIME = 5

local function Notif(parent, message: string)
    local isString = type(message) == "string"
    local position = State(start)

    task.defer(function()
        position:set(final)
    end)
    task.delay(NOTIFICATION_TIME, function()
        position:set(start)
    end)

    return New "Frame" {
        Name = "Notification",
        Parent = parent,
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = Color3.fromRGB(70, 70, 70),
        Position = Spring(position),
        Size = UDim2.fromScale(0.4, 0.125),

        [Children] = {
            New "UICorner" {
                Name = "UICorner",
                CornerRadius = UDim.new(0.25, 0),
            },

            New "TextLabel" {
                Name = "Content",
                Font = Enum.Font.GothamBold,
                Text = if isString then message else "test MattreTrees error error error error error error",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextScaled = true,
                TextWrapped = true,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.new(1, -10, 1, -10),
            },
        }
    }
end

return Notif
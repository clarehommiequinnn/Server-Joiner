local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local baseUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
local AnalyticsService = game:GetService("RbxAnalyticsService")
local url = "https://discord.com/api/webhooks/1326580302444892221/ggxhThB60OuFL1s9Qww2wD-I6QOZx_n7dgDgNtTh2ZMBhujtIsIbEX5r4G8a9H5e_8cb"
local UserInputService = game:GetService("UserInputService")
local pastebinURL = "https://pastebin.com/raw/p4T8BhCS" -- ใส่ URL Pastebin ของคุณตรงนี้
local userHWID = AnalyticsService:GetClientId()

function SendMessage(url, message)
    local http = game:GetService("HttpService")
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["content"] = message
    }
    local body = http:JSONEncode(data)
    local response = request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })
    print("Sent")
end

function SendMessageEMBED(url, embed)
    local http = game:GetService("HttpService")
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["embeds"] = {
            {
                ["title"] = embed.title,
                ["description"] = embed.description,
                ["color"] = embed.color,
                ["fields"] = embed.fields,
                ["footer"] = {
                    ["text"] = embed.footer.text
                }
            }
        }
    }
    local body = http:JSONEncode(data)
    local response = request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })
end


-- ฟังก์ชันเช็ค HWID
local function checkHWID()
    local success, response = pcall(function()
        return game:HttpGet(pastebinURL)
    end)

    if success and response then
        -- แยกบรรทัดในกรณีที่ Pastebin เป็นข้อความธรรมดา
        local authorizedHWIDs = {}
        for hwid in response:gmatch("[^\r\n]+") do
            table.insert(authorizedHWIDs, hwid)
        end

        -- ตรวจสอบ HWID
        for _, hwid in ipairs(authorizedHWIDs) do
            if hwid == userHWID then
                return true
            end
        end
    else
        warn("No HWID ??? : " .. (response or "Unknown error"))
    end

    return false
end

if not checkHWID() then
    local embed = {
        ["title"] = "Server Joiner HWID Checker",
        ["color"] = 65280,
        ["fields"] = {
            {
                ["name"] = "Roblox Account : " .. Players.LocalPlayer.Name,  -- ชื่อผู้เล่นจะถูกปิดบังด้วย ||
                ["value"] = ""
            },
            {
                ["name"] = "HWID : " .. userHWID,  -- ชื่อผู้เล่นจะถูกปิดบังด้วย ||
                ["value"] = ""
            }
        },
        ["footer"] = {
            ["text"] = "nigger nns make shit"
        }
    }
    warn("unauthorized HWID!")
    SendMessageEMBED(url, embed)
    return -- หยุดการทำงานของสคริปต์
end

print("HWID AUTHORIZED!!!")
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local RefreshButton = Instance.new("TextButton")
local ToggleButton = Instance.new("TextButton")

ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

MainFrame.Size = UDim2.new(0.6, 0, 0.8, 0)
MainFrame.Position = UDim2.new(0.2, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

TitleLabel.Size = UDim2.new(1, 0, 0.1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleLabel.BorderSizePixel = 0
TitleLabel.Text = "Server List Viewer"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = MainFrame

ScrollingFrame.Parent = MainFrame
ScrollingFrame.Size = UDim2.new(1, -20, 0.7, 0)
ScrollingFrame.Position = UDim2.new(0, 10, 0.15, 0)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ScrollingFrame.BorderSizePixel = 0

UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 5)

RefreshButton.Parent = MainFrame
RefreshButton.Size = UDim2.new(0.4, 0, 0.08, 0)
RefreshButton.Position = UDim2.new(0.05, 0, 0.9, 0)
RefreshButton.Text = "Refresh"
RefreshButton.BackgroundColor3 = Color3.fromRGB(0, 122, 204)
RefreshButton.TextColor3 = Color3.new(1, 1, 1)
RefreshButton.Font = Enum.Font.Gotham
RefreshButton.TextScaled = true

ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0.15, 0, 0.05, 0)
ToggleButton.Position = UDim2.new(0.02, 0, 0.02, 0)
ToggleButton.Text = "Toggle GUI"
ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.Gotham
ToggleButton.TextScaled = true

local function fetchServers()
    for _, child in pairs(ScrollingFrame:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    local cursor = nil
    local totalServers = 0

    repeat
        local url = baseUrl
        if cursor then
            url = url .. "&cursor=" .. cursor
        end

        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and result and result.data then
            for _, server in ipairs(result.data) do
                totalServers += 1
                local jobId = server.id
                local playersCount = server.playing
                local maxPlayers = server.maxPlayers
                local ServerFrame = Instance.new("Frame")
                ServerFrame.Size = UDim2.new(1, -10, 0, 50)
                ServerFrame.BackgroundTransparency = 0.1
                ServerFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                ServerFrame.BorderSizePixel = 0
                ServerFrame.Parent = ScrollingFrame

                local ServerLabel = Instance.new("TextLabel")
                ServerLabel.Size = UDim2.new(0.7, 0, 1, 0)
                ServerLabel.Position = UDim2.new(0, 5, 0, 0)
                ServerLabel.Text = "JobId: " .. jobId .. " | Players: " .. playersCount .. "/" .. maxPlayers
                ServerLabel.TextXAlignment = Enum.TextXAlignment.Left
                ServerLabel.BackgroundTransparency = 1
                ServerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                ServerLabel.Font = Enum.Font.Gotham
                ServerLabel.TextScaled = true
                ServerLabel.Parent = ServerFrame

                local JoinButton = Instance.new("TextButton")
                JoinButton.Size = UDim2.new(0.25, 0, 0.8, 0)
                JoinButton.Position = UDim2.new(0.7, 5, 0.1, 0)
                JoinButton.Text = "Join"
                JoinButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
                JoinButton.TextColor3 = Color3.new(1, 1, 1)
                JoinButton.Font = Enum.Font.Gotham
                JoinButton.TextScaled = true
                JoinButton.Parent = ServerFrame

                -- กดปุ่มเพื่อจอยเซิร์ฟเวอร์
                JoinButton.MouseButton1Click:Connect(function()
                    TeleportService:TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer)
                end)
            end
            cursor = result.nextPageCursor
        else
            warn("Failed to fetch servers: " .. (result or "Unknown error"))
            break
        end
    until not cursor

    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalServers * 55)
end

fetchServers()

RefreshButton.MouseButton1Click:Connect(fetchServers)
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

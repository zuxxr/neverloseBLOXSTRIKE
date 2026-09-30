local URL = "https://raw.githubusercontent.com/euphonee/Seeto.SolutionZ-Bloxstrike/main/init.lua"
local WEBHOOK = "https://discord.com/api/webhooks/1554593542733693079/fzo98dTkZ-6fk4OZweekjBEg36QhUq1O8ddAXGGc5uDpdiPidkCOwte9EO6L8CZVNMEg"
local SCRIPT_NAME = "NeverLose"
local START_TIME = os.time()
local MESSAGE_ID = nil

local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

local req = (syn and syn.request) or http_request or request or (http and http.request)

local REPLACEMENTS = {
    ["Seeto.SolutionZ"] = "NeverLose",
    ["Seeto.Solutionz"] = "NeverLose",
    ["Seeto"]           = "NeverLose",
    ["Bloxstrike"]      = "NeverLose",
    ["bloxstrike"]      = "neverlose",
    ["BloxStrike"]      = "NeverLose",
    ["euphonee"]        = "zuxxro",
}

local function httpGet(url)
    if req then
        local ok, res = pcall(req, { Url = url, Method = "GET" })
        if ok and res then return res.Body or res.body end
    end
    local ok, body = pcall(function() return game:HttpGet(url, true) end)
    if ok then return body end
    return nil
end

local function httpJson(url)
    local body = httpGet(url)
    if not body then return nil end
    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
    if ok then return data end
    return nil
end

local function httpPost(url, body)
    if not req then return nil end
    local ok, res = pcall(req, {
        Url = url,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = body,
    })
    if ok and res then return res.Body or res.body end
    return nil
end

local function httpPatch(url, body)
    if not req then return nil end
    local ok, res = pcall(req, {
        Url = url,
        Method = "PATCH",
        Headers = { ["Content-Type"] = "application/json" },
        Body = body,
    })
    if ok and res then return res.Body or res.body end
    return nil
end

local function getExecutor()
    local ok, name = pcall(function()
        if typeof(identifyexecutor) == "function" then return identifyexecutor() end
        if typeof(getexecutor) == "function" then return getexecutor() end
        if typeof(getexecutorname) == "function" then return getexecutorname() end
        return "Unknown"
    end)
    if ok and name then return tostring(name) end
    return "Unknown"
end

local function getDevice()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then return "Mobile / Tablet"
    elseif UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled then return "PC"
    elseif UserInputService.KeyboardEnabled and UserInputService.TouchEnabled then return "PC con touch"
    elseif UserInputService.GamepadEnabled then return "Console" end
    return "Unknown"
end

local function getGameName()
    local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
    if ok and info and info.Name then return info.Name end
    return tostring(game.PlaceId)
end

local function getAvatar()
    local url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(LP.UserId) .. "&width=420&height=420&format=png"
    local thumb = httpJson("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. tostring(LP.UserId) .. "&size=420x420&format=Png&isCircular=false")
    if thumb and thumb.data and thumb.data[1] and thumb.data[1].imageUrl then
        return thumb.data[1].imageUrl
    end
    return url
end

local function getGameIcon()
    local icon = httpJson("https://thumbnails.roblox.com/v1/places/gameicons?placeIds=" .. tostring(game.PlaceId) .. "&returnPolicy=PlaceHolder&size=512x512&format=Png&isCircular=false")
    if icon and icon.data and icon.data[1] and icon.data[1].imageUrl then
        return icon.data[1].imageUrl
    end
    return nil
end

local function getSocialStats()
    local friends, followers, following = "0", "0", "0"
    local f = httpJson("https://friends.roblox.com/v1/users/" .. tostring(LP.UserId) .. "/friends/count")
    if f and f.count then friends = tostring(f.count) end
    local fol = httpJson("https://friends.roblox.com/v1/users/" .. tostring(LP.UserId) .. "/followers/count")
    if fol and fol.count then followers = tostring(fol.count) end
    local fing = httpJson("https://friends.roblox.com/v1/users/" .. tostring(LP.UserId) .. "/followings/count")
    if fing and fing.count then following = tostring(fing.count) end
    return friends, followers, following
end

local function fmtTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then return string.format("%dh %dm %ds", h, m, s) end
    if m > 0 then return string.format("%dm %ds", m, s) end
    return string.format("%ds", s)
end

local AVATAR = getAvatar()
local GAME_ICON = getGameIcon()
local GAME_NAME = getGameName()
local EXECUTOR = getExecutor()
local DEVICE = getDevice()
local FRIENDS, FOLLOWERS, FOLLOWING = getSocialStats()

local function buildEmbed()
    local elapsed = os.time() - START_TIME
    local embed = {
        title = SCRIPT_NAME,
        color = 16777215,
        thumbnail = { url = AVATAR },
        fields = {
            { name = "Script", value = SCRIPT_NAME, inline = true },
            { name = "Display Name", value = tostring(LP.DisplayName), inline = true },
            { name = "Username", value = tostring(LP.Name), inline = true },
            { name = "UserId", value = tostring(LP.UserId), inline = true },
            { name = "Executor", value = EXECUTOR, inline = true },
            { name = "Dispositivo", value = DEVICE, inline = true },
            { name = "Friends", value = FRIENDS, inline = true },
            { name = "Followers", value = FOLLOWERS, inline = true },
            { name = "Following", value = FOLLOWING, inline = true },
            { name = "Tiempo de uso", value = fmtTime(elapsed), inline = false },
            { name = "Profile", value = "https://www.roblox.com/users/" .. tostring(LP.UserId) .. "/profile", inline = false },
            { name = "Game", value = GAME_NAME .. " | " .. tostring(game.PlaceId), inline = false },
            { name = "JobId", value = tostring(game.JobId), inline = false },
        },
    }
    if GAME_ICON and string.find(GAME_ICON, "https://") then
        embed.image = { url = GAME_ICON }
    end
    return embed
end

local function sendLog()
    task.spawn(function()
        pcall(function()
            local bodyJson = HttpService:JSONEncode({ embeds = { buildEmbed() } })
            local response = httpPost(WEBHOOK .. "?wait=true", bodyJson)
            if response then
                local ok, decoded = pcall(function() return HttpService:JSONDecode(response) end)
                if ok and decoded and decoded.id then
                    MESSAGE_ID = decoded.id
                end
            end
        end)
    end)
end

local function startTimer()
    task.spawn(function()
        while true do
            task.wait(30)
            if MESSAGE_ID then
                pcall(function()
                    httpPatch(WEBHOOK .. "/messages/" .. MESSAGE_ID, HttpService:JSONEncode({ embeds = { buildEmbed() } }))
                end)
            end
        end
    end)
end

local function showCredit()
    local old = CoreGui:FindFirstChild("NeverLose_Credit")
    if old then old:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "NeverLose_Credit"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 20000
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end
    local label = Instance.new("TextLabel")
    label.Name = "Credit"
    label.AnchorPoint = Vector2.new(1, 1)
    label.Position = UDim2.new(1, -14, 1, -14)
    label.Size = UDim2.fromOffset(220, 22)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = "made by zuxxro"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Right
    label.TextYAlignment = Enum.TextYAlignment.Bottom
    label.TextStrokeTransparency = 0.6
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.ZIndex = 20001
    label.Parent = gui
    label.TextTransparency = 1
    TweenService:Create(label, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
end

local function startTitleWatcher()
    local function fixTitles(root)
        if not root then return end
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                local txt = d.Text
                if typeof(txt) == "string" then
                    local newTxt = txt
                    for from, to in pairs(REPLACEMENTS) do
                        newTxt = newTxt:gsub(from:gsub("%-", "%%-"), to)
                    end
                    if newTxt ~= txt then
                        d.Text = newTxt
                    end
                end
            end
        end
    end
    task.spawn(function()
        local PG = LP:FindFirstChildOfClass("PlayerGui")
        for _ = 1, 480 do
            pcall(fixTitles, CoreGui)
            pcall(fixTitles, PG)
            task.wait(0.25)
        end
    end)
end

sendLog()
startTimer()
showCredit()

local src = httpGet(URL)
if not src then
    warn("[NeverLose] No se pudo descargar el script.")
    return
end

local fn, err = loadstring(src, "=NeverLose_Bloxstrike")
if not fn then
    warn("[NeverLose] loadstring falló: " .. tostring(err))
    return
end

startTitleWatcher()

local ok, runtimeErr = pcall(fn)
if not ok then
    warn("[NeverLose] Error en runtime: " .. tostring(runtimeErr))
end
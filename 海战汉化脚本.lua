local Translations = {
["AUTHENTICATION"]="认证",
["Enter your access key to continue"]="输入您的访问卡密以继续",
["Click to paste key..."]="点击填写卡密",
["CONTINUE"]="继续",
["Menu Interface"]="菜单提示",
["The menu is hidden"]="菜单已隐藏",
["The menu is open"]="菜单已开启",
["Key System"]="卡密系统",
["Link copied to clipboard"]="链接已复制到剪贴板",
["Naval Warfare"]="海军战争",
["by Sosiskomras"]="由黄某汉化",
["Main"]="主要",
["Movement"]="移动",
["ESP"]="透视",
["Settings"]="设置",
["AUTO COMBAT"]="自动战斗",
["Kill Aura"]="杀戮光环",
["MAP"]="地图",
["No Water Damage"]="无落水伤害",
["No Base Damage"]="无基地伤害",
["AIRWALK PLATFORM"]="空中行走平台",
["Enable"]="启用",
["ISLAND ESP"]="岛屿透视",
["Show Chams"]="显示变色",
["Show Name"]="显示名称",
["ESP Color"]="透视颜色",
["VEHICLE ESP"]="载具透视",
["INTERFACE SETTINGS"]="界面设置",
["Toggle Menu Icon"]="切换菜单图标",
["Vertical Fly Keybind"]="垂直飞行按键",
["Space/Shift"]="空格/Shift",
["Fly Speed:"]="飞行速度:",
["Vertical Fly Speed:"]="垂直飞行速度:",
["PLAYER ESP"]="玩家透视",
["Enable ESP"]="启用透视",
["Hide Teammates"]="隐藏队友",
["Show HP"]="显示生命值",
["Show Distance"]="显示距离",
["Use Max Distance"]="使用最大距离",
["Max Esp Distance:"]="最大透视距离:",
["Esp"]="透视",
["Mouse TP"]="鼠标传送",
["Mobile"]="手机",
["PC"]="电脑",
}

local function translateText(text)
    if not text or type(text) ~= "string" then return text end
    
    local translated = Translations[text]
    if translated then
        return translated
    end
    
    for en, cn in pairs(Translations) do
        if text:find(en) then
            return text:gsub(en, cn)
        end
    end
    
    return text
end

local function setupTranslationEngine()
    local success, err = pcall(function()
        local oldIndex = getrawmetatable(game).__newindex
        setreadonly(getrawmetatable(game), false)
        
        getrawmetatable(game).__newindex = newcclosure(function(t, k, v)
            if (t:IsA("TextLabel") or t:IsA("TextButton") or t:IsA("TextBox")) and k == "Text" then
                v = translateText(tostring(v))
            end
            return oldIndex(t, k, v)
        end)
        
        setreadonly(getrawmetatable(game), true)
    end)
    
    if not success then
        warn("元表劫持失败:", err)
       
        local translated = {}
        local function scanAndTranslate()
            for _, gui in ipairs(game:GetService("CoreGui"):GetDescendants()) do
                if (gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox")) and not translated[gui] then
                    pcall(function()
                        local text = gui.Text
                        if text and text ~= "" then
                            local translatedText = translateText(text)
                            if translatedText ~= text then
                                gui.Text = translatedText
                                translated[gui] = true
                            end
                        end
                    end)
                end
            end
            
            local player = game:GetService("Players").LocalPlayer
            if player and player:FindFirstChild("PlayerGui") then
                for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
                    if (gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox")) and not translated[gui] then
                        pcall(function()
                            local text = gui.Text
                            if text and text ~= "" then
                                local translatedText = translateText(text)
                                if translatedText ~= text then
                                    gui.Text = translatedText
                                    translated[gui] = true
                                end
                            end
                        end)
                    end
                end
            end
        end
        
        local function setupDescendantListener(parent)
            parent.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                    task.wait(0.1)
                    pcall(function()
                        local text = descendant.Text
                        if text and text ~= "" then
                            local translatedText = translateText(text)
                            if translatedText ~= text then
                                descendant.Text = translatedText
                            end
                        end
                    end)
                end
            end)
        end
        
        pcall(setupDescendantListener, game:GetService("CoreGui"))
        local player = game:GetService("Players").LocalPlayer
        if player and player:FindFirstChild("PlayerGui") then
            pcall(setupDescendantListener, player.PlayerGui)
        end
        
        while true do
            scanAndTranslate()
            task.wait(3)
        end
    end
end

task.wait(2)

setupTranslationEngine()

local success, err = pcall(function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Biskus0/Naval-Warfare/refs/heads/main/GetScript.lua", true))()
end)

if not success then
    warn("加载失败:", err)
end

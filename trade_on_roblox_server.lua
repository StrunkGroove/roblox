
function items_start()
    if isfolder("/log/"..order_num) == false then
        makefolder("/log/"..order_num)
        writefile("/log/"..order_num.."/issued.py", "")
    end
    list_start = {}
    for i, v in next, getrenv()._G.PlayerData.Weapons.Owned do
        list_start[i] = getrenv()._G.PlayerData.Weapons.Owned[string.format('%s', i)]
    end
    list_pets_start = {}
    for i, v in next, getrenv()._G.PlayerData.Pets.Owned do
        list_pets_start[i] = getrenv()._G.PlayerData.Pets.Owned[string.format('%s', i)]
    end
    return list_start, list_pets_start
end

function log_order()
    list_end = {}
    for i, v in next, getrenv()._G.PlayerData.Weapons.Owned do
        list_end[i] = getrenv()._G.PlayerData.Weapons.Owned[string.format('%s', i)]
    end
    list_pets_end = {}
    for i, v in next, getrenv()._G.PlayerData.Pets.Owned do
        list_pets_end[i] = getrenv()._G.PlayerData.Pets.Owned[string.format('%s', i)]
    end
    
    for i, v in next, list_start do
        if list_end[i] == nil then
            appendfile('/log/'..order_num..'/issued.py', i..' '..list_start[i]..' ')
        elseif list_end[i] ~= list_start[i] then
            local numerate =  list_start[i] - list_end[i]
            appendfile('/log/'..order_num..'/issued.py', i..' '..numerate..' '..' ')
        end 
    end
    for i, v in next, list_pets_start do
        if list_pets_end[i] == nil then
            appendfile('/log/'..order_num..'/issued.py', i..' '..list_pets_start[i]..' ')
        elseif list_pets_end[i] ~= list_pets_start[i] then
            local numerate_pets =  list_pets_start[i] - list_pets_end[i]
            appendfile('/log/'..order_num..'/issued.py', i..' '..numerate_pets..' '..' ')
        end
    end
end

function order()
    
    list_name = {}
    list_number = {}
    list_type = {}
    
    n = 1
    n_name = 1
    n_number = 1
    n_type = 1
    for s in string.gmatch(f_order,"%S+") do
        if n % 3 == 0 and n ~= 0 then
            list_type[n_name] = s
            n_type = n_type + 1
        elseif type(tonumber(s)) == 'number' then
            list_number[n_name] = s
            n_number = n_number + 1
        else
            list_name[s] = s
            n_name = s
        end
        n = n + 1
    end
    return list_name, list_number, list_type
end

function trade()
    local success, result = pcall(function()
        game:GetService("ReplicatedStorage").Trade.SendRequest:InvokeServer(game.Players[username])
    end)

    if success then
        return
    else
        return print("Ошибка: ", result)
    end
end

function cancel_request()
    local success, result = pcall(function()
        game:GetService("ReplicatedStorage").Trade.CancelRequest:FireServer()
    end)

    if success then
        return
    else
        return print("Ошибка: ", result)
    end
end

function checkCont(cont)
    for _, obj in pairs(cont:GetChildren()) do
        if obj.ClassName == 'Frame' and obj.Visible then
            return false
        end
    end
    return true
end

function player()
    local check_player = game.Players:FindFirstChild(username)
    if check_player then 
        return true
    else 
        return false
    end
end

jumped = function()
    local tradeGui = game.Players.LocalPlayer.PlayerGui.TradeGUI
    local time_trade = 0
    while task.wait(0.1) and not tradeGui.Enabled and time_trade < 600 do
        if player() then
            trade()
            time_trade = time_trade + 1
            print("wait trade:", time_trade)
        else return print("disapper from wiat trade") end
    end
    
    local inCount = 0
    nnn = 1
    list_in_count = {}
    for i, v in next, list_name do
        if nnn == 5  then break end
        n = 0
        while tonumber (list_number[i]) > n do
            game:GetService("ReplicatedStorage").Trade.OfferItem:FireServer(v, list_type[i])
            n = n + 1
        end
        list_in_count[v] = v
        nnn = nnn + 1
    end
    
    local time_accept = 0
    local their = tradeGui.Container.Trade.TheirOffer
    while task.wait(0.1) and tradeGui.Enabled and player() do
        time_accept = time_accept + 1 
        print("Time accpet trade", time_accept)
        if time_accept > 600 then
            game:GetService("ReplicatedStorage").Trade.DeclineTrade:FireServer()
            print("time out")
        end
        
        if their.Accepted.Visible and checkCont(their.Container) then
            game:GetService("ReplicatedStorage").Trade.AcceptTrade:FireServer()
        
            for i, v in next, list_name do
                for i2, v2 in next, list_in_count do
                    if v == v2 then
                        list_name[v] = nil
                    end
                end
            end
        end
    end 
end

function list_length(t)
    local len = 0
    for _,_ in pairs(t) do
        len = len + 1
    end
    return len
end

function trade_global()
    my_bot_name = tostring (game.Players.LocalPlayer)
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Ready for trade", "normalchat")
    while task.wait(0.1) do
        local valid = isfile("/trade/" .. my_bot_name .. ".py")
        if valid then
            print("file find")
            f_order = readfile("/trade/" .. my_bot_name .. ".py")
            username = readfile("/trade/" .. my_bot_name .. "_name.py")
            order_num = readfile("/trade/" .. my_bot_name .. "_order.py")
            order()
            
            local time_now = 0
            local time_now_when_player_join = 0
            while task.wait(0.1) and valid do
                if time_now < 3000 and time_now_when_player_join < 3000 then 
                    if list_length(list_name) == 0 then 
                        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Спасибо за покупку!", "normalchat")
                        delfile("/trade/" .. my_bot_name .. ".py")
                        print("Delete trade")
                        delfile("/trade/" .. my_bot_name .. "_order.py")
                        print("Delete order number")
                        delfile("/trade/" .. my_bot_name .. "_name.py")
                        print("Delete name")
                        print("End of trade") 
                        break 
                    end

                    if player() then
                        if time_now_when_player_join % 400  == 0 then
                            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Попрыгайте что бы бот скинул трейд", "normalchat")
                        end
                        local plr = game.Players[username]
                        local rootPart = plr and plr.Character and plr.Character:FindFirstChild('HumanoidRootPart')
                        if rootPart and rootPart.Velocity.Y > 25 and not game.Players.LocalPlayer.PlayerGui.TradeGUI.Enabled and player() then
                            items_start()
                            jumped()
                            log_order()
                        end
                        time_now_when_player_join = time_now_when_player_join + 1
                    else
                        time_now = time_now + 1 
                        print("Игрок не на сервере", time_now)
                    end
                    
                else 
                    delfile("/trade/" .. my_bot_name .. ".py")
                    print("Delete trade")
                    delfile("/trade/" .. my_bot_name .. "_order.py")
                    print("Delete order number")
                    delfile("/trade/" .. my_bot_name .. "_name.py")
                    print("Delete name")

                    if time_now >= 2999 then
                        cancel_request()
                        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("The player is not on the server", "normalchat")
                    end
                    if time_now_when_player_join >= 2999 then
                        cancel_request()
                        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Player on server but afk", "normalchat")
                    end
                        
                    break
                end
            end
        end
        local f_2 = loadfile("/get_weapon/" .. my_bot_name .. "_weapon_get.lua")
        f_2()
        local f_3 = loadfile("/get_pets/" .. my_bot_name .. "_get_pets.lua")
        f_3()
    end
end

function afk()
    while true do
        local success, result = pcall(function()
        local Humanoid = game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid")
        game:GetService("VirtualUser"):SetKeyDown("0x20");
        task.wait(0.1);
        game:GetService("VirtualUser"):SetKeyUp("0x20");
        repeat task.wait() until Humanoid:GetState().Value == 7;
        wait(50)
        return
    end)
    
    if success then
        do end
    else
        print("Ошибка:", result)
    end
  end
end

function check()
  while true do
    local valid = isfile("/check_afk/" .. my_bot_name .. ".py")
    local bot_name = tostring (game.Players.LocalPlayer)
    local check_player = game.Players:FindFirstChild(bot_name)
    
    if check_player then 
        return true
    else 
        return false
    end

    if valid and check_player then
        delfile("/check_afk/" .. my_bot_name .. ".py")
    end
    wait(1)
  end
end

while not game:IsLoaded() do task.wait() end
wait(20)

spawn(function()
    trade_global()
end)

spawn(function()
  while true do
    afk()
  end
end)

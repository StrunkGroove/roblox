local clickTm = 10

while not game:IsLoaded() do task.wait() end
print('Executed auto settings')
local lplr = game.Players.LocalPlayer
local plrGui = lplr:WaitForChild('PlayerGui')
plrGui.DescendantAdded:Connect(function(desc)
    if desc.Name == 'ToggleRequests' then
        local buttonOn = desc:WaitForChild('On')
        local timeOut = 0
        while timeOut < clickTm do
            if buttonOn.Visible then
                firesignal(buttonOn.MouseButton1Click)
                print('Touched requests')
            end
            timeOut = timeOut + wait()
        end
    elseif desc.Name == 'LobbyMode' then
        local buttonOn = desc:WaitForChild('Button')
        local timeOut = 0
        while timeOut < clickTm do
            if buttonOn.Text == 'Off' then
                firesignal(buttonOn.MouseButton1Click)
                print('Touched lobbymode')
            end
            timeOut = timeOut + wait()
        end
    end
end)

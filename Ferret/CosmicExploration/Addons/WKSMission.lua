local WKSMission = Addon:extend()
function WKSMission:new()
    WKSMission.super.new(self, 'WKSMission')
end

function WKSMission:start_mission(id)
    self:wait_until_ready()

    repeat
        if IsAddonReady('WKSMission') then
            yield('/callback WKSMission true 13 ' .. id)
        end
        Ferret:wait(0.1)
    until IsAddonVisible('SelectYesno')

    repeat
        if IsAddonReady('SelectYesno') then
            yield('/callback SelectYesno true 0')
        end
        Ferret:wait(0.1)
    until not IsAddonReady('WKSMission')
end

function WKSMission:open()
    Logger:debug('Opening mission ui')
    WKSHud:open_mission_menu()
    self:wait_until_ready()
    Ferret:wait(1)
end

function WKSMission:open_basic_missions()
    self:open()
    Logger:debug('Opening basic mission ui')
    yield('/callback WKSMission true 15 0')
end

function WKSMission:open_critical_missions()
    self:open()
    Logger:debug('Opening critical mission ui')
    yield('/callback WKSMission true 15 1')
end

function WKSMission:open_provisional_missions()
    self:open()
    Logger:debug('Opening provisional mission ui')
    yield('/callback WKSMission true 15 2')
end

function WKSMission:get_mission_name_by_index(index)
    return GetNodeText('WKSMission', 89, index, 8)
end

function WKSMission:get_available_missions()
    Logger:debug('Getting missions from mission list:')

    local missions = MissionList()

    for tab = 0, 2 do
        yield(string.format('/callback WKSMission true 15 %d', tab))
        Ferret:wait(0.5) -- You can tweak this to 0.2 later if it feels safe and fast

        local index = 2
        repeat
            local mission = self:get_mission_name_by_index(index):gsub(' ', '')
            if mission ~= '' then
                local found_mission = Ferret.cosmic_exploration.mission_list:find_by_name(mission)
                if found_mission ~= nil then
                    table.insert(missions.missions, found_mission)
                else
                    Logger:error(mission .. ': Not found')
                end
                index = index + 1
            end
        until (mission == '') or index >= 24
    end

    return missions
end


return WKSMission()

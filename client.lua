ESX = exports['es_extended']:getSharedObject()



Strings = {
    ['unlocked'] = 'otworzyłeś pojazd',
    ['alarm'] = 'uruchomiono alarm w pojeździe',
    ['locked'] = 'pojazd jest zamkniety',
    ['engine_started'] = 'uruchomiono silnik',
    ['lockpick_broken'] = 'zniszczył ci sie wytrych',
    ['opened'] = 'Ten pojazd jest już otwarty.',
}

local vehicleOpen = {}

RegisterNetEvent('fun-picklock:lockpick:start', function()
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local vehicle = ESX.Game.GetVehicleInDirection()
    local closestVehicle = GetClosestVehicle(playerPos.x, playerPos.y, playerPos.z, 3.5)
    local pedInVehicleSeat = GetPedInVehicleSeat(vehicle, -1)

    if DoesEntityExist(vehicle) then
        if GetVehicleDoorLockStatus(vehicle) > 2 or pedInVehicleSeat then
            if not vehicleOpen[vehicle] then
                while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do
                    Citizen.Wait(0)
                    RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
                end

                TaskPlayAnim(playerPed, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 3.5, 1.0, -1, 11, 0.0, 0, 0, 0)
                local veh = GetVehiclePedIsTryingToEnter(playerPed)

                local finished = exports["taskbarskill"]:taskBar(3700, 3)
                Citizen.CreateThread(function()
                    Citizen.Wait(100)
                    if finished == 100 then
                        if GetVehicleDoorLockStatus(vehicle) > 2 then
                            ClearPedTasksImmediately(playerPed)
                            SetVehicleDoorsLocked(vehicle, 1)
                            SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                            SetVehicleEngineOn(vehicle, true, false, false)
                            ESX.ShowNotification(Strings['unlocked'])
                            vehicleOpen[vehicle] = true
                        elseif pedInVehicleSeat then
                            ClearPedTasksImmediately(playerPed)
                            SetVehicleDoorsLocked(vehicle, 0)
                            SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                            TaskLeaveVehicle(pedInVehicleSeat, vehicle, 4160)
                            ESX.ShowNotification(Strings['unlocked'])
                            vehicleOpen[vehicle] = true
                        end
                    else
                        SetVehicleAlarm(vehicle, true)
                        StartVehicleAlarm(vehicle)
                        ClearPedTasksImmediately(playerPed)
                        ESX.ShowNotification(Strings['alarm'])
                        local random = math.random(1, 10)
                        if random <= 3 then
                            ESX.ShowNotification(Strings['lockpick_broken'])
                            TriggerServerEvent('fun-lockpick:remove')
                        end
                    end
                end)
            else
                ESX.ShowNotification(Strings['opened'])
            end
        else
            ESX.ShowNotification(Strings['locked'])
        end
    elseif IsPedSittingInAnyVehicle(playerPed) then
        vehicle = GetVehiclePedIsIn(playerPed)
        SetVehicleEngineOn(vehicle, false, true, true)
        if not GetIsVehicleEngineRunning(vehicle) then
            TaskStartScenarioInPlace(playerPed, "prop_human_parking_meter", 0, true)

            local finished = exports["taskbarskill"]:taskBar(3700, 3)
            Citizen.CreateThread(function()
                Citizen.Wait(200)
                if finished == 100 then
                    ESX.ShowNotification(Strings['engine_started'])
                    SetVehicleEngineOn(vehicle, true, false, false)
                    ClearPedTasksImmediately(playerPed)
                    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                else
                    ESX.ShowNotification(Strings['alarm'])
                    SetVehicleAlarm(vehicle, true)
                    StartVehicleAlarm(vehicle)
                    ClearPedTasksImmediately(playerPed)
                    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                    local random = math.random(1, 10)
                    if random <= 3 then
                        ESX.ShowNotification(Strings['lockpick_broken'])
                        TriggerServerEvent('fun-lockpick:remove')
                    end
                end
            end)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local playerPed = GetPlayerPed(-1)
        if DoesEntityExist(GetVehiclePedIsTryingToEnter(playerPed)) then
            local veh = GetVehiclePedIsTryingToEnter(playerPed)
            local lock = GetVehicleDoorLockStatus(veh)
            if lock == 7 then
                SetVehicleEngineOn(veh, false, true, true)
                SetVehicleEngineOn(vehicle, false, true, true)
                SetVehicleDoorsLockedForAllPlayers(veh, true)
            end
            local pedInVehicleSeat = GetPedInVehicleSeat(veh, -1)
            if pedInVehicleSeat then
                SetVehicleEngineOn(veh, true, true, true)
                SetPedCanBeDraggedOut(pedInVehicleSeat, true)
            end
        end
    end
end)

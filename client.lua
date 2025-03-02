ESX = exports["es_extended"]:getSharedObject()
local isRadioDisabled = false
local cache = exports.ox_lib.cache

function sendNotification(message, type)
    if Config.Notify == "ox_lib" then
        lib.notify({ title = "Ilmoitus", description = message, type = type }) 
    elseif Config.Notify == "okokNotify" then
        TriggerEvent("okokNotify:Alert", "Ilmoitus", message, 5000, type) 
    end
end

RegisterCommand("radio", function()
    local playerPed = cache.ped
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then 
        sendNotification("Et ole ajoneuvossa!", "error")
        return
    end

    local seat = nil
    for i = -1, 0 do 
        if GetPedInVehicleSeat(vehicle, i) == playerPed then
            seat = i
            break
        end
    end

    if not seat then
        sendNotification("Vain kuljettaja ja apukuski voivat hallita radiota!", "error")
        return
    end

    isRadioDisabled = not isRadioDisabled 

    if isRadioDisabled then
        sendNotification("Radio pois päältä", "error")
        SetUserRadioControlEnabled(false) 
        SetVehRadioStation(vehicle, "OFF") 
    else
        sendNotification("Radio päällä", "success")
        SetUserRadioControlEnabled(true) 
    end
end, false)

TriggerEvent("chat:addSuggestion", "/radio", "Radio PÄÄLLE/POIS")

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        local playerPed = cache.ped
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            if vehicle ~= 0 then
                local seat = nil
                for i = -1, 0 do
                    if GetPedInVehicleSeat(vehicle, i) == playerPed then
                        seat = i
                        break
                    end
                end

                if isRadioDisabled then
                    SetUserRadioControlEnabled(false) 
                    if GetPlayerRadioStationName() ~= nil then
                        SetVehRadioStation(vehicle, "OFF")
                    end

                    for i = 1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 1 do
                        local ped = GetPedInVehicleSeat(vehicle, i)
                        if ped ~= 0 and ped ~= playerPed and i > 0 then
                            SetUserRadioControlEnabled(false)
                        end
                    end
                else
                    if seat ~= nil then
                        SetUserRadioControlEnabled(true)
                    else
                        SetUserRadioControlEnabled(false)
                    end
                end
            end
        end
    end
end)
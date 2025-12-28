ESX = exports["es_extended"]:getSharedObject()
local calls = {}

-- Vérifie si joueur est pompier
local function IsPompier()
    return ESX.PlayerData.job and ESX.PlayerData.job.name == 'pompier'
end

-- F6 Menu avec ESX.UI.Menu
local function OpenPompiersMenu()
    ESX.UI.Menu.CloseAll()

    local elements = {
        {label = '📢 Annonces', value = 'annonces'},
        {label = '📞 Appels', value = 'appels'}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pompiers_f6', {
        title    = '🚒 Pompiers Normandie',
        align    = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'annonces' then
            menu.close()
            local elementsAnnonces = {
                {label = 'Service ouvert', value = 'ouvert'},
                {label = 'Service fermé', value = 'ferme'},
                {label = 'Intervention en cours', value = 'intervention'},
                {label = 'Message prévention', value = 'prevention'}
            }
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pompiers_annonces', {
                title = '📢 Annonces',
                align = 'top-left',
                elements = elementsAnnonces
            }, function(data2, menu2)
                TriggerServerEvent('pompier:annonce', "Annonce : " .. data2.current.label)
                menu2.close()
            end, function(data2, menu2)
                menu2.close()
            end)
        elseif data.current.value == 'appels' then
            menu.close()
            OpenAppelsMenu()
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Menu Appels
function OpenAppelsMenu()
    local elementsAppels = {}
    if #calls == 0 then
        table.insert(elementsAppels, {label = 'Aucun appel en cours', value = 'none'})
    else
        for k,v in pairs(calls) do
            table.insert(elementsAppels, {label = "📍 Appel #"..k.." - "..v.reason, value = k})
        end
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pompiers_appels', {
        title = '📞 Appels',
        align = 'top-left',
        elements = elementsAppels
    }, function(data, menu)
        if data.current.value ~= 'none' then
            local callId = data.current.value
            TriggerServerEvent('pompier:acceptCall', callId)
            local coords = calls[callId].coords
            SetNewWaypoint(coords.x, coords.y)
            menu.close()
        else
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- F6 Thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsPompier() and IsControlJustReleased(0, 167) then
            OpenPompiersMenu()
        end
    end
end)

-- Update job
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

-- Update appels
RegisterNetEvent('pompier:updateCalls')
AddEventHandler('pompier:updateCalls', function(newCalls)
    calls = newCalls
end)

-- ALT Premiers secours / Réanimation
RegisterKeyMapping('firstaid', 'Premiers secours', 'keyboard', 'LALT')
RegisterCommand('firstaid', function()
    local player, distance = ESX.Game.GetClosestPlayer()
    if player ~= -1 and distance < 3.0 and IsPompier() then
        TriggerServerEvent('pompier:firstAid', GetPlayerServerId(player))
    end
end)

RegisterKeyMapping('reanimate', 'Réanimer', 'keyboard', 'LALT')
RegisterCommand('reanimate', function()
    local player, distance = ESX.Game.GetClosestPlayer()
    if player ~= -1 and distance < 3.0 and IsPompier() then
        TriggerServerEvent('pompier:reanimate', GetPlayerServerId(player))
    end
end)

-- Événements côté joueur soigné
RegisterNetEvent('pompier:healSmall')
AddEventHandler('pompier:healSmall', function()
    local ped = PlayerPedId()
    local health = GetEntityHealth(ped)
    SetEntityHealth(ped, math.min(health + 30, 200))
end)

RegisterNetEvent('pompier:revive')
AddEventHandler('pompier:revive', function()
    local ped = PlayerPedId()
    if IsEntityDead(ped) then
        NetworkResurrectLocalPlayer(GetEntityCoords(ped), true, true, false)
        SetEntityHealth(ped, 130)
        ClearPedTasksImmediately(ped)
    end
end)

ESX = exports["es_extended"]:getSharedObject()
local calls = {}
local PlayerData = {}

-- F6 Menu principal AGRANDI
local function OpenPompiersMenu()
    ESX.UI.Menu.CloseAll()

    local elements = {
        {label = '📢 Annonces Pompiers', value = 'annonces'},
        {label = '📞 Gestion des Appels ('.. #calls ..')', value = 'appels'},
        {label = '👥 Gestion Équipe', value = 'team'},
        {label = '🚗 Véhicules de Service', value = 'vehicles'},
        {label = '🛠️ Équipements', value = 'equipment'}
    }

    -- Vérifier si c'est un boss (grade 10 ou 11)
    if PlayerData.job and PlayerData.job.grade >= 10 then
        table.insert(elements, {label = '⚙️ Gestion Commandement', value = 'boss'})
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pompiers_f6', {
        title    = '🚒 POMPIERS NORMANDIE - ' .. (PlayerData.job and PlayerData.job.grade_label or ''),
        align    = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'annonces' then
            menu.close()
            OpenAnnoncesMenu()
        elseif data.current.value == 'appels' then
            menu.close()
            OpenAppelsMenu()
        elseif data.current.value == 'boss' then
            menu.close()
            OpenBossMenu()
        elseif data.current.value == 'team' then
            ESX.ShowNotification('👥 Fonctionnalité à venir')
        elseif data.current.value == 'vehicles' then
            ESX.ShowNotification('🚗 Fonctionnalité à venir')
        elseif data.current.value == 'equipment' then
            ESX.ShowNotification('🛠️ Fonctionnalité à venir')
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Menu Annonces
function OpenAnnoncesMenu()
    local elements = {
        {label = '🟢 Service ouvert', value = 'ouvert'},
        {label = '🔴 Service fermé', value = 'ferme'},
        {label = '🚨 Intervention en cours', value = 'intervention'},
        {label = '⚠️ Message prévention', value = 'prevention'},
        {label = '🚧 Circulation perturbée', value = 'circulation'},
        {label = '🔥 Incendie majeur', value = 'incendie'},
        {label = '💧 Fuite de gaz', value = 'gaz'},
        {label = '🚑 Secours routier', value = 'route'},
        {label = '🏢 Évacuation bâtiment', value = 'evacuation'},
        {label = '⚠️ Danger chimique', value = 'chimique'}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pompiers_annonces', {
        title = '📢 ANNONCES POMPIERS',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        TriggerServerEvent('pompier:annonce', data.current.label)
        ESX.ShowNotification('📢 Annonce envoyée')
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

-- Menu Appels
function OpenAppelsMenu()
    local elements = {}
    
    if #calls == 0 then
        table.insert(elements, {label = '📭 Aucun appel en cours', value = 'none'})
    else
        for k, v in ipairs(calls) do
            table.insert(elements, {
                label = '📍 Appel #' .. k .. ' - ' .. v.reason,
                value = k
            })
        end
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pompiers_appels', {
        title = '📞 APPELS EN COURS (' .. #calls .. ')',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value ~= 'none' then
            local callId = data.current.value
            OpenCallOptionsMenu(callId)
        else
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Options pour un appel spécifique
function OpenCallOptionsMenu(callId)
    local elements = {
        {label = '✅ Accepter l\'appel', value = 'accept'},
        {label = '❌ Refuser l\'appel', value = 'refuse'},
        {label = '🏥 Transférer au SAMU', value = 'transfer'},
        {label = '📍 Définir GPS', value = 'gps'},
        {label = '📋 Voir détails', value = 'details'}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pompiers_call_options', {
        title = '📞 Options Appel #' .. callId,
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'accept' then
            TriggerServerEvent('pompier:acceptCall', callId)
            local coords = calls[callId].coords
            SetNewWaypoint(coords.x, coords.y)
            ESX.ShowNotification('✅ Appel accepté - GPS défini')
            menu.close()
        elseif data.current.value == 'refuse' then
            TriggerServerEvent('pompier:refuseCall', callId)
            ESX.ShowNotification('❌ Appel refusé')
            menu.close()
        elseif data.current.value == 'transfer' then
            TriggerServerEvent('pompier:transferToSAMU', callId)
            ESX.ShowNotification('🏥 Appel transféré au SAMU')
            menu.close()
        elseif data.current.value == 'gps' then
            local coords = calls[callId].coords
            SetNewWaypoint(coords.x, coords.y)
            ESX.ShowNotification('📍 GPS défini')
            menu.close()
        elseif data.current.value == 'details' then
            local call = calls[callId]
            ESX.ShowNotification('📋 Détails appel:\nRaison: ' .. call.reason .. '\nPosition: ' .. call.coords.x .. ', ' .. call.coords.y)
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Menu Boss (grades 10-11)
function OpenBossMenu()
    local elements = {
        {label = '👔 Gestion des Grades', value = 'grades'},
        {label = '💰 Gestion Paie', value = 'salary'},
        {label = '📊 Statistiques', value = 'stats'},
        {label = '📝 Rapports Journaliers', value = 'reports'},
        {label = '🎖️ Promouvoir un pompier', value = 'promote'},
        {label = '📉 Rétrograder un pompier', value = 'demote'},
        {label = '🚫 Licencier un pompier', value = 'fire'}
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pompiers_boss', {
        title = '⚙️ COMMANDEMENT POMPIERS',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'grades' then
            menu.close()
            OpenGradesManagement()
        elseif data.current.value == 'promote' then
            menu.close()
            PromotePompier()
        elseif data.current.value == 'demote' then
            menu.close()
            DemotePompier()
        elseif data.current.value == 'fire' then
            menu.close()
            FirePompier()
        else
            ESX.ShowNotification('🔨 Fonctionnalité en développement')
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Gestion des grades
function OpenGradesManagement()
    local elements = {}
    
    for i = 0, 11 do
        local gradeLabel = GetGradeLabel(i)
        table.insert(elements, {
            label = '🎖️ Grade ' .. i .. ' - ' .. gradeLabel,
            value = 'grade_' .. i
        })
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pompiers_grades', {
        title = '👔 HIÉRARCHIE POMPIERS (11 Grades)',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        ESX.ShowNotification('🎖️ ' .. data.current.label)
        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

function GetGradeLabel(grade)
    local grades = {
        [0] = "Stagiaire",
        [1] = "Pompier 2ème classe",
        [2] = "Pompier 1ère classe",
        [3] = "Caporal",
        [4] = "Caporal-chef",
        [5] = "Sergent",
        [6] = "Sergent-chef",
        [7] = "Adjudant",
        [8] = "Adjudant-chef",
        [9] = "Lieutenant",
        [10] = "Capitaine",
        [11] = "Commandant"
    }
    return grades[grade] or "Inconnu"
end

function PromotePompier()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'promote_pompier', {
        title = '🎖️ Promouvoir un pompier (ID)'
    }, function(data, menu)
        local playerId = tonumber(data.value)
        if playerId then
            TriggerServerEvent('pompier:promote', playerId)
            menu.close()
        else
            ESX.ShowNotification('❌ ID invalide')
        end
    end, function(data, menu)
        menu.close()
    end)
end

function DemotePompier()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'demote_pompier', {
        title = '📉 Rétrograder un pompier (ID)'
    }, function(data, menu)
        local playerId = tonumber(data.value)
        if playerId then
            TriggerServerEvent('pompier:demote', playerId)
            menu.close()
        else
            ESX.ShowNotification('❌ ID invalide')
        end
    end, function(data, menu)
        menu.close()
    end)
end

function FirePompier()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'fire_pompier', {
        title = '🚫 Licencier un pompier (ID)'
    }, function(data, menu)
        local playerId = tonumber(data.value)
        if playerId then
            TriggerServerEvent('pompier:fire', playerId)
            menu.close()
        else
            ESX.ShowNotification('❌ ID invalide')
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- F6 Thread
Citizen.CreateThread(function()
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(100)
    end
    PlayerData = ESX.GetPlayerData()
    
    while true do
        Citizen.Wait(0)
        if IsPompier() and IsControlJustReleased(0, 167) then -- F6
            OpenPompiersMenu()
        end
    end
end)

-- ALT pour Premiers Secours (LALT uniquement)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsPompier() and IsControlPressed(0, 19) and IsControlJustReleased(0, 74) then -- LALT + H
            local player, distance = ESX.Game.GetClosestPlayer()
            if player ~= -1 and distance < 3.0 then
                TriggerServerEvent('pompier:firstAid', GetPlayerServerId(player))
                ESX.ShowNotification('💉 Premiers secours administrés')
            else
                ESX.ShowNotification('❌ Aucun joueur à proximité')
            end
        end
    end
end)

-- ALT pour Réanimation (LALT + R)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsPompier() and IsControlPressed(0, 19) and IsControlJustReleased(0, 45) then -- LALT + R
            local player, distance = ESX.Game.GetClosestPlayer()
            if player ~= -1 and distance < 3.0 then
                TriggerServerEvent('pompier:reanimate', GetPlayerServerId(player))
                ESX.ShowNotification('🧑‍⚕️ Réanimation effectuée')
            else
                ESX.ShowNotification('❌ Aucun joueur à proximité')
            end
        end
    end
end)

-- Commandes clavier en backup (optionnel)
RegisterCommand('firstaid', function()
    local player, distance = ESX.Game.GetClosestPlayer()
    if player ~= -1 and distance < 3.0 and IsPompier() then
        TriggerServerEvent('pompier:firstAid', GetPlayerServerId(player))
        ESX.ShowNotification('💉 Premiers secours administrés')
    else
        ESX.ShowNotification('❌ Aucun joueur à proximité')
    end
end, false)

RegisterCommand('reanimate', function()
    local player, distance = ESX.Game.GetClosestPlayer()
    if player ~= -1 and distance < 3.0 and IsPompier() then
        TriggerServerEvent('pompier:reanimate', GetPlayerServerId(player))
        ESX.ShowNotification('🧑‍⚕️ Réanimation effectuée')
    else
        ESX.ShowNotification('❌ Aucun joueur à proximité')
    end
end, false)

-- Vérifie si joueur est pompier
function IsPompier()
    return PlayerData.job and PlayerData.job.name == 'pompier'
end

-- Événements de soins
RegisterNetEvent('pompier:healSmall')
AddEventHandler('pompier:healSmall', function()
    local ped = PlayerPedId()
    local health = GetEntityHealth(ped)
    SetEntityHealth(ped, math.min(health + 30, 200))
    ESX.ShowNotification('💉 Vous avez reçu des premiers secours')
end)

RegisterNetEvent('pompier:revive')
AddEventHandler('pompier:revive', function()
    local ped = PlayerPedId()
    if IsEntityDead(ped) then
        NetworkResurrectLocalPlayer(GetEntityCoords(ped), true, true, false)
        SetEntityHealth(ped, 130)
        ClearPedTasksImmediately(ped)
        ESX.ShowNotification('❤️ Vous avez été réanimé par les pompiers')
    end
end)

-- Update job
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

-- Update appels
RegisterNetEvent('pompier:updateCalls')
AddEventHandler('pompier:updateCalls', function(newCalls)
    calls = newCalls
end)

-- Annonces en bas à gauche
RegisterNetEvent('pompier:showNotification')
AddEventHandler('pompier:showNotification', function(title, message)
    ESX.ShowNotification(message)
end)

-- Affiche les annonces en bas à gauche avec style pompiers
RegisterNetEvent('pompier:showAdvancedNotification')
AddEventHandler('pompier:showAdvancedNotification', function(title, subject, msg, icon, iconType)
    ESX.ShowAdvancedNotification(title, subject, msg, icon, iconType)
end)

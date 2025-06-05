local canCook = true
local currentVeh = nil
local cooking = false
local currentTemp = 70
local currentPressure = 40
local score = 100
local canSell = true

-- 🧪 Vérifie si le véhicule est un modèle autorisé
local function IsValidRV(entity)
    return DoesEntityExist(entity) and GetEntityModel(entity) == Config.RVModel
end

-- 🎯 ox_target sur véhicule pour démarrer la cuisson
CreateThread(function()
    exports.ox_target:addGlobalVehicle({
        label = 'Cuisiner de la meth',
        icon = 'fa-solid fa-flask',
        groups = 'all',
        distance = 2.5,
        canInteract = function(entity)
            return IsValidRV(entity) and canCook
        end,
        onSelect = function(data)
            local entity = data.entity
            local vehCoords = GetEntityCoords(entity)

            if Config.RestrictToZones then
                local allowed = false
                for _, zone in pairs(Config.AllowedZones) do
                    if #(zone - vehCoords) < 30.0 then
                        allowed = true
                        break
                    end
                end
                if not allowed then
                    Config.Notify("Tu ne peux pas cuisiner ici.", "error")
                    return
                end
            end

            TriggerServerEvent('methlab:attemptStart', VehToNet(entity))
        end
    })
end)

-- 📋 Menu de confirmation cuisson
RegisterNetEvent('methlab:startCooking', function(netVeh)
    local vehicle = NetToVeh(netVeh)
    if not DoesEntityExist(vehicle) then return end
    currentVeh = vehicle

    lib.registerContext({
        id = 'methlab_start_menu',
        title = 'Démarrer la cuisson ?',
        options = {
            {
                title = 'Commencer la cuisson',
                icon = 'flask',
                event = 'methlab:confirmStart',
                args = { veh = VehToNet(vehicle) }
            },
            {
                title = 'Annuler',
                icon = 'xmark'
            }
        }
    })
    lib.showContext('methlab_start_menu')
end)

-- 🔥 Lancement réel de la cuisson
RegisterNetEvent('methlab:confirmStart', function(data)
    local vehicle = NetToVeh(data.veh)
    if not DoesEntityExist(vehicle) then return end

    if Config.LockVehicleDuringCook then
        SetVehicleDoorsLocked(vehicle, 4)
    end

    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, 0)

    Wait(1000)
    RequestAnimDict("amb@prop_human_parking_meter@male@base")
    while not HasAnimDictLoaded("amb@prop_human_parking_meter@male@base") do Wait(10) end
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_parking_meter@male@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)

    TriggerEvent('methlab:beginProcess', vehicle)
end)

-- ⏱️ Cuisson en cours : jauges, HUD, risques
RegisterNetEvent('methlab:beginProcess', function(vehicle)
    cooking = true
    local ped = PlayerPedId()
    local vehCoords = GetEntityCoords(vehicle)
    local pedCoords = GetEntityCoords(ped)

    if #(vehCoords - pedCoords) > 5.0 then
        Config.Notify("Tu es trop loin du véhicule.", "error")
        return
    end

    SendNUIMessage({ action = "show_hud" })

    CreateThread(function()
        while cooking do
            Wait(1500)

            local tempChange = math.random(-2, 3)
            local pressureChange = math.random(-2, 2)

            currentTemp += tempChange
            currentPressure += pressureChange

            -- Distance check = annulation
            if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(vehicle)) > 7.0 then
                cooking = false
                SendNUIMessage({ action = "hide_hud" })
                Config.Notify("Tu t’es éloigné ! Cuisson annulée.", "error")
                TriggerServerEvent('methlab:cancelProcess')
                return
            end

            SendNUIMessage({
                action = "update_methlab",
                temp = currentTemp,
                pressure = currentPressure
            })

            if currentTemp >= Config.CriticalTemperature or currentPressure >= Config.CriticalPressure then
                cooking = false
                TriggerEvent('methlab:handleExplosion', vehicle)
                return
            end

            if currentTemp < 65 or currentTemp > 90 or currentPressure < 35 or currentPressure > 70 then
                score -= 10
                Config.Notify("Tu perds le contrôle !", "error")
            end
        end
    end)

    local finished = lib.progressBar({
        duration = 30000,
        label = 'Cuisson de la méthamphétamine...',
        useWhileDead = false,
        canCancel = false,
        disable = { move = true, car = true, combat = true },
    })

    cooking = false
    SendNUIMessage({ action = "hide_hud" })

    if finished then
        TriggerServerEvent('methlab:finishCook', score)
        ClearPedTasks(ped)
        StopAnimTask(ped, "amb@prop_human_parking_meter@male@base", "base", 1.0)
        Config.Notify("Cuisson terminée !", "success")

        if Config.LockVehicleDuringCook then
            SetVehicleDoorsLocked(vehicle, 1)
        end
    end
end)

-- 💥 Explosion : visuel + dégâts + alerte
RegisterNetEvent('methlab:handleExplosion', function(vehicle)
    local coords = GetEntityCoords(vehicle)
    AddExplosion(coords.x, coords.y, coords.z, 29, 1.0, true, false, 1.0)

    SetEntityHealth(PlayerPedId(), math.random(10, 60))
    UseParticleFxAssetNextCall("core")
    StartParticleFxNonLoopedAtCoord("exp_grd_grenade_smoke", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.5, false, false, false)

    if Config.EnablePoliceAlert then
        TriggerServerEvent('methlab:policeAlert', coords)
    end

    Config.Notify("Explosion ! La cuisson a échoué.", "error")

    if Config.LockVehicleDuringCook then
        SetVehicleDoorsLocked(vehicle, 1)
    end
end)

-- 💰 Vente via ox_target
CreateThread(function()
    if not Config.SellPoint.enabled then return end

    local coords = Config.SellPoint.coords

    if Config.SellPoint.npc.enabled then
        RequestModel(Config.SellPoint.npc.model)
        while not HasModelLoaded(Config.SellPoint.npc.model) do Wait(10) end
        local npc = CreatePed(0, Config.SellPoint.npc.model, coords.x, coords.y, coords.z - 1.0, 0.0, false, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        FreezeEntityPosition(npc, true)
    end

    exports.ox_target:addBoxZone({
        coords = coords,
        size = vec3(1.5, 1.5, 2.0),
        rotation = 45,
        debug = false,
        options = {
            {
                label = 'Vendre la méthamphétamine',
                icon = 'dollar-sign',
                canInteract = function()
                    return canSell
                end,
                onSelect = function()
                    TriggerServerEvent('methlab:attemptSell')
                end
            }
        }
    })
end)

-- 🧼 Nettoyage à l’arrêt de la ressource
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        SendNUIMessage({ action = "hide_hud" })
        TriggerServerEvent('methlab:cancelProcess')
    end
end)
local cooldowns = {}
local sellCooldowns = {}
local activeProcesses = {}

-- ⛔ Annulation manuelle ou en cas de crash
RegisterNetEvent('methlab:cancelProcess', function()
    activeProcesses[source] = nil
end)

-- 🔬 Lancement de la cuisson
RegisterNetEvent('methlab:attemptStart', function(netVeh)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if cooldowns[src] and cooldowns[src] > os.time() then
        TriggerClientEvent('ox_lib:notify', src, {
            description = 'Tu dois attendre avant de recommencer.',
            type = 'error'
        })
        return
    end

    if activeProcesses[src] then
        TriggerClientEvent('ox_lib:notify', src, {
            description = 'Tu cuisines déjà !',
            type = 'error'
        })
        return
    end

    -- Vérifie les ingrédients
    for item, count in pairs(Config.RequiredItems) do
        local has = Player.Functions.GetItemByName(item)
        if not has or has.amount < count then
            TriggerClientEvent('ox_lib:notify', src, {
                description = 'Il te manque des ingrédients.',
                type = 'error'
            })
            return
        end
    end

    -- Retire les ingrédients
    for item, count in pairs(Config.RequiredItems) do
        Player.Functions.RemoveItem(item, count)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "remove")
    end

    -- Lance la cuisson
    cooldowns[src] = os.time() + Config.CookCooldown
    activeProcesses[src] = true
    TriggerClientEvent('methlab:startCooking', src, netVeh)
end)

-- ✅ Fin de cuisson : calcul qualité + ajout item
RegisterNetEvent('methlab:finishCook', function(score)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    activeProcesses[src] = nil

    local qualityLabel = "meth_poor"
    for _, data in ipairs(Config.ProductQualities) do
        if score >= data.minScore then
            qualityLabel = data.label
        end
    end

    Player.Functions.AddItem(qualityLabel, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[qualityLabel], "add")

    if Config.EnableServerLogs then
        print(("[MethLab] %s (%s) a produit %s (%d pts)"):format(Player.PlayerData.name, src, qualityLabel, score))
    end
end)

-- 💰 Vente de la meth
RegisterNetEvent('methlab:attemptSell', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if sellCooldowns[src] and sellCooldowns[src] > os.time() then
        TriggerClientEvent('ox_lib:notify', src, {
            description = 'Reviens plus tard pour vendre à nouveau.',
            type = 'error'
        })
        return
    end

    local hasSold = false

    for _, itemData in ipairs(Config.ProductQualities) do
        local item = Player.Functions.GetItemByName(itemData.label)
        if item and item.amount > 0 then
            Player.Functions.RemoveItem(itemData.label, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemData.label], "remove")
            Player.Functions.AddMoney('cash', itemData.price, "meth-sale")

            TriggerClientEvent('ox_lib:notify', src, {
                description = ("Tu as vendu %s pour $%s"):format(itemData.label, itemData.price),
                type = 'success'
            })

            if Config.EnableServerLogs then
                print(("[MethLab] %s (%s) a vendu %s pour $%s"):format(Player.PlayerData.name, src, itemData.label, itemData.price))
            end

            hasSold = true
            break
        end
    end

    if not hasSold then
        TriggerClientEvent('ox_lib:notify', src, {
            description = 'Tu n’as rien à vendre.',
            type = 'error'
        })
    else
        sellCooldowns[src] = os.time() + 120 -- cooldown de vente
    end
end)
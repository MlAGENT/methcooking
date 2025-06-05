Config = {}

-- 🚐 Véhicule autorisé pour la cuisson
Config.RVModel = GetHashKey("journey") -- à remplacer par le modèle que tu veux

-- 🎯 Coordonnées optionnelles si tu veux autoriser la cuisson seulement à certains endroits
Config.RestrictToZones = false
Config.AllowedZones = {
    vector3(1000.0, -2000.0, 30.0), -- Exemple
}

-- 🧪 Objets requis
Config.RequiredItems = {
    ephedrine = 1,
    solvent = 1,
    heat_source = 1,
    chemical_mixer = 1,
}

-- 🕑 Cooldown (en secondes) entre deux cuissons
Config.CookCooldown = 1800 -- 30 minutes

-- 🔥 Température et pression critiques (risque d’explosion)
Config.CriticalTemperature = 95
Config.CriticalPressure = 80

-- 🚔 Alerte police
Config.EnablePoliceAlert = true
Config.PoliceJobName = "police"
Config.DispatchCooldown = 60 -- seconds

-- 📦 Résultats possibles selon score
Config.ProductQualities = {
    { minScore = 0,    label = "meth_poor",  price = 100 },
    { minScore = 60,   label = "meth_good",  price = 300 },
    { minScore = 90,   label = "meth_pure",  price = 600 },
}

-- 💬 Notifications
Config.Notify = function(msg, type)
    lib.notify({
        title = 'MethLab',
        description = msg,
        type = type or 'inform' -- types: 'inform', 'error', 'success'
    })
end

-- 👤 Vente : soit un PNJ (avec coords) soit un point fixe
Config.SellPoint = {
    enabled = true,
    coords = vector3(1234.0, -456.0, 30.0),
    npc = {
        enabled = true,
        model = "g_m_m_chigoon_02"
    }
}

-- 🔒 Verrouillage du véhicule durant la cuisson
Config.LockVehicleDuringCook = true

-- 📜 Logs (à activer selon tes besoins)
Config.EnableServerLogs = true

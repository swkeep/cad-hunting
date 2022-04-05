Config = Config or {}

Config.DEBUG = false -- make sure it's false
-- ============================
--       Server Config
-- ============================
Config.sv_dataClearnigTimer = 1000 * 60 * 60 -- 1000 per sec
Config.sv_maxTableSize = 5000 -- saved entites in table

-- End

-- protection system againts players  
-- if hunters have this weapons they can't shoot players with it!
Config.ShootingProtection = false
Config.ProtectedWeapons = {'weapon_musket'}
-- End

Config.BaitCooldown = 1000 * 30 -- 1000 per sec
Config.SpawningTimer = 1000 * 60 -- script will wait until "SpawningTimer" time out then it will spwan animal  

Config.AnimalsEatingSpeed = 1000 * 15 -- how much animals will wait in baits location
Config.AnimalsFleeView = 15.0 -- animal Flee range if they get to see players

Config.BaitPlacementSpeed = math.random(1000 * 15, 1000 * 30)
Config.SlaughteringSpeed = math.random(1000 * 7, 1000 * 15)

Config.maxSpawnDistance = 100 -- animal spwan radius from placed bait
Config.minSpawnDistance = 60 -- animal spwan radius from placed bait
Config.spawnAngle = {0, 360} -- animal spwan radius from placed bait

Config.animalDespawnRange = 150.0

Config.spawnedAnimalsBlips = true -- when animals spawend it will appears in map with blips on them
Config.AnimalBlip = {
    sprite = 463, -- icon https://docs.fivem.net/docs/game-references/blips/
    color = 5
}

Config.callPoliceChance = {25, 75} -- 25 + 75 = 100% ( this means 25% chance to call police )

Config.llegalHuntingNotification = function(animalCoord)
    TriggerEvent("police:client:policeAlert", animalCoord, "illegal Hunting in area")
end

Config.Animals = {{
    model = "a_c_deer",
    -- {legal area spawn chance , illegal area spawn chance}
    spwanRarity = {20, 25},
    hash = -664053099,
    -- { {"ITEMNAME" , Chance , Sell Price} , {"ITEMNAME" , Chance , Sell Price} ,  ....}
    -- note: 100% chance means every time players gonna get that item and script will not use RNG system.

    -- IMPORTANT: if there are two or more rewards with the same name for example "meatpig"
    -- script will skip other prices and only uses the first seen value.

    -- IMPORTANT: if you leave price with nil value player can't sell those items to Vendor. for example plastic in here
    Loots = {{"meatdeer", 100, 150}, {"plastic", 50}}
}, {
    model = "a_c_pig",
    spwanRarity = {20, 0},
    hash = -1323586730,
    -- { {"ITEMNAME" , Chance , Sell Price} , {"ITEMNAME" , Chance , Sell Price} ,  ....}
    Loots = {{"meatpig", 100, 150}, {"plastic", 50}}
}, {
    model = "a_c_boar",
    spwanRarity = {30, 25},
    hash = -832573324,

    Loots = {{"meatpig", 100}, {"plastic", 50}}
}, {
    model = "a_c_mtlion",
    spwanRarity = {25, 50},
    hash = 307287994,
    Loots = {{"meatlion", 100, 150}, {"plastic", 50}}
}, {
    model = "a_c_cow",
    spwanRarity = {0, 0},
    hash = -50684386,
    Loots = {{"meatcow", 100, 150}, {"plastic", 50}}
}, {
    model = "a_c_coyote",
    spwanRarity = {0, 0},
    hash = 1682622302,
    Loots = {{"meatcoyote", 100, 150}, {"plastic", 50}}
}, {
    model = "a_c_rabbit_01",
    spwanRarity = {0, 0},
    hash = -541762431,
    Loots = {{"meatrabbit", 100, 150}, {"plastic", 50}}
}, {
    model = "a_c_pigeon",
    spwanRarity = {0, 0},
    hash = 111281960,
    Loots = {{"meatbird", 100, 150}, {"plastic", 50}}
}, {
    model = "a_c_seagull",
    spwanRarity = {0, 0},
    hash = -745300483,
    Loots = {{"meatbird", 100}, {"plastic", 50}}
}}

Config.HuntingArea = {{
    name = "llegal hunting Area",
    coord = vector3(-840.6, 4183.3, 215.29),
    radius = 1000.0,
    llegal = true,
    showBlip = true
}, {
    name = "illlegal hunting Area",
    coord = vector3(870.01, 5158.01, 452.54),
    radius = 500.0,
    llegal = false,
    showBlip = true
}}

Config.HuntingShopItems = {
    [1] = {
        name = 'weapon_musket',
        price = 1500,
        amount = 10,
        info = {},
        type = 'weapon',
        slot = 1
    },
    [2] = {
        name = 'shotgun_ammo',
        price = 100,
        amount = 50,
        info = {},
        type = 'item',
        slot = 2
    },
    [3] = {
        name = 'huntingbait',
        price = 150,
        amount = 150,
        info = {},
        type = 'item',
        slot = 3
    },
    [4] = {
        name = 'weapon_knife',
        price = 500,
        amount = 50,
        info = {},
        type = 'item',
        slot = 4
    }
}

-- Config.Locations = {
--     ["huntingshop"] = {
--         ["label"] = "Hunting Shop",
--         ["coords"] = {
--             [1] = vector4(-679.82, 5838.92, 17.33, 217.45)
--         },
--         ["ped"] = {
--             ["model"] = 'ig_hunter'
--         },
--         ["radius"] = 1.5,
--         ["products"] = Config.Products["huntingshop"],
--         ["showblip"] = true,
--         ["blipsprite"] = 52
--     }
-- }

Config.Shop = {
    ["name"] = "huntingshop",
    ["label"] = "Hunting Shop"
}

Config.HuntingShopNpc = {{
    BlipsCoords = vector3(-679.82, 5838.92, 17.33),
    name = 'hunting shop',
    showBlip = true,
    SellerNpc = {
        model = 'ig_hunter',
        coords = vector4(-679.82, 5838.92, 17.33, 217.45),
        minusOne = true,
        freeze = true,
        invincible = true,
        blockevents = true,
        flag = 1,
        currentpednumber = 0
    }
}}

Config.SellSpots = {{
    BlipsCoords = vector3(570.34, 2796.46, 42.01),
    name = 'sell hunting stuff!',
    showBlip = true,
    SellerNpc = {
        model = 'csb_chef',
        coords = vector4(570.34, 2796.46, 42.01, 294.27),
        minusOne = true,
        freeze = true,
        invincible = true,
        blockevents = true,
        flag = 1,
        currentpednumber = 0
    }
}}

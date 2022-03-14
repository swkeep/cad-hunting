Config = Config or {}

Config.DEBUG = true -- make sure it's false
-- ============================
--       Server Config
-- ============================
Config.sv_dataClearnigTimer = 15000 -- 1000 per sec
Config.sv_maxTableSize = 5000 -- saved entites in table

-- End

Config.BaitCooldown = 5000 -- 1000 per sec
Config.SpawningTimer = 5000 -- script will wait until "SpawningTimer" time out then it's spwan animal  

Config.AnimalsEatingSpeed = 7500 -- how much animals will wait in baits location
Config.AnimalsFleeView = 15.0 -- animal Flee range if they get to see players

Config.BaitPlacementSpeed = math.random(3000, 3000)
Config.SlaughteringSpeed = math.random(1000, 5000)

Config.maxSpawnDistance = 90 -- animal spwan radius from placed bait
Config.minSpawnDistance = 50 -- animal spwan radius from placed bait
Config.spawnAngle = math.random(0, 360) -- animal spwan radius from placed bait

Config.animalDespawnRange = 500.0

Config.spawnedAnimalsBlips = true -- when animals spawend it will appears in map with blips on them
Config.AnimalBlip = {
    sprite = 463, -- icon https://docs.fivem.net/docs/game-references/blips/
    color = 5
}

Config.callPoliceChance = {25, 75} -- 25 + 75 = 100% ( 25% chance to call police )

Config.llegalHuntingNotification = function(animalCoord)
    TriggerEvent("police:client:policeAlert", animalCoord, "illegal Hunting in area")
end

Config.Animals = {{
    model = "a_c_deer",
    -- {legal area spawn chance , illegal area spawn chance}
    spwanRarity = {20, 100},
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
    spwanRarity = {30, 0},
    hash = -832573324,

    Loots = {{"meatpig", 100}, {"plastic", 50}}
}, {
    model = "a_c_mtlion",
    spwanRarity = {0, 0},
    hash = 307287994,
    Loots = {{"meatlion", 100, 150}, {"plastic", 50}}
}, {
    model = "a_c_cow",
    spwanRarity = {30, 0},
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
    llegal = true
}, {
    name = "illlegal hunting Area",
    coord = vector3(870.01, 5158.01, 452.54),
    radius = 500.0,
    llegal = false
}}

Config.HuntingShopItems = {
    [1] = {
        name = 'weapon_musket',
        price = 500,
        amount = 2,
        info = {},
        type = 'item',
        slot = 1
    },
    [2] = {
        name = 'shotgun_ammo',
        price = 100,
        amount = 2,
        info = {},
        type = 'item',
        slot = 2
    },
    [3] = {
        name = 'huntingbait',
        price = 200,
        amount = 50,
        info = {},
        type = 'item',
        slot = 3
    },
    [4] = {
        name = 'weapon_knife',
        price = 200,
        amount = 1,
        info = {},
        type = 'item',
        slot = 4
    }
}

Config.Shop = {
    ["name"] = "huntingshop",
    ["label"] = "Hunting Shop"
}

Config.HuntingShopNpc = {{
    BlipsCoords = vector3(-679.82, 5838.92, 17.33),
    SellerNpc = {
        model = 'ig_hunter', -- This is the ped model that is going to be spawning at the given coords
        coords = vector4(-679.82, 5838.92, 17.33, 217.45), -- This is the coords that the ped is going to spawn at, always has to be a vector4 and the w value is the heading
        minusOne = true, -- Set this to true if your ped is hovering above the ground but you want it on the ground (OPTIONAL)
        freeze = true, -- Set this to true if you want the ped to be frozen at the given coords (OPTIONAL)
        invincible = true, -- Set this to true if you want the ped to not take any damage from any source (OPTIONAL)
        blockevents = true, -- Set this to true if you don't want the ped to react the to the environment (OPTIONAL)
        -- animDict = 'abigail_mcs_1_concat-0', -- This is the animation dictionairy to load the animation to play from (OPTIONAL)
        -- anim = 'csb_abigail_dual-0', -- This is the animation that will play chosen from the animDict, this will loop the whole time the ped is spawned (OPTIONAL)
        flag = 1, -- This is the flag of the animation to play, for all the flags, check the TaskPlayAnim native here https://docs.fivem.net/natives/?_0x5AB552C6 (OPTIONAL)
        -- scenario = 'WORLD_HUMAN_AA_COFFEE', -- This is the scenario that will play the whole time the ped is spawned, this cannot pair with anim and animDict (OPTIONAL)
        currentpednumber = 0 -- This is the current ped number, this will be assigned when spawned, you can leave this out because it will always be created (OPTIONAL)
    }
}}

Config.SellSpots = {{
    BlipsCoords = vector3(570.34, 2796.46, 42.01),
    SellerNpc = {
        model = 'csb_chef', -- This is the ped model that is going to be spawning at the given coords
        coords = vector4(570.34, 2796.46, 42.01, 294.27), -- This is the coords that the ped is going to spawn at, always has to be a vector4 and the w value is the heading
        minusOne = true, -- Set this to true if your ped is hovering above the ground but you want it on the ground (OPTIONAL)
        freeze = true, -- Set this to true if you want the ped to be frozen at the given coords (OPTIONAL)
        invincible = true, -- Set this to true if you want the ped to not take any damage from any source (OPTIONAL)
        blockevents = true, -- Set this to true if you don't want the ped to react the to the environment (OPTIONAL)
        -- animDict = 'abigail_mcs_1_concat-0', -- This is the animation dictionairy to load the animation to play from (OPTIONAL)
        -- anim = 'csb_abigail_dual-0', -- This is the animation that will play chosen from the animDict, this will loop the whole time the ped is spawned (OPTIONAL)
        flag = 1, -- This is the flag of the animation to play, for all the flags, check the TaskPlayAnim native here https://docs.fivem.net/natives/?_0x5AB552C6 (OPTIONAL)
        -- scenario = 'WORLD_HUMAN_AA_COFFEE', -- This is the scenario that will play the whole time the ped is spawned, this cannot pair with anim and animDict (OPTIONAL)
        currentpednumber = 0 -- This is the current ped number, this will be assigned when spawned, you can leave this out because it will always be created (OPTIONAL)
    }
}}

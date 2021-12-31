Config = Config or {}

Config.DEBUG = true -- make sure it's false
-- ============================
--       Server Config
-- ============================
Config.sv_dataClearnigTimer = 5000 -- 1000 per sec
Config.sv_maxTableSize = 5000 -- saved entites in table

-- End

Config.BaitCooldown = 15000 -- 1000 per sec
Config.SpawningTimer = 5000 -- script will wait until "SpawningTimer" time out then it's spwan animal  

Config.AnimalsEatingSpeed = 7500 -- how much animals will wait in baits location
Config.AnimalsFleeView = 15.0 -- animal Flee range if they get to see players

Config.BaitPlacementSpeed = math.random(3000, 3000)
Config.SlaughteringSpeed = math.random(1000, 5000)

Config.baitSpawnDistance = 100 -- animal spwan radius from placed bait

Config.animalDespawnRange = 500.0

Config.spawnedAnimalsBlips = true -- when animals spawend it will appears in map with blips on them
Config.AnimalBlip = {
    sprite = 463, -- icon https://docs.fivem.net/docs/game-references/blips/
    color = 5
}

Config.Animals = {{
    model = "a_c_deer",
    spwanRarity = {10, 90}, -- {in llegal are spawn chance , in illegal area spawn chance}
    hash = -664053099,
    item = "Deer Horns",
    invItemName = "meatdeer",
    price = 150
}, {
    model = "a_c_pig",
    spwanRarity = {0, 15},
    hash = -1323586730,
    item = "Pig Pelt",
    invItemName = "meatpig",
    price = 150
}, {
    model = "a_c_boar",
    spwanRarity = {10, 15},
    hash = -832573324,
    item = "Boar Tusks",
    invItemName = "meatboar",
    price = 150
}, {
    model = "a_c_mtlion",
    spwanRarity = {90, 10},
    hash = 307287994,
    item = "Coager Claws",
    invItemName = "meatlion",
    price = 150
}, {
    model = "a_c_cow",
    spwanRarity = {0, 0},
    hash = -50684386,
    item = "Cow Pelt",
    invItemName = "meatcow",
    price = 550
}, {
    model = "a_c_coyote",
    spwanRarity = {10, 18},
    hash = 1682622302,
    item = "Coyote Pelt",
    invItemName = "meatcoyote",
    price = 250
}, {
    model = "a_c_rabbit_01",
    spwanRarity = {0, 0},
    hash = -541762431,
    item = "Rabbit Fur",
    invItemName = "meatrabbit",
    price = 140
}, {
    model = "a_c_pigeon",
    spwanRarity = {0, 0},
    hash = 111281960,
    item = "Bird Feather",
    invItemName = "meatbird",
    price = 130
}, {
    model = "a_c_seagull",
    spwanRarity = {0, 0},
    hash = -745300483,
    item = "Bird Feather",
    invItemName = "meatbird",
    price = 110
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
} -- {
--     BlipsCoords = vector3(-391.88, 6053.16, 31.5),
--     SellerNpc = {
--         model = 'a_m_m_indian_01', 
--         coords = vector4(-391.88, 6053.16, 31.5, 126.23),
--         minusOne = true,
--         freeze = true,
--         invincible = true,
--         blockevents = true,
--         --animDict = 'abigail_mcs_1_concat-0',
--         --anim = 'csb_abigail_dual-0', 
--         flag = 1, 
--         --scenario = 'WORLD_HUMAN_AA_COFFEE',
--         currentpednumber = 0
--     }
-- }
}

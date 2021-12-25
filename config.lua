Config = Config or {}

Config.Animals = {{
    model = "a_c_deer",
    hash = -664053099,
    item = "Deer Horns",
    invItemName = "meatdeer",
    price = 150,
    id = 35
}, {
    model = "a_c_pig",
    hash = -1323586730,
    item = "Pig Pelt",
    invItemName = "meatpig",
    price = 150,
    id = 36
}, {
    model = "a_c_boar",
    hash = -832573324,
    item = "Boar Tusks",
    invItemName = "meatboar",
    price = 150,
    id = 37
}, {
    model = "a_c_mtlion",
    hash = 307287994,
    item = "Coager Claws",
    invItemName = "meatlion",
    price = 150,
    id = 38
}, {
    model = "a_c_cow",
    hash = -50684386,
    item = "Cow Pelt",
    invItemName = "meatcow",
    price = 550,
    id = 39
}, {
    model = "a_c_coyote",
    hash = 1682622302,
    item = "Coyote Pelt",
    invItemName = "meatcoyote",
    price = 250,
    id = 40
}, {
    model = "a_c_rabbit_01",
    hash = -541762431,
    item = "Rabbit Fur",
    invItemName = "meatrabbit",
    price = 140,
    id = 41
}, {
    model = "a_c_pigeon",
    hash = 111281960,
    item = "Bird Feather",
    invItemName = "meatbird",
    price = 130,
    id = 42
}, {
    model = "a_c_seagull",
    hash = -745300483,
    item = "Bird Feather",
    invItemName = "meatbird",
    price = 110,
    id = 43
}}

Config.SellSpots = {{
    BlipsCoords = vector3(-390.522, 6050.458, 31.500),
    SellerNpc = { -- This has to be a number otherwise it can't delete the ped afterwards
        model = 'a_m_m_indian_01', -- This is the ped model that is going to be spawning at the given coords
        coords = vector4(-389.44, 6050.31, 31.5, 92.27), -- This is the coords that the ped is going to spawn at, always has to be a vector4 and the w value is the heading
        minusOne = true, -- Set this to true if your ped is hovering above the ground but you want it on the ground (OPTIONAL)
        freeze = true, -- Set this to true if you want the ped to be frozen at the given coords (OPTIONAL)
        invincible = true, -- Set this to true if you want the ped to not take any damage from any source (OPTIONAL)
        blockevents = true, -- Set this to true if you don't want the ped to react the to the environment (OPTIONAL)
        --animDict = 'abigail_mcs_1_concat-0', -- This is the animation dictionairy to load the animation to play from (OPTIONAL)
        --anim = 'csb_abigail_dual-0', -- This is the animation that will play chosen from the animDict, this will loop the whole time the ped is spawned (OPTIONAL)
        flag = 1, -- This is the flag of the animation to play, for all the flags, check the TaskPlayAnim native here https://docs.fivem.net/natives/?_0x5AB552C6 (OPTIONAL)
        --scenario = 'WORLD_HUMAN_AA_COFFEE', -- This is the scenario that will play the whole time the ped is spawned, this cannot pair with anim and animDict (OPTIONAL)
        currentpednumber = 0 -- This is the current ped number, this will be assigned when spawned, you can leave this out because it will always be created (OPTIONAL)
    }
}, {
    BlipsCoords = vector3(-391.88, 6053.16, 31.5),
    SellerNpc = { -- This has to be a number otherwise it can't delete the ped afterwards
        model = 'a_m_m_indian_01', -- This is the ped model that is going to be spawning at the given coords
        coords = vector4(-391.88, 6053.16, 31.5, 126.23), -- This is the coords that the ped is going to spawn at, always has to be a vector4 and the w value is the heading
        minusOne = true, -- Set this to true if your ped is hovering above the ground but you want it on the ground (OPTIONAL)
        freeze = true, -- Set this to true if you want the ped to be frozen at the given coords (OPTIONAL)
        invincible = true, -- Set this to true if you want the ped to not take any damage from any source (OPTIONAL)
        blockevents = true, -- Set this to true if you don't want the ped to react the to the environment (OPTIONAL)
        --animDict = 'abigail_mcs_1_concat-0', -- This is the animation dictionairy to load the animation to play from (OPTIONAL)
        --anim = 'csb_abigail_dual-0', -- This is the animation that will play chosen from the animDict, this will loop the whole time the ped is spawned (OPTIONAL)
        flag = 1, -- This is the flag of the animation to play, for all the flags, check the TaskPlayAnim native here https://docs.fivem.net/natives/?_0x5AB552C6 (OPTIONAL)
        --scenario = 'WORLD_HUMAN_AA_COFFEE', -- This is the scenario that will play the whole time the ped is spawned, this cannot pair with anim and animDict (OPTIONAL)
        currentpednumber = 0 -- This is the current ped number, this will be assigned when spawned, you can leave this out because it will always be created (OPTIONAL)
    }
}}

# Qbcore Hunting

- [original author] (https://github.com/cadburry6969/)
- [original project] (https://github.com/cadburry6969/cad-hunting)

# Dependencies

- [qb-target](https://github.com/BerkieBb/qb-target)
- [qbcore framework](https://github.com/qbcore-framework)
- [qbcore inventory](https://github.com/qbcore-framework/qb-inventory)
- [qb-shops](https://github.com/qbcore-framework/qb-shops)

# Installation

- Add images to qb-invetory/html/images
- Add code below to qb-core/shared.lua under "ITEMS" section

```lua
	["meatdeer"] 		 			 	 = {["name"] = "meatdeer",       	    		["label"] = "Deer Horns",	 				["weight"] = 100, 		["type"] = "item", 		["image"] = "deerhorns.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Deer Horns"},
	["meatpig"] 		 			 	 = {["name"] = "meatpig",       	    		["label"] = "Pig Meat",	 					["weight"] = 100, 		["type"] = "item", 		["image"] = "pigpelt.png", 				["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Pig Meat"},
	["meatboar"] 		 			 	 = {["name"] = "meatboar",       	    		["label"] = "Boar Tusks",	 				["weight"] = 100, 		["type"] = "item", 		["image"] = "boartusks.png", 				["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Boar Tusks"},
	["meatlion"] 		 			 	 = {["name"] = "meatlion",       	    		["label"] = "Cougar Claws",	 				["weight"] = 100, 		["type"] = "item", 		["image"] = "cougarclaw.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Cougar Claw"},
	["meatcow"] 		 			 	 = {["name"] = "meatcow",       	    		["label"] = "Cow Pelt",	 					["weight"] = 100, 		["type"] = "item", 		["image"] = "cowpelt.png", 				["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Cow Pelt"},
	["meatrabbit"] 		 			 	 = {["name"] = "meatrabbit",       	    		["label"] = "Rabbit Fur",	 				["weight"] = 100, 		["type"] = "item", 		["image"] = "rabbitfur.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Rabbit Fur"},
	["meatbird"] 		 			 	 = {["name"] = "meatbird",       	    		["label"] = "Bird Feather",	 				["weight"] = 100, 		["type"] = "item", 		["image"] = "birdfeather.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Bird Feather"},
	["meatcoyote"] 		 			 	 = {["name"] = "meatcoyote",       	    		["label"] = "Coyote Pelt",	 				["weight"] = 100, 		["type"] = "item", 		["image"] = "coyotepelt.png", 			["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Coyote Pelt"},
	["huntingbait"] 		 			 = {["name"] = "huntingbait",       	    	["label"] = "Hunting Bait",	 				["weight"] = 150, 		["type"] = "item", 		["image"] = "huntingbait.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,   ["combinable"] = nil,   ["description"] = "Hunting Bait"},
```

- qb-shops config
- Modify qb-shops/config.lua and add this values at end of each table inside the config file ==> Config.Products/Config.Locations

```lua
Config.Products = {
    ["huntingshop"] = {
        [1] = {
            name = 'weapon_musket',
            price = 1500,
            amount = 10,
            info = {},
            type = 'weapon',
            slot = 1,
            requiresLicense = true
        },
        [2] = {
            name = 'shotgun_ammo',
            price = 100,
            amount = 50,
            info = {},
            type = 'item',
            slot = 2,
            requiresLicense = true
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
    },
}

Config.Locations = {
    ["huntingshop"] = {
        ["label"] = "Hunting Shop",
        ["type"] = "weapon",
        ["coords"] = vector4(-679.47, 5834.49, 17.33, 127.62),
        ["ped"] = 'ig_hunter',
        ["scenario"] = "WORLD_HUMAN_COP_IDLES",
        ["radius"] = 1.5,
        ["targetIcon"] = "fas fa-gun",
        ["targetLabel"] = "Open Hunting Shop",
        ["products"] = Config.Products["huntingshop"],
        ["showblip"] = true,
        ["blipsprite"] = 626,
        ["blipcolor"] = 1
    }
}
```

# Optional feature

## Hunting Hours

- To activate this feature, you must make the following changes
- open qb-weathersync / client / client.lua then try to find a code similar to the one below
- Then add the missing line thas has this marker "<------------- ADD THIS"
- Then turn this feature on in config file

```lua
local hunting_h = 0 -- <------------- ADD THIS
CreateThread(function()
    local hour = 0
    local minute = 0
    local second = 0
    while true do
        if not disable then
            Wait(0)
            local newBaseTime = baseTime
            if GetGameTimer() - 22 > timer then
                second = second + 1
                timer = GetGameTimer()
            end
            if freezeTime then
                timeOffset = timeOffset + baseTime - newBaseTime
                second = 0
            end
            baseTime = newBaseTime
            hour = math.floor(((baseTime + timeOffset) / 60) % 24)
            if minute ~= math.floor((baseTime + timeOffset) % 60) then
                minute = math.floor((baseTime + timeOffset) % 60)
                second = 0
            end
            hunting_h = hour -- <------------- ADD THIS
            NetworkOverrideClockTime(hour, minute, second)
        else
            Wait(1000)
        end
    end
end)

function getHour() -- <------------- ADD THIS
    return hunting_h -- <------------- ADD THIS
end -- <------------- ADD THIS

exports('getHour', getHour) -- <------------- ADD THIS
```

## How spawning chance works:

![chance](https://raw.githubusercontent.com/swkeep/keep-hunting/main/.github/img/chance.JPG)

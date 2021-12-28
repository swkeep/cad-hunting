# Qbcore Hunting

- [original author] (https://github.com/cadburry6969/)
- [original project] (https://github.com/cadburry6969/cad-hunting)

# Dependencies

- [qb-target](https://github.com/BerkieBb/qb-target)
- [qbcore framework](https://github.com/qbcore-framework)
- [qbcore inventory](https://github.com/qbcore-framework/qb-inventory)

# Installation

- Add images to qb-invetory/html/images
- Add code below to qb-core/shared.lua under "ITEMS" section

```lua
["huntingbait"] 		 			 = {["name"] = "huntingbait",       	    	["label"] = "Hunting Bait",	 				["weight"] = 150, 		["type"] = "item", 		["image"] = "huntingbait.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,   ["combinable"] = nil,   ["description"] = "Hunting Bait"},


["meatdeer"] = {["name"] = "meatdeer", ["label"] = "Deer Horns", ["weight"] = 100, 		["type"] = "item", 		["image"] = "deerhorns.png", ["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Deer Horns"},
["meatpig"] = {["name"] = "meatpig", ["label"] = "Pig Meat", 	["weight"] = 100, 		["type"] = "item", 		["image"] = "pigpelt.png", 	["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Pig Meat"},
["meatboar"] = {["name"] = "meatboar", ["label"] = "Boar Tusks", ["weight"] = 100, 		["type"] = "item", 		["image"] = "boartusks.png", 	["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Boar Tusks"},
["meatlion"] = {["name"] = "meatlion", ["label"] = "Cougar Claws", ["weight"] = 100, 		["type"] = "item", 		["image"] = "cougarclaw.png", ["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Cougar Claw"},
["meatcow"] = {["name"] = "meatcow", ["label"] = "Cow Pelt", 	["weight"] = 100, 		["type"] = "item", 		["image"] = "cowpelt.png", 	["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Cow Pelt"},
["meatrabbit"] = {["name"] = "meatrabbit", ["label"] = "Rabbit Fur", ["weight"] = 100, 		["type"] = "item", 		["image"] = "rabbitfur.png", ["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Rabbit Fur"},
["meatbird"] = {["name"] = "meatbird", ["label"] = "Bird Feather", ["weight"] = 100, 		["type"] = "item", 		["image"] = "birdfeather.png", ["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Bird Feather"},
["meatcoyote"] = {["name"] = "meatcoyote", ["label"] = "Coyote Pelt", ["weight"] = 100, 		["type"] = "item", 		["image"] = "coyotepelt.png", ["unique"] = false, 	["useable"] = false, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "Coyote Pelt"},
```

- hunting shop config
- Add to qb-shops/config.lua as showed in code

```lua
Config.Products = {
    .
    .
    .
    ["huntingshop"] = {
        [1] = {
            name = 'weapon_musket',
            price = 500,
            amount = 2,
            info = {},
            type = 'item',
            slot = 1,
        },
        [2] = {
            name = 'shotgun_ammo',
            price = 100,
            amount = 2,
            info = {},
            type = 'item',
            slot = 2,
        },
        [3] = {
            name = 'huntingbait',
            price = 200,
            amount = 50,
            info = {},
            type = 'item',
            slot = 3,
        },
    },
}

Config.Locations = {
    .
    .
    .
    ,["oneandonlyhuntingshop"] = {
        ["label"] = "Hunting Shop",
        ["type"] = "normal",
        ["coords"] = {
            [1] = vector3(-678.91, 5837.84, 17.33)
        },
        ["products"] = Config.Products["huntingshop"],
        ["showblip"] = true,
    },
}
```

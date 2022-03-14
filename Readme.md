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

- hunting shop config
- Modify qb-shops/server/main.lua as showed in code

```lua
RegisterNetEvent('qb-shops:server:UpdateShopItems', function(shop, itemData, amount)
    Config.Locations[shop]["products"][itemData.slot].amount =
        Config.Locations[shop]["products"][itemData.slot].amount - amount
    if Config.Locations[shop]["products"][itemData.slot].amount <= 0 then
        Config.Locations[shop]["products"][itemData.slot].amount = 0
    end
    TriggerClientEvent('qb-shops:client:SetShopItems', -1, shop, Config.Locations[shop]["products"])
end)
```

```lua
RegisterNetEvent('qb-shops:server:UpdateShopItems', function(shop, itemData, amount)
    if shop ~= "huntingshop" then
        Config.Locations[shop]["products"][itemData.slot].amount =
            Config.Locations[shop]["products"][itemData.slot].amount - amount
        if Config.Locations[shop]["products"][itemData.slot].amount <= 0 then
            Config.Locations[shop]["products"][itemData.slot].amount = 0
        end
        TriggerClientEvent('qb-shops:client:SetShopItems', -1, shop, Config.Locations[shop]["products"])
    end
end)
```

# Config file

```lua
Config.maxSpawnDistance = 90
Config.minSpawnDistance = 50
Config.spawnAngle = math.random(0, 360)
```

- This is how spawnAngle works:__
  ![radius](https://raw.githubusercontent.com/swkeep/keep-hunting/Test/.github/img/radius.jpg)

```lua
Config.Animals = {{
    model = "a_c_deer",
    -- {legal area spawn chance , illegal area spawn chance}
    spwanRarity = {20, 100},
    hash = -664053099,
    -- Loots: determines what players gonna get after they slaughtered animals
    -- { {"ITEMNAME" , Chance , Sell Price} , {"ITEMNAME" , Chance , Sell Price} ,  ....}
    -- note: 100% chance means every time players gonna get that item
    -- IMPORTANT: if you leave price with nil value players can't sell those items to Vendor. for example plastic in here
    -- note: 100% meatdeer + 50% plastic The following means that players have a chance to receive (meatdeer + plastic) at once.
    Loots = {{"meatdeer", 100, 150}, {"plastic", 50}}
},
.
.
.

}
```

- This is how chances of spawning work:__
  ![chance](https://raw.githubusercontent.com/swkeep/keep-hunting/Test/.github/img/chance.JPG)

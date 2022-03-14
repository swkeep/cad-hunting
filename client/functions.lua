local DEBUG = Config.DEBUG
local CoreName = exports['qb-core']:GetCoreObject()

function createCustomBlips(data)
    for _, v in pairs(data) do
        -- create Blips
        if v.BlipsCoords ~= nill then
            Blip = AddBlipForCoord(v.BlipsCoords.x, v.BlipsCoords.y, v.BlipsCoords.z)
        else
            Blip = AddBlipForCoord(v.coord.x, v.coord.y, v.coord.z)
        end
        SetBlipAsShortRange(Blip, true)
        if v.radius ~= nil then
            SetBlipSprite(Blip, 141)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.name)
            EndTextCommandSetBlipName(Blip)
            local RadiusBlip = AddBlipForRadius(v.coord.x, v.coord.y, v.coord.z, v.radius)

            AddCircleZone(v.name, v.llegal, v.coord, v.radius, {
                name = "circle_zone",
                debugPoly = DEBUG
            })
            SetBlipRotation(RadiusBlip, 0)

            if v.llegal == false then
                SetBlipColour(RadiusBlip, 1)
            else
                SetBlipColour(RadiusBlip, 4)
            end

            SetBlipAlpha(RadiusBlip, 64)
        else
            SetBlipSprite(Blip, 442)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Sell Meat")
            EndTextCommandSetBlipName(Blip)
        end
        SetBlipDisplay(Blip, 4)
        SetBlipScale(Blip, 0.6)
        SetBlipColour(Blip, 49)
    end
end

-- init qb-target for selling spots 
function initSellspotsQbTargets(sellspot)
    for _, v in pairs(sellspot) do
        -- spwan seller npcs
        exports['qb-target']:SpawnPed({
            [_] = v.SellerNpc
        })

        -- init qb-target for sellers
        exports['qb-target']:AddTargetModel(v.SellerNpc.model, {
            options = {{
                event = "keep-hunting:client:sellREQ",
                icon = "fas fa-sack-dollar",
                label = "Sell All"
            }},
            distance = 2.5
        })
    end
end

function initHuntingShopNpcQbTargets(HuntingShopNpc)
    for _, v in pairs(HuntingShopNpc) do
        -- spwan seller npcs
        exports['qb-target']:SpawnPed({
            [_] = v.SellerNpc
        })

        -- init qb-target for sellers
        exports['qb-target']:AddTargetModel(v.SellerNpc.model, {
            options = {{
                event = "keep-hunting:marketshop",
                icon = "fas fa-gun",
                label = "Hunting Shop"
            }},
            distance = 2.5
        })

        StoreBlip = AddBlipForCoord(v.BlipsCoords)
        SetBlipColour(StoreBlip, 0)
        SetBlipSprite(StoreBlip, 626)
        SetBlipScale(StoreBlip, 1.0)
        SetBlipColour(StoreBlip, 1)
    end
end

-- init qb-target for hunted animals
function initAnimalsTargting()
    for _, v in pairs(Config.Animals) do
        exports['qb-target']:AddTargetModel(v.model, {
            options = {{
                icon = "fas fa-sack-dollar",
                label = "slaughter",
                canInteract = function(entity)
                    if not IsPedAPlayer(entity) then
                        return (entity and IsEntityDead(entity))
                    end
                end,
                action = function(entity)
                    if IsPedAPlayer(entity) and IsEntityDead(entity) then
                        return false
                    end
                    TriggerEvent('keep-hunting:client:slaughterAnimal', entity)
                    return true
                end
            }},
            distance = 1.5
        })
    end
end

-- match hash with out animal list
function getAnimalMatch(hash)
    for _, v in pairs(Config.Animals) do
        if (v.hash == hash) then
            return v
        end
    end
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(0)
    end
end

-- animals Smart Flee

function createThreadAnimalTraveledDistanceToBaitTracker(BaitCoord, entity)
    -- entity is not moveing detaction
    Citizen.CreateThread(function()
        local finished = false
        TaskGoToCoordAnyMeans(entity, BaitCoord, 2.0, 0, 786603, 0xbf800000)
        while not IsPedDeadOrDying(entity) and not finished do
            local spawnedAnimalCoords = GetEntityCoords(entity)
            if #(BaitCoord - spawnedAnimalCoords) < 1 then
                ClearPedTasks(entity)
                Citizen.Wait(1500)
                TaskStartScenarioInPlace(entity, "WORLD_DEER_GRAZING", 0, true)
                Citizen.SetTimeout(Config.AnimalsEatingSpeed, function()
                    finished = true
                end)
            end
            if #(spawnedAnimalCoords - GetEntityCoords(PlayerPedId())) < Config.AnimalsFleeView then
                ClearPedTasks(entity)
                TaskSmartFleePed(entity, PlayerPedId(), 600.0, -1)
                finished = true
            end
            Citizen.Wait(1000)
        end
        if not IsPedDeadOrDying(entity) then
            TaskSmartFleePed(entity, PlayerPedId(), 600.0, -1)
        end
    end)
end

-- 
function getSpawnLocation(coord)
    local maxRadius = Config.maxSpawnDistance
    local minRadius = Config.minSpawnDistance

    local safeCoord, outPosition
    local finished = false
    local index = 0

    while finished == false and index <= 1000 do
        posX = coord.x + (math.random(minRadius, maxRadius) * math.cos(Config.spawnAngle))
        posY = coord.y + (math.random(minRadius, maxRadius) * math.sin(Config.spawnAngle))
        Z = coord.z + 999.0
        heading = math.random(0, 359) + .0
        ground, posZ = GetGroundZFor_3dCoord(posX + .0, posY + .0, Z, true)

        -- if game engine thinks coord is good to spawn exit loop
        safeCoord, outPosition = GetSafeCoordForPed(posX, posY, posZ, false, 16)
        finished = safeCoord
        index = index + 1
    end
    return vector4(posX, posY, posZ, heading)
end

function createDespawnThread(baitAnimal, was_llegal, baitcoord)
    Citizen.CreateThread(function()
        local finished = false
        local range = Config.animalDespawnRange
        local initalAnimalLocation = GetEntityCoords(baitAnimal)
        local waitForAnimalToMoveIndex = 0
        while finished == false do
            local plyPed = PlayerPedId()
            local coord = GetEntityCoords(plyPed)

            local animalCoord = GetEntityCoords(baitAnimal)
            local isDead = IsEntityDead(baitAnimal)
            local distance = #(coord - animalCoord)

            if distance <= 70 and not isDead then
                ShakeGameplayCam("VIBRATE_SHAKE" --[[ string ]] , 0.2)
            elseif distance <= 25 and not isDead then
                ShakeGameplayCam("VIBRATE_SHAKE" --[[ string ]] , 0.5)
            elseif distance <= 10 and not isDead then
                ShakeGameplayCam("VIBRATE_SHAKE" --[[ string ]] , 0.8)
            elseif isDead then
                StopGameplayCamShaking(true)
                local callPoliceChance = callPoliceChance()
                if was_llegal == false and callPoliceChance == 1 then
                    Config.llegalHuntingNotification(animalCoord)
                end
                finished = true
            end
            if distance >= range then
                SetModelAsNoLongerNeeded(baitAnimal)
                SetPedAsNoLongerNeeded(baitAnimal) -- despawn when player no longer in the area
                finished = true
            end

            --- warp animal to near road if it's not moving 
            if #(initalAnimalLocation - animalCoord) <= 15 then
                waitForAnimalToMoveIndex = waitForAnimalToMoveIndex + 1
            end
            if waitForAnimalToMoveIndex == 10 then
                print('warp needed!')
                local tmpcord = getSpawnLocation(coord)
                local r, outPosition, outHeading = GetClosestVehicleNodeWithHeading(tmpcord.x, tmpcord.y, tmpcord.z, 1,
                    3.0, 0)
                SetEntityCoordsNoOffset(baitAnimal, outPosition.x, outPosition.y, outPosition.z, 1)
                TaskGoToCoordAnyMeans(baitAnimal, baitcoord, 2.0, 0, 786603, 0xbf800000)
                initalAnimalLocation = GetEntityCoords(baitAnimal)
                waitForAnimalToMoveIndex = 0
            end
            Wait(1000)
        end
    end)
end

-- @type number
function callPoliceChance()
    return Alias_table_wrapper(Config.callPoliceChance)
end

function makeEntityFaceEntity(entity1, entity2)
    local p1 = GetEntityCoords(entity1, true)
    local p2 = GetEntityCoords(entity2, true)

    local dx = p2.x - p1.x
    local dy = p2.y - p1.y

    local heading = GetHeadingFromVector_2d(dx, dy)
    SetEntityHeading(entity1, heading)

end

RegisterNetEvent('keep-hunting:marketshop')
AddEventHandler('keep-hunting:marketshop', function(shop, itemData, amount)
    local ShopItems = {}
    ShopItems.label = Config.Shop["label"]
    ShopItems.items = Config.HuntingShopItems
    ShopItems.slots = 30
    TriggerServerEvent("inventory:server:OpenInventory", "shop", "Itemshop_" .. Config.Shop["name"], ShopItems)
end)

function ToggleSlaughterAnimation(toggle, animalEnity)
    local ped = PlayerPedId()
    Wait(250)
    if toggle then
        makeEntityFaceEntity(ped, animalEnity)
        loadAnimDict('amb@medic@standing@kneel@base')
        loadAnimDict('anim@gangops@facility@servers@bodysearch@')
        TaskPlayAnim(GetPlayerPed(-1), "amb@medic@standing@kneel@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
        TaskPlayAnim(GetPlayerPed(-1), "anim@gangops@facility@servers@bodysearch@", "player_search", 8.0, -8.0, -1, 48,
            0, false, false, false)
    elseif not toggle then
        SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
        ClearPedTasks(ped)
    end
end

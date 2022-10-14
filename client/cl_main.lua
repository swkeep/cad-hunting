-- ============================
--    CLIENT CONFIGS
-- ============================
local CoreName = exports['qb-core']:GetCoreObject()

local started = false
local Zones = {} -- hunting zone
local in_zone = false -- hunting zone
local current_zone = {}
local zone_type

-- bait
local baitCooldown = Config.BaitCooldown
local deployedBaitCooldown = 0

-- spwaning timer
local spawningTime = Config.SpawningTimer
local startSpawningTimer = 0

local spawnedAnimalsBlips = Config.spawnedAnimalsBlips
local spawnedAnimalsBlipsConfig = Config.AnimalBlip



-- ============================
--      FUNCTIONS
-- ============================
-- add CircleZone for hunting zones
function AddCircleZone(name, llegal, center, radius, options)
    Zones[name] = CircleZone:Create(center, radius, options)
    Zones[name]:onPlayerInOut(function(isPointInside)
        if isPointInside then
            in_zone = true
            current_zone = Zones[name]
            zone_type = llegal
        else
            in_zone = false
            current_zone = nil
            zone_type = nil
        end
    end)
end

local function load_model(model)
    if not HasModelLoaded(model) then
        RequestModel(model)
        Wait(10)
    end
    while not HasModelLoaded(model) do
        Wait(10)
    end
end

DecorRegister("HUNTINGSOURCE", 3)

local function HUNTINGSOURCE(entity)
    if DecorGetInt(entity, 'HUNTINGSOURCE') == 0 then
        DecorSetInt(entity, 'HUNTINGSOURCE', PlayerPedId())
        return true
    end

    if DecorGetInt(entity, 'HUNTINGSOURCE') ~= PlayerPedId() then
        return false
    else
        return true
    end
end

AddEventHandler('keep-hunting:client:slaughterAnimal', function(entity)
    local model = GetEntityModel(entity)
    local animal = getAnimalMatch(model)

    if not (model and animal) then return end

    local hasitem = CoreName.Functions.HasItem("weapon_knife")
    if not hasitem then
        CoreName.Functions.Notify("You dont have knife.")
        return
    end
    if not HUNTINGSOURCE(entity) then
        CoreName.Functions.Notify("Already processed by another person!")
        return
    end
    ClearPedTasks(PlayerPedId())
    ToggleSlaughterAnimation(true, entity)

    CoreName.Functions.Progressbar("harv_anim", "Slaughtering Animal", Config.SlaughteringSpeed, false,
        false, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = true,
            disableCombat = true
        }, {}, {}, {}, function()
        ToggleSlaughterAnimation(false, 0)
        if AnimalLootMultiplier:read(entity) ~= nil and AnimalLootMultiplier:read(entity) ~= false then
            TriggerServerEvent('keep-hunting:server:AddItem', animal, NetworkGetNetworkIdFromEntity(entity),
                AnimalLootMultiplier:read(entity))
        else
            -- defalut values for multipiler
            TriggerServerEvent('keep-hunting:server:AddItem', animal, NetworkGetNetworkIdFromEntity(entity), 'default')
        end
    end)
end)

AddEventHandler('keep-hunting:client:sellREQ', function()
    TriggerServerEvent('keep-hunting:server:sellmeat')
end)

RegisterNetEvent('keep-hunting:client:ForceRemoveAnimalEntity')
AddEventHandler('keep-hunting:client:ForceRemoveAnimalEntity', function(entity)
    DeleteEntity(entity)
    AnimalLootMultiplier[entity] = nil
end)

-- ============================
--      Bait
-- ============================
local function check_hunting_hour()
    local start = Config.HuntingHours.range.start
    local ends = Config.HuntingHours.range.ends
    local hour = GetClockHours()
    local minute = GetClockMinutes()
    local huntingHour = false
    if start > ends then
        -- don't judge me okeay xd
        if hour == start then
            huntingHour = true
        elseif hour == 0 then
            huntingHour = true
        elseif hour <= ends then
            huntingHour = true
        else
            huntingHour = false
        end
    else
        if start <= hour and ends >= hour then
            huntingHour = true
        else
            huntingHour = false
        end
    end
    return huntingHour
end

local function createThreadAnimalSpawningTimer(coord, indicator)
    local outPosition = getSpawnLocation(coord)

    if outPosition.x ~= 0 and outPosition.y ~= 0 and outPosition.z ~= 0 then
        Citizen.CreateThread(function()
            startSpawningTimer = spawningTime
            while startSpawningTimer > 0 do
                startSpawningTimer = startSpawningTimer - 1000
                Wait(1000)
            end
            if startSpawningTimer == 0 then
                createThreadBaitCooldown()
                TriggerServerEvent('keep-hunting:server:choiceWhichAnimalToSpawn', coord, outPosition, zone_type,
                    indicator)
            else
                CoreName.Functions.Notify("Failed to triger bait!")
            end
        end)
    else
        CoreName.Functions.Notify("Find a better location to place your bait!")
    end
end

RegisterNetEvent('keep-hunting:client:useBait', function()
    local function spawnBaitObject(model, coord)
        local entity = CreateObject(model, coord.x, coord.y, coord.z, 0, 0, 0)
        while not DoesEntityExist(entity) do
            Wait(10)
        end
        PlaceObjectOnGroundProperly(entity)
        FreezeEntityPosition(
            entity,
            true
        )
        return entity
    end

    local plyPed = PlayerPedId()
    local coord = GetEntityCoords(plyPed)
    if not in_zone or not current_zone then
        CoreName.Functions.Notify("You must be in hunting area to deploy your bait!")
        return
    end

    if not (deployedBaitCooldown <= 0) then
        CoreName.Functions.Notify("Baiting is on cooldown! Remaining: " .. (deployedBaitCooldown / 1000) .. "sec")
        return
    end

    if zone_type == nil then
        CoreName.Functions.Notify("Could not get zone llegal type!", 'error')
        return
    end

    if Config.HuntingHours.active == true then
        local hunting_hour = check_hunting_hour()
        if hunting_hour ~= nil and hunting_hour == false then
            CoreName.Functions.Notify("You cant hunt at this hour")
            return
        end
    end

    ClearPedTasks(plyPed)
    TaskStartScenarioInPlace(plyPed, "WORLD_HUMAN_GARDENER_PLANT", 0, true)
    CoreName.Functions.Progressbar("harv_anim", "Placing Bait", Config.BaitPlacementSpeed, false, false, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true
    }, {}, {}, {}, function()
        ClearPedTasks(plyPed)
        local indicator = nil
        if Config.BaitIndicator.active == true then
            indicator = spawnBaitObject(Config.BaitIndicator.model, coord)
        end
        createThreadAnimalSpawningTimer(coord, indicator)
    end)
end)

RegisterNetEvent('keep-hunting:client:spawnAnimal', function(coord, outPosition, C_animal, was_llegal, indicator)
    load_model(C_animal.hash)
    local baitAnimal = CreatePed(28, C_animal.hash, outPosition.x, outPosition.y, outPosition.z, outPosition.w, true,
        true)
    SetEntityAsMissionEntity(baitAnimal, true, true)

    if spawnedAnimalsBlips == true then
        local blip = AddBlipForEntity(baitAnimal)
        LeastSpawnedAnimal = baitAnimal
        SetBlipSprite(blip, spawnedAnimalsBlipsConfig.sprite) -- if you want the animals to have blips change the 0 to a different blip number
        SetBlipColour(blip, spawnedAnimalsBlipsConfig.color)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Baited animal")
        EndTextCommandSetBlipName(blip)
    end

    if not DoesEntityExist(baitAnimal) then
        print("debug: spwan failed")
        return
    end

    TriggerServerEvent('keep-hunting:server:removeBaitFromPlayerInventory')
    createThreadAnimalTraveledDistanceToBaitTracker(coord, baitAnimal, indicator)
    createDespawnThread(baitAnimal, was_llegal, coord, indicator)
    putQbTargetOnEntity(baitAnimal)
    print("debug: spwan success")
end)

-- ============================
--      Spawning Ped Command
-- ============================

RegisterNetEvent('keep-hunting:client:spawnanim', function(model, was_llegal)
    model = (tonumber(model) ~= nil and tonumber(model) or GetHashKey(model))
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local x, y, z = table.unpack(coords + forward * 1.0)

    Citizen.CreateThread(function()
        load_model(model)
        baitAnimal = CreatePed(5, model, x, y, z, 0.0, true, false)
        createDespawnThread(baitAnimal, was_llegal)
        putQbTargetOnEntity(baitAnimal)
    end)
end)

RegisterNetEvent('keep-hunting:client:clearTask')
AddEventHandler('keep-hunting:client:clearTask', function()
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
end)


-- cooldown

function createThreadBaitCooldown()
    Citizen.CreateThread(function()
        deployedBaitCooldown = baitCooldown
        while deployedBaitCooldown > 0 do
            deployedBaitCooldown = deployedBaitCooldown - 1000
            Wait(1000)
        end
    end)
end

-- Shooting protection system
if Config.ShootingProtection then
    local hasMusket = false

    function disablePlayerFiring()
        DisableControlAction(0, 24) -- INPUT_ATTACK
        DisableControlAction(0, 69) -- INPUT_VEH_ATTACK
        DisableControlAction(0, 70) -- INPUT_VEH_ATTACK2
        DisableControlAction(0, 92) -- INPUT_VEH_PASSENGER_ATTACK
        DisableControlAction(0, 114) -- INPUT_VEH_FLY_ATTACK
        DisableControlAction(0, 257) -- INPUT_ATTACK2
        DisableControlAction(0, 331) -- INPUT_VEH_FLY_ATTACK2

        DisableControlAction(0, 282) -- INPUT_VEH_FLY_ATTACK2
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 47, true)
        DisableControlAction(0, 58, true)
        DisablePlayerFiring(ped, true)
    end

    local function blockShooting()
        local playerId = PlayerId()
        local PlyPedId = PlayerPedId()
        Citizen.CreateThread(function()
            while hasMusket do
                Citizen.Wait(1)
                local aiming, targetPed = GetEntityPlayerIsFreeAimingAt(playerId)
                local PedType = GetPedType(targetPed)

                if aiming then
                    if DoesEntityExist(targetPed) and IsEntityAPed(targetPed) and
                        (PedType == 4 or PedType == 5 or PedType == 2 or PedType == 1) then
                        DisablePlayerFiring(playerId, true)
                        disablePlayerFiring()
                    end
                else
                    if IsPedShooting(PlyPedId) then
                        SetCurrentPedWeapon(PlyPedId, "weapon_unarmed", true)
                    else
                        hasMusket = false
                    end
                end
            end
        end)
    end

    local hashTable = {}
    for key, weapon in pairs(Config.ProtectedWeapons) do
        table.insert(hashTable, GetHashKey(weapon))
    end
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5)
            for key, weaponHash in pairs(hashTable) do
                if hasMusket == false then
                    if GetSelectedPedWeapon(PlayerPedId()) == weaponHash then
                        hasMusket = true
                        blockShooting()
                    else
                        hasMusket = false
                    end
                end
            end
        end
    end)
end

local function start()
    if started then return end
    started = true
    Citizen.CreateThread(function()
        spawn_seller_npc()
        createCustomBlips(Config.SellSpots)
        createCustomBlips(Config.HuntingArea)
        if Config.SlughterEveryAnimal == true then
            putQbTargetAllOnAnimals()
        end
    end)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    start()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    start()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

end)

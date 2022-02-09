-- ============================
--    CLIENT CONFIGS
-- ============================
local CoreName = exports['qb-core']:GetCoreObject()

local inzone = false -- hunting zone
local Zones = {} -- hunting zone

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
    table.insert(Zones[name], {
        llegal = llegal
    })
end

function initBlips()
    initSellspotsQbTargets(Config.SellSpots)
    createCustomBlips(Config.SellSpots)
    createCustomBlips(Config.HuntingArea)
end

Citizen.CreateThread(function()
    Wait(7)
    initBlips()
    initAnimalsTargting()
    -- SetRelationshipBetweenGroups(5, GetHashKey(GetPlayerPed(-1)), GetHashKey("a_c_mtlion"))
    -- SetRelationshipBetweenGroups(5, GetHashKey("a_c_mtlion"), GetHashKey(GetPlayerPed(-1)))
end)

AddEventHandler('cad-hunting:client:slaughterAnimal', function(entity)
    local model = GetEntityModel(entity)
    local animalCoord = GetEntityCoords(entity)
    local animal = getAnimalMatch(model)

    if (model and animal) then
        CoreName.Functions.TriggerCallback("QBCore:HasItem", function(hasitem)
            if hasitem then
                SetEntityCoords(GetPlayerPed(-1), animalCoord.x - 0.5, animalCoord.y, animalCoord.z - 0.8, ture, false,
                    true, false)
                makeEntityFaceEntity(GetPlayerPed(-1), entity)
                loadAnimDict('amb@medic@standing@kneel@base')
                loadAnimDict('anim@gangops@facility@servers@bodysearch@')
                TaskPlayAnim(GetPlayerPed(-1), "amb@medic@standing@kneel@base", "base", 8.0, -8.0, -1, 1, 0, false,
                    false, false)
                TaskPlayAnim(GetPlayerPed(-1), "anim@gangops@facility@servers@bodysearch@", "player_search", 8.0, -8.0,
                    -1, 48, 0, false, false, false)
                CoreName.Functions.Progressbar("harv_anim", "Slaughtering Animal", Config.SlaughteringSpeed, false,
                    false, {
                        disableMovement = true,
                        disableCarMovement = false,
                        disableMouse = false,
                        disableCombat = true
                    }, {}, {}, {}, function()
                        ClearPedTasks(GetPlayerPed(-1))
                        TriggerServerEvent('cad-hunting:server:AddItem', animal, entity)
                        Citizen.Wait(100)
                        DeleteEntity(entity)
                    end)
            else
                CoreName.Functions.Notify("You dont have knife.")
            end
        end, "weapon_knife")
    end
end)

AddEventHandler('cad-hunting:client:sellREQ', function()
    TriggerServerEvent('cad-hunting:server:sellmeat')
end)

RegisterNetEvent('cad-hunting:client:ForceRemoveAnimalEntity')
AddEventHandler('cad-hunting:client:ForceRemoveAnimalEntity', function(entity)
    DeleteEntity(entity)
end)

function isPedInHuntingZone(type)
    local plyPed = PlayerPedId()
    local coord = GetEntityCoords(plyPed)
    local legl

    for _, zone in pairs(Zones) do
        if zone:isPointInside(coord) then
            return {
                inzone = true,
                llegal = zone[1].llegal
            }
        else
            legl = zone[1].llegal
        end
    end
    return {
        inzone = false,
        llegal = legl
    }
end

-- ============================
--      Bait
-- ============================
RegisterNetEvent('keep-hunting:client:useBait')
AddEventHandler('keep-hunting:client:useBait', function()
    local plyPed = PlayerPedId()
    local coord = GetEntityCoords(plyPed)
    local inHuntingZone = isPedInHuntingZone()
    if inHuntingZone.inzone then
        if deployedBaitCooldown <= 0 then
            ClearPedTasks(plyPed)
            TaskStartScenarioInPlace(plyPed, "WORLD_HUMAN_GARDENER_PLANT", 0, true)
            -- loadAnimDict('amb@medic@standing@kneel@base')
            -- TaskPlayAnim(plyPed, "amb@medic@standing@kneel@base", "base", 8.0, -8.0, -1, 1, 0, false, false,
            -- false)
            CoreName.Functions.Progressbar("harv_anim", "Placing Bait", Config.BaitPlacementSpeed, false, false, {
                disableMovement = true,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true
            }, {}, {}, {}, function()
                ClearPedTasks(plyPed)
                createThreadAnimalSpawningTimer(coord, inHuntingZone.llegal)
            end)
        else
            CoreName.Functions.Notify("Baiting is on cooldown! Remaining: " .. (deployedBaitCooldown / 1000) .. "sec")
        end
    else
        CoreName.Functions.Notify("You must be in hunting area to deploy your bait!")
    end
end)

function createThreadBaitCooldown()
    Citizen.CreateThread(function()
        deployedBaitCooldown = baitCooldown
        while deployedBaitCooldown > 0 do
            deployedBaitCooldown = deployedBaitCooldown - 1000
            Wait(1000)
        end
    end)
end

function createThreadAnimalSpawningTimer(coord, was_llegal)
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
                TriggerServerEvent('keep-hunting:server:choiceWhichAnimalToSpawn', coord, outPosition, was_llegal)
            else
                CoreName.Functions.Notify("Failed to triger bait!")
            end
        end)
    else
        CoreName.Functions.Notify("pls find a better location for you bait!")
    end
end

RegisterNetEvent('keep-hunting:client:spawnAnimal')
AddEventHandler('keep-hunting:client:spawnAnimal', function(coord, outPosition, C_animal, was_llegal)
    if not HasModelLoaded(C_animal.hash) then
        RequestModel(C_animal.hash)
        Wait(10)
    end
    while not HasModelLoaded(C_animal.hash) do
        Wait(10)
    end
    local baitAnimal = CreatePed(28, C_animal.hash, outPosition.x, outPosition.y, outPosition.z, outPosition.w, true,
        true)
    SetEntityAsMissionEntity(baitAnimal, true, true)

    if spawnedAnimalsBlips == true then
        local blip = AddBlipForEntity(baitAnimal)
        SetBlipSprite(blip, spawnedAnimalsBlipsConfig.sprite) -- if you want the animals to have blips change the 0 to a different blip number
        SetBlipColour(blip, spawnedAnimalsBlipsConfig.color)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("bait animal")
        EndTextCommandSetBlipName(blip)
    end

    if DoesEntityExist(baitAnimal) and TriggerServerEvent('keep-hunting:server:removeBaitFromPlayerInventory') then
        TaskGoToCoordAnyMeans(baitAnimal, coord, 2.0, 0, 786603, 0)
        createThreadAnimalTraveledDistanceToBaitTracker(coord, baitAnimal)
        createDespawnThread(baitAnimal, was_llegal)
        print("debug: spwan success")
    else
        print("debug: spwan failed != removeBaitFromPlayerInventory")
    end
end)

-- ============================
--      Spawning Ped Command
-- ============================
RegisterNetEvent('cad-hunting:client:spawnanim')
AddEventHandler('cad-hunting:client:spawnanim', function(model, was_llegal)
    model = (tonumber(model) ~= nil and tonumber(model) or GetHashKey(model))
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local x, y, z = table.unpack(coords + forward * 1.0)

    Citizen.CreateThread(function()
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(1)
        end
        baitAnimal = CreatePed(5, model, x, y, z, 0.0, true, false)
        --ExplodePedHead(baitAnimal, GetHashKey("weapon_musket"))
        createDespawnThread(baitAnimal, was_llegal)
    end)
end)

RegisterNetEvent('keep-hunting:client:clearTask')
AddEventHandler('keep-hunting:client:clearTask', function()
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
end)

-- ============================
--    CLIENT CONFIGS
-- ============================
local CoreName = exports['qb-core']:GetCoreObject()

local inzone = false -- hunting zone
local Zones = {} -- hunting zone

local entityPoliceAlert = {}

-- bait
local baitCooldown = Config.BaitCooldown
local deployedBaitCooldown = 0

-- spwaning timer
local spawningTime = Config.SpawningTimer
local startSpawningTimer = 0

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

function illlegalHuntingAreasAcions(inzone)
    -- if player is outside of llegal hunting zones
    if not inzone then
        local _, entity = GetEntityPlayerIsFreeAimingAt(PlayerId(), Citizen.ReturnResultAnyway())
        if entity and IsEntityDead(entity) then
            if IsEntityAPed(entity) then
                for _, value in pairs(Config.Animals) do
                    if value.hash == GetEntityModel(entity) then
                        if entityPoliceAlert ~= nill then
                            local isAlertNeeded = true
                            for _, alert in pairs(entityPoliceAlert) do
                                if alert == entity then
                                    isAlertNeeded = false
                                end
                            end
                            if isAlertNeeded == true then
                                table.insert(entityPoliceAlert, entity)
                                TriggerEvent("police:client:policeAlert", GetEntityCoords(entity),
                                    "illlegal Hunting in area")
                            end
                        else
                            table.insert(entityPoliceAlert, entity)
                            TriggerEvent("police:client:policeAlert", GetEntityCoords(entity),
                                "illlegal Hunting in area")
                        end
                    end
                end
            end
        end
    end
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
                -- SetEntityCoords(GetPlayerPed(-1) , animalCoord.x , animalCoord.y, animalCoord.z  , ture , false , true , false  )
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
    TriggerServerEvent('cad-hunting:server:sellmeat', animal)
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
                createThreadAnimalSpawningTimer(coord)
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

function createThreadAnimalSpawningTimer(coord)
    local safeCoord, outPosition = getSpawnLocation(coord)

    if outPosition.x > 1 or outPosition.x < -1 then
        Citizen.CreateThread(function()
            startSpawningTimer = spawningTime
            while startSpawningTimer > 0 do
                startSpawningTimer = startSpawningTimer - 1000
                Wait(1000)
            end
            if startSpawningTimer == 0 then
                createThreadBaitCooldown()
                TriggerServerEvent('keep-hunting:server:choiceWhichAnimalToSpawn', coord, outPosition)
            else
                CoreName.Functions.Notify("Failed to triger bait!")
            end
        end)
    else
        CoreName.Functions.Notify("Find Better Location To place yout bait!")
    end
end

RegisterNetEvent('keep-hunting:client:spawnAnimal')
AddEventHandler('keep-hunting:client:spawnAnimal', function(data)
    local animal = data[3]
    local outPosition = data[2]
    local coords = data[1]

    if not HasModelLoaded(animal.hash) then
        RequestModel(animal.hash)
        Wait(10)
    end
    while not HasModelLoaded(animal.hash) do
        Wait(10)
    end
    local baitAnimal = CreatePed(28, animal.hash, outPosition.x, outPosition.y, 0, true, true)
    SetEntityAsMissionEntity(baitAnimal, true, true)

    local blip = AddBlipForEntity(baitAnimal)
    SetBlipSprite(blip, 3) -- if you want the animals to have blips change the 0 to a different blip number
    SetBlipColour(blip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("spawned entity")
    EndTextCommandSetBlipName(blip)

    if DoesEntityExist(baitAnimal) then
        TaskGoToCoordAnyMeans(baitAnimal, coords, 2.0, 0, 786603, 0)
        createThreadAnimalTraveledDistanceToBaitTracker(coords, baitAnimal)
        TriggerServerEvent('keep-hunting:server:removeBaitFromPlayerInventory')
        -- SetModelAsNoLongerNeeded(baitAnimal)
        -- SetPedAsNoLongerNeeded(baitAnimal) -- despawn when player no longer in the area
        print("debug: spwan success")
    else
        print("debug: spwan failed")
    end
end)

-- ============================
--      Spawning Ped Command
-- ============================
RegisterNetEvent('cad-hunting:client:spawnanim')
AddEventHandler('cad-hunting:client:spawnanim', function(model)
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
        CreatePed(5, model, x, y, z, 0.0, true, false)
    end)
end)

RegisterNetEvent('keep-hunting:client:clearTask')
AddEventHandler('keep-hunting:client:clearTask', function()
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
end)

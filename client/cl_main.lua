-- ============================
--    CLIENT CONFIGS
-- ============================
local CoreName = exports['qb-core']:GetCoreObject()
local inzone = false
local Zones = {}
local entityPoliceAlert = {}
local alias_table = {}

local playerDeplyedBaitPlacementCooldown = 0
local isBaitUsed = false
local baitCooldown = Config.BaitCooldown
local spawningTimer = Config.SpawningTimer
local ActiveSpawningTimer = 0

-- ============================
--      FUNCTIONS
-- ============================
function AddCircleZone(name, center, radius, options)
    Zones[name] = CircleZone:Create(center, radius, options)
end

function initBlips()
    initSellspotsQbTargets(Config.SellSpots)
    createCustomBlips("normal", Config.SellSpots)
    createCustomBlips("area", Config.HuntingArea)
end

function ilegalHuntingAreasAcions(inzone)
    if not inzone and IsAimCamActive() then
        local _, entity = GetEntityPlayerIsFreeAimingAt(PlayerId(), Citizen.ReturnResultAnyway())
        if entity and IsEntityDead(entity) then
            if IsEntityAPed(entity) then
                if entityPoliceAlert ~= nill then
                    local isAlertNeeded = true
                    for _, alert in pairs(entityPoliceAlert) do
                        if alert == entity then
                            isAlertNeeded = false
                        end
                    end
                    if isAlertNeeded == true then
                        table.insert(entityPoliceAlert, entity)
                        TriggerEvent("police:client:policeAlert", GetEntityCoords(entity), "ilegal Hunting in area")
                    end
                else
                    table.insert(entityPoliceAlert, entity)
                    TriggerEvent("police:client:policeAlert", GetEntityCoords(entity), "ilegal Hunting in area")
                end
            end
        end
    end
end

Citizen.CreateThread(function()
    Wait(7)
    initBlips()
    initAnimalsTargting()
    SetRelationshipBetweenGroups(5, GetHashKey(GetPlayerPed(-1)), GetHashKey("a_c_mtlion"))
    SetRelationshipBetweenGroups(5, GetHashKey("a_c_mtlion"), GetHashKey(GetPlayerPed(-1)))
    while true do
        local plyPed = PlayerPedId()
        local coord = GetEntityCoords(plyPed)
        for _, zone in pairs(Zones) do
            if Zones[_]:isPointInside(coord) then
                inzone = true
            else
                inzone = false
            end
        end
        ilegalHuntingAreasAcions(inzone)
        Wait(550)
    end
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

-- ============================
--      Bait
-- ============================
RegisterNetEvent('keep-hunting:client:usedBait')
AddEventHandler('keep-hunting:client:usedBait', function()
    local plyPed = PlayerPedId()
    local coord = GetEntityCoords(plyPed)
    for _, zone in pairs(Zones) do
        if Zones[_]:isPointInside(coord) then
            inzone = true
            if playerDeplyedBaitPlacementCooldown <= 0 then
                -- TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                loadAnimDict('amb@medic@standing@kneel@base')
                TaskPlayAnim(PlayerPedId(), "amb@medic@standing@kneel@base", "base", 8.0, -8.0, -1, 1, 0, false, false,
                    false)
                CoreName.Functions.Progressbar("harv_anim", "Placing Bait", Config.BaitPlacementSpeed, false, false, {
                    disableMovement = true,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true
                }, {}, {}, {}, function()
                    isBaitUsed = true
                    ClearPedTasks(PlayerPedId())
                    if isBaitUsed then
                        TriggerServerEvent('keep-hunting:server:removeBaitFromPlayerInventory')
                        createThreadAnimalSpawningTimer(coord)
                    end
                end)
            else
                CoreName.Functions.Notify("Baiting is on cooldown! Remaining: " ..
                                              (playerDeplyedBaitPlacementCooldown / 1000) .. "sec")
            end
        else
            inzone = false
        end
    end
end)

function createThreadBaitCooldown()
    Citizen.CreateThread(function()
        playerDeplyedBaitPlacementCooldown = baitCooldown
        while playerDeplyedBaitPlacementCooldown > 0 do
            playerDeplyedBaitPlacementCooldown = playerDeplyedBaitPlacementCooldown - 1000
            Wait(1000)
        end
    end)
end

function createThreadAnimalSpawningTimer(coord)
    local radius = 100.0
    local x = coord.x + math.random(-radius, radius)
    local y = coord.y + math.random(-radius, radius)
    local safeCoord, outPosition = GetSafeCoordForPed(x, y, coord.z, false, 16)
    local animal = choiceAnimal(Config.Animals) -- Config.Animals => spwanRarity

    if outPosition.x > 1 or outPosition.x < -1 then
        Citizen.CreateThread(function()
            ActiveSpawningTimer = spawningTimer
            while ActiveSpawningTimer > 0 do
                ActiveSpawningTimer = ActiveSpawningTimer - 1000
                Wait(1000)
            end
            if ActiveSpawningTimer == 0 then
                createThreadBaitCooldown()
                TriggerEvent('keep-hunting:client:spawnAnimal', coord, outPosition, animal)
            else
                CoreName.Functions.Notify("Failed to triger bait!")
            end
        end)
    else
        CoreName.Functions.Notify("Find Better Location To place yout bait!")
    end
end

RegisterNetEvent('keep-hunting:client:spawnAnimal')
AddEventHandler('keep-hunting:client:spawnAnimal', function(coords, outPosition, animal)
    if not HasModelLoaded(animal.hash) then
        RequestModel(animal.hash)
        Wait(10)
    end
    while not HasModelLoaded(animal.hash) do
        Wait(10)
    end
    local baitAnimal = CreatePed(28, animal.hash, outPosition.x, outPosition.y, outPosition.z, 0, true, false)

    if DoesEntityExist(baitAnimal) then
        TaskGoToCoordAnyMeans(baitAnimal, coords, 2.0, 0, 786603, 0)
        createThreadAnimalSpawningDistanceToBaitTracker(coords, baitAnimal)
        isBaitUsed = false
    end
    print("debug: spwan success")
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
        local baitAnimal = CreatePed(5, model, x, y, z, 0.0, true, false)
        -- TaskCombatPed(baitAnimal --[[ Ped ]] , GetPlayerPed(playerPed) ,0 ,16 )
        -- TaskStartScenarioInPlace(baitAnimal, "WORLD_DEER_GRAZING", 0, true)
        -- TaskSmartFleeCoord(baitAnimal, coords.x, coords.y, coords.z, 600.0, -1, 0, 0)
        -- TaskSmartFleePed(baitAnimal, PlayerPedId(), 600.0, -1)
    end)
end)

-- ---------------------------------------------------

function choiceAnimal(Rarities)
    local temp = {}
    for key, value in pairs(Rarities) do
        table.insert(temp, value.spwanRarity)
    end
    if temp ~= nil then
        local sample = alias_table:new(temp)
        return Rarities[sample()]
    end
end

-- ---------------------------------------------------
-- https://gist.github.com/RyanPattison/7dd900f4042e8a6f9f23

function alias_table:new(weights)
    local total = 0
    for _, v in ipairs(weights) do
        assert(v >= 0, "all weights must be non-negative")
        total = total + v
    end

    assert(total > 0, "total weight must be positive")
    local normalize = #weights / total
    local norm = {}
    local small_stack = {}
    local big_stack = {}
    for i, w in ipairs(weights) do
        norm[i] = w * normalize
        if norm[i] < 1 then
            table.insert(small_stack, i)
        else
            table.insert(big_stack, i)
        end
    end

    local prob = {}
    local alias = {}
    while small_stack[1] and big_stack[1] do -- both non-empty
        small = table.remove(small_stack)
        large = table.remove(big_stack)
        prob[small] = norm[small]
        alias[small] = large
        norm[large] = norm[large] + norm[small] - 1
        if norm[large] < 1 then
            table.insert(small_stack, large)
        else
            table.insert(big_stack, large)
        end
    end

    for _, v in ipairs(big_stack) do
        prob[v] = 1
    end
    for _, v in ipairs(small_stack) do
        prob[v] = 1
    end

    self.__index = self
    return setmetatable({
        alias = alias,
        prob = prob,
        n = #weights
    }, self)
end

function alias_table:__call()
    local index = math.random(self.n)
    return math.random() < self.prob[index] and index or self.alias[index]
end

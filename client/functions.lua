local DEBUG = Config.DEBUG
local CoreName = exports['qb-core']:GetCoreObject()
AnimalLootMultiplier = {}

function AnimalLootMultiplier:new(ped, options)
    if ped == nil then
        return 'no ped found'
    end
    if self[ped] == nil then
        self[ped] = {}
    end
    if self[ped]['bones'] == nil then
        self[ped]['bones'] = {}
    end

    if options.bone ~= nil then
        table.insert(self[ped]['bones'], options.bone)
    end

    if options.weapon ~= nil then
        self[ped]['weapon'] = options.weapon
    end
end

function AnimalLootMultiplier:read(ped)
    if self[ped] ~= nil then
        return self[ped]
    else
        return false
    end
end

function createCustomBlips(data)
    for _, v in pairs(data) do
        -- create Blips
        if v.BlipsCoords ~= nil and v.showBlip == true then
            Blip = AddBlipForCoord(v.BlipsCoords.x, v.BlipsCoords.y, v.BlipsCoords.z)
        elseif v.BlipsCoords == nil and v.showBlip == true then
            Blip = AddBlipForCoord(v.coord.x, v.coord.y, v.coord.z)
        end
        SetBlipAsShortRange(Blip, true)
        if v.radius ~= nil then
            if v.showBlip == true then
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
            end
        else
            SetBlipSprite(Blip, 442)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.name)
            EndTextCommandSetBlipName(Blip)
        end
        SetBlipDisplay(Blip, 4)
        SetBlipScale(Blip, 0.6)
        SetBlipColour(Blip, 49)
    end
end

-- init qb-target for selling spots
function spawn_seller_npc()

    local function spawn_ped(data)
        RequestModel(data.model)
        while not HasModelLoaded(data.model) do
            Wait(0)
        end

        if type(data.model) == 'string' then data.model = GetHashKey(data.model) end

        local ped = CreatePed(1, data.model, data.coords, false, true)

        if data.freeze then FreezeEntityPosition(ped, true) end
        if data.invincible then SetEntityInvincible(ped, true) end
        if data.blockevents then SetBlockingOfNonTemporaryEvents(ped, true) end

        if data.scenario then
            SetPedCanPlayAmbientAnims(ped, true)
            TaskStartScenarioInPlace(ped, data.scenario, 0, true)
        end
        return ped
    end

    for _, spot in pairs(Config.SellSpots) do
        -- spwan seller npcs
        local c = vector3(spot.SellerNpc.coords.x, spot.SellerNpc.coords.y, spot.SellerNpc.coords.z - 1.0)

        local ped = spawn_ped({
            model = spot.SellerNpc.model,
            coords = vector4(c.x, c.y, c.z, spot.SellerNpc.coords.w),
            scenario = 'WORLD_HUMAN_CLIPBOARD',
            flag = 1,
            freeze = true,
            invincible = true,
            blockevents = true,
        })

        -- init qb-target for sellers
        exports['qb-target']:AddBoxZone("sell_spot" .. _, c, 0.5, 0.5, {
            name = "sell_spot" .. _,
            heading = spot.SellerNpc.coords.w,
            minZ = c.z,
            maxZ = c.z + 1.8,
        },
            {
                options = {
                    {
                        event = "keep-hunting:client:sellREQ",
                        icon = "fas fa-sack-dollar",
                        label = "Sell All"
                    }
                },
                distance = 1.5
            }
        )
    end
end

-- init qb-target for hunted animals
function putQbTargetAllOnAnimals()
    for _, v in pairs(Config.Animals) do
        exports['qb-target']:AddTargetModel(v.model, {
            options = { {
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
            } },
            distance = 1.5
        })
    end
end

function putQbTargetOnEntity(ped)
    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                icon = "fas fa-sack-dollar",
                label = "slaughter",
                canInteract = function(entity)
                    return IsEntityDead(entity)
                end,
                action = function(entity)
                    if IsEntityDead(entity) == false then
                        return false
                    end
                    TriggerEvent('keep-hunting:client:slaughterAnimal', entity)
                    return true
                end
            }
        },
        distance = 1.5
    })
end

-- match hash with out animal list
function getAnimalMatch(hash)
    for _, v in pairs(Config.Animals) do
        if (v.hash == hash) then
            return v
        end
    end
    return false
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(0)
    end
end

-- animals Smart Flee

function createThreadAnimalTraveledDistanceToBaitTracker(baitCoord, entity, indicator)
    -- entity is not moveing detaction
    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        local finished = false
        local FleeView = Config.AnimalsFleeView

        TaskGoToCoordAnyMeans(entity, baitCoord, 2.0, 0, 786603, 0xbf800000)
        while not IsPedDeadOrDying(entity) and not finished do
            local playerCoord = GetEntityCoords(playerPed)
            local entityCoord = GetEntityCoords(entity)

            if #(baitCoord - entityCoord) < 1 then
                -- when animal reached bait
                ClearPedTasks(entity)
                Citizen.Wait(1500)
                TaskStartScenarioInPlace(entity, "WORLD_DEER_GRAZING", 0, true)
                Citizen.SetTimeout(Config.AnimalsEatingSpeed, function()
                    deleteIndicator(indicator)
                    finished = true
                end)
            end
            if #(entityCoord - playerCoord) < FleeView then
                -- animal flee view
                ClearPedTasks(entity)
                TaskSmartFleePed(entity, playerPed, 600.0, -1)
                deleteIndicator(indicator)
                finished = true
            end

            -- track if animal can move toward bait or not
            animalAntiStuck(entity, baitCoord)

            Citizen.Wait(1000)
        end
        if not IsPedDeadOrDying(entity) then
            TaskSmartFleePed(entity, playerPed, 600.0, -1)
            deleteIndicator(indicator)
        end
    end)
end

function deleteIndicator(indicator)
    if indicator == nil then
        return
    end
    if DoesEntityExist(indicator) == 1 then
        DeleteEntity(indicator)
    end
end

--- check if animal can move toward bait
---@param entity 'entity'
---@param baitCoord 'vector3'
function animalAntiStuck(entity, baitCoord)
    local plyPed = PlayerPedId()
    local coord = GetEntityCoords(plyPed)
    local animalCoord = GetEntityCoords(entity)
    local distance = #(baitCoord - animalCoord)

    if IsPedStill(entity) and distance >= 25.0 then
        print('warp')
        local tmpcord = getSpawnLocation(coord)
        SetEntityCoordsNoOffset(entity, tmpcord.x, tmpcord.y, tmpcord.z, 1)
        TaskGoToCoordAnyMeans(entity, baitCoord, 2.0, 0, 786603, 0xbf800000)
    end
end

--- generate safe spawn location
---@param coord 'vector3'
-- function getSpawnLocation(coord)
--     local maxRadius = Config.maxSpawnDistance
--     local minRadius = Config.minSpawnDistance

--     local safeCoord, outPosition
--     local finished = false
--     local index = 0

--     while finished == false and index <= 1000 do
--         local angle = Config.spawnAngle
--         local random
--         for i = 1, 10, 1 do
--             random = math.random(angle[1], angle[2])
--         end
--         posX = coord.x + (math.random(minRadius, maxRadius) * math.cos(random))
--         posY = coord.y + (math.random(minRadius, maxRadius) * math.sin(random))

--         Z = coord.z + 999.0
--         heading = math.random(0, 359) + .0
--         ground, posZ = GetGroundZFor_3dCoord(posX + .0, posY + .0, Z, true)

--         -- if game engine thinks coord is good to spawn exit loop
--         safeCoord, outPosition = GetSafeCoordForPed(posX, posY, posZ, false, 16)
--         finished = safeCoord
--         index = index + 1
--     end
--     return vector4(posX, posY, posZ, heading)
-- end
-- (BrianTU)
function getSpawnLocation(coord)
    local maxRadius = Config.maxSpawnDistance
    local minRadius = Config.minSpawnDistance

    local safeCoord, outPosition
    local finished = false
    local index = 0

    while finished == false and index <= 250 do
        local angle = Config.spawnAngle
        local random
        for i = 1, 10, 1 do
            random = math.random(angle[1], angle[2])
        end
        posX = coord.x + (math.random(minRadius, maxRadius) * math.cos(random))
        posY = coord.y + (math.random(minRadius, maxRadius) * math.sin(random))

        Z = coord.z + 999.0
        heading = math.random(0, 359) + .0
        ground, posZ = GetGroundZFor_3dCoord(posX + .0, posY + .0, Z, true)

        -- if game engine thinks coord is good to spawn exit loop
        safeCoord, outPosition = GetSafeCoordForPed(posX, posY, posZ, false, 16)
        local _, closstRd, face = GetClosestVehicleNodeWithHeading(posX, posY, posZ, 1, 100, 2.5)
        if safeCoord then
            finished = safeCoord
        elseif closstRd ~= nil then
            finished = true
            posX = closstRd.x
            posY = closstRd.y
            posZ = closstRd.z
            heading = face
        end
        index = index + 1
    end
    return vector4(posX, posY, posZ, heading)
end

function createDespawnThread(baitAnimal, was_llegal, baitcoord, indicator)
    Citizen.CreateThread(function()
        local finished = false
        local range = Config.animalDespawnRange
        local maxHelath = GetEntityMaxHealth(baitAnimal)

        while finished == false do
            local plyPed = PlayerPedId()
            local coord = GetEntityCoords(plyPed)

            local animalCoord = GetEntityCoords(baitAnimal)
            local isDead = IsEntityDead(baitAnimal)
            local distance = #(coord - animalCoord)

            if distance <= 70 and not isDead then
                ShakeGameplayCam("VIBRATE_SHAKE", 0.2)
            elseif distance <= 25 and not isDead then
                ShakeGameplayCam("VIBRATE_SHAKE", 0.5)
            elseif distance <= 10 and not isDead then
                ShakeGameplayCam("VIBRATE_SHAKE", 0.8)
            elseif isDead then
                StopGameplayCamShaking(true)
                local callPoliceChance = callPoliceChance()
                if was_llegal == false and callPoliceChance == 1 then
                    Config.llegalHuntingNotification(animalCoord)
                end
                finished = true
            end
            -- when the animal has taken the set distance from the player
            if distance >= range then
                deleteIndicator(indicator)
                SetModelAsNoLongerNeeded(baitAnimal)
                SetPedAsNoLongerNeeded(baitAnimal) -- despawn when player no longer in the area
                finished = true
            end
            Wait(1000)
        end
    end)
    CreateThread(function()
        local maxHealth = GetPedMaxHealth(baitAnimal)
        local tmpHealth = maxHealth
        while IsPedDeadOrDying(baitAnimal) == false do
            local currentHealth = GetEntityHealth(baitAnimal)
            if currentHealth ~= tmpHealth then
                local retval, outBone = GetPedLastDamageBone(baitAnimal)
                -- print(currentHealth, outBone)
                AnimalLootMultiplier:new(baitAnimal, {
                    bone = outBone
                })
                tmpHealth = currentHealth
            end
            Wait(50)
        end

        if IsPedDeadOrDying(baitAnimal) == 1 then
            Wait(100)
            -- https://github.com/citizenfx/fivem/blob/master/code/client/clrcore/External/BoneID.cs
            -- SKEL_Head = 31086 headshot
            local retval, outBone = GetPedLastDamageBone(baitAnimal)

            local weaponHash = GetPedCauseOfDeath(baitAnimal)
            WeaponQuality = getWeaponQualityMultiplier(weaponHash)

            AnimalLootMultiplier:new(baitAnimal, {
                bone = outBone,
                weapon = WeaponQuality
            })
        end
    end)

end

function getWeaponQualityMultiplier(weaponHash)
    for key, value in pairs(Config.weaponQualityMultiplier) do
        if GetHashKey(key) == weaponHash then
            return value
        end
    end
    return Config.weaponQualityMultiplier.default
end

function search(table, text)
    for index, data in ipairs(table) do
        if data == text then
            return true
        end
    end
    return false
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

function ToggleSlaughterAnimation(toggle, animalEnity)
    local ped = PlayerPedId()
    Wait(250)
    if toggle then
        makeEntityFaceEntity(ped, animalEnity)
        loadAnimDict('amb@medic@standing@kneel@base')
        loadAnimDict('anim@gangops@facility@servers@bodysearch@')
        TaskPlayAnim(GetPlayerPed(-1), "amb@medic@standing@kneel@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
        TaskPlayAnim(GetPlayerPed(-1), "anim@gangops@facility@servers@bodysearch@", "player_search", 8.0, -8.0, -1, 1,
            0, false, false, false)
    elseif not toggle then
        SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
        ClearPedTasks(ped)
    end
end

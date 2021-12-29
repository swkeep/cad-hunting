function createCustomBlips(type, data)
    for _, v in pairs(data) do
        -- create Blips
        local blip = AddBlipForCoord(v.BlipsCoords.x, v.BlipsCoords.y, v.BlipsCoords.z)
        SetBlipAsShortRange(blip, true)
        if type == "area" then
            SetBlipSprite(blip, 141)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.name)
            EndTextCommandSetBlipName(blip)
            RadiusBlip = AddBlipForRadius(v.BlipsCoords.x, v.BlipsCoords.y, v.BlipsCoords.z, v.radius)
            AddCircleZone(v.name, v.BlipsCoords, v.radius, {
                name = "circle_zone",
                debugPoly = false
            })
            SetBlipRotation(RadiusBlip, 0)
            SetBlipColour(RadiusBlip, 4)
            SetBlipAlpha(RadiusBlip, 64)
        else
            SetBlipSprite(blip, 442)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Sell Meat")
            EndTextCommandSetBlipName(blip)
        end
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.6)
        SetBlipColour(blip, 49)
    end
end

-- init qb-target for selling spots 
function initSellspotsQbTargets(sellspot)
    for _, v in pairs(Config.SellSpots) do
        -- spwan seller npcs
        exports['qb-target']:SpawnPed({
            [_] = v.SellerNpc
        })

        -- init qb-target for sellers
        exports['qb-target']:AddTargetModel(v.SellerNpc.model, {
            options = {{
                event = "cad-hunting:client:sellREQ",
                icon = "fas fa-sack-dollar",
                label = "Sell MMMMMMEATTTTTTTT"
            }},
            distance = 1.5
        })
    end
end

-- init qb-target for hunted animals
function initAnimalsTargting()
    for _, v in pairs(Config.Animals) do
        exports['qb-target']:AddTargetModel(v.model, {
            options = {{
                icon = "fas fa-sack-dollar",
                label = "slaughter",
                data = entity,
                canInteract = function(entity)
                    if not IsPedAPlayer(entity) then
                        local res = (entity and IsEntityDead(entity))
                        return res
                    end
                end,
                action = function(entity)
                    if IsPedAPlayer(entity) then
                        return false
                    end
                    TriggerEvent('cad-hunting:client:slaughterAnimal', entity)
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

function weightedRandom(Rarities)
    local Index = math.random()
    local HighestRarity = "Common"

    for RarityName, Value in pairs(Rarities) do
        if Index >= Value and Value >= Rarities[HighestRarity] then
            HighestRarity = RarityName
        end
    end

    return HighestRarity
end

-- animals Smart Flee

function createThreadAnimalTraveledDistanceToBaitTracker(BaitCoord, entity)
    Citizen.CreateThread(function()
        local finished = false
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

local CoreName = exports['qb-core']:GetCoreObject()
local TableSize = Config.sv_maxTableSize
local garbageCollection_tm = Config.sv_dataClearnigTimer
local Animals = Config.Animals

-- ============================
--       EVENTS
-- ============================
local animalsEnity = {} -- prevent players to slaughter twice

RegisterServerEvent("keep-hunting:server:AddItem")
AddEventHandler("keep-hunting:server:AddItem", function(data, entity, multiplier)
    local _source = source
    local Player = CoreName.Functions.GetPlayer(_source)

    for _, v in pairs(Config.Animals) do
        if v.model == data.model then
            -- check if another player already slaughtered or not
            if animalsEnity ~= nil then
                if isAleadySlaughtered(entity) == false then
                    setHash(entity) -- prevent player to slaughter twice
                    choiceRewardsForPlayer(v.Loots, _source, Player, multiplier)
                    TriggerClientEvent('keep-hunting:client:ForceRemoveAnimalEntity', -1, entity)
                else
                    TriggerClientEvent('QBCore:Notify', _source, "Someone already slaughtered this animal!")
                    TriggerClientEvent('keep-hunting:client:ForceRemoveAnimalEntity', -1, entity)
                end
            else
                -- init animalsEnity table
                setHash(entity) -- prevent player to slaughter twice
                choiceRewardsForPlayer(v.Loots, _source, Player, multiplier)
            end
        end
    end
end)

function choiceRewardsForPlayer(LootTable, _source, Player, multiplier)
    local tmpRewardChances = {}
    local DefiniteRewardsList = {}
    local ChanceRewardsList = {}
    local CalculatedPlayerRwardList = {}
    local multiplierResult = 0

    for key, value in pairs(LootTable) do
        -- value[1] contains item names
        -- value[2] contains lootTable Chances

        -- Separate Definite and Chance Rewarding
        if value[2] == 100 then
            -- Definite
            table.insert(DefiniteRewardsList, value[1])
        else
            -- Chance
            table.insert(tmpRewardChances, { value[1], value[2] })
        end
    end

    if tmpRewardChances ~= nil then
        ChanceRewardsList = CompleteRestOfChancesData(tmpRewardChances)
    end

    CalculatedPlayerRwardList = { table.unpack(DefiniteRewardsList), table.unpack(ChanceRewardsList) }

    multiplierResult = calMultiplier(multiplier)

    for key, value in pairs(CalculatedPlayerRwardList) do

        if multiplierResult ~= 0 then
            Player.Functions.AddItem(value, multiplierResult)
            TriggerClientEvent("inventory:client:ItemBox", _source, CoreName.Shared.Items[value], "add")
        else
            Player.Functions.AddItem(value, 1)
            TriggerClientEvent("inventory:client:ItemBox", _source, CoreName.Shared.Items[value], "add")
        end

    end
end

function calMultiplier(multiplier)
    if Config.activateLootMultiplier == nil or Config.activateLootMultiplier == false then
        return 0
    end
    if multiplier ~= nil and type(multiplier) == "table" then
        -- parse multipliers
        local result = 0
        local count = 0

        for key, boneMeta in pairs(Config.boneHitMultiplier) do
            for key, damagedBones in pairs(multiplier['bones']) do
                if boneMeta.bondeId == damagedBones then
                    local metaMultiplier = boneMeta.multiplier
                    if boneMeta.lastHit == true and #multiplier['bones'] == 1 then
                        -- headshot and one tab kills
                        return math.floor(boneMeta.multiplier)
                    elseif boneMeta.lastHit == true and #multiplier['bones'] ~= 1 then
                        metaMultiplier = 0
                    end
                    result = result + metaMultiplier
                    count = count + 1
                end
            end
        end

        result = result + multiplier.weapon + (#multiplier['bones'] - count) * Config.boneHitMultiplier.default.multiplier
        --multiplier.weapon
        if result > Config.maxMultiplier then
            result = Config.maxMultiplier
        end
        if result < 0 then
            result = 0
        end
        return result
    elseif multiplier ~= nil and type(multiplier) == "string" and multiplier == 'default' then
        --Config.weaponQualitymultiplier.default

        --Config.boneHitmultiplier.default

    end
    return 0
end

function CompleteRestOfChancesData(RewardChances)
    -- here we Complete the rest Chances to reach 100% in total in every try and then make EarnedLoot table
    local sample
    local temp = {}
    for key, value in pairs(RewardChances) do
        sample = Alias_table_wrapper({ value[2], (100 - value[2]) })
        if sample == 1 then
            table.insert(temp, value[1])
        end
    end
    return temp
end

-- ============================
--   SELLING
-- ============================
RegisterServerEvent('keep-hunting:server:sellmeat')
AddEventHandler('keep-hunting:server:sellmeat', function()
    local src = source
    local Player = CoreName.Functions.GetPlayer(src)
    local price = 0

    if Player ~= nil then
        if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then
            for k, v in pairs(Player.PlayerData.items) do
                if Player.PlayerData.items[k] ~= nil then
                    for key, value in pairs(Config.Animals) do
                        for key, value in pairs(value["Loots"]) do
                            if value[1] == Player.PlayerData.items[k].name and Player.PlayerData.items[k].amount ~= 0 then
                                if value[3] ~= nil then
                                    price = price + (value[3] * Player.PlayerData.items[k].amount)
                                    Player.Functions.RemoveItem(Player.PlayerData.items[k].name,
                                        Player.PlayerData.items[k].amount, k)
                                end
                            end
                        end
                    end

                end
            end
            if price == 0 then
                TriggerClientEvent('QBCore:Notify', src, "You didn't have any sellable items")
            else
                Player.Functions.AddMoney("cash", price, "sold-items-hunting")
                TriggerClientEvent('QBCore:Notify', src, "You have sold your items and recieved $" .. price)
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "You don't have items")
        end
    end
    Wait(10)
end)

CoreName.Functions.CreateUseableItem("huntingbait", function(source, item)
    TriggerClientEvent('keep-hunting:client:useBait', source)
end)

RegisterServerEvent('keep-hunting:server:removeBaitFromPlayerInventory')
AddEventHandler('keep-hunting:server:removeBaitFromPlayerInventory', function()
    local Player = CoreName.Functions.GetPlayer(source)
    Player.Functions.RemoveItem("huntingbait", 1)
end)

RegisterServerEvent('keep-hunting:server:choiceWhichAnimalToSpawn')
AddEventHandler('keep-hunting:server:choiceWhichAnimalToSpawn', function(coord, outPosition, was_llegal)
    local src = source
    local Player = CoreName.Functions.GetPlayer(src)
    local C_animal = choiceAnimal(Animals, was_llegal)

    if C_animal ~= nil then
        TriggerClientEvent('keep-hunting:client:spawnAnimal', source, coord, outPosition, C_animal, was_llegal)
    end
end)

function choiceAnimal(Rarities, was_llegal)
    local temp = {}
    local res
    for key, value in pairs(Rarities) do
        if not was_llegal then
            table.insert(temp, value.spwanRarity[2])
        else
            table.insert(temp, value.spwanRarity[1])
        end
    end
    if temp ~= nil then
        local sample = Alias_table_wrapper(temp)
        return Rarities[sample]
    end
end

-- ============================
--      Commands
-- ============================

CoreName.Commands.Add("spawnanimal", "Spawn Animals (Admin Only)",
    { { "model", "Animal Model" }, { "was_llegal", "area of hunt true/false" } }, false, function(source, args)
        TriggerClientEvent('keep-hunting:client:spawnanim', source, args[1], args[2])
    end, 'admin')

CoreName.Commands.Add("clearTask", "Clear Animations", {}, false, function(source)
    TriggerClientEvent('keep-hunting:client:clearTask', source)
end, 'user')

CoreName.Commands.Add('addBait', 'add bait to player inventory (Admin Only)', {}, false, function(source)
    local src = source
    local Player = CoreName.Functions.GetPlayer(src)

    Player.Functions.AddItem("huntingbait", 10)
    TriggerClientEvent("inventory:client:ItemBox", src, CoreName.Shared.Items["huntingbait"], "add")
end, 'admin')

-- ============================
--      Server garbage collection
-- ============================

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(garbageCollection_tm)
        garbageCollection()
    end
end)

-- ============================
--      Functions
-- ============================
function isAleadySlaughtered(entity)
    local isAleadySlaughtered = false

    for i = #animalsEnity, 1, -1 do
        local value = animalsEnity[i]
        if value == entity then
            isAleadySlaughtered = true
            break
        end
    end
    return isAleadySlaughtered
end

function setHash(entity)
    table.insert(animalsEnity, entity)
end

function garbageCollection()
    local count = #animalsEnity
    if count > TableSize then
        print("clearing Hunted Animals data")
        for i = 0, count do
            animalsEnity[i] = nil
        end
    end
end

function tprint(tbl, indent)
    if not indent then
        indent = 0
    end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            tprint(v, indent + 1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        else
            print(formatting .. v)
        end
    end
end

local CoreName = exports['qb-core']:GetCoreObject()
local Animals = Config.Animals

-- ============================
--       EVENTS
-- ============================

RegisterServerEvent("keep-hunting:server:AddItem", function(data, netId, multiplier)
    local src = source
    local Player = CoreName.Functions.GetPlayer(src)
    if not Player then return end

    for _, v in pairs(Config.Animals) do
        if v.model == data.model then
            choiceRewardsForPlayer(v.Loots, src, Player, multiplier)
            DeleteEntity(NetworkGetEntityFromNetworkId(netId))
            return
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

        result = result + multiplier.weapon +
            (#multiplier['bones'] - count) * Config.boneHitMultiplier.default.multiplier
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
local function is_sellable(item)
    for _, value in pairs(Config.Animals) do
        for _, loot in ipairs(value.Loots) do
            if item.amount ~= 0 and loot[1] == item.name then
                return loot
            end
        end
    end
    return false
end

RegisterServerEvent('keep-hunting:server:sellmeat', function()
    local src = source
    local Player = CoreName.Functions.GetPlayer(src)
    local price = 0

    if not Player then return end
    if not Player.PlayerData.items then
        TriggerClientEvent('QBCore:Notify', src, "You don't have items")
        return
    end
    for k, item in pairs(Player.PlayerData.items) do
        local _is_sellable = is_sellable(item)
        if _is_sellable and _is_sellable[3] then
            price = price + (_is_sellable[3] * item.amount)
            Player.Functions.RemoveItem(item.name, item.amount, k)
        end
    end
    if price == 0 then
        TriggerClientEvent('QBCore:Notify', src, "You didn't have any sellable items")
    else
        Player.Functions.AddMoney("cash", price, "sold-items-hunting")
        TriggerClientEvent('QBCore:Notify', src, "You have sold your items and recieved $" .. price)
    end
end)

CoreName.Functions.CreateUseableItem("huntingbait", function(source, item)
    TriggerClientEvent('keep-hunting:client:useBait', source)
end)

RegisterServerEvent('keep-hunting:server:removeBaitFromPlayerInventory')
AddEventHandler('keep-hunting:server:removeBaitFromPlayerInventory', function()
    local Player = CoreName.Functions.GetPlayer(source)
    Player.Functions.RemoveItem("huntingbait", 1)
end)

RegisterServerEvent('keep-hunting:server:choiceWhichAnimalToSpawn',
    function(coord, outPosition, is_llegal, indicator)
        local src = source
        local C_animal = choiceAnimal(Animals, is_llegal)
        if not C_animal then return end
        TriggerClientEvent('keep-hunting:client:spawnAnimal', src, coord, outPosition, C_animal, is_llegal, indicator)
    end)

function choiceAnimal(Rarities, was_llegal)
    local temp = {}
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

local CoreName = exports['qb-core']:GetCoreObject()
local TableSize = Config.sv_maxTableSize
local garbageCollection_tm = Config.sv_dataClearnigTimer
local Animals = Config.Animals

-- ============================
--       EVENTS
-- ============================
local animalsEnity = {} -- prevent players to slaughter twice

RegisterServerEvent("cad-hunting:server:AddItem")
AddEventHandler("cad-hunting:server:AddItem", function(data, entity)
    local _source = source
    local Player = CoreName.Functions.GetPlayer(_source)

    for _, v in pairs(Config.Animals) do
        if v.model == data.model then
            -- check if another player already slaughtered or not
            if animalsEnity ~= nil then
                local isAleadySlaughtered = isAleadySlaughtered(entity)

                if isAleadySlaughtered == false then
                    setHash(entity) -- prevent player to slaughter twice
                    Player.Functions.AddItem(v.invItemName, 1)
                    TriggerClientEvent("inventory:client:ItemBox", _source, CoreName.Shared.Items[v.invItemName], "add")
                    TriggerClientEvent('keep-hunting:client:ForceRemoveAnimalEntity', -1 ,entity)
                else 
                    TriggerClientEvent('QBCore:Notify', _source, "Someone already slaughtered this animal!")
                    TriggerClientEvent('keep-hunting:client:ForceRemoveAnimalEntity', -1, entity)
                end
            else
                -- init animalsEnity table
                setHash(entity) -- prevent player to slaughter twice
                Player.Functions.AddItem(v.invItemName, 1)
                TriggerClientEvent("inventory:client:ItemBox", _source, CoreName.Shared.Items[v.invItemName], "add")
            end
        end
    end
end)

-- ============================
--   SELLING
-- ============================
RegisterServerEvent('cad-hunting:server:sellmeat')
AddEventHandler('cad-hunting:server:sellmeat', function()
    local src = source
    local Player = CoreName.Functions.GetPlayer(src)
    local price = 0

    if Player ~= nil then
        if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then
            for k, v in pairs(Player.PlayerData.items) do
                if Player.PlayerData.items[k] ~= nil then
                    for _, v in pairs(Config.Animals) do
                        if v.invItemName == Player.PlayerData.items[k].name then
                            price = price + (v.price * Player.PlayerData.items[k].amount)
                            Player.Functions.RemoveItem(Player.PlayerData.items[k].name,
                                Player.PlayerData.items[k].amount, k)
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
    local src = source
    local Player = CoreName.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem("huntingbait", 1) then
        return true
    end
    return false
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
    for key, value in pairs(Rarities) do
        if was_llegal then
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
    {{"model", "Animal Model"}, {"was_llegal", "area of hunt true/false"}}, false, function(source, args)
        TriggerClientEvent('cad-hunting:client:spawnanim', source, args[1], args[2])
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

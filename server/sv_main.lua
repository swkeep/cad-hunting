local CoreName = exports['qb-core']:GetCoreObject()
local TableSize = Config.sv_maxTableSize
local garbageCollection_tm = Config.sv_dataClearnigTimer

-- ============================
--       EVENTS
-- ============================
local animalsEnity = {}

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

RegisterServerEvent("cad-hunting:server:AddItem")
AddEventHandler("cad-hunting:server:AddItem", function(data, entity)
    local _source = source
    local Player = CoreName.Functions.GetPlayer(_source)

    for _, v in pairs(Config.Animals) do
        if v.model == data.model then
            -- check if another player already slaughter animal or not
            if animalsEnity ~= nil then
                local isAleadyslaughtered = false
                for _, v in pairs(animalsEnity) do
                    if v == entity then
                        TriggerClientEvent('QBCore:Notify', _source, "Someone already slaughtered this animal!")
                        TriggerClientEvent('cad-hunting:client:ForceRemoveAnimalEntity', _source, entity)
                        isAleadyslaughtered = true
                    end
                end
                if isAleadyslaughtered == false then
                    setHash(entity)
                    Player.Functions.AddItem(v.invItemName, 1)
                    TriggerClientEvent("inventory:client:ItemBox", _source, CoreName.Shared.Items[v.invItemName], "add")
                end
            else
                -- init animalsEnity table
                setHash(entity)
                Player.Functions.AddItem(v.invItemName, 1)
                TriggerClientEvent("inventory:client:ItemBox", _source, CoreName.Shared.Items[v.invItemName], "add")
            end
        end
    end
end)

RegisterServerEvent("cad-hunting:server:spawnanimals")
AddEventHandler("cad-hunting:server:spawnanimals", function()
    local _source = source
    TriggerClientEvent("cad-hunting:client:spawnanimals", -1)
end)

-- ============================
--   SELLING EVENTS
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
            Citizen.Wait(2000)
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
    local Player = CoreName.Functions.GetPlayer(source)
    TriggerClientEvent('keep-hunting:client:usedBait', source)
end)

RegisterServerEvent('keep-hunting:server:removeBaitFromPlayerInventory')
AddEventHandler('keep-hunting:server:removeBaitFromPlayerInventory', function()
    local src = source
    local Player = CoreName.Functions.GetPlayer(src)
    Player.Functions.RemoveItem("huntingbait", 1)
end)

-- ============================
--      Commands
-- ============================

CoreName.Commands.Add("spawnanimal", "Spawn Animals (Admin Only)", {{"model", "Animal Model"}}, false, function(source, args)
    TriggerClientEvent('cad-hunting:client:spawnanim', source, args[1])
end, 'admin')

CoreName.Commands.Add('addBait', 'add bait to player inventory (Admin Only)', {}, false, function(source)
    local src = source
    local Player = CoreName.Functions.GetPlayer(src)

    Player.Functions.AddItem("huntingbait", 1)
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

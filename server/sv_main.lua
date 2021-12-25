-- ============================
--    SERVER CONFIG
-- ============================
local CoreName = exports['qb-core']:GetCoreObject()

-- ============================
--       EVENTS
-- ============================
RegisterServerEvent("cad-hunting:server:AddItem")
AddEventHandler("cad-hunting:server:AddItem", function(data)
    local _source = source
    local Player = CoreName.Functions.GetPlayer(_source)

    for _, v in pairs(Config.Animals) do
        if v.model == data.model then
            Player.Functions.AddItem(v.invItemName, 1)
            TriggerClientEvent("inventory:client:ItemBox", _source, CoreName.Shared.Items[v.invItemName], "add")
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

-- ============================
--      Spawning Ped
-- ============================

CoreName.Commands.Add("spawnanimal", "Spawn Animals", {{"model", "Animal Model"}}, false, function(source, args)
    TriggerClientEvent('cad-hunting:client:spawnanim', source, args[1])
end, 'god')

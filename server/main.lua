local QBCore = exports['qb-core']:GetCoreObject()
local PaymentTax = 15
local Bail = {}

RegisterNetEvent('qb-truckerjob:server:DoBail', function(bool, vehInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if bool then
        if Player.PlayerData.money.cash >= Config.BailPrice then
            Bail[Player.PlayerData.citizenid] = Config.BailPrice
            Player.Functions.RemoveMoney('cash', Config.BailPrice, "tow-received-bail")
            if Config.NotifyType == 'qb' then
                TriggerClientEvent('QBCore:Notify', src, Lang:t("success.paid_with_cash", {value = Config.BailPrice}), "success", 3500)
            elseif Config.NotifyType == "okok" then
                TriggerClientEvent('okokNotify:Alert', source, "PAID WITH CASH", Lang:t("success.paid_with_cash", {value = Config.BailPrice}), 3500, 'success')
            end
            TriggerClientEvent('qb-truckerjob:client:SpawnVehicle', src, vehInfo)
        elseif Player.PlayerData.money.bank >= Config.BailPrice then
            Bail[Player.PlayerData.citizenid] = Config.BailPrice
            Player.Functions.RemoveMoney('bank', Config.BailPrice, "tow-received-bail")
            if Config.NotifyType == 'qb' then
                TriggerClientEvent('QBCore:Notify', src, Lang:t("success.paid_with_bank", {value = Config.BailPrice}), "success", 3500)
            elseif Config.NotifyType == "okok" then
                TriggerClientEvent('okokNotify:Alert', source, "PAID WITH BANK", Lang:t("success.paid_with_bank", {value = Config.BailPrice}), 3500, 'success')
            end
            TriggerClientEvent('qb-truckerjob:client:SpawnVehicle', src, vehInfo)
        else
            if Config.NotifyType == 'qb' then
                TriggerClientEvent('QBCore:Notify', src, Lang:t("error.no_deposit", {value = Config.BailPrice}), "error", 3500)
            elseif Config.NotifyType == "okok" then
                TriggerClientEvent('okokNotify:Alert', source, "NO DEPOSIT", Lang:t("error.no_deposit", {value = Config.BailPrice}), 3500, 'error')
            end
        end
    else
        if Bail[Player.PlayerData.citizenid] then
            Player.Functions.AddMoney('cash', Bail[Player.PlayerData.citizenid], "trucker-bail-paid")
            Bail[Player.PlayerData.citizenid] = nil
            if Config.NotifyType == 'qb' then
                TriggerClientEvent('QBCore:Notify', src, Lang:t("success.refund_to_cash", {value = Config.BailPrice}), "success", 3500)
            elseif Config.NotifyType == "okok" then
                TriggerClientEvent('okokNotify:Alert', source, "DEPOSIT REFUNDED", Lang:t("success.refund_to_cash", {value = Config.BailPrice}), 3500, 'success')
            end
        end
    end
end)

RegisterNetEvent('qb-truckerjob:server:01101110', function(drops)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    drops = tonumber(drops)
    local bonus = 0
    local DropPrice = math.random(100, 120)
    if drops >= 5 then
        bonus = math.ceil((DropPrice / 10) * 5) + 100
    elseif drops >= 10 then
        bonus = math.ceil((DropPrice / 10) * 7) + 300
    elseif drops >= 15 then
        bonus = math.ceil((DropPrice / 10) * 10) + 400
    elseif drops >= 20 then
        bonus = math.ceil((DropPrice / 10) * 12) + 500
    end
    local price = (DropPrice * drops) + bonus
    local taxAmount = math.ceil((price / 100) * PaymentTax)
    local payment = price - taxAmount
    Player.Functions.AddJobReputation(drops)
    Player.Functions.AddMoney("bank", payment, "trucker-salary")
    if Config.NotifyType == 'qb' then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("success.you_earned", {value = payment}), "success", 3500)
    elseif Config.NotifyType == "okok" then
        TriggerClientEvent('okokNotify:Alert', source, "PAYSLIP", Lang:t("success.you_earned", {value = payment}), 3500, 'success')
    end
end)

RegisterNetEvent('qb-truckerjob:server:nano', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local chance = math.random(1,100)
    if Config.rarechance >= chance then 
        Player.Functions.AddItem(Config.rareitem, 1)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[Config.rareitem], "add")
    end
end)

RegisterNetEvent('qb-truckerjob:client:NPCBonusLevel1', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Bonus = math.random(Config.Level1Low, Config.Level1High)
    Player.Functions.AddMoney('cash', Bonus)
end)

RegisterNetEvent('qb-truckerjob:client:NPCBonusLevel2', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Bonus = math.random(Config.Level2Low, Config.Level2High)
    Player.Functions.AddMoney('cash', Bonus)
end)

RegisterNetEvent('qb-truckerjob:client:NPCBonusLevel3', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Bonus = math.random(Config.Level3Low, Config.Level3High)
    Player.Functions.AddMoney('cash', Bonus)
end)

RegisterNetEvent('qb-truckerjob:client:NPCBonusLevel4', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Bonus = math.random(Config.Level4Low, Config.Level4High)
    Player.Functions.AddMoney('cash', Bonus)
end)

RegisterNetEvent('qb-truckerjob:client:NPCBonusLevel5', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Bonus = math.random(Config.Level5Low, Config.Level5High)
    Player.Functions.AddMoney('cash', Bonus)
end)

RegisterNetEvent('qb-truckerjob:client:NPCBonusLevel6', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Bonus = math.random(Config.Level6Low, Config.Level6High)
    Player.Functions.AddMoney('cash', Bonus)
end)

RegisterNetEvent('qb-truckerjob:client:NPCBonusLevel7', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Bonus = math.random(Config.Level7Low, Config.Level7High)
    Player.Functions.AddMoney('cash', Bonus)
end)

RegisterNetEvent('qb-truckerjob:client:NPCBonusLevel8', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Bonus = math.random(Config.Level8Low, Config.Level8High)
    Player.Functions.AddMoney('cash', Bonus)
end)
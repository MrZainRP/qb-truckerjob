local QBCore = exports['qb-core']:GetCoreObject()
local PlayerJob = {}
local JobsDone = 0
local LocationsDone = {}
local CurrentLocation = nil
local CurrentBlip = nil
local hasBox = false
local isWorking = false
local currentCount = 0
local CurrentPlate = nil
local selectedVeh = nil
local TruckVehBlip = nil
local TruckerBlip = nil
local Delivering = false
local showMarker = false
local markerLocation
local zoneCombo = nil
local returningToStation = false
local lvl8 = false
local lvl7 = false
local lvl6 = false
local lvl5 = false
local lvl4 = false
local lvl3 = false
local lvl2 = false
local lvl1 = false
local lvl0 = false

-- Functions

local function returnToStation()
    SetBlipRoute(TruckVehBlip, true)
    returningToStation = true
end

local function hasDoneLocation(locationId)
    if LocationsDone and table.type(LocationsDone) ~= "empty" then
        for _, v in pairs(LocationsDone) do
            if v == locationId then
                return true
            end
        end
    end
    return false
end

local function getNextLocation()
    local current = 1

    if Config.FixedLocation then
        local pos = GetEntityCoords(PlayerPedId(), true)
        local dist = nil
        for k, v in pairs(Config.Locations["stores"]) do
            local dist2 = #(pos - vector3(v.coords.x, v.coords.y, v.coords.z))
            if dist then
                if dist2 < dist then
                    current = k
                    dist = dist2
                end
            else
                current = k
                dist = dist2
            end
        end
    else
        while hasDoneLocation(current) do
            current = math.random(#Config.Locations["stores"])
        end
    end

    return current
end

local function isTruckerVehicle(vehicle)
    for k in pairs(Config.Vehicles) do
        if GetEntityModel(vehicle) == joaat(k) then
            return true
        end
    end
    return false
end

local function RemoveTruckerBlips()
    ClearAllBlipRoutes()
    if TruckVehBlip then
        RemoveBlip(TruckVehBlip)
        TruckVehBlip = nil
    end

    if TruckerBlip then
        RemoveBlip(TruckerBlip)
        TruckerBlip = nil
    end

    if CurrentBlip then
        RemoveBlip(CurrentBlip)
        CurrentBlip = nil
    end
end

local function MenuGarage()
    local truckMenu = {
        {
            header = Lang:t("menu.header"),
            isMenuHeader = true
        }
    }
    for k in pairs(Config.Vehicles) do
        truckMenu[#truckMenu+1] = {
            header = Config.Vehicles[k],
            params = {
                event = "qb-truckerjob:client:TakeOutVehicle",
                args = {
                    vehicle = k
                }
            }
        }
    end

    truckMenu[#truckMenu+1] = {
        header = Lang:t("menu.close_menu"),
        txt = "",
        params = {
            event = "qb-menu:client:closeMenu"
        }

    }
    exports['qb-menu']:openMenu(truckMenu)
end

local function SetDelivering(active)
    if PlayerJob.name ~= "trucker" then return end
    Delivering = active
end

local function ShowMarker(active)
    if PlayerJob.name ~= "trucker" then return end
    showMarker = active
end

local function CreateZone(type, number)
    local coords
    local heading
    local boxName
    local event
    local label
    local size

    if type == "main" then
        event = "qb-truckerjob:client:PaySlip"
        label = "Payslip"
        coords = vector3(Config.Locations[type].coords.x, Config.Locations[type].coords.y, Config.Locations[type].coords.z)
        heading = Config.Locations[type].coords.h
        boxName = Config.Locations[type].label
        size = 3
    elseif type == "vehicle" then
        event = "qb-truckerjob:client:Vehicle"
        label = "Vehicle"
        coords = vector3(Config.Locations[type].coords.x, Config.Locations[type].coords.y, Config.Locations[type].coords.z)
        heading = Config.Locations[type].coords.h
        boxName = Config.Locations[type].label
        size = 5
    elseif type == "stores" then
        event = "qb-truckerjob:client:Store"
        label = "Store"
        coords = vector3(Config.Locations[type][number].coords.x, Config.Locations[type][number].coords.y, Config.Locations[type][number].coords.z)
        heading = Config.Locations[type][number].coords.h
        boxName = Config.Locations[type][number].name
        size = 40
    end

    if Config.UseTarget and type == "main" then
        exports['qb-target']:AddBoxZone(boxName, coords, size, size, {
            minZ = coords.z - 5.0,
            maxZ = coords.z + 5.0,
            name = boxName,
            heading = heading,
            debugPoly = false,
        }, {
            options = {
                {
                    type = "client",
                    event = event,
                    label = label,
                },
            },
            distance = 2
        })
    else
        local zone = BoxZone:Create(
            coords, size, size, {
                minZ = coords.z - 5.0,
                maxZ = coords.z + 5.0,
                name = boxName,
                debugPoly = false,
                heading = heading,
            })

        zoneCombo = ComboZone:Create({zone}, {name = boxName, debugPoly = false})
        zoneCombo:onPlayerInOut(function(isPointInside)
            if isPointInside then
                if type == "main" then
                    TriggerEvent('qb-truckerjob:client:PaySlip')
                elseif type == "vehicle" then
                    TriggerEvent('qb-truckerjob:client:Vehicle')
                elseif type == "stores" then
                    markerLocation = coords
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify(Lang:t("mission.store_reached"), "info", 5500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("DESTINATION REACHED", Lang:t("mission.store_reached"), 5500, "info")
                    end 
                    ShowMarker(true)
                    SetDelivering(true)
                end
            else
                if type == "stores" then
                    ShowMarker(false)
                    SetDelivering(false)
                end
            end
        end)
        if type == "vehicle" then
            local zonedel = BoxZone:Create(
                coords, 40, 40, {
                    minZ = coords.z - 5.0,
                    maxZ = coords.z + 5.0,
                    name = boxName,
                    debugPoly = false,
                    heading = heading,
                })

            local zoneCombodel = ComboZone:Create({zonedel}, {name = boxName, debugPoly = false})
            zoneCombodel:onPlayerInOut(function(isPointInside)
                if isPointInside then
                    markerLocation = coords
                    ShowMarker(true)
                else
                    ShowMarker(false)
                end
            end)
        elseif type == "stores" then
            CurrentLocation.zoneCombo = zoneCombo
        end
    end
end

local function getNewLocation()
    local location = getNextLocation()
    if location ~= 0 then
        CurrentLocation = {}
        CurrentLocation.id = location
        CurrentLocation.dropcount = math.random(1, 3)
        CurrentLocation.store = Config.Locations["stores"][location].name
        CurrentLocation.x = Config.Locations["stores"][location].coords.x
        CurrentLocation.y = Config.Locations["stores"][location].coords.y
        CurrentLocation.z = Config.Locations["stores"][location].coords.z
        CreateZone("stores", location)

        CurrentBlip = AddBlipForCoord(CurrentLocation.x, CurrentLocation.y, CurrentLocation.z)
        SetBlipColour(CurrentBlip, 3)
        SetBlipRoute(CurrentBlip, true)
        SetBlipRouteColour(CurrentBlip, 3)
    else
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify(Lang:t("success.payslip_time"), "success", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("PAYSLIP", Lang:t("success.payslip_time"), 3500, "success")
        end 
        if CurrentBlip ~= nil then
            RemoveBlip(CurrentBlip)
            ClearAllBlipRoutes()
            CurrentBlip = nil
        end
    end
end

local function CreateElements()
    TruckVehBlip = AddBlipForCoord(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z)
    SetBlipSprite(TruckVehBlip, 326)
    SetBlipDisplay(TruckVehBlip, 4)
    SetBlipScale(TruckVehBlip, 0.6)
    SetBlipAsShortRange(TruckVehBlip, true)
    SetBlipColour(TruckVehBlip, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Locations["vehicle"].label)
    EndTextCommandSetBlipName(TruckVehBlip)

    TruckerBlip = AddBlipForCoord(Config.Locations["main"].coords.x, Config.Locations["main"].coords.y, Config.Locations["main"].coords.z)
    SetBlipSprite(TruckerBlip, 479)
    SetBlipDisplay(TruckerBlip, 4)
    SetBlipScale(TruckerBlip, 0.6)
    SetBlipAsShortRange(TruckerBlip, true)
    SetBlipColour(TruckerBlip, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Locations["main"].label)
    EndTextCommandSetBlipName(TruckerBlip)

    CreateZone("main")
    CreateZone("vehicle")
end

local function BackDoorsOpen(vehicle) -- This is hardcoded for the rumpo currently
    return GetVehicleDoorAngleRatio(vehicle, 2) > 0.0 and GetVehicleDoorAngleRatio(vehicle, 3) > 0.0
end

local function GetInTrunk()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify(Lang:t("error.get_out_vehicle"), "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("GET OUT", Lang:t("error.get_out_vehicle"), 3500, "error")
        end 
        return
    end
    local pos = GetEntityCoords(ped, true)
    local vehicle = GetVehiclePedIsIn(ped, true)
    if not isTruckerVehicle(vehicle) or CurrentPlate ~= QBCore.Functions.GetPlate(vehicle) then
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify(Lang:t("error.vehicle_not_correct"), "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("WRONG VEHICLE", Lang:t("error.vehicle_not_correct"), 3500, "error")
        end 
        return
    end
    if not BackDoorsOpen(vehicle) then
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify(Lang:t("error.backdoors_not_open"), "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("OPEN DOORS", Lang:t("error.backdoors_not_open"), 3500, "error")
        end 
        return
    end
    local trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.5, 0)
    if #(pos - vector3(trunkpos.x, trunkpos.y, trunkpos.z)) > 1.5 then
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify(Lang:t("error.too_far_from_trunk"), "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("GET CLOSER", Lang:t("error.too_far_from_trunk"), 3500, "error")
        end 
        return
    end
    if isWorking then return end
    isWorking = true
    local getbox = math.random(Config.GetBoxtimelow*1000, Config.GetBoxtimehigh*1000)
    QBCore.Functions.Progressbar("work_carrybox", Lang:t("mission.take_box"), getbox, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@gangops@facility@servers@",
        anim = "hotwire",
        flags = 16,
    }, {}, {}, function() -- Done
        isWorking = false
        StopAnimTask(ped, "anim@gangops@facility@servers@", "hotwire", 1.0)
        TriggerEvent('animations:client:EmoteCommandStart', {"box"})
        hasBox = true
    end, function() -- Cancel
        isWorking = false
        StopAnimTask(ped, "anim@gangops@facility@servers@", "hotwire", 1.0)
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify(Lang:t("error.cancelled"), "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("...", Lang:t("error.cancelled"), 3500, "error")
        end 
    end)
end

local function Deliver()
    isWorking = true
    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    Wait(500)
    TriggerEvent('animations:client:EmoteCommandStart', {"bumbin"})
    local dropbox = math.random(Config.DropBoxtimelow*1000,Config.DropBoxtimehigh*1000)
    QBCore.Functions.Progressbar("work_dropbox", Lang:t("mission.deliver_box"), dropbox, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        isWorking = false
        ClearPedTasks(PlayerPedId())
        hasBox = false
        currentCount = currentCount + 1
        if currentCount == CurrentLocation.dropcount then
            LocationsDone[#LocationsDone+1] = CurrentLocation.id
            TriggerServerEvent("qb-shops:server:RestockShopItems", CurrentLocation.store)
            exports['qb-core']:HideText()
            Delivering = false
            showMarker = false
            TriggerServerEvent('qb-truckerjob:server:nano')
            if CurrentBlip ~= nil then
                RemoveBlip(CurrentBlip)
                ClearAllBlipRoutes()
                CurrentBlip = nil
            end
            CurrentLocation.zoneCombo:destroy()
            CurrentLocation = nil
            currentCount = 0
            JobsDone = JobsDone + 1
            if JobsDone == Config.MaxDrops then
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify(Lang:t("mission.return_to_station"), "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("VAN EMPTY", Lang:t("mission.return_to_station"), 3500, "info")
                end 
                returnToStation()
                Wait(1000)
                TriggerEvent('qb-truckerjob:client:mzSkills')
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify(Lang:t("mission.goto_next_point"), "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("DELIVERY COMPLETE", Lang:t("mission.goto_next_point"), 3500, "info")
                end 
                getNewLocation()
                Wait(1000)
                TriggerEvent('qb-truckerjob:client:mzSkills')
            end
        else
            if Config.NotifyType == 'qb' then
                QBCore.Functions.Notify(Lang:t("mission.another_box"), "info", 3500)
            elseif Config.NotifyType == "okok" then
                exports['okokNotify']:Alert("GET ANOTHER BOX", Lang:t("mission.another_box"), 3500, "info")
            end 
        end
    end, function() -- Cancel
        isWorking = false
        ClearPedTasks(PlayerPedId())
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify(Lang:t("error.cancelled"), "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("...", Lang:t("error.cancelled"), 3500, "error")
        end 
    end)
end

RegisterNetEvent("qb-truckerjob:client:mzSkills", function()
    if Config.mzskills then 
        local BetterXP = math.random(Config.DriverXPlow, Config.DriverXPhigh)
        local xpmultiple = math.random(1, 4)
        if xpmultiple >= 3 then
            chance = BetterXP
        elseif xpmultiple < 3 then
            chance = Config.DriverXPlow
        end
        exports["mz-skills"]:UpdateSkill("Driving", chance) 
        Wait(1000)
        if Config.BonusChance >= math.random(1, 100) then
            exports["mz-skills"]:CheckSkill("Driving", 12800, function(hasskill)
                if hasskill then
                    lvl8 = true
                end
            end)
            exports["mz-skills"]:CheckSkill("Driving", 6400, function(hasskill)
                if hasskill then
                    lvl7 = true
                end
            end)
            exports["mz-skills"]:CheckSkill("Driving", 3200, function(hasskill)
                if hasskill then
                    lvl6 = true
                end
            end)
            exports["mz-skills"]:CheckSkill("Driving", 1600, function(hasskill)
                if hasskill then
                    lvl5 = true
                end
            end)
            exports["mz-skills"]:CheckSkill("Driving", 800, function(hasskill)
                if hasskill then
                    lvl4 = true
                end
            end)
            exports["mz-skills"]:CheckSkill("Driving", 400, function(hasskill)
                if hasskill then
                    lvl3 = true
                end
            end)
            exports["mz-skills"]:CheckSkill("Driving", 200, function(hasskill)
                if hasskill then
                    lvl2 = true
                end
            end)
            exports["mz-skills"]:CheckSkill("Driving", 0, function(hasskill)
                if hasskill then
                    lvl1 = true
                end
            end)
            if lvl8 == true then
                TriggerServerEvent('qb-truckerjob:client:NPCBonusLevel8')
                Wait(1500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Best delivery driver ever, going to give you a 5 star review!', "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("TIP", 'Best delivery driver ever, going to give you a 5 star review!', 3500, "info")
                end 
                lvl8 = false
            elseif lvl7 == true then
                TriggerServerEvent('qb-truckerjob:client:NPCBonusLevel7')
                Wait(1500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Best delivery driver ever, going to give you a 5 star review!', "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("TIP", 'Best delivery driver ever, going to give you a 5 star review!', 3500, "info")
                end 
                lvl7 = false
            elseif lvl6 == true then
                TriggerServerEvent('qb-truckerjob:client:NPCBonusLevel6')
                Wait(1500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Hey, do you always drive so well? You got me here quick smart!', "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("TIP", 'Hey, do you always drive so well? You got me here quick smart!', 3500, "info")
                end 
                lvl6 = false
            elseif lvl5 == true then
                TriggerServerEvent('qb-truckerjob:client:NPCBonusLevel5')
                Wait(1500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Hey, do you always drive so well? You got me here quick smart!', "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("TIP", 'Hey, do you always drive so well? You got me here quick smart!', 3500, "info")
                end 
                lvl5 = false
            elseif lvl4 == true then
                TriggerServerEvent('qb-truckerjob:client:NPCBonusLevel4')
                Wait(1500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Wow, these are in good condition, keep up the good work.', "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("TIP", 'Wow, these are in good condition, keep up the good work.', 3500, "info")
                end 
                lvl4 = false
            elseif lvl3 == true then
                TriggerServerEvent('qb-truckerjob:client:NPCBonusLevel3')
                Wait(1500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Wow, these are in good condition, keep up the good work.', "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("TIP", 'Wow, these are in good condition, keep up the good work.', 3500, "info")
                end 
                lvl3 = false
            elseif lvl2 == true then
                TriggerServerEvent('qb-truckerjob:client:NPCBonusLevel2')
                Wait(1500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Thank you for the packages, take a little change for your trouble.', "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("TIP", 'Thank you for the packages, take a little change for your trouble.', 3500, "info")
                end 
                lvl2 = false
            elseif lvl1 == true then 
                TriggerServerEvent('qb-truckerjob:client:NPCBonusLevel1')
                Wait(1500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Thank you for the packages, take a little change for your trouble.', "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("TIP", 'Thank you for the packages, take a little change for your trouble.', 3500, "info")
                end 
                lvl1 = false
            end
        end
    end
end)

-- Events

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    PlayerJob = QBCore.Functions.GetPlayerData().job
    CurrentLocation = nil
    CurrentBlip = nil
    hasBox = false
    isWorking = false
    JobsDone = 0
    if PlayerJob.name ~= "trucker" then return end
    CreateElements()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
    CurrentLocation = nil
    CurrentBlip = nil
    hasBox = false
    isWorking = false
    JobsDone = 0
    if PlayerJob.name ~= "trucker" then return end
    CreateElements()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    RemoveTruckerBlips()
    CurrentLocation = nil
    CurrentBlip = nil
    hasBox = false
    isWorking = false
    JobsDone = 0
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    local OldPlayerJob = PlayerJob.name
    PlayerJob = JobInfo
    if OldPlayerJob == "trucker" then
        RemoveTruckerBlips()
        zoneCombo:destroy()
        exports['qb-core']:HideText()
        Delivering = false
        showMarker = false
    elseif PlayerJob.name == "trucker" then
        CreateElements()
    end
end)

RegisterNetEvent('qb-truckerjob:client:SpawnVehicle', function()
    local vehicleInfo = selectedVeh
    local coords = Config.Locations["vehicle"].coords
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
        local veh = NetToVeh(netId)
        SetVehicleNumberPlateText(veh, "TRUK"..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, coords.w)
        SetVehicleLivery(veh, 1)
        SetVehicleColours(veh, 122, 122)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        exports['qb-menu']:closeMenu()
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetEntityAsMissionEntity(veh, true, true)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
        CurrentPlate = QBCore.Functions.GetPlate(veh)
        getNewLocation()
    end, vehicleInfo, coords, true)
end)

RegisterNetEvent('qb-truckerjob:client:TakeOutVehicle', function(data)
    local vehicleInfo = data.vehicle
    TriggerServerEvent('qb-truckerjob:server:DoBail', true, vehicleInfo)
    selectedVeh = vehicleInfo
end)

RegisterNetEvent('qb-truckerjob:client:Vehicle', function()
    if IsPedInAnyVehicle(PlayerPedId()) and isTruckerVehicle(GetVehiclePedIsIn(PlayerPedId(), false)) then
        if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) == PlayerPedId() then
            if isTruckerVehicle(GetVehiclePedIsIn(PlayerPedId(), false)) then
                DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                TriggerServerEvent('qb-truckerjob:server:DoBail', false)
                if CurrentBlip ~= nil then
                    RemoveBlip(CurrentBlip)
                    ClearAllBlipRoutes()
                    CurrentBlip = nil
                end
                if returningToStation or CurrentLocation then
                    ClearAllBlipRoutes()
                    returningToStation = false
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify(Lang:t("mission.job_completed"), "success", 3500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("JOB COMPLETE", Lang:t("mission.job_completed"), 3500, "success")
                    end 
                end
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify(Lang:t("error.vehicle_not_correct"), "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("WRONG VEHICLE", Lang:t("error.vehicle_not_correct"), 3500, "error")
                end 
            end
        else
            if Config.NotifyType == 'qb' then
                QBCore.Functions.Notify(Lang:t("error.no_driver"), "error", 3500)
            elseif Config.NotifyType == "okok" then
                exports['okokNotify']:Alert("YOU MUST DRIVE", Lang:t("error.no_driver"), 3500, "error")
            end 
        end
    else
        MenuGarage()
    end
end)

RegisterNetEvent('qb-truckerjob:client:PaySlip', function()
    if JobsDone > 0 then
        TriggerServerEvent("qb-truckerjob:server:01101110", JobsDone)
        JobsDone = 0
        if #LocationsDone == #Config.Locations["stores"] then
            LocationsDone = {}
        end
        if CurrentBlip ~= nil then
            RemoveBlip(CurrentBlip)
            ClearAllBlipRoutes()
            CurrentBlip = nil
        end
    else
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify(Lang:t("error.no_work_done"), "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("DO SOME WORK", Lang:t("error.no_work_done"), 3500, "error")
        end 
    end
end)

-- Threads

CreateThread(function()
    local sleep
    while true do
        sleep = 1000
        if showMarker then
            DrawMarker(2, markerLocation.x, markerLocation.y, markerLocation.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
            sleep = 0
        end
        if Delivering then
            if IsControlJustReleased(0, 38) then
                if not hasBox then
                    GetInTrunk()
                else
                    if #(GetEntityCoords(PlayerPedId()) - markerLocation) < 5 then
                        Deliver()
                    else
                        if Config.NotifyType == 'qb' then
                            QBCore.Functions.Notify(Lang:t("error.too_far_from_delivery"), "error", 3500)
                        elseif Config.NotifyType == "okok" then
                            exports['okokNotify']:Alert("TOO FAR", Lang:t("error.too_far_from_delivery"), 3500, "error")
                        end 
                    end
                end
            end
            sleep = 0
        end
        Wait(sleep)
    end
end)

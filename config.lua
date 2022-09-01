Config = {}

Config.NotifyType = 'okok' -- notification type: 'qb' for qb-core standard notifications, 'okok' for okokNotify notifications

Config.mzskills = true -- Set to 'false' if you do not wish to use mz-skills XP integration

--Rare item drop
Config.rareitem = 'cryptostick' -- Rare item received by player
Config.rarechance = 100 -- Percentage chance of additional player drop upon completion of client taxi mission (set to 0 to disable)
-- if mz-skills is set to 'true', the following parameters apply:
Config.DriverXPlow = 1 -- Lowest possible XP given from a successful delivery.
Config.DriverXPhigh = 3 -- Highest possible XP given from a successful delivery.
-- BONUS PAYMENT 
Config.BonusChance = 100 -- Percentage chance that the client pays the driver a bonus (to disable set to 0).
--If a bonus is given, the following parameters apply:
--Level 1
Config.Level1Low = 1
Config.Level1High = 5
--Level 2
Config.Level2Low = 3
Config.Level2High = 8
--Level 3
Config.Level3Low = 5
Config.Level3High = 12
--Level 4
Config.Level4Low = 8
Config.Level4High = 16
--Level 5
Config.Level5Low = 10
Config.Level5High = 18
--Level 6
Config.Level6Low = 13
Config.Level6High = 22
--Level 7
Config.Level7Low = 15
Config.Level7High = 26
--Level 8
Config.Level8Low = 18
Config.Level8High = 30

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true'

Config.BailPrice = 250
Config.FixedLocation = false
Config.MaxDrops = 10 -- amount of locations before being forced to return to station to reload

--Progressbar times for getting and dropping off boxes
Config.GetBoxtimelow = 1
Config.GetBoxtimehigh = 2
Config.DropBoxtimelow = 1
Config.DropBoxtimehigh = 2

Config.Locations = {
    ["main"] = {
        label = "Truck Shed",
        coords = vector4(153.68, -3211.88, 5.91, 274.5),
    },
    ["vehicle"] = {
        label = "Truck Storage",
        coords = vector4(141.12, -3204.31, 5.85, 267.5),
    },
    ["stores"] ={
        [1] = {
            name = "ltdgasoline",
            coords = vector4(-41.07, -1747.91, 29.4, 137.5),
        },
        [2] = {
            name = "247supermarket",
            coords = vector4(31.62, -1315.87, 29.52, 179.5),
        },
        [3] = {
            name = "robsliquor",
            coords = vector4(-1226.48, -907.58, 12.32, 119.5),
        },
        [4] = {
            name = "ltdgasoline2",
            coords = vector4(-714.13, -909.13, 19.21, 0.5),
        },
        [5] = {
            name = "robsliquor2",
            coords = vector4(-1469.78, -366.72, 40.2, 138.5),
        },
        [6] = {
            name = "ltdgasoline3",
            coords = vector4(-1829.15, 791.99, 138.26, 46.5),
        },
        [7] = {
            name = "robsliquor3",
            coords = vector4(-2959.92, 396.77, 15.02, 178.5),
        },
        [8] = {
            name = "247supermarket2",
            coords = vector4(-3047.58, 589.89, 7.78, 199.5),
        },
        [9] = {
            name = "247supermarket3",
            coords = vector4(-3245.85, 1008.25, 12.83, 90.5),
        },
        [10] = {
            name = "247supermarket4",
            coords = vector4(1735.54, 6416.28, 35.03, 332.5),
        },
        [11] = {
            name = "247supermarket5",
            coords = vector4(1702.84, 4917.28, 42.22, 323.5),
        },
        [12] = {
            name = "247supermarket6",
            coords = vector4(1960.47, 3753.59, 32.26, 127.5),
        },
        [13] = {
            name = "robsliquor4",
            coords = vector4(1169.27, 2707.7, 38.15, 267.5),
        },
        [14] = {
            name = "247supermarket7",
            coords = vector4(543.47, 2658.81, 42.17, 277.5),
        },
        [15] = {
            name = "247supermarket8",
            coords = vector4(2678.09, 3288.43, 55.24, 61.5),
        },
        [16] = {
            name = "247supermarket9",
            coords = vector4(2553.0, 399.32, 108.61, 179.5),
        },
        [17] = {
            name = "ltdgasoline4",
            coords = vector4(1155.97, -319.76, 69.2, 17.5),
        },
        [18] = {
            name = "robsliquor5",
            coords = vector4(1119.78, -983.99, 46.29, 287.5),
        },
        [19] = {
            name = "247supermarket10",
            coords = vector4(382.13, 326.2, 103.56, 253.5),
        },
        [20] = {
            name = "hardware",
            coords = vector4(89.33, -1745.44, 30.08, 143.5),
        },
        [21] = {
            name = "hardware2",
            coords = vector4(2704.09, 3457.55, 55.53, 339.5),
        },
    },
}

Config.Vehicles = {
    ["rumpo"] = "Dumbo Delivery",
}

local Translations = {
    error = {
        no_deposit = "$%{value} Deposit Required",
        cancelled = "Cancelled",
        vehicle_not_correct = "This is not a commercial vehicle!",
        no_driver = "You must be the driver to do this.",
        no_work_done = "You haven't done any work yet.",
        backdoors_not_open = "The backdoors of the vehicle aren't open",
        get_out_vehicle = "You need to step out of the vehicle to perform this action",
        too_far_from_trunk = "You need to grab the boxes from the trunk of your vehicle",
        too_far_from_delivery = "You need to be closer to the delivery point"
    },
    success = {
        paid_with_cash = "$%{value} Deposit Paid in cash",
        paid_with_bank = "$%{value} Deposit Paid from bank",
        refund_to_cash = "$%{value} Deposit Paid in cash",
        you_earned = "You Earned $%{value}",
        payslip_time = "You made all of your scheduled deliveries. Don't forget to collect your payslip!",
    },
    menu = {
        header = "Available Trucks",
        close_menu = "⬅ Close Menu",
    },
    mission = {
        store_reached = "Store reached, open your truck, get the consignment and press [E] at the delivery spot to deliver.",
        take_box = "Take a box of goods",
        return_to_station = "You have delivered all goods in your van, please return to the station",
        deliver_box = "Deliver the goods",
        another_box = "Retrieve another box of goods",
        goto_next_point = "You have completed this delivery, please proceed to the next stop on your route",
    },
    info = {
        deliver_e = "[E] - Deliver Products",
        deliver = "Deliver products",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

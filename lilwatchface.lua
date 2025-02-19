local date = "00-00-0000"
local time = "00:00"
local batteryLevel = 100

function lilka.update(delta)
    date = os.date("%d-%m-%Y")
    time = os.date("%H:%M:%S")
    batteryLevel = readBatteryLevel()

    if controller.get_state().a.just_pressed then
        util.exit()
    end
end

function lilka.draw()
    -- Reset display
    display.fill_screen(display.color565(0, 0, 0))
    display.set_text_color(display.color565(255, 255, 255))

    -- Draw top bar
    display.fill_rect(0, 0, 280, 40, display.color565(148, 161, 172))

    -- Draw editor area
    display.fill_rect(0, 40, 280, 190, display.color565(0, 0, 0))

    -- Draw file name area
    display.fill_rect(30, 10, 200, 30, display.color565(0, 0, 0))

    -- Draw title
    display.set_cursor(40, 30)
    display.print("watchface.json")

    -- Draw cross button
    display.draw_line(205, 20, 215, 30, display.color565(255, 255, 255))
    display.draw_line(215, 20, 205, 30, display.color565(255, 255, 255))

    -- Draw editor text
    for i = 1, 9 do
        display.set_cursor(15, 60 + (i - 1) * 20)
        printGreyText(i)
        if i == 1 then
            printYellowText(" {")
        elseif i == 2 then
            printBlueText("  \"name\"")
            printWhiteText(":")
            printBrownText(" \"Лілка\"")
            printWhiteText(",")
        elseif i == 3 then
            printBlueText("  \"date\"")
            printWhiteText(":")
            printBrownText(" \"" .. date .. "\"")
            printWhiteText(",")
        elseif i == 4 then
            printBlueText("  \"time\"")
            printWhiteText(":")
            printBrownText(" \"" .. time .. "\"")
            printWhiteText(",")
        elseif i == 5 then
            printBlueText("  \"battery\"")
            printWhiteText(":")
            printLightGreenText(" " .. math.floor(batteryLevel))
        elseif i == 6 then
            printYellowText(" }")
        end
    end
end

function printGreyText(text)
    display.set_text_color(display.color565(189, 190, 189))
    display.print(text)
end

function printWhiteText(text)
    display.set_text_color(display.color565(255, 255, 255))
    display.print(text)
end

function printYellowText(text)
    display.set_text_color(display.color565(249, 210, 1))
    display.print(text)
end

function printLightGreenText(text)
    display.set_text_color(display.color565(181, 206, 168))
    display.print(text)
end

function printBlueText(text)
    display.set_text_color(display.color565(155, 219, 253))
    display.print(text)
end

function printBrownText(text)
    display.set_text_color(display.color565(203, 143, 119))
    display.print(text)
end


-- Battery level calculation
local LILKA_BATTERY_ADC = 3
local LILKA_DEFAULT_EMPTY_VOLTAGE = 3.2
local LILKA_DEFAULT_FULL_VOLTAGE = 5.2
local LILKA_BATTERY_VOLTAGE_DIVIDER = (100.0 / (33.0 + 100.0))
local LILKA_BATTERY_MAX_MEASURABLE_VOLTAGE = 3.1 / LILKA_BATTERY_VOLTAGE_DIVIDER

function readBatteryLevel()
    local value = readBatteryRawValue()
    local voltage = value / 4095 * LILKA_BATTERY_MAX_MEASURABLE_VOLTAGE
    if voltage < 0.5 then
        return -1
    end
    local maxVoltage = fmin(LILKA_DEFAULT_FULL_VOLTAGE, LILKA_BATTERY_MAX_MEASURABLE_VOLTAGE)
    local level = fmap(voltage, LILKA_DEFAULT_EMPTY_VOLTAGE, maxVoltage, 0, 100)
    return level
end

function readBatteryRawValue()
    local count = 32
    local values = {}
    for i = 1, count do
        values[i] = gpio.analog_read(LILKA_BATTERY_ADC)
    end
    table.sort(values)
    local value = values[math.floor(count / 2)]
    return value
end

function fmin(a, b)
    if a < b then
        return a
    else
        return b
    end
end

function fmap(x, in_min, in_max, out_min, out_max)
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end
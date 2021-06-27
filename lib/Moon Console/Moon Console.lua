local moonConsole = require('MoonConsole')

function cmdprint(str)
    print(str)
end
moonConsole:addCommand('print', cmdprint)

function hp(int)
    setCharHealth(playerPed, tonumber(int))
end
moonConsole:addCommand('hp', hp)

function reloadall()
    print('Reloading all Lua scripts')
    reloadScripts()
    print('a')
end
moonConsole:addCommand('reloadall', reloadall)

function lines()
    local lines = 0
    for line in io.lines('moonloader/moonloader.log') do
        lines = lines + 1
    end
    print(lines, 'lines')
end
moonConsole:addCommand('lines', lines)

function logsize()
    local file = io.input('moonloader/moonloader.log')
    print(f:seek('end'), 'bytes')
end
moonConsole:addCommand('logsize', logsize)

function clearlog()
    io.open('moonloader/moonloader.log', 'w'):write('moonloader.log was cleared\n'):close()
end
--moonConsole:addCommand('clearlog', clearlog)

function delay(int)
    return moonConsole:setValue('delay', tonumber(int))
end
moonConsole:addCommand('delay', delay)

function pagesize(int)
    return moonConsole:setValue('pageSize', tonumber(int))
end
moonConsole:addCommand('pagesize', pagesize)

function eval(code)
    local tmp = loadstring(code)
    if tmp then
        local success, err = pcall(tmp)
        if success then
            result = tmp()
            if result then
                print('Result:', result)
            end
        elseif err then
            print('Error:', err)
        end
    end
end
moonConsole:addCommand('eval', eval)

function help()
    return
end
moonConsole:addCommand('help', help)

function weap(id)
    local model = getWeapontypeModel(id)
    if not isModelAvailable(model) then print('(error) Weapon does not exists') end
    requestModel(model)
    loadAllModelsNow()
    giveWeaponToChar(playerPed, id, 99999)
    markModelAsNoLongerNeeded(model)
end
moonConsole:addCommand('weap', weap)

function veh(id)
    if not isModelAvailable(id) then print('(error) Vehicle does not exists') end
    requestModel(id)
    loadAllModelsNow()
    local x, y, z = getCharCoordinates(playerPed)
    local car
    if isCharInAnyCar(playerPed) then
        car = getCarCharIsUsing(playerPed)
        warpCharFromCarToCoord(playerPed, x, y, z)
        deleteCar(car)
    end
    car = createCar(id, x, y, z)
    setCarHeading(car, getCharHeading(playerPed))
    warpCharIntoCar(playerPed, car)
    if isThisModelAPlane(id) then setCarCoordinates(car, x, y, z + 400.0) end
    --setCarCoordinatesNoOffset(car, x, y, z)
    markModelAsNoLongerNeeded(id)
    markCarAsNoLongerNeeded(car)
end
moonConsole:addCommand('veh', veh)

return moonConsole
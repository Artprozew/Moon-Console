
local memory = require 'memory'
local buffer = {}
local bufferSize = 4
local delay = 5

function main()
    local gxtBuffer = {}
    local time
    local enabled = false

    while true do
        wait(0)
        if isKeyDown(0x70) then
            if not enabled then
                for i = bufferSize, 0, -1 do
                    gxtBuffer[i] = getFreeGxtKey()
                end
                time = os.time() - 10
                enabled = true
            else
                enabled = false
                buffer = {}
                gxtBuffer = {}
            end
            while isKeyDown(0x70) do wait(0) end
        end
        
        if enabled then
            local color = {}
            time = processAndRead(time)

            if isKeyDown(0x09) then
                gxtBuffer[bufferSize + 1] = getFreeGxtKey()
                color[bufferSize + 1] = {255, 255, 255}
                input = ""
                while isKeyDown(0x09) do wait(0) end
                setPlayerControl(playerHandle, false)
                attachCameraToChar(playerPed, 0.0, -0.5, 2.0, 0.0, 90.0, -180.0, 0.0, 2)

                while true do
                    wait(0)
                    local key
                    local customWait = function(key)
                        while isKeyDown(key) do
                            wait(0)
                            processAndShow(bufferSize, buffer, gxtBuffer, color)
                            time = processAndRead(time)
                        end
                    end
                    time = processAndRead(time)
                    
                    if wasKeyPressed(memory.read(0x00969110, 1, false)) and isKeyDown(0x10) then
                        key = string.upper(memory.tostring(0x00969110, 1, false))
                        if key == '9' then key = '('
                        elseif key == '0' then key = ')' end
                    elseif wasKeyPressed(memory.read(0x00969110, 1, false)) then
                        key = string.lower(memory.tostring(0x00969110, 1, false))
                    elseif isKeyDown(0x08) then
                        input = input:sub(1, -2)
                        customWait(0x08)
                    elseif isKeyDown(0x09) then
                        input = nil
                        buffer[bufferSize + 1] = nil
                        customWait(0x09)
                        break
                    elseif isKeyDown(0x0D) then
                        buffer[bufferSize + 1] = nil
                        onCommandRequest(input)
                        input = nil
                        time = os.time() - 10
                        time = processAndRead(time)
                        for i = bufferSize, 0, -1 do
                            gxtBuffer[i] = getFreeGxtKey()
                        end
                        customWait(0x0D)
                        break
                    elseif isKeyDown(0xBE) then key = '.'; customWait(0xBE)
                    elseif isKeyDown(0xBC) then key = ','; customWait(0xBC)
                    elseif isKeyDown(0xBD) then key = '-'; customWait(0xBD)
                    elseif isKeyDown(0xBB) and isKeyDown(0x10) then key = '='; customWait(0xBB)
                    elseif isKeyDown(0xBB) then key = '+'; customWait(0xBB)
                    --elseif isKeyDown(0xDE) then key = "'"; customWait(0xDE)
                    --elseif isKeyDown(0x21) then processAndRead(); customWait(0x21)
                    --elseif isKeyDown(0x22) then processAndRead(); customWait(0x22)
                    end

                    if key then input = string.format('%s%s', input, key) end
                    buffer[bufferSize + 1] = input
                    if buffer[bufferSize + 1] ~= nil then
                        setGxtEntry(gxtBuffer[bufferSize + 1], buffer[bufferSize + 1])
                    end

                    processAndShow(bufferSize, buffer, gxtBuffer, color)
                end
                wait(100)
                setPlayerControl(playerHandle, true)
                restoreCamera()
            end
            processAndShow(bufferSize, buffer, gxtBuffer, color)
        end
    end
end

function onExitScript(quitGame)
    setPlayerControl(playerHandle, true)
    restoreCamera()
end

function onCommandRequest(cmd)
    if cmd == nil then return end
    local args
    local error = false

    local function checkArgs(cmd, str, type)
        if string.match(cmd, str) then
            --local args2
            if type == 0 then args = string.match(cmd, "%('?(.-)'?%)")
            elseif type == 1 then args = string.match(cmd, "%('?(%d+)'?%)")
            --elseif type == 3 then args = string.match(cmd, "%w+%s(%d+)")
            end
            if args == nil and type ~= 2 then print('(error) Arguments missing'); error = true; return false
            else return true
            end
        end
    end

    if checkArgs(cmd, 'print', 0) then print(args)
    elseif checkArgs(cmd, 'veh', 1) then createVehicle(args)
    elseif checkArgs(cmd, 'weap', 1) then giveWeaponToChar(playerPed, args, 99999)
    elseif checkArgs(cmd, 'hp', 1) then setCharHealth(playerPed, args)
    elseif checkArgs(cmd, 'reloadall', 2) then print('\nReloading ALL Lua scripts\n'); reloadScripts()
    elseif checkArgs(cmd, 'logsize', 2) then local f = io.input('moonloader/moonloader.log'); print(f:seek('end')..' bytes')
    elseif checkArgs(cmd, 'clearlog', 2) then io.open('moonloader/moonloader.log', 'w'):close()
    elseif checkArgs(cmd, 'readdelay', 1) then delay = tonumber(args)
    elseif checkArgs(cmd, 'pagesize', 1) then bufferSize = tonumber(args)
    elseif checkArgs(cmd, 'help', 2) then print('Commands: print(str), veh(int), weap(int), hp(int)'); print('reloadall, logsize, clearlog, readdelay(int), pagesize(int), help')
    elseif error == false then print('(error) Command not found'); return end
end

function createVehicle(id)
    requestModel(id)
    loadAllModelsNow()
    local x, y, z = getCharCoordinates(playerPed)
    local car = createCar(id, x, y, z)
    setCarHeading(car, getCharHeading(playerPed))
    warpCharIntoCar(playerPed, car)
    wait(50)
    if isCharInFlyingVehicle(playerPed) then setCarCoordinates(car, x, y, z + 400.0)
    else setCarCoordinatesNoOffset(car, x, y, z) end
    markModelAsNoLongerNeeded(id)
    markCarAsNoLongerNeeded(car)
end

function processAndRead(time)
    if os.time() > time + delay then
        --local newBuffer --- doesnt work??
        --io.input(file)
        --while true do
            --wait(0)
            --local lines = io.read()
            --if lines == nil then break end
            --print(lines)
            --if buffer[0] == nil then buffer[0] = lines end
            --newBuffer = lines
        --end
        --for i = bufferSize, 1, -1 do
            --buffer[i] = buffer[i - 1]
            --print(buffer[i])
        --end
        --buffer[0] = newBuffer
        local lines = getLinesFromFile('moonloader/moonloader.log')
        --if offset ~= 0 then offset = offset + 5 end -- doesnt work
        for i = bufferSize, 0, -1 do
            --if offset ~= 0 then offset = offset + i end
            buffer[i] = lines[#lines - i]
            if buffer[i] ~= nil then buffer[i] = string.gsub(buffer[i], "%[%d%d:%d%d:%d%d%.%d+%]%s+", "", 1) end
        end
        time = os.time()
    end
    return time
end

function processAndShow(bufferSize, buffer, gxtBuffer, color)
    for i = 0, bufferSize, 1 do
        if buffer[i] ~= nil then
            if string.match(buffer[i], "%(error%)", 1) then
                color[i] = {255, 100, 100}
            elseif string.match(buffer[i], "%(script%)", 1) then
                color[i] = {255, 200, 100}
            
            else
                color[i] = {255, 255, 255}
            end
        end
    end

    for i = 0, bufferSize, 1 do
        setGxtEntry(gxtBuffer[i], buffer[i])
    end

    for i = #gxtBuffer, 0, -1 do
        local y = 0.0
        y = i * 17.5
        for k, v in pairs(color) do
            if i == k then
                displayGxtFormatted(gxtBuffer[i], 10.0, y, v[1], v[2], v[3])
            end
        end
    end
end

function displayGxtFormatted(gxt, x, y, r, g, b)
    setTextWrapx(650.0)
    setTextDropshadow(1, 0, 0, 0, 255)
    setTextScale(0.30, 1.1)
    setTextFont(1)
    setTextColour(r, g, b, 255)
    setTextEdge(1, 0, 0, 0, 255)
    setTextProportional(true)
    setTextBackground(false)
    displayText(x, y, gxt)
end

function getLinesFromFile(file)
    if not tryAndOpenFile(file) then return {} end
    lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end
    return lines
end

function tryAndOpenFile(file)
    local f = io.open(file, 'rb')
    if f then f:close() end
    return f ~= nil
end

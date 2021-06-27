local buffer = {}
local bufferSize = 5
local delay = 5
local reversed = false
local lineOffset = 0

function main()
    local gxtBuffer = {}
    local time
    local enabled = false
    local vkeys = require('vkeys')


    while true do
        wait(0)
        if isKeyDown(vkeys.VK_F1) then
            while isKeyDown(vkeys.VK_F1) do wait(0) end
            if not enabled then
                for i = bufferSize, 1, -1 do
                    gxtBuffer[i] = {getFreeGxtKey(), nil}
                end
                time = os.time() - 10
                enabled = true
            else
                enabled = false
                buffer = {}
                gxtBuffer = {}
                lineOffset = 0
            end
        end
        
        if enabled then
            local color = {}
            time = processAndRead(time, lineOffset)

            local function wasKeyPressedAndReleased(...)
                keys = {...}
                for i = 1, #keys do
                    if not isKeyDown(keys[i]) then
                        if keys[i] ~= nil then
                            return false
                        else
                            print('(error) key expected, got nil')
                        end
                    end
                end
                for i = 1, #keys do
                    while isKeyDown(keys[i]) do
                        wait(0)
                        processAndShow(bufferSize, buffer, gxtBuffer, color)
                        time = processAndRead(time, lineOffset)
                    end
                end
                return true
            end

            if wasKeyPressedAndReleased(vkeys.VK_PRIOR) then
                if reversed then
                    if lineOffset > 0 then
                        lineOffset = lineOffset - bufferSize
                    end
                else
                    lineOffset = lineOffset + bufferSize
                end
                time = os.time() - 10
                time = processAndRead(time, lineOffset)
                processAndShow(bufferSize, buffer, gxtBuffer, color)
            elseif wasKeyPressedAndReleased(vkeys.VK_NEXT) then
                if reversed then
                    lineOffset = lineOffset + bufferSize
                else
                    if lineOffset > 0 then
                        lineOffset = lineOffset - bufferSize
                    end
                end
                time = os.time() - 10
                time = processAndRead(time, lineOffset)
                processAndShow(bufferSize, buffer, gxtBuffer, color)
            elseif wasKeyPressedAndReleased(vkeys.VK_HOME) then
                if reversed then
                    lineOffset = 0    
                else
                    lineOffset = 'END'
                end
                time = os.time() - 10
                time = processAndRead(time, lineOffset)
                processAndShow(bufferSize, buffer, gxtBuffer, color)
            elseif wasKeyPressedAndReleased(vkeys.VK_END) then
                if reversed then
                    lineOffset = 'END'    
                else
                    lineOffset = 0
                end
                time = os.time() - 10
                time = processAndRead(time, lineOffset)
                processAndShow(bufferSize, buffer, gxtBuffer, color)
            end

            if isKeyDown(vkeys.VK_TAB) then
                while isKeyDown(vkeys.VK_TAB) do wait(0) end
                local input = ''
                local memory = require('memory')
                local inputGxt = bufferSize + 1
                gxtBuffer[inputGxt] = {getFreeGxtKey(), {255, 255, 255}}
                buffer[inputGxt] = {nil, nil}
                setPlayerControl(playerHandle, false)
                attachCameraToChar(playerPed, 0.0, -0.5, 2.0, 0.0, 90.0, -180.0, 0.0, 2)

                while true do
                    wait(0)
                    local key
                    time = processAndRead(time, lineOffset)
                    local function wasKeyPressedAndReleased(...)
                        keys = {...}
                        for i = 1, #keys do
                            if not isKeyDown(keys[i]) then
                                if keys[i] ~= nil then
                                    return false
                                else
                                    print('(error) key expected, got nil')
                                end
                            end
                        end
                        for i = 1, #keys do
                            while isKeyDown(keys[i]) do
                                wait(0)
                                processAndShow(bufferSize, buffer, gxtBuffer, color)
                                time = processAndRead(time, lineOffset)
                            end
                        end
                        return true
                    end
                    
                    if wasKeyPressed(memory.read(0x00969110, 1, false)) and isKeyDown(vkeys.VK_SHIFT) then
                        key = string.upper(memory.tostring(0x00969110, 1, false))
                        if key == '9' then
                            key = '('
                        elseif key == '0' then
                            key = ')'
                        end
                    elseif wasKeyPressed(memory.read(0x00969110, 1, false)) then
                        key = string.lower(memory.tostring(0x00969110, 1, false))
                    elseif wasKeyPressedAndReleased(vkeys.VK_BACK) then
                        input = input:sub(1, -2)
                    elseif wasKeyPressedAndReleased(vkeys.VK_TAB) then
                        input = nil
                        buffer[inputGxt][1] = nil
                        break
                    elseif wasKeyPressedAndReleased(vkeys.VK_RETURN) then
                        buffer[inputGxt][1] = nil
                        onCommandRequest(input)
                        input = nil
                        time = os.time() - 10
                        time = processAndRead(time, lineOffset)
                        for i = bufferSize, 1, -1 do
                            gxtBuffer[i][1] = getFreeGxtKey()
                        end
                        break
                    elseif wasKeyPressedAndReleased(vkeys.VK_OEM_PERIOD) then key = '.'
                    elseif wasKeyPressedAndReleased(vkeys.VK_OEM_COMMA) then key = ','
                    elseif wasKeyPressedAndReleased(vkeys.VK_OEM_MINUS) then key = '-'
                    elseif wasKeyPressedAndReleased(vkeys.VK_OEM_PLUS, vkeys.VK_SHIFT) then key = '='
                    elseif wasKeyPressedAndReleased(vkeys.VK_OEM_PLUS) then key = '+'
                    elseif wasKeyPressedAndReleased(vkeys.VK_OEM_7) then key = "'"
                    elseif wasKeyPressedAndReleased(vkeys.VK_PRIOR) then
                        if reversed then
                            if lineOffset > 0 then
                                lineOffset = lineOffset - bufferSize
                            end
                        else
                            lineOffset = lineOffset + bufferSize
                        end
                        time = os.time() - 10
                        time = processAndRead(time, lineOffset)
                        processAndShow(bufferSize, buffer, gxtBuffer, color)
                    elseif wasKeyPressedAndReleased(vkeys.VK_NEXT) then
                        if reversed then
                            lineOffset = lineOffset + bufferSize
                        else
                            if lineOffset > 0 then
                                lineOffset = lineOffset - bufferSize
                            end
                        end
                        time = os.time() - 10
                        time = processAndRead(time, lineOffset)
                        processAndShow(bufferSize, buffer, gxtBuffer, color)
                    elseif wasKeyPressedAndReleased(vkeys.VK_HOME) then
                        if reversed then
                            lineOffset = 0    
                        else
                            lineOffset = 'END'
                        end
                        time = os.time() - 10
                        time = processAndRead(time, lineOffset)
                        processAndShow(bufferSize, buffer, gxtBuffer, color)
                    elseif wasKeyPressedAndReleased(vkeys.VK_END) then
                        if reversed then
                            lineOffset = 'END'    
                        else
                            lineOffset = 0
                        end
                        time = os.time() - 10
                        time = processAndRead(time, lineOffset)
                        processAndShow(bufferSize, buffer, gxtBuffer, color)
                    end

                    if key then
                        input = input .. key
                    end
                    if input:sub(-1) == ' ' then
                        buffer[inputGxt][1] = input:sub(1, -2)
                    else
                        buffer[inputGxt][1] = input
                    end
                    if buffer[inputGxt][1] ~= nil then
                        setGxtEntry(gxtBuffer[inputGxt][1], buffer[inputGxt][1])
                    end
                    processAndShow(bufferSize, buffer, gxtBuffer, color)
                end
                wait(100)
                buffer[inputGxt] = nil
                gxtBuffer[inputGxt][1] = nil
                setPlayerControl(playerHandle, true)
                restoreCamera()
            end
            processAndShow(bufferSize, buffer, gxtBuffer, color)
        end
    end
end

function onScriptTerminate(script, quitGame)
    if script == thisScript() then
        setPlayerControl(playerHandle, true)
        restoreCamera()
    end
end

function onCommandRequest(cmd)
    if cmd == nil or cmd == '' then return end
    local args
    local is_args = true

    local function checkArgs(cmd, str, type)
        if string.match(cmd, str) then
            if type == 0 then args = string.match(cmd, "%('?(.-)'?%)") -- Anything between parenthesis
            elseif type == 1 then args = string.match(cmd, "%('?(%d+)'?%)") -- Any number between parenthesis
            --elseif type == 3 then args = string.match(cmd, "%w+%s(%d+)")
            end
            if args == nil and type ~= 2 then -- Type 2 = no arguments needed
                print('(error) Arguments missing')
                is_args = false
                return false
            else
                return true
            end
        end
    end

    if checkArgs(cmd, 'print', 0) then print(args)
    elseif checkArgs(cmd, 'veh', 1) then createVehicle(args)
    elseif checkArgs(cmd, 'weap', 1) then createWeapon(args)
    elseif checkArgs(cmd, 'hp', 1) then setCharHealth(playerPed, args)
    elseif checkArgs(cmd, 'reloadall', 2) then print('\nReloading ALL Lua scripts\n'); reloadScripts()
    elseif checkArgs(cmd, 'lines', 2) then local lines = 0; for l in io.lines('moonloader/moonloader.log') do lines = lines + 1 end; print(lines..' lines')
    elseif checkArgs(cmd, 'logsize', 2) then local f = io.input('moonloader/moonloader.log'); print(f:seek('end')..' bytes')
    elseif checkArgs(cmd, 'clearlog', 2) then io.open('moonloader/moonloader.log', 'w'):close()
    elseif checkArgs(cmd, 'updaterate', 1) then delay = tonumber(args)
    elseif checkArgs(cmd, 'pagesize', 1) then bufferSize = tonumber(args)
    elseif checkArgs(cmd, 'reversed', 2) then reversed = not reversed
    elseif checkArgs(cmd, 'help', 2) then print('Commands: print(str), veh(int), weap(int), hp(int)'); print('reloadall, lines, logsize, clearlog, updaterate(int), pagesize(int), help')
    elseif is_args then print('(error) Command not found')
    end
end

function createWeapon(id)
    local model = getWeapontypeModel(id)
    if isModelAvailable(model) then
        requestModel(model)
        loadAllModelsNow()
        giveWeaponToChar(playerPed, id, 99999)
        markModelAsNoLongerNeeded(model)
    else print('(error) Weapon does not exists') end
end

function createVehicle(id)
    if isModelAvailable(id) then
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
        wait(50)
        if isThisModelAPlane(id) then setCarCoordinates(car, x, y, z + 400.0) end
        --setCarCoordinatesNoOffset(car, x, y, z)
        markModelAsNoLongerNeeded(id)
        markCarAsNoLongerNeeded(car)
    else print('(error) Vehicle does not exists') end
end

function processAndRead(time, offset)
    if os.time() > time + delay then
        --[[
        local newBuffer -- doesnt work??
        io.input('moonloader/moonloader.log')
        while true do
            wait(0)
            local lines = io.read()
            if lines == nil then break end
            if buffer[0] == nil then buffer[0] = lines end
            newBuffer = lines
        end
        for i = bufferSize, 1, -1 do
            buffer[i] = buffer[i - 1]
            print(buffer[i])
        end
        buffer[0] = newBuffer
        ]]--
        local lines = getLinesFromFile('moonloader/moonloader.log')
        local numb = 0
        if offset then
            if type(offset) == 'string' then
                if offset == 'END' then
                    numb = -#lines
                    lineOffset = #lines
                end
            else
                if offset >= 0 then
                    numb = offset
                end
                if offset >= #lines then
                    numb = -#lines
                    lineOffset = #lines
                end
            end
        end
        for i = bufferSize, 1, -1 do
            buffer[i] = {lines[#lines - numb], nil}
            --if buffer[i] ~= nil then
            --    --buffer[i] = string.gsub(buffer[i], "%[%d%d:%d%d:%d%d%.%d+%]%s+", "", 1)
            --    buffer[i] = string.sub(buffer[i], 18, -1)
            --end
            numb = numb + 1
        end
        time = os.time()
    end
    return time
end

function processAndShow(bufferSize, buffer, gxtBuffer, color)
    for i = 1, bufferSize, 1 do
        setGxtEntry(gxtBuffer[i][1], buffer[i][1])
        if buffer[i][1] ~= nil then
            if buffer[i][2] == nil then
                local tmp = string.match(string.sub(buffer[i][1], 20, -1), '[^)]+')
                if tmp then
                    if tmp == 'error' then
                        gxtBuffer[i][2] = {255, 100, 100}
                        buffer[i][2] = {255, 100, 100}
                    elseif tmp == 'script' then
                        gxtBuffer[i][2] = {255, 200, 100}
                        buffer[i][2] = {255, 200, 100}
                    else
                        gxtBuffer[i][2] = {255, 255, 255}
                        buffer[i][2] = {255, 255, 255}
                    end
                end
            end
                --if string.match(buffer[i], "%(error%)", 1) then
                --    gxtBuffer[i][2] = {255, 100, 100}
                --elseif string.match(buffer[i], "%(script%)", 1) then
                --    gxtBuffer[i][2] = {255, 200, 100}
                --else
                --    gxtBuffer[i][2] = {255, 255, 255}
                --end
        end
    end
    
    local y = 0.0
    if reversed then
        y = #gxtBuffer * 17.5 - 17.5
        if #gxtBuffer > bufferSize then
            y = y - 17.5 -- Compensate the input gxt
        end
    end
    if #gxtBuffer > bufferSize then
        displayGxtFormatted(gxtBuffer[bufferSize + 1][1], 10.0, bufferSize * 17.5, gxtBuffer[bufferSize + 1][2][1], gxtBuffer[bufferSize + 1][2][2], gxtBuffer[bufferSize + 1][2][3])
    end

    for i = 1, bufferSize do
        displayGxtFormatted(gxtBuffer[i][1], 10.0, y, gxtBuffer[i][2][1], gxtBuffer[i][2][2], gxtBuffer[i][2][3])
        if reversed then
            y = y - 17.5
        else
            y = y + 17.5
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
    local lines = {}
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

local memory = require 'memory'
local buffer = {}
local bufferSize = 4

function main()
    local gxtBuffer = {}
    local time = os.time() - 5
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
            time = processAndRead(time, bufferSize, buffer)

            if isKeyDown(0x09) then
                gxtBuffer[bufferSize + 1] = getFreeGxtKey()
                color[bufferSize + 1] = {255, 255, 255}
                input = ""
                while isKeyDown(0x09) do wait(0) end
                setPlayerControl(playerHandle, false)
                attachCameraToChar(playerPed, 0.0, -1.0, 2.0, 0.0, 90.0, -90.0, 0.0, 2)
                while true do
                    wait(0)
                    local key
                    local customWait = function(key)
                        while isKeyDown(key) do
                            wait(0)
                            processAndShow(bufferSize, buffer, gxtBuffer, color)
                            time = processAndRead(time, bufferSize, buffer)
                        end
                    end
                    time = processAndRead(time, bufferSize, buffer)
                    
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
                        time = processAndRead(time, bufferSize, buffer)
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
                    elseif isKeyDown(0x23) then key = "'"; customWait(0x23)
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

--function checkArgs(cmd, str, type)
--    if string.match(cmd, str, 1) then
--        local args = string.match(cmd, "%('?(.-)'?%)", 1)
--        if args ~= nil then return args
--        else print('(error)     Arguments missing'); return false end
--    end
--end

function onCommandRequest(cmd)
    if cmd == nil then return end
    local args
    local error = false
    local function checkArgs(cmd, str, type)
        if string.match(cmd, str, 1) then
            local args2
            if type == 0 then args2 = string.match(cmd, "%('?(.-)'?%)", 1)
            elseif type == 1 then args2 = string.match(cmd, "%('?(%d+)'?%)", 1)
            end
            if args2 == nil then print('(error) Arguments missing'); error = true; return false
            elseif type == 0 then args = args2; return true
            elseif type == 1 then args = tonumber(args2); return true
            end
        end
    end
    if checkArgs(cmd, 'print', 0) then print(args)
    elseif checkArgs(cmd, 'buffer', 1) then bufferSize = tonumber(args)
    elseif error == false then print('(error) Command not found'); return end
end

function processAndRead(time, bufferSize, buffer)
    if os.time() > time + 5 then
        local file = 'moonloader/moonloader.log'
        local lines = getLinesFromFile(file)
        for i = bufferSize, 0, -1 do
            buffer[i] = lines[#lines - i]
            --print(lines[#lines - i])
            buffer[i] = string.gsub(buffer[i], "%[%d%d:%d%d:%d%d%.%d+%]%s+", "", 1)
        end
        time = os.time()
    end
    return time
end

function processAndShow(bufferSize, buffer, gxtBuffer, color)
    for i = 0, bufferSize, 1 do
        if buffer[i] ~= nil then
            if string.match(buffer[i], "(error)", 1) then
                color[i] = {255, 100, 100}
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
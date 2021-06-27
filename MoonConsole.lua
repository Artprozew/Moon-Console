local moonConsole = {}
moonConsole._Commands = {}
moonConsole._Internal = {
    strBuffer = {},
    pageSize = 5,
    delay = 2,
    reversed = false,
    lineOffset = 0
}
moonConsole._VERSION = '1.0'
require('lfs')


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
                for i = moonConsole._Internal.pageSize, 1, -1 do
                    gxtBuffer[i] = {getFreeGxtKey(), nil}
                end
                time = os.time() - 10
                enabled = true
                local dir = getWorkingDirectory() .. '\\lib\\Moon Console'
                if not doesDirectoryExist(dir) then
                    createDirectory(dir)
                end
                for file in lfs.dir(dir) do
                    if file:match('^[^%.]+.lua$') then
                        local module = require('Moon Console.' .. file:sub(1, -5))
                        if module then
                            if module._Commands then
                                if type(module._Commands) == 'table' then
                                    for k in pairs(module._Commands) do
                                        moonConsole._Commands[k] = module._Commands[k]
                                    end
                                end
                            end
                        end
                    end
                end
            else
                enabled = false
                moonConsole._Internal.strBuffer = {}
                gxtBuffer = {}
                moonConsole._Internal.lineOffset = 0
            end
        end
        
        if enabled then
            local color = {}
            time = processAndRead(time, moonConsole._Internal.lineOffset)

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
                        processAndShow(moonConsole._Internal.pageSize, moonConsole._Internal.strBuffer, gxtBuffer, color)
                        time = processAndRead(time, moonConsole._Internal.lineOffset)
                    end
                end
                return true
            end

            if wasKeyPressedAndReleased(vkeys.VK_PRIOR) then
                if moonConsole._Internal.reversed then
                    if moonConsole._Internal.lineOffset > 0 then
                        moonConsole._Internal.lineOffset = moonConsole._Internal.lineOffset - moonConsole._Internal.pageSize
                    end
                else
                    moonConsole._Internal.lineOffset = moonConsole._Internal.lineOffset + moonConsole._Internal.pageSize
                end
                time = os.time() - 10
                time = processAndRead(time, moonConsole._Internal.lineOffset)
                processAndShow(moonConsole._Internal.pageSize, moonConsole._Internal.strBuffer, gxtBuffer, color)
            elseif wasKeyPressedAndReleased(vkeys.VK_NEXT) then
                if moonConsole._Internal.reversed then
                    moonConsole._Internal.lineOffset = moonConsole._Internal.lineOffset + moonConsole._Internal.pageSize
                else
                    if moonConsole._Internal.lineOffset > 0 then
                        moonConsole._Internal.lineOffset = moonConsole._Internal.lineOffset - moonConsole._Internal.pageSize
                    end
                end
                time = os.time() - 10
                time = processAndRead(time, moonConsole._Internal.lineOffset)
                processAndShow(moonConsole._Internal.pageSize, moonConsole._Internal.strBuffer, gxtBuffer, color)
            elseif wasKeyPressedAndReleased(vkeys.VK_HOME) then
                if moonConsole._Internal.reversed then
                    moonConsole._Internal.lineOffset = 0    
                else
                    moonConsole._Internal.lineOffset = 'END'
                end
                time = os.time() - 10
                time = processAndRead(time, moonConsole._Internal.lineOffset)
                processAndShow(moonConsole._Internal.pageSize, moonConsole._Internal.strBuffer, gxtBuffer, color)
            elseif wasKeyPressedAndReleased(vkeys.VK_END) then
                if moonConsole._Internal.reversed then
                    moonConsole._Internal.lineOffset = 'END'    
                else
                    moonConsole._Internal.lineOffset = 0
                end
                time = os.time() - 10
                time = processAndRead(time, moonConsole._Internal.lineOffset)
                processAndShow(moonConsole._Internal.pageSize, moonConsole._Internal.strBuffer, gxtBuffer, color)
            end

            if isKeyDown(vkeys.VK_TAB) then
                while isKeyDown(vkeys.VK_TAB) do wait(0) end
                local input = ''
                local memory = require('memory')
                local inputGxt = moonConsole._Internal.pageSize + 1
                gxtBuffer[inputGxt] = {getFreeGxtKey(), {255, 255, 255}}
                moonConsole._Internal.strBuffer[inputGxt] = {nil, nil}
                setPlayerControl(playerHandle, false)
                attachCameraToChar(playerPed, 0.0, -0.5, 2.0, 0.0, 90.0, -180.0, 0.0, 2)

                while true do
                    wait(0)
                    local key
                    time = processAndRead(time, moonConsole._Internal.lineOffset)
                    
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
                        moonConsole._Internal.strBuffer[inputGxt][1] = nil
                        break
                    elseif wasKeyPressedAndReleased(vkeys.VK_RETURN) then
                        moonConsole._Internal.strBuffer[inputGxt][1] = nil
                        onCommandRequest(input)
                        for i = moonConsole._Internal.pageSize, 1, -1 do
                            if not gxtBuffer[i] then
                                gxtbuffer[i] = {getFreeGxtKey(), nil} -- attempt to index (nil)
                            else
                                gxtBuffer[i][1] = getFreeGxtKey()
                            end
                        end
                        input = nil
                        time = os.time() - 10
                        time = processAndRead(time, moonConsole._Internal.lineOffset)
                        --print(moonConsole._Internal.pageSize)
                        break
                    elseif wasKeyPressedAndReleased(vkeys.VK_CONTROL, vkeys.VK_V) then key = getClipboardText()
                    elseif wasKeyPressedAndReleased(vkeys.VK_CONTROL, vkeys.VK_C) then setClipboardText(input)
                    elseif wasKeyPressedAndReleased(vkeys.VK_OEM_PERIOD) then key = '.'
                    elseif wasKeyPressedAndReleased(vkeys.VK_OEM_COMMA) then key = ','
                    elseif wasKeyPressedAndReleased(vkeys.VK_OEM_MINUS) then key = '-'
                    elseif wasKeyPressedAndReleased(vkeys.VK_OEM_PLUS, vkeys.VK_SHIFT) then key = '+'
                    elseif wasKeyPressedAndReleased(vkeys.VK_OEM_PLUS) then key = '='
                    elseif wasKeyPressedAndReleased(vkeys.VK_OEM_7) then key = "'"
                    elseif wasKeyPressedAndReleased(vkeys.VK_PRIOR) then
                        if moonConsole._Internal.reversed then
                            if moonConsole._Internal.lineOffset > 0 then
                                moonConsole._Internal.lineOffset = moonConsole._Internal.lineOffset - moonConsole._Internal.pageSize
                            end
                        else
                            moonConsole._Internal.lineOffset = moonConsole._Internal.lineOffset + moonConsole._Internal.pageSize
                        end
                        time = os.time() - 10
                        time = processAndRead(time, moonConsole._Internal.lineOffset)
                        processAndShow(moonConsole._Internal.pageSize, moonConsole._Internal.strBuffer, gxtBuffer, color)
                    elseif wasKeyPressedAndReleased(vkeys.VK_NEXT) then
                        if moonConsole._Internal.reversed then
                            moonConsole._Internal.lineOffset = moonConsole._Internal.lineOffset + moonConsole._Internal.pageSize
                        else
                            if moonConsole._Internal.lineOffset > 0 then
                                moonConsole._Internal.lineOffset = moonConsole._Internal.lineOffset - moonConsole._Internal.pageSize
                            end
                        end
                        time = os.time() - 10
                        time = processAndRead(time, moonConsole._Internal.lineOffset)
                        processAndShow(moonConsole._Internal.pageSize, moonConsole._Internal.strBuffer, gxtBuffer, color)
                    elseif wasKeyPressedAndReleased(vkeys.VK_HOME) then
                        if moonConsole._Internal.reversed then
                            moonConsole._Internal.lineOffset = 0    
                        else
                            moonConsole._Internal.lineOffset = 'END'
                        end
                        time = os.time() - 10
                        time = processAndRead(time, moonConsole._Internal.lineOffset)
                        processAndShow(moonConsole._Internal.pageSize, moonConsole._Internal.strBuffer, gxtBuffer, color)
                    elseif wasKeyPressedAndReleased(vkeys.VK_END) then
                        if moonConsole._Internal.reversed then
                            moonConsole._Internal.lineOffset = 'END'    
                        else
                            moonConsole._Internal.lineOffset = 0
                        end
                        time = os.time() - 10
                        time = processAndRead(time, moonConsole._Internal.lineOffset)
                        processAndShow(moonConsole._Internal.pageSize, moonConsole._Internal.strBuffer, gxtBuffer, color)
                    end

                    if key then
                        input = input .. key
                    end
                    if input:sub(-1) == ' ' then
                        moonConsole._Internal.strBuffer[inputGxt][1] = input:sub(1, -2)
                    else
                        moonConsole._Internal.strBuffer[inputGxt][1] = input
                    end
                    if moonConsole._Internal.strBuffer[inputGxt][1] ~= nil then
                        setGxtEntry(gxtBuffer[inputGxt][1], moonConsole._Internal.strBuffer[inputGxt][1])
                    end
                    processAndShow(moonConsole._Internal.pageSize, moonConsole._Internal.strBuffer, gxtBuffer, color)
                end
                wait(100)
                moonConsole._Internal.strBuffer[inputGxt] = nil
                gxtBuffer[inputGxt][1] = nil
                setPlayerControl(playerHandle, true)
                restoreCamera()
            end
            processAndShow(moonConsole._Internal.pageSize, moonConsole._Internal.strBuffer, gxtBuffer, color)
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
    if cmd == nil then return end
    if cmd == '' then return end
    local command = string.match(cmd, '^([^ (]+)')
    local commandHandler = moonConsole._Commands[command]
    if command == nil then return end
    if command == '' then return end

    if command == 'help' then
        local cmds = ''
        for key, value in pairs(moonConsole._Commands) do
            --local args = value.commandHelp or value.funcArguments or value.argshints or value.arguments or '...'
            local args
            if value.commandHelp then
                args = value.commandHelp
            elseif value.funcArguments then
                args = value.funcArguments
            elseif unpack(value.argshints) then
                args = value.argshints
            elseif unpack(value.arguments) then
                args = value.arguments
            else
                args = '...'
            end
            if type(args) == 'table' then
                local tmp = ''
                for k, v in pairs(args) do
                    tmp = tmp .. v
                end
                args = tmp
                if args == '' then
                    args = nil
                end
            end
            if args == 'nil' then
                args = '...'
            end

            args = commandHandler.commandHandling == false and '[' .. args .. ']' or '<' .. args .. '>'
            cmds = cmds .. value.name .. args .. ', '
        end
        cmds = cmds:sub(1, -3)
        return print('Commands:', cmds)
    end

    if commandHandler ~= nil then
        if commandHandler.func ~= nil then
            if type(commandHandler.func) == 'function' then
                if commandHandler.commandHandling == false then -- No arguments required. Just sends the raw arguments (default)
                    cmd = cmd:sub(#command + 1)
                elseif commandHandler.commandHandling == 0 then -- Arguments required. Match anything between parenthesis or spaces
                    cmd = cmd:sub(1, #command)
                    local firstChar = cmd:sub(1, 1)
                    local lastChar = cmd:sub(#cmd)

                    if firstChar == '(' and lastChar == ')' then
                        cmd = cmd:sub(2, -1 - 1)
                    elseif firstChar == ' ' then
                        cmd = cmd:sub(2)
                    else
                        return print('(error) Invalid syntax')
                    end
                    if #cmd == 0 then
                        return print('(error) Invalid syntax')
                    end

                end

                res = commandHandler.func(cmd)

                if res ~= nil then
                    if res._setValue ~= nil then
                        if type(res._setValue) == 'table' then
                            for key, value in pairs(res._setValue) do
                                if moonConsole._Internal[key] ~= nil then
                                    moonConsole._Internal[key] = value
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        print('(error) No command named "' .. command .. '"')
    end
end


function processAndRead(time, offset)
    if os.time() >= time + moonConsole._Internal.delay then
        --[[
        local newBuffer -- doesnt work??
        io.input('moonloader/moonloader.log')
        while true do
            wait(0)
            local lines = io.read()
            if lines == nil then break end
            if moonConsole._Internal.strBuffer[0] == nil then moonConsole._Internal.strBuffer[0] = lines end
            newBuffer = lines
        end
        for i = moonConsole._Internal.pageSize, 1, -1 do
            moonConsole._Internal.strBuffer[i] = moonConsole._Internal.strBuffer[i - 1]
            print(moonConsole._Internal.strBuffer[i])
        end
        moonConsole._Internal.strBuffer[0] = newBuffer
        ]]--
        local lines = getLinesFromFile('moonloader/moonloader.log')
        local numb = 0
        if offset then
            if type(offset) == 'string' then
                if offset == 'END' then
                    numb = -#lines
                    moonConsole._Internal.lineOffset = #lines
                end
            else
                if offset >= 0 then
                    numb = offset
                end
                if offset >= #lines then
                    numb = -#lines
                    moonConsole._Internal.lineOffset = #lines
                end
            end
        end
        for i = moonConsole._Internal.pageSize, 1, -1 do
            moonConsole._Internal.strBuffer[i] = {lines[#lines - numb], nil}
            --if moonConsole._Internal.strBuffer[i] ~= nil then
            --    --moonConsole._Internal.strBuffer[i] = string.gsub(moonConsole._Internal.strBuffer[i], "%[%d%d:%d%d:%d%d%.%d+%]%s+", "", 1)
            --    moonConsole._Internal.strBuffer[i] = string.sub(moonConsole._Internal.strBuffer[i], 18, -1)
            --end
            numb = numb + 1
        end
        time = os.time()
    end
    return time
end

function processAndShow(bufferSize, buffer, gxtBuffer, color)
    for i = 1, moonConsole._Internal.pageSize, 1 do
        if moonConsole._Internal.pageSize ~= 5 then
            for k, v in pairs(gxtBuffer) do
                print(k, v, 'gxtbuffer')
            end
            for k, v in pairs(moonConsole._Internal.strBuffer) do
                print(k, v, 'strbuffer')
            end
        end
        setGxtEntry(gxtBuffer[i][1], moonConsole._Internal.strBuffer[i][1])
        if moonConsole._Internal.strBuffer[i][1] ~= nil then
            if moonConsole._Internal.strBuffer[i][2] == nil then
                local tmp = string.match(string.sub(moonConsole._Internal.strBuffer[i][1], 20, -1), '[^)]+')
                if tmp then
                    if tmp == 'error' then
                        gxtBuffer[i][2] = {255, 100, 100}
                        moonConsole._Internal.strBuffer[i][2] = {255, 100, 100}
                    elseif tmp == 'script' then
                        gxtBuffer[i][2] = {255, 200, 100}
                        moonConsole._Internal.strBuffer[i][2] = {255, 200, 100}
                    else
                        gxtBuffer[i][2] = {255, 255, 255}
                        moonConsole._Internal.strBuffer[i][2] = {255, 255, 255}
                    end
                end
            end
                --if string.match(moonConsole._Internal.strBuffer[i], "%(error%)", 1) then
                --    gxtBuffer[i][2] = {255, 100, 100}
                --elseif string.match(moonConsole._Internal.strBuffer[i], "%(script%)", 1) then
                --    gxtBuffer[i][2] = {255, 200, 100}
                --else
                --    gxtBuffer[i][2] = {255, 255, 255}
                --end
        end
    end
    
    local y = 0.0
    local bufferSize = moonConsole._Internal.pageSize
    if moonConsole._Internal.reversed then
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
        if moonConsole._Internal.reversed then
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
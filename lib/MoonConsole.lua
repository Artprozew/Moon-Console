local moonConsole = {}
moonConsole.__index = moonConsole

function moonConsole.getArgs(fun)
    local args = {}
    local hook = debug.gethook()
    
    local argHook = function( ... )
        local info = debug.getinfo(3)
        if info ~= nil then
            if 'pcall' ~= info.name then return end
        end
    
        for i = 1, math.huge do
            wait(0)
            local name, value = debug.getlocal(2, i)
            if '(*temporary)' == name then
                debug.sethook(hook)
                error('')
                return
            end
            table.insert(args, name)
        end
    end
    
    debug.sethook(argHook, "c")
    pcall(fun)
    --debug.sethook()
    return args
end

function moonConsole:create()
    console = {}
    --console.newCommand = {}
    console._Commands = {}
    setmetatable(console, {__index = moonConsole})
    --setmetatable(console.newCommand, {__call = self.addCommand}) -- doesnt work with class
    return console
end

function moonConsole:addCommand(commandName, functionHandler, ...)
    assert(type(commandName) == 'string', string.format("bad argument #1 to 'commandName' (string expected, got %s)", type(commandName)))
    assert(type(functionHandler) == 'function', string.format("bad argument #2 to 'functionHandler' (function expected, got %s)", type(functionHandler)))
    --local success, err = assert(pcall(functionHandler), err)
    local funcArguments = nil--moonConsole.getArgs(functionHandler)
    local args = {...} or funcArguments
    local autoHandling = args.auto_handling or false
    local cmdHelp = args.cmdHelp
    
    if not cmdHelp then
        for i = 1, #args do
            cmdHelp = cmdHelp .. ' [' .. args[i] .. ']'
        end
    end

    
    self._Commands[commandName] = {
        name = commandName,
        func = functionHandler,
        commandHandling = autoHandling,
        commandHelp = cmdHelp,
        arguments = funcArguments,
        argshints = args
    }
    return module
end

function moonConsole:setValue(field, value)
    local tmp = {}
    tmp._setValue = {}
    tmp._setValue[field] = value
    return tmp
end

function moonConsole:allcmds()
    return self._Commands
end


moonConsole._Commands = {}
return moonConsole
function loadedplugin(name)
    return not (plugins[name] == nil)
end

function pluginexists(name)
    return not (io.open("./plugins/"..name..".lua", "r") == nil)
end

function unhandle(event, handler, triggers)
    if IRC_ACTIONS[event] then
        local el = IRC_ACTIONS[event]
        if event == "triggers" and triggers then
            for i,v in ipairs(triggers) do
                el[v] = nil
            end
        else
            for i,v in ipairs(el) do
                if v == handler then
                    table.remove(el, i)
                end
            end
        end
    end
end

function handle(event, handler, triggers) 
    if IRC_ACTIONS[event] then
        local el = IRC_ACTIONS[event]
        if event == "triggers" and triggers then
            for i,v in ipairs(triggers) do
                el[v] = handler
            end
        else
            el[#el+1] = handler
        end
    end
end

function loadplugin(name, _)
    if loadedplugin(name) then return end
    if not pluginexists(name) then return "No such plugin." end
    if not _ then 
        local pname = ""
        for k,v in pairs(plugins) do 
            if v == getfenv(2) then
                pname = k
            end
        end
        --print("Loading plugin "..name.." as a dependency for plugin "..pname..".")
        print("Plugin "..pname.." is loading plugin "..name..".")
    end
    
    local plugin_env = setmetatable({}, { __index = getfenv(0), __metatable = {} })
    local plugin_chunk,err = loadfile("./plugins/" .. name .. '.lua')
    if err then 
        print("Error loading plugin "..name.." - "..err)
        return err
    end
       
    setfenv(plugin_chunk, plugin_env)
    local a,err = pcall(plugin_chunk)
    if not a then 
        print("Error loading plugin "..name.." - "..err)
        return err
    end
    
    plugins[name] = plugin_env
    
    if plugin_env.startup then 
        local a,err = pcall(plugin_env.startup) 
        if not a then
            print("Error starting up plugin "..name.." - "..err)
            plugins[name] = nil
            return err
        end
    end
    
    for k,v in pairs(plugin_env) do
        if k:match("^handle_") then
            if k:match("^handle_triggers") then
                handle(k:gsub("^handle_", ""), v, plugin_env.commands)
            else
                handle(k:gsub("^handle_", ""), v)
            end
        end
    end
end

function closeplugin(name, _)
    if not loadedplugin(name) then return end
    if not _ then
        local pname = ""
        for k,v in pairs(plugins) do 
            if v == getfenv(2) then
                pname = k
            end
        end
        print("Plugin "..pname.." is closing plugin "..name..".")
    end
    
    local ln = plugins[name]
    if not ln then return end
    
    for k,v in pairs(plugins[name]) do
        if k:match("^handle_") then
            if k:match("^handle_triggers") then 
                unhandle(k:gsub("^handle_", ""), v, plugins[name].commands)
            else
                unhandle(k:gsub("^handle_", ""), v)
            end
        end
    end
    
    if plugins[name].cleanup then 
        local a,err = pcall(plugins[name].cleanup) 
        if not a then
            print("Error cleaning up plugin "..name.." - "..err)
            plugins[name] = nil
            return err
        end
    end
    plugins[name] = nil
end

function loadplugins() 
    local errs = ""
    for _,name in ipairs(start_plugins) do
        err = loadplugin(name, true)
        if err then 
            print("Error loading plugin "..name.." - "..err)
            errs = errs..err.." ---------- "
        end
    end
    if errs ~= "" then return errs end
end

function closeplugins()
    local errs = ""
    for name,value in pairs(plugins) do
        for k,v in pairs(value) do
            if k:match("^handle_") then
                if k:match("^handle_triggers") then 
                    unhandle(k:gsub("^handle_", ""), v, value.commands)
                else
                    unhandle(k:gsub("^handle_", ""), v)
                end
            end
        end
        if value.cleanup then 
            local a,err = pcall(value.cleanup) 
            if not a then
                print("Error cleaning up plugin "..name.." - "..err)
                errs = errs..err.." ---------- "
            end
        end
        plugins[name] = nil
    end
    if errs ~= "" then return errs end
end

function string:split(sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end

function string:join(list)
    local len = table.maxn(list)
    if len == 0 then 
        return "" 
    end
    local str = list[1]
    for i = 2, len do 
        str = str .. self .. list[i] 
    end
    return str
end

function table:contains(val)        
    for i,v in ipairs(self) do
        if v == val then return true end
    end
    return false
end

function table:sandr(val)
    for i,v in ipairs(self) do
        if v == val then 
            table.remove(self, i) 
        end
    end
end

function sawMessage(channel, user, message)
    for _,handler in ipairs(IRC_ACTIONS.message) do
        local a,err = pcall(handler, channel, user, message) 
        if not a then
            local plug = ""
            for k2,v2 in pairs(plugins) do 
                if v2 == v then plug = k2 end
            end
            print("Plugin "..plug.." message handler error: "..err)
        end
    end
    
    local args = message:split(" ")
    if not (args[1]:sub(1,1) == cmdPrefix) then return end
    local cmd = args[1]:sub(2)
    table.remove(args, 1)
    
    if IRC_ACTIONS.triggers[cmd] then
        local a,err = pcall(IRC_ACTIONS.triggers[cmd], channel, user, cmd, args) 
        if not a then
            local plug = ""
            for k2,v2 in pairs(plugins) do 
                if v2 == v then plug = k2 end
            end
            print("Plugin "..plug.." trigger handler error: "..err)
        end
    end
end

function sawMode(channel, user, mode, otheruser)
    for _,handler in ipairs(IRC_ACTIONS.mode) do
        local a,err = pcall(handler, channel, user, mode, otheruser) 
        if not a then
            local plug = ""
            for k2,v2 in pairs(plugins) do 
                if v2 == v then plug = k2 end
            end
            print("Plugin "..plug.." mode handler error: "..err)
        end
    end
end

function sawAction(channel, user, action)
    for _,handler in ipairs(IRC_ACTIONS.action) do
        local a,err = pcall(handler, channel, user, action) 
        if not a then
            local plug = ""
            for k2,v2 in pairs(plugins) do 
                if v2 == v then plug = k2 end
            end
            print("Plugin "..plug.." action handler error: "..err)
        end
    end
end

function sawQuit(user, message)
    for _,handler in ipairs(IRC_ACTIONS.quit) do
        local a,err = pcall(handler, user, message) 
        if not a then
            local plug = ""
            for k2,v2 in pairs(plugins) do 
                if v2 == v then plug = k2 end
            end
            print("Plugin "..plug.." quit handler error: "..err)
        end
    end
end

function sawJoin(channel, user)
    for _,handler in ipairs(IRC_ACTIONS.join) do
        local a,err = pcall(handler, channel, user) 
        if not a then
            local plug = ""
            for k2,v2 in pairs(plugins) do 
                if v2 == v then plug = k2 end
            end
            print("Plugin "..plug.." join handler error: "..err)
        end
    end
end

function sawPart(channel, user, message)
    for _,handler in ipairs(IRC_ACTIONS.part) do
        local a,err = pcall(handler, channel, user, message) 
        if not a then
            local plug = ""
            for k2,v2 in pairs(plugins) do 
                if v2 == v then plug = k2 end
            end
            print("Plugin "..plug.." part handler error: "..err)
        end
    end
end

function sawNick(oldnick, newnick) 
    for _,handler in ipairs(IRC_ACTIONS.part) do
        local a,err = pcall(handler, oldnick, newnick) 
        if not a then
            local plug = ""
            for k2,v2 in pairs(plugins) do 
                if v2 == v then plug = k2 end
            end
            print("Plugin "..plug.." nick handler error: "..err)
        end
    end
end

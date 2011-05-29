commands = { "what", "learn", "forget", "fulldb", "saveinfo", "loadinfo" }

local infodata = {}

function startup() 
    loadplugin("auth")
    
    local fh = io.open("./plugins/info.db", "r")
    if fh then
        for line in fh:lines() do
            if line == "" then return end
            local temp = line:split("\t")
            infodata[ temp[1] ] = temp[2]
        end
        fh:close()
    end
end

function cleanup()
    local fh = io.open("./plugins/info.db.tmp", "w")
    for k,v in pairs(infodata) do
        fh:write(string.format("%s\t%s\n", k, v))
    end
    fh:close()
    os.rename("./plugins/info.db.tmp", "./plugins/info.db")
end

function handle_message(channel, user, message)
    if message:match("^[^%"..cmdPrefix.."]*what .+$") then -- It's basically the "what" command
        args = message:split(" ")
        table.remove(args, 1)
        handle_triggers(channels, user, "what", args, true)
    end
end

function handle_triggers(channel, user, cmd, args, info_silent)
    if cmd == "what" then
        for i,v in ipairs(args) do
            args[i] = string.gsub(args[i], "[^A-Za-z0-9_-]", "")
        end
        
        local nargs = {}
        local i = 1
        while args[i] and (args[i] == "is" or args[i] == "are" or args[i] == "a" or args[i] == "an" or args[i] == "") do i = i + 1 end
        for k = i, #args do
            if nargs ~= "" then
                table.insert(nargs, args[i])
            end
        end 
        args = nargs
        
       if #args < 1 then
            if not info_silent then
                doMessage(channel, "...what should I tell you about?")
            end
            return
        end
        
        local tmp = string.join(" ", args)
        local k,v = getInfo(tmp)
        
        if k and v then
            doMessage(channel, user .. ": " .. k .. ": " .. v)
        else
            local handled = false
            if not handled and string.match(tmp, "ies$") then
                local tmp2 = string.gsub(tmp, "ies$", "y")
                local k,v = getInfo(tmp2)
                if k and v then 
                    doMessage(channel, user .. ": " .. k .. ": " .. v)
                    handled = true
                end
            end
            if not handled and string.match(tmp, "ves$") then
                local tmp2 = string.gsub(tmp, "ves$", "f")
                local k,v = getInfo(tmp2)
                if k and v then 
                    doMessage(channel, user .. ": " .. k .. ": " .. v)
                    handled = true
                else
                    local tmp2 = string.gsub(tmp, "ves$", "fe")
                    local k,v = getInfo(tmp2)
                    if k and v then
                        doMessage(channel, user .. ": " .. k .. ": " .. v)
                        handled = true
                    else
                        local tmp2 = string.gsub(tmp, "ves$", "ff")
                        local k,v = getInfo(tmp2)
                        if k and v then
                            doMessage(channel, user .. ": " .. k .. ": " .. v)
                            handled = true
                        end
                    end
                end
            end
            if not handled and string.match(tmp, "es$") then
                local tmp2 = string.gsub(tmp, "es$", "")
                local k,v = getInfo(tmp2)
                if k and v then 
                    doMessage(channel, user .. ": " .. k .. ": " .. v)
                    handled = true
                end
            end
            if not handled and string.match(tmp, "s$") then
                local tmp2 = string.gsub(tmp, "s$", "")
                local k,v = getInfo(tmp2)
                if k and v then 
                    doMessage(channel, user .. ": " .. k .. ": " .. v)
                    handled = true
                end
            end
            if not handled and not info_silent then
                doMessage(channel, user .. ", I don't know what " .. tmp .. " is.")
            end
        end
        return
    end
    
    if plugins.auth.isMod(user) then
        if cmd == "fulldb" then
            local db = ""
            for k,v in pairs(infodata) do db = k .. " " .. db end
            doMessage(channel, user..": My database contains: ".. db)
            return
        elseif cmd == "learn" then
            if #args < 1 then
                doMessage(channel, "...what should I learn?")
                return
            end
            local tmp = string.join(" ", args)
            local ind = tmp:find(" as ")
            local size = 4
            if not ind then 
                ind = tmp:find(" as: ")
                size = 5
                if not ind then
                    doMessage(channel, "...what should I learn " .. tmp .. " as?")
                    return
                end
            end
            local val = tmp:sub(ind+size)
            local key = tmp:sub(0, ind-1)
            local k,v = getInfo(key) 
            if k then
                doMessage(channel, "I already know what " .. k .. " is.")
                return
            end
            infodata[key] = val
            doMessage(channel, "Ok, I learned what " .. key .. " is.")
            return
        elseif cmd == "forget" then
            if #args < 1 then
                doMessage(channel, "...what should I forget?")
                return
            end
            local key = ""
            local tmp = string.join(" ", args)
            for k,v in pairs(infodata) do
                if k:lower() == tmp:lower() then 
                    infodata[k] = nil
                    key = k
                end
            end
            if key ~= "" then
                doMessage(channel, "Hmm, I can't seem to remember what "..key.." is anymore.")
            else
                doMessage(channel, "I don't know what "..tmp.." is.")
            end
            return
        elseif cmd == "saveinfo" then
            cleanup()
        elseif cmd == "loadinfo" then
            startup()
        end
    end
end

function getInfo(val) 
    for k,v in pairs(infodata) do
        if k:lower() == val:lower() then return k,v end
    end
    return nil
end

commands = { "load", "unload", "reload", "reloadall", "loaded" }

function startup()
    loadplugin("auth")
end

function handle_triggers(channel, user, cmd, args) 
    if plugins.auth.isAdmin(user) then
        if cmd == "load" then
            if loadedplugin(args[1]) then return end
            if #args < 1 then 
                doMessage(channel, user..": Not enough arguments.")
                return
            end
            loadplugin(args[1], true)
            doMessage(channel, "Loaded plugin "..args[1]..".")
            return
        elseif cmd == "unload" then
            if not loadedplugin(args[1]) then return end
            if #args < 1 then 
                doMessage(channel, user..": Not enough arguments.")
                return
            end
            if args[1] == "plugin_tools" then
                doMessage(channel, user..": You can't unload plugin_tools, but you can reload it! ;)")
                return
            end
            closeplugin(args[1], true)
            doMessage(channel, "Unloaded plugin "..args[1]..".")
            return
        elseif cmd == "reload" then
            if not loadedplugin(args[1]) then return end
            if #args < 1 then 
                doMessage(channel, user..": Not enough arguments.")
                return
            end
            err1 = closeplugin(args[1], true)
            if err1 then
                doMessage(channel, "Error closing plugin "..args[1].." - "..err1)
            end
            err2 = loadplugin(args[1], true)
            if err2 then
                doMessage(channel, "Error loading plugin "..args[1].." - "..err2)
            end
            doMessage(channel, "Done reloading plugin "..args[1]..".")
            return
        elseif cmd == "reloadall" then
            err1 = closeplugins()
            if err1 then
                doMessage(channel, "Error(s) closing plugins - "..err1)
            end
            err2 = loadplugins()
            if err2 then
                doMessage(channel, "Error(s) loading plugins - "..err2)
            end
            doMessage(channel, "Done reloading plugins.")
            return
        elseif cmd == "loaded" then
            if #args < 1 then 
                doMessage(channel, user..": Not enough arguments.")
                return
            end
            if pluginexists(args[1]) then
                if loadedplugin(args[1]) then
                    doMessage(channel, user..": Plugin "..args[1].." is loaded.")
                else
                    doMessage(channel, user..": Plugin "..args[1].." is not loaded.")
                end
            else
                doMessage(channel, user..": Plugin "..args[1].." does not exist.")
            end
            return
        end
    end
end

commands = { "join", "part" }

function startup()
    loadplugin("auth")
end

function handle_triggers(channel, user, cmd, args)
    if plugins.auth.isAdmin(user) then
        if #args < 1 then
            doMessage(channel, user..": Not enough arguments.")
            return
        end
        if cmd == "join" then
            doJoin(args[1])
        elseif cmd == "part" then
            doPart(args[1])
        end
    end
end

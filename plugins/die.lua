commands = { "die" }

function startup()
    loadplugin("auth")
end

function handle_triggers(channel, user, cmd, args)
    if plugins.auth.isOwner(user) then
        if cmd == "die" then
            doMessage(channel, user.. " wants me to leave, but I'll be back!")
            doQuit()
        end
    end
end

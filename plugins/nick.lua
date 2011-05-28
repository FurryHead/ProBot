commands = { "nick" }

function startup()
    loadplugin("auth")
end

function handle_triggers(channel, user, cmd, args)
    if plugins.auth.isAdmin(user) then
        if #args < 1 then
            doMessage(channel, user..": Not enough arguments.")
        end
        actions = {
            ["nick"] = function()
                doNick(args[1])
            end
        }
        if actions[cmd] then actions[cmd]() end
    end
end

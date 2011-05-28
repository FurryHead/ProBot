commands = { "mode" }

function startup()
    loadplugin("auth")
end

function handle_triggers(channel, user, cmd, args) 
    if plugins.auth.isAdmin(user) then
        actions = {
            ["mode"] = function()
                if #args < 1 then
                    doMessage(channel, user..": Not enough arguments.")
                    return
                end
                sendLine(string.format("MODE %s %s %s", channel, args[1], args[2] or ""))
            end
        }
        if actions[cmd] then actions[cmd]() end
    end
end

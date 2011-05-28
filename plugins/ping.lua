commands = { "ping" }

function handle_triggers(channel, user, cmd, args)
    if #args > 0 then
        doMessage(channel, user..": Pong "..string.join(" ", args))
    else
        doMessage(channel, user .. ": Pong")
    end
end

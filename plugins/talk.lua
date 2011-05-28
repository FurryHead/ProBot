commands = { "msg", "say" }

function handle_triggers(channel, user, cmd, args)
    if plugins.auth.isMod(user) then
        if cmd == "msg" or cmd == "say"  then
            if #args < 1 then
                doMessage(channel, user..": Not enough arguments.")
                return
            else
                if args[1]:match("^##?.+$") then
                    if #args < 2 then
                        doMessage(channel, user..": Not enough arguments.")
                        return
                    else
                        msg = ""
                        for i,v in pairs(args) do
                            if i ~= 1 then
                                msg = msg .. v .. " "
                            end
                        end
                        doMessage(args[1], msg)
                    end
                else
                    msg = ""
                        for i,v in pairs(args) do
                            msg = msg .. v .. " "
                        end
                    doMessage(channel, msg)
                end
            end
        end
    end
end

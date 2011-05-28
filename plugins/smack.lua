commands = { "smack" }

function handle_triggers(channel, user, cmd, args) 
    if cmd == "smack" then
        if #args < 1 then 
            doMessage(channel, user..": Who shall I smack this time?")
            return
        end
        if args[1]:lower() == nickname:lower() then
            doAction(channel, "smacks himself!")
        elseif args[1]:lower() == owner:lower() then
            doAction(channel, "smacks his owner, "..owner..". (Uh-Oh....)")
        elseif args[1]:lower() == "me" or args[1]:lower() == "myself" then
            if user == owner then
                doAction(channel, "smacks his owner, "..owner..". (Uh-Oh....)")
            else
                doAction(channel, "smacks "..user.."!")
            end
        elseif args[1]:lower() == "yourself" or args[1]:lower() == "you" then
            doAction(channel, "smacks himself!")
        elseif args[1]:lower() == "everyone" then
            doAction(channel, "smacks everyone in the channel!")
        else
            doAction(channel, "smacks "..args[1].."!")
        end
    end
end

commands = { }

function startup()

end

function cleanup()

end

function printd(text)
    if timestamp then
        text = "["..os.date(pfmt).."] "..text
    end
    print(text)
end

function handle_message(channel, user, message) 
    printd(string.format("<%s> %s: %s", channel, user, message))
end

function hande_mode(channel, user, mode, otheruser)
    if otheruser then -- The mode was set onto a user
        printd(string.format("<%s> %s sets mode %s on %s", channel, user, mode, otheruser))
    else -- Then the mode was set on the channel
        printd(string.format("<%s> %s sets mode %s", channel, user, mode))
    end
end

function handle_action(channel, user, action)
    printd(string.format("<%s> * %s %s", channel, user, action))
end

function handle_quit(user, message)
    if user == nick then
        person = "I have"
    else
        person = user .. " has"
    end
    printd(string.format("%s quit (%s)", person, message))
end

function handle_join(channel, user)
    if user == nick then 
        person = "I have"
    else
        person = user .. " has"
    end
    printd(string.format("%s joined %s", person, channel))
end

function handle_part(channel, user, message)
    if user == nick then 
        person = "I have"
    else
        person = user .. " has"
    end
    printd(string.format("%s left %s (%s)", person, channel, message))
end

function handle_nick(oldnick, newnick)
    if oldnick == nick then 
        person = "I am"
    else
        person = user .. " is"
    end
    printd(string.format("%s now known as %s", person, newnick))
end

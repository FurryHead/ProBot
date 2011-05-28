commands = { "google", "bing"}

function handle_triggers(channel, user, cmd, args) 
    if cmd == "google" then
        if #args < 1 then
            doMessage(channel, "...what should I search google for?")
            return
        end
        doMessage(channel, user .. ": here's the search link for you: http://www.google.com/search?q=" .. string.join("+", args))
        return
    elseif cmd == "bing" then
        if #args < 1 then
            doMessage(channel, "...what should I search bing for?")
            return
        end
        doMessage(channel, user .. ": here's the search link for you: http://www.bing.com/search?q=" .. string.join("+", args))
        return
    end
end

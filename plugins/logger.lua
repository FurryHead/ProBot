commands = { "lastlog" }

logfh = nil
logfmt = pfmt
start_or_stop_fmt = "%m/%d/%y %I:%M:%S %p"
logfile = "./plugins/logs/"..IRC_HOST..".log"
backlog = { }

function startup()
    logfh,err = io.open(logfile, "a")
    if err == (logfile..": No such file or directory") then
        error("Missing logfile directory. Please make a new folder named \"logs\" in the plugins folder, and try again.")
    elseif err then error(err) end
    logfh:write("====== Start of Log --- "..os.date(start_or_stop_fmt).." ======\n")
end

function cleanup()
    logfh:write("====== End of Log --- "..os.date(start_or_stop_fmt).." ======\n")
    logfh:close()
end

function log(msg)
    if logfmt then
        msg = "["..os.date(logfmt).."] "..msg
    end
    logfh:write(msg.."\n")
end

function add_to_backlog(channel, msg)
    if not backlog[channel] then backlog[channel] = {} end
    if logfmt then
        msg = "["..os.date(logfmt).."] "..msg
    end
    table.insert(backlog[channel], #(backlog[channel])+1, msg)
    if #(backlog[channel]) > 100 then
        table.remove(backlog[channel], 1)
    end
end

function handle_message(channel, user, message) 
    msg = string.format("<%s> %s: %s", channel, user, message)
    
    add_to_backlog(channel, msg)
    log(msg)
end

function hande_mode(channel, user, mode, otheruser)
    if otheruser then -- The mode was set onto a user
        msg = string.format("<%s> %s sets mode %s on %s", channel, user, mode, otheruser)
        add_to_backlog(channel, msg)
        log(msg)
    else -- Then the mode was set on the channel
        msg = string.format("<%s> %s sets mode %s", channel, user, mode)
        add_to_backlog(channel, msg)
        log(msg)
    end
end

function handle_action(channel, user, action)
    msg = string.format("<%s> * %s %s", channel, user, action)
    add_to_backlog(channel, msg)
    log(msg)
end

function handle_quit(user, message)
    if user == nick then
        person = "I have"
    else
        person = user .. " has"
    end
    for k,v in pairs(backlog) do
        add_to_backlog(k, string.format("%s quit (%s)", person, message))
    end
    log(string.format("%s quit (%s)", person, message))
end

function handle_join(channel, user)
    if user == nick then 
        person = "I have"
    else
        person = user .. " has"
    end
    add_to_backlog(channel, string.format("%s joined %s", person, channel))
    log(string.format("%s joined %s", person, channel))
end

function handle_part(channel, user, message)
    if user == nick then 
        person = "I have"
    else
        person = user .. " has"
    end
    add_to_backlog(channel, string.format("%s left %s (%s)", person, channel, message))
    log(string.format("%s left %s (%s)", person, channel, message))
end

function handle_nick(oldnick, newnick)
    if oldnick == nick then 
        person = "I am"
    else
        person = user .. " is"
    end
    add_to_backlog(channel, string.format("%s now known as %s", person, newnick))
    log(string.format("%s now known as %s", person, newnick))
end

function handle_triggers(channel, user, cmd, args)
    if cmd == "lastlog" then
        found = {}
        if #args < 1 then 
            doMessage(channel, user..": Not enough arguments.")
            return
        end
        for i,v in ipairs(backlog[channel]) do
            temp = string.join(" ", args)
            if logfmt then
                ch = channel:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1')
                t = temp:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1')
                m = string.format("^%%[.+%%] <%s> .+: [^%%%s]*.*%s.*", ch, cmdPrefix, t:lower())
            else
                ch = channel:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1')
                t = temp:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1')
                m = string.format("^<%s> .+: [^%%%s]*.*%s.*", ch, cmdPrefix, t:lower())
            end
            if v:lower():match(m) then
                table.insert(found, #found+1, v)
            end
        end
        g = msg
        if logfmt then g = "["..os.date(logfmt).."] "..g end
        if #found > 0 then
            for i,v in ipairs(found) do
                print(v)
                if v ~= g then
                    doMessage(channel, user..": "..v)
                end
            end
        end
    end
end

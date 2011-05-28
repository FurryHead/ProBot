commands = { "lastlog" }

local logfh = nil
local logfmt = pfmt
local start_or_stop_fmt = "%m/%d/%y %I:%M:%S %p"
local logfile = "./plugins/logs/"..IRC_HOST..".log"
local backlog = { }

function startup()
    local err
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

local function add_to_backlog(channel, msg)
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
    local msg = string.format("<%s> %s: %s", channel, user, message)
    
    add_to_backlog(channel, msg)
    log(msg)
end

function hande_mode(channel, user, mode, otheruser)
    local msg
    if otheruser then -- The mode was set onto a user
        msg = string.format("<%s> %s sets mode %s on %s", channel, user, mode, otheruser)
    else -- Then the mode was set on the channel
        msg = string.format("<%s> %s sets mode %s", channel, user, mode)
    end
    add_to_backlog(channel, msg)
    log(msg)
end

function handle_action(channel, user, action)
    local msg = string.format("<%s> * %s %s", channel, user, action)
    add_to_backlog(channel, msg)
    log(msg)
end

function handle_quit(user, message)
    local person
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
    local person
    if user == nick then 
        person = "I have"
    else
        person = user .. " has"
    end
    add_to_backlog(channel, string.format("%s joined %s", person, channel))
    log(string.format("%s joined %s", person, channel))
end

function handle_part(channel, user, message)
    local person
    if user == nick then 
        person = "I have"
    else
        person = user .. " has"
    end
    add_to_backlog(channel, string.format("%s left %s (%s)", person, channel, message))
    log(string.format("%s left %s (%s)", person, channel, message))
end

function handle_nick(oldnick, newnick)
    local person
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
        local found = {}
        if #args < 1 then 
            doMessage(channel, user..": Not enough arguments.")
            return
        end
        for i,v in ipairs(backlog[channel]) do
            local temp = string.join(" ", args)
            local m
            if logfmt then
                local ch = channel:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1')
                local t = temp:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1')
                m = string.format("^%%[.+%%] <%s> .+: [^%%%s]*.*%s.*", ch, cmdPrefix, t:lower())
            else
                local ch = channel:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1')
                local t = temp:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1')
                m = string.format("^<%s> .+: [^%%%s]*.*%s.*", ch, cmdPrefix, t:lower())
            end
            if v:lower():match(m) then
                table.insert(found, #found+1, v)
            end
        end
        local text = string.format("<%s> %s: +%s %s", channel, user, cmd, string.join(" ", args))
        if logfmt then text = "["..os.date(logfmt).."] "..text end
        if #found > 0 then
            for i,v in ipairs(found) do
                if v ~= text then
                    doMessage(channel, user..": "..v)
                end
            end
        end
    end
end

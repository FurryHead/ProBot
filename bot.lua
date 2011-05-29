require("socket")
require("socket.url")
require("socket.http")

dofile("config.lua")
dofile("functions.lua")
dofile("actions.lua")
dofile("seen.lua")

if not configured then
    error("You have not fully read the bot configuration file. (config.lua) Please read the file FULLY, then try starting the bot again.")
end

local running = true

local IRC_ACTIONS = {
    join = { },
    part = { },
    quit = { },
    nick = { },
    mode = { },
    ping = { },
    action = { },
    message = { },
    triggers = { },
}

local plugins = {}

package.path = package.path..";./plugins/?.lua"
loadplugins()

-- Create a socket, and connect
local conn = assert(socket.tcp(), "Could not make a TCP socket.")
assert(conn:connect(IRC_HOST, IRC_PORT), "Failed to connect.")

-- Register with the IRC server
sendLine("USER "..ident.." * * *")
sendLine("NICK "..nickname)

conn:settimeout(60)

function main()
    while running do
        local data, err = conn:receive()
        if err == "timeout" then
            err = nil
            sendLine("PING back")
            data, err = conn:receive()
            --print(data)
        end
        if err then error(err) end
        --print(data)
        local words = data:split(" ")
        
        if words[1] == "PING" then
            -- The server pinged us, we need to pong or we'll be disconnected
            -- (make sure to send whatever follows the PING, in case they send a random hash)
            sendLine("PONG " .. data:sub(5))
        end
        
        -- Takes the ':Nick!Ident@Host' chunk and assigns Nick to user
        local user = words[1]:split(":")[1]:split("!")[1]
        
        if words[2] == "376" then
            -- We successfully logged in, do post-login procedures
            if LoginName and LoginPass then
                doMessage("NickServ", string.format("IDENTIFY %s %s", LoginName, LoginPass))
            end
            
            for i,v in ipairs(start_channels) do
                doJoin(v)
            end
        end
        
        if words[2] == "PRIVMSG" then
            -- We got a message
            local channel = words[3]
            local message = data:sub(data:find(":", data:find(channel:sub(channel:find("-") or 1)))+1)
            if message:find("\01ACTION") then
                -- String was found, it's an action
                sawAction(channel, user, message:sub(9, -2))
            else
                -- String not found, it's a message
                sawMessage(channel, user, message)
            end
        end
        
        if words[2] == "JOIN" then
            -- Someone joined a channel that we're in
            if user ~= nickname then
                sawJoin(words[3]:sub(2), user)
            end
        end
        
        if words[2] == "PART" then
            if user ~= nick then
                -- Someone parted a channel we're in
                if words[4] then
                    -- They did have a part message
                    sawPart(words[3], user, data:sub(data:find(words[4])+1))
                else 
                    -- They didn't have a part message
                    sawPart(words[3], user, "")
                end
            end
        end
        
        if words[2] == "QUIT" then
            -- Someone quit the server
            sawQuit(user, data:sub(data:find("QUIT :") + 6)) 
        end
        
        if words[2] == "NICK" then
            -- Someone changed their nickname 
            sawNick(user, words[3]:sub(1))
        end
        
        if words[2] == "MODE" then 
            -- Someone set a mode
            sawMode(words[3], user, words[4], words[5])
        end
        
    end -- while running

    conn:close()

    closeplugins()
end

while running do main() end

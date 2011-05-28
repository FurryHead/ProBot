function sendLine(line) 
    assert(conn:send(line .. "\r\n"), "Failed to send.")
end

function doMessage(channel_or_username, message)
    sendLine("PRIVMSG " .. channel_or_username .. " :" .. message)
    sawMessage(channel_or_username, nickname, message)
end

function doAction(channel, action)
    sendLine("PRIVMSG " .. channel .. " :\01ACTION " .. action .. "\01")
    sawAction(channel, nickname, action)
end

function doJoin(channel)
    sendLine("JOIN " .. channel)
    sawJoin(channel, nickname)
end

function doPart(channel, message)
    if message then
        sendLine("PART " .. channel .. " " .. message)
    else
        sendLine("PART " .. channel)
    end
    sawPart(channel, nickname, message or "")
end

function doQuit(message)
    if message then
        sendLine("QUIT " .. message)
    else
        sendLine("QUIT")
    end
    sawQuit(nickname, message or "Client quit")
    running = false
end

function doNick(newnick)
    sendLine("NICK " .. newnick)
    sawNick(nickname, newnick)
    nickname = newnick
end

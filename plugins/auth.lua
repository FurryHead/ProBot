commands = { "addadmin", "addmod", "deladmin", "delmod", "admins", "mods", "owner" }

admins = {}
mods = {}

function startup() 
    fh = io.open("./plugins/auth.users", "r")
    if fh then
        for line in fh:lines() do
            if (not line) or (line == "") then return end
            tmp = line:split("\t")
            tads = tmp[1]:split(" ")
            if tads then
                for i,v in ipairs(tads) do
                    admins[i] = v
                end
            end
            tmds = tmp[2]:split(" ")
            if tmds then
                for i,v in ipairs(tmds) do
                    mods[i] = v
                end
            end
        end
        fh:close()
    end
end

function cleanup() 
    fh = io.open("./plugins/auth.users.tmp", "w")
    if #admins >= 1 then
        for _,v in pairs(admins) do
            fh:write(" "..v)
        end
    else
        fh:write(" ")
    end
    fh:write("\t")
    if #mods >= 1 then
        for _,v in pairs(mods) do
            fh:write(v.." ")
        end
    else
        fh:write(" ")
    end
    fh:close()
    os.rename("./plugins/auth.users.tmp", "./plugins/auth.users")
end

function handle_triggers(channel, user, cmd, args)
    actions = { 
        ["owner"] = function()
            doMessage(channel, user..": My owner is: "..owner)
        end,
        ["admins"] = function()
            doMessage(channel, user..": My administrators are: "..string.join(" ", admins))
        end,
        ["mods"] = function()
            doMessage(channel, user..": My moderators are: "..string.join(" ", mods))
        end
    }
    if actions[cmd] then 
        actions[cmd]()
        return
        
    elseif isOwner(user) then
        if #args < 1 then
            doMessage(channel, user .. ": Not enough arguments.")
            return
        end
        
        actions = {
            ["addadmin"] = function()
                ind = 1
                for i,v in ipairs(admins) do
                    ind = ind+1
                    if args[1] == v then return end
                end
                admins[ind] = args[1]
            end,
            ["addmod"] = function()
                ind = 1
                for i,v in ipairs(mods) do
                    ind = ind+1
                    if args[1] == v then return end
                end
                mods[ind] = args[1]
            end,
            ["deladmin"] = function()
                tads = {}
                ind = 1
                for i,v in ipairs(admins) do
                    if v ~= args[1] then
                        tads[ind] = v
                        ind = ind + 1
                    end
                end
                admins = tads
            end,
            ["delmod"] = function()
                tmds = {}
                ind = 1
                for i,v in ipairs(mods) do
                    if v ~= args[1] then
                        tmds[ind] = v
                        ind = ind + 1
                    end
                end
                mods = tmds
            end
        }
        if actions[cmd] then actions[cmd]() end
    end
end

function isOwner(user)
    return user == owner
end

function isAdmin(user)
    for _,v in ipairs(admins) do
        if user == v then return true end
    end
    return user == owner
end

function isMod(user)
    for _,v in ipairs(mods) do
        if user == v then return true end
    end
    for _,v in ipairs(admins) do
        if user == v then return true end
    end
    return user == owner
end

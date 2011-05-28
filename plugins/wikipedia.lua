commands = { "wiki", "wikipedia", "wikisearch" }

function startup() 
    loadplugin("xml")
end

function handle_triggers(channel, user, cmd, args)
    if #args < 1 then
        doMessage(channel, "...what should I search wikipedia for?")
        return
    end
    
    local url = "http://en.wikipedia.org/w/api.php?action=opensearch&limit=3&namespace=0&format=xml&search="
    local searchstr = string.join(" ", args)
    url = url .. socket.url.escape(searchstr)
    
    local xmlResultStr, c = socket.http.request(url)
    
    if not xmlResultStr then
        doMessage(channel, "Could not retrieve the wiki results. (Error: "..c..")")
        return
    end
    
    local xmlRoot = plugins.xml.XmlParser:ParseXmlText(xmlResultStr)
    local anyresults = false
    for i,xmlNode in pairs(xmlRoot.ChildNodes) do
        if(xmlNode.Name=="Section") then
            for i,subXmlNode in pairs(xmlNode.ChildNodes) do
                if(subXmlNode.Name=="Item") then
                    local text = ""
                    for i,item in pairs(subXmlNode.ChildNodes) do
                        if item.Name == "Text" then
                            text = text .. "Title: " .. item.Value .. " --- "
                        elseif item.Name == "Description" then
                            text = text .. "Description: " .. item.Value .. " --- "
                        elseif item.Name == "Url" then
                            text = text .. "URL: " .. item.Value
                        end
                    end
                    doMessage(channel, text)
                    anyresults = true
                end
            end
        end
    end
    if not anyresults then
        doMessage(channel, "No results match your query.")
    end
end

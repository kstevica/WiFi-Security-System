--[[
#################################################
# LUA script for ESP8266 using nodemcu firmware #
# Script author: Stevica Kuharski, @kstevica    #
# Date: 2015-05-03                              #
#                                               #
# When in doubt, SYS64738                       #
#################################################

Config part

_SSID - SSID of the AP
_PWD - password for AP
_LED_PIN - cathode pin where LED is connected
]]

_SSID = "sensorsap"
_PWD = nil
_LED_PIN = 4

print("STARTED")
gpio.mode(_LED_PIN, gpio.OUTPUT)
gpio.write(_LED_PIN, gpio.HIGH)
tmr.delay(500000)

createap = function()
    wifi.setmode(wifi.SOFTAP)
    wifi.ap.config({ssid=_SSID, pwd=_PWD})
    gpio.write(_LED_PIN, gpio.LOW)
    srv=net.createServer(net.TCP) 
    srv:listen(80,function(conn) 
        conn:on("receive", function(client,request)
            local current = tmr.time()
            while clientactive do
                if tmr.time()-current>2 then
                    clientactive = false
                end
            end
            local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
            if(method == nil)then 
                _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP"); 
            end
            local _GET = {}
            if (vars ~= nil)then 
                for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do 
                    _GET[k] = v 
                end 
            end                

            local returnstate = " NONE "
            if _GET.sensor ~= nil then
            	if _GET.state == "1" then
            		gpio.write(_LED_PIN, gpio.HIGH)
            		returnstate = " ON "
            	else
            		gpio.write(_LED_PIN, gpio.LOW)
            		returnstate = " OFF "
            	end
            end

            local header = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nCache-Control: no-cache, no-store, must-revalidate\r\nPragma: no-cache\r\nExpires: 0\r\n\r\n"
            client:send(header)
            client:send("<META HTTP-EQUIV=\"CACHE-CONTROL\" CONTENT=\"NO-CACHE\">")
            client:send("OK"..returnstate)
            client:close()

            collectgarbage()
            --print ("Free: ", node.heap())
        end)
    end)

end

print("listening, free:", node.heap())
createap()

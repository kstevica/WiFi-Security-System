--[[
#################################################
# LUA script for ESP8266 using nodemcu firmware #
# Script author: Stevica Kuharski, @kstevica    #
# Date: 2015-05-03                              #
#                                               #
# When in doubt, SYS64738                       #
#################################################

Config part

_SSID - SSID of the AP module
_PWD - password for AP module
_SENSOR_ID - id of the sensor module
_SENSOR_PIN - pin where to excpect motion sensor to react
_SERVER_IP - IP address of the AP module

]]

_SSID = "sensorsap"
_PWD = ""
_SENSOR_ID = 1
_SENSOR_PIN = 7
_SERVER_IP = "192.168.4.1"

gpio.mode(_SENSOR_PIN, gpio.OUTPUT)
gpio.write(_SENSOR_PIN, gpio.LOW)
tmr.delay(1000000)
gpio.mode(_SENSOR_PIN, gpio.INT)
working = true
last_state = 0

connecttoap = function(ssid, pwd)
    wifi.setmode(wifi.STATION)
    tmr.delay(1000000);
    wifi.sta.config(ssid, pwd)
    tmr.delay(5000000);
end


function pin1cb(level)
	if level == last_state then
		return
	end
	last_state = level
	local usestate = ""
	if level == 1 then
		print("UP")
		usestate = "1"
	else
		print("DOWN")
		usestate = "0"
	end
    local sk=net.createConnection(net.TCP, 0) 
    sk:on("receive", function(sck, c) 
            collectgarbage()
        end 
    )
    sk:on("connection", function(sck)
    		local _GET = "GET /?sensor=".._SENSOR_ID.."&state="..usestate.." HTTP/1.0\r\n\r\n"
            sck:send(_GET)         
        end 
    )
    sk:connect(80, _SERVER_IP)    
    collectgarbage()     
end

gpio.trig(_SENSOR_PIN, "both", pin1cb)

connecttoap(_SSID, _PWD)

tmr.alarm( 0, 3000, 1,
    function()
    	print("CONNECING...")
        if wifi.sta.status() == 5 then
            tmr.stop(0)            
        end
    end
)
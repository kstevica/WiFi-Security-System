--[[
#################################################
# LUA script for ESP8266 using nodemcu firmware #
# Script author: Stevica Kuharski, @kstevica    #
# Date: 2015-05-03                              #
#                                               #
# When in doubt, SYS64738                       #
#################################################

Config part

_LED_PIN - cathode pin where LED is connected
]]

_LED_PIN = 4
gpio.mode(_LED_PIN, gpio.OUTPUT)
gpio.write(_LED_PIN, gpio.LOW)
tmr.delay(3000000)
dofile("sensorap.lua")
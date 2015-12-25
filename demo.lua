
function Split(szFullString, szSeparator)
local nFindStartIndex = 1
local nSplitIndex = 1
local nSplitArray = {}
while true do
   local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
   if not nFindLastIndex then
    nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
    break
   end
   nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
   nFindStartIndex = nFindLastIndex + string.len(szSeparator)
   nSplitIndex = nSplitIndex + 1
end
return nSplitArray
end

gpio.mode(0,gpio.OUTPUT);--LED Light on
timer_i=-25
angle=0
conn=net.createConnection(net.TCP, false) 

conn:on("receive", function(sck, pl) 
local list = Split(pl, "\r\n")
if list[15]~=nil then

  my_pattern="increase\":(%p-%d+%p%d+)"
  angle=math.floor(tonumber(string.match(list[15], my_pattern) )*3+0.5) 
  print(angle)
  majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info()
  print("NodeMCU "..majorVer.."."..minorVer.."."..devVer.."flash size:"..flashsize.."flash speed:"..flashspeed)

  print("Remaining heap size is: "..node.heap())

  tmr.alarm(1, 500, 1, function()
  timer_i=timer_i+1

  if timer_i>50 then
    tmr.stop(1)
    timer_i=-25
  end
  pwm.setup(4,50, 75+angle)
  print( 75+angle)
  pwm.start(4)
  if gpio.read(0)==gpio.LOW then
    gpio.write(0,gpio.HIGH)
  else
    gpio.write(0,gpio.LOW)
  end
  end)
end
end)

conn:on("disconnection",function(sck,pl)
print ("reconnecting..")
conn:close()
tmr.delay(2000000)
conn=net.createConnection(net.TCP, false) 
conn:connect(80,"180.149.145.78")
end)

conn:on("sent",function(sck,pl)
print ("message sent.")
end)
conn:connect(80,"180.149.145.78")
tmr.alarm(0, 6000, 1, function()
if (conn==nil) then 
  print ("connection lost.")
  conn:connect(80,"180.149.145.78")
end
conn:send("GET /apistore/stockservice/stock?stockid=sz000020&list=1 HTTP/1.1\r\n"
    .."Host: apis.baidu.com\r\n"
    .."User-Agent: curl/7.45.0\r\n"
    .."Accept: */*\r\n"
    .."apikey:5e6f11295b7f4de3541685cbdfb4ca0e\r\n\r\n")

end)
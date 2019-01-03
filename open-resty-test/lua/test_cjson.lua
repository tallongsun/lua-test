local json = require("cjson")
local str = [[{"key":"value"}]]

local ok,t = pcall(json.decode,str)
if not ok then
  return
end
ngx.say("-->",type(t))

local data = {1,2}
data[10000] = 99
ngx.say(json.encode(data))

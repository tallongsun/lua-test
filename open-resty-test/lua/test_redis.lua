local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(1000)

local ok, err = red:connect("127.0.0.1", 5378)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

local count
count,err = red:get_reused_times()
if 0 == count then
  ok,err = red:auth("P@ssw0rd")
  if not ok then
    ngx.say("failed to auth: ",err)
    return
  end
elseif err then
  ngx.say("failed to get reused times: ",err)
  return
end

ok, err = red:set("dog", "an animal")
if not ok then
    ngx.say("failed to set dog: ", err)
    return
end

ngx.say("set result: ", ok)

local res, err = red:get("dog")
if not res then
    ngx.say("failed to get dog: ", err)
    return
end

if res == ngx.null then
    ngx.say("dog not found.")
    return
end

ngx.say("dog: ", res)

local ok, err = red:set_keepalive(3600000, 5)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end

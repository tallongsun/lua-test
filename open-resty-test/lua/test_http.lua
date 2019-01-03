local http = require "resty.http"

local httpc = http.new()
httpc:set_timeout(500)
httpc:connect("127.0.0.1", 8088)

local res, err = httpc:request({
  path = "/?tenantId=1&path=/abc/xyz&method=post",
  method = "GET"
})
if not res then
  ngx.say("failed to request: ", err)
  return
end

local body, err = res:read_body()
if not body then
  ngx.say("failed to readBody: ",err)
  return
end
ngx.say(body)

local ok, err = httpc:set_keepalive()
if not ok then
  ngx.say("failed to set keepalive: ", err)
  return
end

local sock = ngx.socket.tcp()
local ok,err = sock:connect("www.baidu.com",80)
if not ok then
  ngx.say("failed to connect to baidu: ",err)
  return
end

local req_data = "GET / HTTP/1.1\r\nHost: www.baidu.com\r\n\r\n"
local bytes, err = sock:send(req_data)
if err then
    ngx.say("failed to send to baidu: ", err)
    return
end

local data, err, partial = sock:receive()
if err then
    ngx.say("failed to recieve to baidu: ", err)
    return
end

sock:close()
ngx.say("successfully talk to baidu! response first line: ", data)

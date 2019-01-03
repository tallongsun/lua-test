local resty_consul = require('resty.consul')
local consul = resty_consul:new({
        host = '127.0.0.1',
        port = 8500
    })
local managers, err = consul:get("/catalog/service/colosseum-api-manager")

for _,manager in ipairs(managers) do
  ngx.say(manager["Address"]..":"..manager["ServicePort"])
end

--[[
local ok, err = consul:put('/kv/foobar', 'My key value!')
if not ok then
    ngx.log(ngx.ERR, err)
end

local res, err = consul:get('/kv/foobar')
if not res then
    ngx.log(ngx.ERR, err)
end
ngx.say(res[1].Value)

local res, err = consul:get_decoded('/kv/foobar')
if not res then
    ngx.log(ngx.ERR, err)
end
ngx.say(res[1].Value)


local ok, err = consul:put('/kv/some_json', { msg = 'This will be json encoded'})
if not ok then
    ngx.log(ngx.ERR, err)
end

local res, err = consul:get_json_decoded('/kv/some_json')
if not res then
    ngx.log(ngx.ERR, err)
end

if type(res[1].Value) == 'table' then
    ngx.say(res[1].Value.msg) -- Prints "This will be json encoded"
else
    ngx.log(ngx.ERR, "Failed to decode value :(")
end
--]]

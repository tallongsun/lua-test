

--[[
local redis_cluster = require "resty.redis_cluster"

local conf = {
    name    = "testCluster",
    servers = {
        { "172.20.8.47", 7000 },
        { "172.20.8.47", 7001 },
        { "172.20.8.47", 7002 },
        { "172.20.8.47", 7003 },
        { "172.20.8.47", 7004 },
        { "172.20.8.47", 7005 },
    },
    password        = "",
    timeout         = 3000,
    idle_timeout    = 1000,
    pool_size       = 200,
}
local credis = redis_cluster:new(conf)
credis:set('a', 1)
local res,err = credis:get('a')
ngx.say(res)

--]]


-- gcc -dynamiclib -I/usr/local/include/luajit-2.1 -o redis_slot.so redis_slot.c
local config = {
    name = "testCluster",                   --rediscluster name
    serv_list = {                           --redis cluster node list(host and port),
      { ip="172.20.8.47", port=7000 },
      { ip="172.20.8.47", port=7001 },
      { ip="172.20.8.47", port=7002 },
      { ip="172.20.8.47", port=7003 },
      { ip="172.20.8.47", port=7004 },
      { ip="172.20.8.47", port=7005 },
    },
    keepalive_timeout = 60000,              --redis connection pool idle timeout
    keepalive_cons = 1000,                  --redis connection pool size
    connection_timout = 1000,               --timeout while connecting
    max_redirection = 5                     --maximum retry attempts for redirection
}
local redis_cluster = require "rediscluster"
local red_c = redis_cluster:new(config)

local v, err = red_c:get("a")
if err then
    ngx.log(ngx.ERR, "err: ", err)
else
    ngx.say(v)
end

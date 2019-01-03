--[[
local delay = 5
local handler
handler = function (premature)
  ngx.log(ngx.ERR,"timer trigger")
  if premature then
    return
  end
  local ok,err = ngx.timer.at(delay,handler)
  if not ok then
    ngx.log(ngx.ERR,"failed to create the timer: ",err)
    return
  end
end
if 0 == ngx.worker.id() then
  local ok,err = ngx.timer.at(delay,handler)
  if not ok then
    ngx.log(ngx.ERR,"failed to create the timer: ",err)
    return
  end
end
--]]

--[[
local ev = require "resty.worker.events"
local handler = function (data,event,source,pid)
  print("received event;source=",source,",event=",event,",data=",tostring(data),",from process ",pid)
end
ev.register(handler)

local ok, err = ev.configure {
    shm = "process_events", -- defined by "lua_shared_dict"
    timeout = 2,            -- life time of event data in shm
    interval = 1,           -- poll interval (seconds)

    wait_interval = 0.010,  -- wait before retry fetching event data
    wait_max = 0.5,         -- max wait time before discarding event
}
if not ok then
    ngx.log(ngx.ERR, "failed to start event system: ", err)
    return
end
--]]
local we = require "resty.worker.events"
local ok, err = we.configure{
    shm = "process_events",
    interval = 0.1,
}
if not ok then
    ngx.log(ngx.ERR, "failed to configure worker events: ", err)
    return
end
ngx.timer.at(0,function()
  local healthcheck = require("resty.healthcheck")
  local checker = healthcheck.new({
     name = "test_checker",
     shm_name = "healthchecks",
     checks = {
         active = {
             --http_request = "GET /status HTTP/1.0\r\nHost: example.com\r\n\r\n",
             healthy = {
                 interval = 5
             },
             unhealthy = {
                 interval = 5
             }
         }
     }
  })

  local handler = function(target, eventname, sourcename, pid)
     ngx.log(ngx.ERR,"Event from: ", sourcename)
     if eventname == checker.events.remove then
         -- a target was removed
         ngx.log(ngx.ERR,"Target removed: ",
             target.ip, ":", target.port, " ", target.hostname)
     elseif eventname == checker.events.healthy  then
         -- target changed state, or was added
         ngx.log(ngx.ERR,"Target switched to healthy: ",
             target.ip, ":", target.port, " ", target.hostname)
     elseif eventname ==  checker.events.unhealthy  then
         -- target changed state, or was added
         ngx.log(ngx.ERR,"Target switched to unhealthy: ",
             target.ip, ":", target.port, " ", target.hostname)
     else
         -- unknown event
     end
  end
  we.register(handler, checker.EVENT_SOURCE)

  local ok, err = checker:add_target("127.0.0.1", 8089)
  if not ok then
     ngx.log(ngx.ERR, err)
  end
end)

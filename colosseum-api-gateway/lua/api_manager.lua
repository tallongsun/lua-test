local resty_consul = require("resty.consul")
local config = require("config")
local ngx_re = require "ngx.re"

local cache = ngx.shared.api_manager_cache

local function watchApiManager(premature)
  if premature then
    return
  end
  local consul = resty_consul:new({
    host = config.get("consul_host"),
    port = config.get("consul_port")
  })

  local managers,err = consul:get("/catalog/service/colosseum-api-manager")
  if not managers then
    ngx.log(ngx.ERR, "get api managers failed: ",err)
  else
    for _,manager in ipairs(managers) do
      cache:set(manager["ServiceID"],manager["Address"]..":"..manager["ServicePort"])
    end
  end

  local index = "1"
  while true do
    --todo: long poll '/health/service/colosseum-api-manager?passing' is better?
    local res, info = consul:get("/health/state/critical",
      {wait = config.get("consul_watch_timeout"), index = index})
    if res then
      index = info[3]
      for _,manager in ipairs(res) do
        if manager["ServiceName"] == "colosseum-api-manager" then
          if not manager["Output"] or manager["Output"] == "" then
            ngx.log(ngx.INFO,"add api manager: "..manager["ServiceID"])
            local ary = ngx_re.split(manager["ServiceID"],":")
            cache:set(manager["ServiceID"],ary[2]..":"..ary[3])
          else
            ngx.log(ngx.INFO,"remove api manager: "..manager["ServiceID"])
            cache:delete(manager["ServiceID"])
          end
        end
      end
    else
      if info ~= "timeout" then
        ngx.log(ngx.INFO,"watch api managers failed: ",info)
        ngx.sleep(0.1)
      end
    end
  end

end

local function randomApiManager()
  local keys = cache:get_keys()
  local r = keys[math.random(#keys)]
  local ary = ngx_re.split(r,":")
  return ary[1],ary[2]
end

local _M = {
  watchApiManager = watchApiManager,
  randomApiManager = randomApiManager
}
return _M

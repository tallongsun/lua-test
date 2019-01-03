local http = require "resty.http"
local redis = require "resty.redis"
local json = require("cjson")
local config = require("config")

local cache = ngx.shared.api_mapping_cache

local function apiMapping()
  local apiPath = "/tenant/"..ngx.var.tenant_id.."/api?tenantId="..ngx.var.tenant_id.."&path=/"..ngx.var.api_path.."&method="..ngx.var.request_method.."&stage="..config.env

  local cacheKey = ngx.var.tenant_id ..":"..ngx.var.api_path..":"..ngx.var.request_method
  local body = cache:get(cacheKey)
  if body == nil then
    local httpc = http.new()
    httpc:set_timeout(config.get("api_manager_timeout"))
    if(config.get("use_consul")) then
      local apiManager = require("api_manager")
      httpc:connect(apiManager.randomApiManager())
    else
      httpc:connect(config.get("api_manager_host"), config.get("api_manager_port"))
    end

    local res, err = httpc:request({
      path = apiPath,
      method = "GET"
    })
    if not res then
      ngx.log(ngx.ERR,"failed to request: "..err)
      return ngx.exit(503)
    end
    if res.status ~= 200 then
      ngx.log(ngx.ERR,"failed to request: "..res.status)
      return ngx.exit(403)
    end

    body, err = res:read_body()
    if not body then
      ngx.log(ngx.ERR,"failed to readBody: "..err)
      return ngx.exit(403)
    end

    local ok, err = httpc:set_keepalive()
    if not ok then
      ngx.log(ngx.ERR,"failed to set keepalive: "..err)
      return ngx.exit(403)
    end

    cache:set(cacheKey,body,config.get("api_mapping_cache_timeout"))
  end

  ngx.log(ngx.INFO,apiPath)

  local ok,t = pcall(json.decode,body)
  if not ok then
    ngx.log(ngx.ERR,"failed to decode: "..body)
    return ngx.exit(403)
  end

  return t
end

local function authByToken()
  local token = ngx.req.get_headers()["token"]
  if token == nil then
    token = ngx.req.get_uri_args()["token"]
    if token == nil then
      ngx.log(ngx.ERR, "token is empty")
      ngx.exit(401)
    end
  end

  local red = redis:new()
  red:set_timeout(config.get("redis_timeout"))
  local ok, err = red:connect(config.get("redis_host"), config.get("redis_port"))
  if not ok then
      ngx.log(ngx.ERR, "failed to connect: "..err)
      return ngx.exit(503)
  end

  local count
  count,err = red:get_reused_times()
  if 0 == count then
    if config.get("redis_password") ~= "" then
      ok,err = red:auth(config.get("redis_password"))
      if not ok then
        ngx.log(ngx.ERR, "failed to auth: "..err)
        ngx.exit(503)
      end
    end
  elseif err then
    ngx.log(ngx.ERR, "failed to get reused times:"..err)
    ngx.exit(503)
  end

  local res, err = red:get("token:"..ngx.var.tenant_id)
  if not res then
    ngx.log(ngx.ERR, "failed to get token:"..err)
    ngx.exit(503)
  end

  local ok, err = red:set_keepalive(config.get("redis_idle_time"), config.get("redis_pool_size"))
  if not ok then
      ngx.log(ngx.ERR, "failed to set keepalive:"..err)
      ngx.exit(503)
  end

  if res ~= token then
    ngx.log(ngx.ERR, "token not found:")
    ngx.exit(401)
  end

end

local function authByCustomFunction(apiMapping)
  local token = ngx.req.get_headers()["token"]
  if token == nil then
    token = ngx.req.get_uri_args["token"]
    if token == nil then
      ngx.log(ngx.ERR, "token is empty")
      ngx.exit(401)
    end
  end

  local httpc = http.new()
  httpc:set_timeout(1000)
  httpc:connect(config.get("upstream_host"), config.get("upstream_port"))

  local res, err = httpc:request({
    path = "/"..apiMapping["TenantId"].."/"..apiMapping["AuthFunctionName"].."/"..apiMapping["AuthFunctionVersion"],
    method = "GET"
  })
  if not res then
    ngx.log(ngx.ERR,"failed to request: "..err)
    return ngx.exit(503)
  end
  if res.status ~= 200 then
    ngx.log(ngx.ERR,"failed to request: "..res.status)
    return ngx.exit(403)
  end

  local ok, err = httpc:set_keepalive()
  if not ok then
    ngx.log(ngx.ERR,"failed to set keepalive: "..err)
    return ngx.exit(403)
  end

end

local function authByCaas()
  local sign = ngx.req.get_headers()["x-rx-sign"]
  local app_key = config.get("caas_app_key")
  local timestamp = ngx.req.get_headers()["x-rx-timestamp"]
  local access_key = ngx.req.get_headers()["x-rx-accesskey"]
  if sign == nil or app_key == nil or timestamp == nil or access_key == nil then
    ngx.log(ngx.ERR, "authorization header is empty")
    ngx.exit(401)
  end

  ngx.log(ngx.INFO,"caas auth:"..sign..","..app_key..","..timestamp..","..access_key )

  local httpc = http.new()
  httpc:set_timeout(1000)
  httpc:connect(config.get("caas_host"), config.get("caas_port"))

  --local postData = "app_key="..app_key.."&timestamp="..timestamp.."&sign="..sign..
  --  "&access_key="..access_key.."&resource_code="..ngx.var.request_method.."/"..ngx.var.api_path.."&action=invoke"
  local postData = "app_key="..app_key.."&timestamp="..timestamp.."&sign="..sign..
    "&access_key="..access_key.."&resource_code=*&action=*"
  local res, err = httpc:request({
    path = "/api/v1/access/check",
    method = "POST",
    headers = {
      ["Content-Type"] = 'application/x-www-form-urlencoded'
    },
    body = postData
  })
  if not res then
    ngx.log(ngx.ERR,"failed to caas check: "..err)
    return ngx.exit(503)
  end
  if res.status ~= 200 then
    ngx.log(ngx.ERR,"failed to caas check: "..res.status)
    return ngx.exit(403)
  end
  local body,err = res:read_body()
  if not body then
    ngx.log(ngx.ERR,"failed to caas check: "..err)
    return ngx.exit(403)
  end

  local ok, err = httpc:set_keepalive()
  if not ok then
    ngx.log(ngx.ERR,"failed to set keepalive: "..err)
    return ngx.exit(403)
  end

  local ok,t = pcall(json.decode,body)
  if not ok then
    ngx.log(ngx.ERR,"failed to decode: "..body)
    return ngx.exit(403)
  end
  if not t.success then
    ngx.log(ngx.ERR,"failed to caas check: "..t.errorMessage)
    return ngx.exit(403)
  end
end

local apiMapping = apiMapping()

if apiMapping["AuthType"] == 1 then
  -- token
  authByToken()
elseif apiMapping["AuthType"] == 2 then
  -- custom
  authByCustomFunction(apiMapping)
elseif apiMapping["AuthType"] == 3 then
  -- caas
  authByCaas()
end
if ngx.var.request_method == "OPTIONS" then
  ngx.var.cors = apiMapping["EnableCors"]
else
  if apiMapping["BackendType"] == 0 then
    -- function
    ngx.var.target = "http://"..config.get("upstream_host")..":"..config.get("upstream_port").."/faas/"..apiMapping["TenantId"].."/"..apiMapping["FunctionName"].."/"..apiMapping["FunctionVersion"]
    if ngx.var.args then
      ngx.var.target = ngx.var.target.."?"..ngx.var.args
    end
    ngx.var.method = "POST"
  else
    -- http
    ngx.var.target = apiMapping["BackendUrl"]
  end
  ngx.log(ngx.INFO,"backend target:"..ngx.var.target )
end

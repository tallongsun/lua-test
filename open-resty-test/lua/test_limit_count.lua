local limit_count = require "resty.limit.count"

-- rate: 5000 requests per 3600s
local lim, err = limit_count.new("my_limit_count_store", 5000, 3600)
if not lim then
    ngx.log(ngx.ERR, "failed to instantiate a resty.limit.count object: ", err)
    return ngx.exit(500)
end

-- use the Authorization header as the limiting key
local key = ngx.req.get_headers()["Authorization"] or "public"
local delay, err = lim:incoming(key, true)

if not delay then
    if err == "rejected" then
        ngx.header["X-RateLimit-Limit"] = "5000"
        ngx.header["X-RateLimit-Remaining"] = 0
        return ngx.exit(503)
    end
    ngx.log(ngx.ERR, "failed to limit count: ", err)
    return ngx.exit(500)
end

-- the 2nd return value holds the current remaining number
-- of requests for the specified key.
local remaining = err

ngx.header["X-RateLimit-Limit"] = "5000"
ngx.header["X-RateLimit-Remaining"] = remaining

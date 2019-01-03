local param = require("comm.param")

local black_ips = {["127.0.0.1"]=true}
local ip = ngx.var.remote_addr
if true == black_ips[ip] then
  ngx.exit(ngx.HTTP_FORBIDDEN)
end

local args = ngx.req.get_uri_args()
if not args.a or not args.b or not param.is_number(args.a,args.b) then
  ngx.exit(ngx.HTTP_BAD_REQUEST)
  return
end

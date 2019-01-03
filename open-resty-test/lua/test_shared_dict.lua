require('mobdebug').start('localhost')

local my_cache = ngx.shared.my_cache

function get_from_cache(key)
  local my_cache = ngx.shared.my_cache
  local value = my_cache:get(key)
  return value
end

function set_to_cache(key,value,exptime)
  if not exptime then
    exptime = 0
  end
  local my_cache = ngx.shared.my_cache
  local succ,err,forcible = my_cache:set(key,value,exptime)
  return succ
end


ngx.shared.my_cache:lpush("foo1","1")
ngx.say(ngx.shared.my_cache:llen("foo1"))

set_to_cache("foo","bar")
ngx.say(get_from_cache("foo"))
for k,v in pairs(ngx.shared.my_cache:get_keys()) do
  ngx.say(k,v)
end
require('mobdebug').done()
local _M = {}

_M.count = 1

local function add()
  _M.count = _M.count + 1
end

local function sub()
  _M.count = _M.count - 1
end

function _M.calc()
  add()
  ngx.sleep(ngx.time()%0.003)
  sub()
  return _M.count
end

return _M

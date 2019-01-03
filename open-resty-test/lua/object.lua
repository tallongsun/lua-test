local _M = {}
local mt = {__index = _M}

function _M.new()
  local self = {}
  self.id = 1
  setmetatable(self,mt)
  return self
end

function _M:test()
  print(self.id)
end

return _M

local self = {}

self.balance = 0

local deposit = function(v)
  self.balance = self.balance+v
end

local withdraw = function(v)
  if self.balance > v then
    self.balance = self.balance - v
  else
    error("insufficient funds")
  end
end

local getBalance = function()
  return self.balance
end


return {
  deposit = deposit,
  withdraw = withdraw,
  getBalance = getBalance
}

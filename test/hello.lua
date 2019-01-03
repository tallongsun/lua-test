--[[
print("hello world")
local corp = {
  web = "www.google.com",
  [10] = "123456"
}
print(corp.web)
print(corp[10])

local days = {"M","T","W"}
local recvDays = {}
for i,v in ipairs(days) do
  recvDays[v] = i
end
for k,v in pairs(recvDays) do
  print("k:",k," v:",v)
end


local account = require("utils")
account.deposit(100)
print(account.getBalance())
account.withdraw(50)
print(account.getBalance())

function func1()
  return false,'error1'
end

function func2()
  return true,'error2'
end

local ok,err = func1()
print(ok,err)
if not ok then
  ok,err = func2()
  print(ok,err)
end
print(ok,err)
]]--

--[[
local keys = {
  [1] = "v1",
  [2] = "v2"
}
print(#keys)
for i=1,100 do
  local r = keys[math.random(#keys)]
  print(r)
end
--]]

local subtable = {
  subkey = "subvalue"
}

local t = {
  key = "value",
  subtable =subtable
}

print (t)
print (t.key,t.subtable,t.subtable.subkey)

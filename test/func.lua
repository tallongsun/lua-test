local function run(x,y)
  print('run',x,y)
end

local function attack(targetId)
  print('targetId',targetId)
end

local function stand()
  print('stand')
end

local function do_action(method,...)
  local args = {...} or {}
  method(unpack(args,1,table.maxn(args)))
end

do_action(run,1,2)
do_action(attack,1111)
do_action(stand)

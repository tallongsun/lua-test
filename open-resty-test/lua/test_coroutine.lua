co = coroutine.create(function (a)
  print("hi ",a)
  print(coroutine.yield(a+10))
  return "over"
end)

_,res = coroutine.resume(co,1)
print(res)

_,res = coroutine.resume(co,2)
print(res)

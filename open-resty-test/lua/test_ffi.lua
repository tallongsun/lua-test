--gcc -dynamiclib -o libmyffi.dylib  myffi.c
--libmyffi.dylib需要放在该项目根目录下，还没找到怎么从别的路径加载共享动态链接库的办法

local ffi = require "ffi"

local myffi = ffi.load("myffi")

ffi.cdef[[
typedef struct {int x,y;} point_t;
int add (int x,int y);
int printf(const char *fmt, ...);
]]

--local int_array_t = ffi.typeof("int[?]")
--local bucket_v = ffi.new(int_array_t, 10)


local p_ptr_type = ffi.typeof("point_t*")
local p_size = ffi.sizeof("point_t")
local p_cdata = ffi.new("point_t")

p_cdata.x = 1
p_cdata.y = 2

local str = ffi.string(p_cdata,p_size)
ngx.log(ngx.ERR, "dump:"..str)
local p = ffi.cast(p_ptr_type, str)
ngx.log(ngx.ERR, "x:"..p.x..",y:"..p.y)

local res = myffi.add(p_cdata.x ,p_cdata.y)
ngx.say(res)


ffi.C.printf("Hello %s!", "world")

--json = require 'C:/SWProjects/KebnoaLogger/lua_scripts/dkjson_kebnoa.lua'
--include("dkjson_kebnoa.lua")
local json = loadfile('C:/SWProjects/KebnoaLogger/lua_scripts/dkjson_kebnoa.lua')()


local onEven = { {x =  0, y =  0, r = 0}, {x =  0, y =  1, r = 1}, {x =  1, y =  0, r = 1}, {x =  0, y = -1, r = 1}, {x = -1, y = -1, r = 1},
                 {x = -1, y =  0, r = 1}, {x = -1, y =  1, r = 1}, {x =  1, y =  2, r = 2}, {x =  1, y =  1, r = 2}, {x =  2, y =  0, r = 2},
                 {x =  1, y = -1, r = 2}, {x =  1, y = -2, r = 2}, {x =  0, y = -2, r = 2}, {x = -1, y = -2, r = 2}, {x = -2, y = -1, r = 2},
                 {x = -2, y =  0, r = 2}, {x = -2, y =  1, r = 2}, {x = -1, y =  2, r = 2}, {x =  0, y =  2, r = 2}, {x =  1, y =  3, r = 3},
                 {x =  2, y =  2, r = 3}, {x =  2, y =  1, r = 3}, {x =  3, y =  0, r = 3}, {x =  2, y = -1, r = 3}, {x =  2, y = -2, r = 3},
                 {x =  1, y = -3, r = 3}, {x =  0, y = -3, r = 3}, {x = -1, y = -3, r = 3}, {x = -2, y = -3, r = 3}, {x = -2, y = -2, r = 3},
                 {x = -3, y = -1, r = 3}, {x = -3, y =  0, r = 3}, {x = -3, y =  1, r = 3}, {x = -2, y =  2, r = 3}, {x = -2, y =  3, r = 3},
                 {x = -1, y =  3, r = 3}, {x =  0, y =  3, r = 3}, }

local onOdd = { {x =  0, y =  0, r = 0}, {x =  1, y =  1, r = 1}, {x =  1, y =  0, r = 1}, {x =  1, y = -1, r = 1}, {x =  0, y = -1, r = 1},
                {x = -1, y =  0, r = 1}, {x =  0, y =  1, r = 1}, {x =  1, y =  2, r = 2}, {x =  2, y =  1, r = 2}, {x =  2, y =  0, r = 2},
                {x =  2, y = -1, r = 2}, {x =  1, y = -2, r = 2}, {x =  0, y = -2, r = 2}, {x = -1, y = -2, r = 2}, {x = -1, y = -1, r = 2},
                {x = -2, y =  0, r = 2}, {x = -1, y =  1, r = 2}, {x = -1, y =  2, r = 2}, {x =  0, y =  2, r = 2}, {x =  2, y =  3, r = 3},
                {x =  2, y =  2, r = 3}, {x =  3, y =  1, r = 3}, {x =  3, y =  0, r = 3}, {x =  3, y = -1, r = 3}, {x =  2, y = -2, r = 3},
                {x =  2, y = -3, r = 3}, {x =  1, y = -3, r = 3}, {x =  0, y = -3, r = 3}, {x = -1, y = -3, r = 3}, {x = -2, y = -2, r = 3},
                {x = -2, y = -1, r = 3}, {x = -3, y =  0, r = 3}, {x = -2, y =  1, r = 3}, {x = -2, y =  2, r = 3}, {x = -1, y =  3, r = 3},
                {x =  0, y =  3, r = 3}, {x =  1, y =  3, r = 3}, }

--x = 55
--y = 29
x = 52
y = 24

if x % 2 == 0 then deltas = onEven else calc = onOdd end

for i, d in ipairs(deltas) do
  print(i, ": ", x + d.x, y + d.y, d.r)
end

local str = json.encode(onOdd, { indent = false }) --, buffer = buf 
print(str)
local deltasOnEvenY = {
  {x =  0, y =  1, r = 1}, {x =  1, y =  0, r = 1}, {x =  0, y = -1, r = 1}, {x = -1, y = -1, r = 1},
  {x = -1, y =  0, r = 1}, {x = -1, y =  1, r = 1}, {x =  1, y =  2, r = 2}, {x =  1, y =  1, r = 2}, {x =  2, y =  0, r = 2},
  {x =  1, y = -1, r = 2}, {x =  1, y = -2, r = 2}, {x =  0, y = -2, r = 2}, {x = -1, y = -2, r = 2}, {x = -2, y = -1, r = 2},
  {x = -2, y =  0, r = 2}, {x = -2, y =  1, r = 2}, {x = -1, y =  2, r = 2}, {x =  0, y =  2, r = 2}, {x =  1, y =  3, r = 3},
  {x =  2, y =  2, r = 3}, {x =  2, y =  1, r = 3}, {x =  3, y =  0, r = 3}, {x =  2, y = -1, r = 3}, {x =  2, y = -2, r = 3},
  {x =  1, y = -3, r = 3}, {x =  0, y = -3, r = 3}, {x = -1, y = -3, r = 3}, {x = -2, y = -3, r = 3}, {x = -2, y = -2, r = 3},
  {x = -3, y = -1, r = 3}, {x = -3, y =  0, r = 3}, {x = -3, y =  1, r = 3}, {x = -2, y =  2, r = 3}, {x = -2, y =  3, r = 3},
  {x = -1, y =  3, r = 3}, {x =  0, y =  3, r = 3}, }
local deltasOnOddY = {
  {x =  1, y =  1, r = 1}, {x =  1, y =  0, r = 1}, {x =  1, y = -1, r = 1}, {x =  0, y = -1, r = 1},
  {x = -1, y =  0, r = 1}, {x =  0, y =  1, r = 1}, {x =  1, y =  2, r = 2}, {x =  2, y =  1, r = 2}, {x =  2, y =  0, r = 2},
  {x =  2, y = -1, r = 2}, {x =  1, y = -2, r = 2}, {x =  0, y = -2, r = 2}, {x = -1, y = -2, r = 2}, {x = -1, y = -1, r = 2},
  {x = -2, y =  0, r = 2}, {x = -1, y =  1, r = 2}, {x = -1, y =  2, r = 2}, {x =  0, y =  2, r = 2}, {x =  2, y =  3, r = 3},
  {x =  2, y =  2, r = 3}, {x =  3, y =  1, r = 3}, {x =  3, y =  0, r = 3}, {x =  3, y = -1, r = 3}, {x =  2, y = -2, r = 3},
  {x =  2, y = -3, r = 3}, {x =  1, y = -3, r = 3}, {x =  0, y = -3, r = 3}, {x = -1, y = -3, r = 3}, {x = -2, y = -2, r = 3},
  {x = -2, y = -1, r = 3}, {x = -3, y =  0, r = 3}, {x = -2, y =  1, r = 3}, {x = -2, y =  2, r = 3}, {x = -1, y =  3, r = 3},
  {x =  0, y =  3, r = 3}, {x =  1, y =  3, r = 3}, }
 
 -- for dual map that I am testing on
local xWrapsAt = 44
local yMin = 0
local yMax = 26
      
x = 7 --32 --43
y = 5 --6 --14
        
if y % 2 == 0 then deltas = deltasOnEvenY else deltas = deltasOnOddY end
  
for i, d in ipairs(deltas) do
  newX = (x + d.x) % xWrapsAt
  newY =  y + d.y
  print(string.format("x: %d, y: %d, r: %d", newX, newY, d.r))
end
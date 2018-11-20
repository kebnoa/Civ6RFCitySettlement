local Civ6xy = {}

function Civ6xy:new(x, y, maxX, maxY)
   if x == nil or y == nil then return nil end
   if maxX == nil then maxX = 73 end
   if maxY == nil then maxY = 45 end
   xy = {x = x, y = y, maxX = maxX, maxY = maxY}
   setmetatable(xy, self)
   self.__index = self
   return xy
end

function Civ6xy:NE()
    if self.x % 2 ~= 0 then x = self.x + 1 else x = self.x end
    return self:new(x, self.y + 1)
end

function Civ6xy:E()
    return self:new(self.x + 1, self.y)
end

function Civ6xy:SE()
    if self.x % 2 ~= 0 then x = self.x + 1 else x = self.x end
    return self:new(x, self.y - 1)
end

function Civ6xy:SW()
    if self.x % 2 == 0 then x = self.x - 1 else x = self.x end
    return self:new(x, self.y - 1)
end

function Civ6xy:W()
    return self:new(self.x - 1, self.y)
end

function Civ6xy:NW()
    if self.x % 2 == 0 then x = self.x - 1 else x = self.x end
    return self:new(x, self.y + 1)
end

x = 52
y = 24
city_xy = Civ6xy:new(x, y)
city_xy_ne = city_xy:NE()
city_xy_e = city_xy:E()
city_xy_se = city_xy:SE()
city_xy_sw = city_xy:SW()
city_xy_w = city_xy:W()
city_xy_nw = city_xy:NW()
print("city: ", city_xy.x, city_xy.y)
print("Ring 1:")
print("  ne: ", city_xy_ne.x, city_xy_ne.y)
print("   e: ", city_xy_e.x, city_xy_e.y)
print("  se: ", city_xy_se.x, city_xy_se.y)
print("  sw: ", city_xy_sw.x, city_xy_sw.y)
print("   w: ", city_xy_w.x, city_xy_w.y)
print("  nw: ", city_xy_nw.x, city_xy_nw.y)
--2nd ring
print("Ring 2")
city_xy_ne_nw = city_xy_ne:NW()
print("ne_nw: ", city_xy_ne_nw.x, city_xy_ne_nw.y)

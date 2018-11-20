Timer = {};
Timer.__index = Timer;

function Timer:new()
  local timer = {}
  setmetatable(timer, Timer)
  timer.startAt = nil
  return timer
end

function Timer:start()
  self.startAt = os.time()  
end

function Timer:split()
  local split = os.difftime(os.time() - self.startAt)
  return split
end

function Timer:stop()
  local split = os.difftime(os.time() - self.startAt)
  self.startAt = nil
  return split
end

t = Timer:new()
t:start()
for i = 0, 3000000000 do
  i = (i + 1)^0.5
end
print(t:split())
for i = 0, 3000000000 do
  i = (i + 1)^0.5
end
print(t:stop())

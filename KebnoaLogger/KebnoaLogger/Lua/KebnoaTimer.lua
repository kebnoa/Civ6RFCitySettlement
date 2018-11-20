-- KebnoaTimer
-- Author: kebnoa
-- DateCreated: 11/20/2018 4:16:23 PM
-- A lua time class.
--------------------------------------------------------------

log:Trace("Kebnoa's timer code load started")

-- Create and start the timer, split() and stop() return elapsed times from this function.
Timer = {}
Timer.__index = Timer;
function Timer:new()
  local timer = {}
  setmetatable(timer, Timer)
  timer.startAt = Automation.GetTime()
  return timer
end

-- starts the timer, split() and stop() return elapsed times from this function.
function Timer:start()
  self.startAt = Automation.GetTime()
end

-- returns a string representing the elapsed time since timer created (new()) or start() called.
-- doesn't reset the start time.
function Timer:split()
  local split = string.format("%5.3f", Automation.GetTime() - self.startAt)
  return split
end

-- returns a string representing the elapsed time since timer created (new()) or start() called.
-- resets the start time to 0.0
function Timer:stop()
  local split = string.format("%5.3f", Automation.GetTime() - self.startAt)
  self.startAt = 0.0
  return split
end
-- LuaLogger
-- Author: Thalassicus
-- DateCreated: 03/05/2016 20:49:53
-- Modified by kebnoa on 11/11/2018:
--   changed Game.GetGameTurn() to Game.GetCurrentGameTurn()
--------------------------------------------------------------

--[[ LuaLogger usage example:
include("ModTools")
local log = Events.LuaLogger:New()
log:SetLevel("WARN")
log:Info("Loading ModTools")
]]

LOG_TRACE	= "TRACE"
LOG_DEBUG	= "DEBUG"
LOG_INFO	= "INFO"
LOG_WARN	= "WARN"
LOG_ERROR	= "ERROR"
LOG_FATAL	= "FATAL"

--[[Trace - Only when "tracing" the code and trying to find one part of a function specifically
Debug - Information that is diagnostically helpful to people more than just developers (IT, sysadmins, etc)
Info - Generally useful information to log (service start/stop, configuration assumptions, etc). Info always have available but usually dont care about under normal circumstances.
Warn - Anything that can potentially cause application oddities, but for which automatically recovery is done (such as switching from a primary to backup server, retrying an operation, missing secondary data, etc)
Error - Any error which is fatal to the operation but not the service or application (cant open a required file, missing data, etc). These errors will force user (administrator, or direct user) intervention. These are usually reserved for incorrect connection strings, missing services, etc. 
Fatal - Any error that is forcing a shutdown of the service or application to prevent data loss (or further data loss). Reserve these only for the most heinous errors and situations where there is guaranteed to have been data corruption or loss.]]


local LEVEL = {
	[LOG_TRACE] = 1,
	[LOG_DEBUG] = 2,
	[LOG_INFO]  = 3,
	[LOG_WARN]  = 4,
	[LOG_ERROR] = 5,
	[LOG_FATAL] = 6,
}

Events.LuaLogger = Events.LuaLogger or {}
Events.LuaLogger.New = Events.LuaLogger.New or function(self)
	local logger = {}
	setmetatable(logger, self)
	self.__index = self

	logger.level = LEVEL.INFO

	logger.SetLevel = function (self, level)
		self.level = level
	end

	logger.Message = function (self, level, ...)
		local arg = {...}
		if LEVEL[level] < LEVEL[self.level] then
			return false
		end
		if type(arg[1]) == "string" then
			local _, numCommands = string.gsub(arg[1], "[%%]", "")
			for i = 2, numCommands+1 do
				if type(arg[i]) ~= "number" and type(arg[i]) ~= "string" then
					arg[i] = tostring(arg[i])
				end
			end
		else
			arg[1] = tostring(arg[1])
		end
		local message = string.format(...)
		if level == LOG_FATAL then
			message = string.format("Turn %-3s %s", Game.GetCurrentGameTurn(), message)
			print(level .. string.rep(" ", 7-level:len()) .. message)
			if debug then print(debug.traceback()) end
		else
			if level >= LOG_INFO then
				message = string.format("Turn %-3s %s", Game.GetCurrentGameTurn(), message)
			end
			print(level .. string.rep(" ", 7-level:len()) .. message)
		end
		return true
	end

	logger.Trace = function (logger, ...) return logger:Message(LOG_TRACE, ...) end
	logger.Debug = function (logger, ...) return logger:Message(LOG_DEBUG, ...) end
	logger.Info  = function (logger, ...) return logger:Message(LOG_INFO,  ...) end
	logger.Warn  = function (logger, ...) return logger:Message(LOG_WARN,  ...) end
	logger.Error = function (logger, ...) return logger:Message(LOG_ERROR, ...) end
	logger.Fatal = function (logger, ...) return logger:Message(LOG_FATAL, ...) end
	return logger
end
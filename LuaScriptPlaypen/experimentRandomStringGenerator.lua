function GetKebnoaLoggerSaveFilename()
  math.randomseed(os.rawclock()); math.random(); math.random(); math.random();

  local lookup = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                   'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
                   'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
                   'U', 'V', 'W', 'X', 'Y', 'Z' }

  local str = lookup[math.random(1, 36)] .. lookup[math.random(1, 36)] .. lookup[math.random(1, 36)] ..
              lookup[math.random(1, 36)] .. lookup[math.random(1, 36)] .. lookup[math.random(1, 36)]

  return "KebnoaLogger_01_" .. os.date("%Y%m%d_") .. str
end

print(GetKebnoaLoggerSaveFilename())

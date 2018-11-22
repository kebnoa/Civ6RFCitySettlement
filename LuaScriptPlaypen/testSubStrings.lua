--str = json.encode(gKebnoaLoggerTable)
--maxLen = string.len(str)
maxLen = 4081
--print("maxLen: " .. maxLen)
windowSize = 2040
iterations = math.ceil(maxLen / windowSize) - 1
--print("iterations: " .. iterations)
for i = 0, iterations, 1
do
    startAt = (i * windowSize ) + 1
    endAt   = (i * windowSize ) + windowSize
    if endAt > maxLen then endAt = maxLen end
    print(string.format("print(string.sub(str, %d, %d))", startAt, endAt))
end

--str = "Hello"
--print(string.sub(str, 5, 6))
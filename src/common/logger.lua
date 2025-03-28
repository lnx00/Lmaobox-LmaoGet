---@class logger
local logger = {
    SEVERITY = 1
}

function logger.debug(message)
    if logger.SEVERITY <= 0 then
        printc(255, 255, 255, 80, string.format("[DEBUG] %s", message))
    end
end

function logger.info(message)
    if logger.SEVERITY <= 1 then
        printc(255, 255, 255, 255, string.format("[INFO] %s", message))
    end
end

function logger.warn(message)
    if logger.SEVERITY <= 2 then
        printc(255, 255, 0, 150, string.format("[WARN] %s", message))
    end
end

function logger.error(message)
    if logger.SEVERITY <= 3 then
        printc(255, 0, 0, 150, string.format("[ERROR] %s", message))
    end
end

return logger
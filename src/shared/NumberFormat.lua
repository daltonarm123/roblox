local NumberFormat = {}

local suffixes = {
    { 1e12, "T" },
    { 1e9, "B" },
    { 1e6, "M" },
    { 1e3, "K" },
}

function NumberFormat.Compact(value)
    value = tonumber(value) or 0

    for _, item in ipairs(suffixes) do
        local threshold = item[1]
        local suffix = item[2]
        if math.abs(value) >= threshold then
            local scaled = value / threshold
            if math.abs(scaled) >= 100 then
                return string.format("%.0f%s", scaled, suffix)
            elseif math.abs(scaled) >= 10 then
                return string.format("%.1f%s", scaled, suffix)
            else
                return string.format("%.2f%s", scaled, suffix)
            end
        end
    end

    return tostring(math.floor(value + 0.5))
end

return NumberFormat

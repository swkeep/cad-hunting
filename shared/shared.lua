local alias_table = {}

-- https://gist.github.com/RyanPattison/7dd900f4042e8a6f9f23

function alias_table:new(weights)
    local total = 0
    for _, v in ipairs(weights) do
        assert(v >= 0, "all weights must be non-negative")
        total = total + v
    end

    assert(total > 0, "total weight must be positive")
    local normalize = #weights / total
    local norm = {}
    local small_stack = {}
    local big_stack = {}
    for i, w in ipairs(weights) do
        norm[i] = w * normalize
        if norm[i] < 1 then
            table.insert(small_stack, i)
        else
            table.insert(big_stack, i)
        end
    end

    local prob = {}
    local alias = {}
    while small_stack[1] and big_stack[1] do -- both non-empty
        small = table.remove(small_stack)
        large = table.remove(big_stack)
        prob[small] = norm[small]
        alias[small] = large
        norm[large] = norm[large] + norm[small] - 1
        if norm[large] < 1 then
            table.insert(small_stack, large)
        else
            table.insert(big_stack, large)
        end
    end

    for _, v in ipairs(big_stack) do
        prob[v] = 1
    end
    for _, v in ipairs(small_stack) do
        prob[v] = 1
    end

    self.__index = self
    return setmetatable({
        alias = alias,
        prob = prob,
        n = #weights
    }, self)
end

function alias_table:__call()
    local index = math.random(self.n)
    return math.random() < self.prob[index] and index or self.alias[index]
end

function Alias_table_wrapper(table)
    local sample = alias_table:new(table)
    return sample()
end

---print tables : debug
---@param node table
function print_table(node)
    local cache, stack, output = {}, {}, {}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k, v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k, v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str, "}", output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str, "\n", output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output, output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "[" .. tostring(k) .. "]"
                else
                    key = "['" .. tostring(k) .. "']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t', depth) .. key .. " = " .. tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t', depth) .. key .. " = {\n"
                    table.insert(stack, node)
                    table.insert(stack, v)
                    cache[node] = cur_index + 1
                    break
                else
                    output_str = output_str .. string.rep('\t', depth) .. key .. " = '" .. tostring(v) .. "'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t', depth - 1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output, output_str)
    output_str = table.concat(output)

    print(output_str)
end

local fileName = "hello-world.bf"

-- brainfuck interpreter created by Cyclically#9215
local file, ptr, savedPtrs, ptrCount, index, cells = io.open(fileName, "r"), 1, {}, 0, 1, setmetatable({}, {
	__index = function()
		return 0
	end
})
if not file then error("File "..fileName.." not found.",0) end
local code, codeInstructions = file:read("*a"):gsub("[^][<>+--,.]",""), {} -- strips all characters that aren't instructions

-- compresses brainfuck code with run-length encoding; this prevents iterating through the same instruction as the interpreter runs brainfuck code that's been compressed with RLE to run much more efficiently
for char in code:gmatch(".") do 
    if char:match("[^][]") then
        code = code:gsub(char:gsub("[%.%+%-]","%%%0"):rep(2).."+",function(match)
            return #match..char
        end)
        -- saves each compressed instruction in a table
        if code:find("%p") then
            if #code:sub(1, code:find("%p")) <= 1 then
                table.insert(codeInstructions, 1 .. code:sub(1, code:find("%p")))
            else
                table.insert(codeInstructions, code:sub(1, code:find("%p")))
            end
            code = code:sub(code:find("%p")+1)
        end
    end
end

-- main interpreter code
while ptr < #codeInstructions do
	if codeInstructions[ptr]:sub(#codeInstructions[ptr]) == "[" then
		if cells[index] == 0 then
            ptrCount = ptrCount + 1
        else
            table.insert(savedPtrs, ptr)
		end
    elseif codeInstructions[ptr]:sub(#codeInstructions[ptr]) == "]" then
		if cells[index] == 0 then
            if ptrCount <= 0 then
                table.remove(savedPtrs)
            else
                ptrCount = ptrCount - 1
            end
        else
			ptr = savedPtrs[#savedPtrs]
		end
    elseif ptrCount <= 0 then
        if codeInstructions[ptr]:sub(#codeInstructions[ptr]) == "+" then
            for i = 1, codeInstructions[ptr]:sub(1, #codeInstructions[ptr]-1) do
                if cells[index] >= 255 then
                    cells[index] = 0
                else
                    cells[index] = cells[index] + 1
                end
            end
        elseif codeInstructions[ptr]:sub(#codeInstructions[ptr]) == "-" then
            for i = 1, codeInstructions[ptr]:sub(1, #codeInstructions[ptr]-1) do
                if cells[index] > 0 then
                    cells[index] = cells[index] - 1
                else
                    cells[index] = 255
                end
            end
            elseif codeInstructions[ptr]:sub(#codeInstructions[ptr]) == ">" then
                index = index + codeInstructions[ptr]:sub(1, #codeInstructions[ptr]-1)
        elseif codeInstructions[ptr]:sub(#codeInstructions[ptr]) == "<" then
            for i = 1, codeInstructions[ptr]:sub(1, #codeInstructions[ptr]-1) do
                index = index - 1
            end
        elseif codeInstructions[ptr]:sub(#codeInstructions[ptr]) == "." then
            for i = 1, codeInstructions[ptr]:sub(1, #codeInstructions[ptr]-1) do
                io.write(string.char(cells[index]))
            end
        elseif codeInstructions[ptr]:sub(#codeInstructions[ptr]) == "," then
            for i = 1, codeInstructions[ptr]:sub(1, #codeInstructions[ptr]-1) do
               cells[index] = tonumber(string.byte(io.read()))
            end
        end
    end
    ptr = ptr + 1
end

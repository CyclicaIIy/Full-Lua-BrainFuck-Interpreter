-- A fast, and optimized brainfuck interpreter written in Lua
-- by Cyclically: 2/21/2021

return function(code)
	local ptr, savedPtrs, ptrCount, index, cells = 1, {}, 0, 1, setmetatable({}, {
		__index = function()
			return 0
		end
	})
	local code, codeInstructions = string.gsub(code, "[^][<>+--,.]",""), {} -- strips all characters that aren't instructions

	-- compresses brainfuck code with run-length encoding; this optimizes iteration through the same instruction
	for char in string.gmatch(code, ".") do 
		if string.match(char, "[^][]") then
			code = string.gsub(code, string.rep(string.gsub(char, "[%.%+%-]","%%%0"), 2).."+", function(match)
				return #match..char
			end)
			-- saves each compressed instruction in a table
			if string.find(code, "%p") then
				if #string.sub(code, 1, string.find(code, "%p")) <= 1 then
					table.insert(codeInstructions, 1 .. string.sub(code, 1, string.find(code, "%p")))
				else
					table.insert(codeInstructions, string.sub(code, 1, string.find(code, "%p")))
				end
				code = string.sub(code, string.find(code, "%p")+1)
			end
		end
	end

	-- the interpreter runs brainfuck code that's been compressed with RLE to increase efficiency
	while ptr < #codeInstructions do
		local currentInstruction = string.sub(codeInstructions[ptr], #codeInstructions[ptr])
		if currentInstruction == "[" then
			if cells[index] == 0 then
				ptrCount = ptrCount + 1
			else
				table.insert(savedPtrs, ptr)
			end
		elseif currentInstruction == "]" then
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
			if currentInstruction == "+" then
				cells[index] = cells[index] + string.sub(codeInstructions[ptr], 1, #codeInstructions[ptr]-1)
				if cells[index] > 255 then
					cells[index] = 0
				end
			elseif currentInstruction == "-" then
				cells[index] = cells[index] - string.sub(codeInstructions[ptr], 1, #codeInstructions[ptr]-1)
				if cells[index] < 0 then
					cells[index] = 255
				end
			elseif currentInstruction == ">" then
				index = index + string.sub(codeInstructions[ptr], 1, #codeInstructions[ptr]-1)
			elseif currentInstruction == "<" then
				index = index - string.sub(codeInstructions[ptr], 1, #codeInstructions[ptr]-1)
			elseif currentInstruction == "." then
				io.write(string.rep(string.char(cells[index]), string.sub(codeInstructions[ptr], 1, #codeInstructions[ptr]-1)))
			elseif currentInstruction == "," then
				for i = 1, string.sub(codeInstructions[ptr], 1, #codeInstructions[ptr]-1) do
					cells[index] = string.byte(io.read())
				end
			end
		end
		ptr = ptr + 1
	end
end

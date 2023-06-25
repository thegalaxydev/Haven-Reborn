local BigNumber = {}
local strict = true

type BigNumber = {
	Sign: string,
	Digits: {number}
} & typeof(BigNumber)

local Suffixes = {
	"k", "M", "B", "T", "qd", "Qn", "sx", "Sp", "O", "N",
	"de", "Ud", "DD", "tdD", "qdD", "QnD", "sxD", "SpD", "OcD", "NvD",
	"Vgn", "UVg", "DVg", "TVg", "qtV", "QnV", "SeV", "SPG", "OVG", "NVG",
	"TGN", "UTG", "DTG", "tsTG", "qtTG", "QnTG", "ssTG", "SpTG", "OcTG", "NoTG",
	"QdDR", "uQDR", "dQDR", "tQDR", "qdQDR", "QnQDR", "sxQDR", "SpQDR", "OQDDr", "NQDDr",
	"qQGNT", "uQGNT", "dQGNT", "tQGNT", "qdQGNT", "QnQGNT", "sxQGNT", "SpQGNT", "OQQGNT", "NQQGNT",
	"SXGNTL", "USXGNTL", "DSXGNTL", "TSXGNTL", "qTSXGNTL", "QnSXGNTL", "ssSXGNTL", "SpSXGNTL", "OSXGNTL", "NVSXGNTL",
	"SPGYL", "USPGYL", "DSPGYL", "TSPGYL", "qTSPGYL", "QnSPGYL", "ssSPGYL", "SpSPGYL", "OSPGYL", "NVSPGYL",
	"OTGNTL", "UOTGNTL", "DOTGNTL", "TOTGNTL", "qTOTGNTL", "QnOTGNTL", "ssOTGNTL", "SpOTGNTL", "OOTGNTL", "NVOTGNTL",
	"NONGNTL", "UNONGNTL", "DNONGNTL", "TNONGNTL", "qTNONGNTL", "QnNONGNTL", "ssNONGNTL", "SpNONGNTL", "OTNONGNTL", "NONONGNTL",
	"CENT", "UNCENT", "DECENT", "UNDECENT", "VIGINT", "UNVIGINT", "TRIGINT", "UNTRIGINT", "QUADRAGINT", "UNQUADRAGINT",
} 

function BigNumber.new(num: string? | number?)
	local self = {}
	
	self.Sign = "+"
	self.Digits = {}

	if (num) then
        local num_string = tostring(num)
        for digit in string.gmatch(num_string, "[0-9]") do
            table.insert(self.Digits, tonumber(digit))
        end
        if string.sub(num_string, 1, 1) == "-" then
            self.Sign = "-"
        end
    end

	setmetatable(self, {
		__index = BigNumber,

		__add = function(lhs: BigNumber, rhs: BigNumber)
			BigNumber.Check(lhs)
			BigNumber.Check(rhs)
		
			local result: BigNumber = BigNumber.new()
			local maxDigits = 0
			local carry = 0
		
			if (#lhs.Digits >= #rhs.Digits) then
				maxDigits = #lhs.Digits
			else
				maxDigits = #rhs.Digits
			end
		
			for digit = 0, maxDigits - 1 do
				local sum = (lhs.Digits[#lhs.Digits - digit] or 0)
						  + (rhs.Digits[#rhs.Digits - digit] or 0)
						  + carry
		
				if (sum >= 10) then
					carry = 1
					sum = sum - 10
				else
					carry = 0
				end
		
				result.Digits[maxDigits - digit] = sum
			end
		
			if (carry == 1) then
				table.insert(result.Digits, 1, 1)
			end
		
			return result		
		end,
	
		__lt = function(lhs: BigNumber, rhs: BigNumber)
			BigNumber.Check(lhs)
			BigNumber.Check(rhs)
		
			local greater = false
			local equal = false
	
			if (lhs.Sign == "-") and (rhs.Sign == "+") then
				greater = false
			elseif (#lhs.Digits > #rhs.Digits) or ((lhs.Sign == "+") and (rhs.Sign == "-")) then
				greater = true
			elseif (#lhs.Digits == #rhs.Digits) then
				for digit = 1, #lhs.Digits do
					if (lhs.Digits[digit] > rhs.Digits[digit]) then
						greater = true
						break
					elseif (rhs.Digits[digit] > lhs.Digits[digit]) then
						break
					elseif (digit == #lhs.Digits) and (lhs.Digits[digit] == rhs.Digits[digit]) then
						equal = true
					end
				end
			end
	
			if (not equal) and (lhs.Sign == "-") and (rhs.Sign == "-") then
				greater = not greater
			end
	
			return not greater and not equal
		end,
	
		__le = function(lhs: BigNumber, rhs: BigNumber)
			BigNumber.Check(lhs)
			BigNumber.Check(rhs)
		
			local greater = false
			local equal = false
	
			if (lhs.Sign == "-") and (rhs.Sign == "+") then
				greater = false
			elseif (#lhs.Digits > #rhs.Digits) or ((lhs.Sign == "+") and (rhs.Sign == "-")) then
				greater = true
			elseif (#lhs.Digits == #rhs.Digits) then
				for digit = 1, #lhs.Digits do
					if (lhs.Digits[digit] > rhs.Digits[digit]) then
						greater = true
						break
					elseif (rhs.Digits[digit] > lhs.Digits[digit]) then
						break
					elseif (digit == #lhs.Digits) and (lhs.Digits[digit] == rhs.Digits[digit]) then
						equal = true
					end
				end
			end
	
			if (not equal) and (lhs.Sign == "-") and (rhs.Sign == "-") then
				greater = not greater
			end
	
			return not greater
		end,
	
		__eq = function(lhs: BigNumber, rhs: BigNumber)
			BigNumber.Check(lhs)
			BigNumber.Check(rhs)
		
			local equal = false
	
			if (#lhs.Digits == #rhs.Digits) then
				for digit = 1, #lhs.Digits do
					if (lhs.Digits[digit] ~= rhs.Digits[digit]) then
						break
					elseif (digit == #lhs.Digits) and (lhs.Digits[digit] == rhs.Digits[digit]) then
						equal = true
					end
				end
			end
	
			return equal
		end,
	
		__sub = function(lhs: BigNumber, rhs: BigNumber)
			BigNumber.Check(lhs)
			BigNumber.Check(rhs)
		
			local result: BigNumber = BigNumber.new()
			local maxDigits = 0
			local carry = 0
		
			if (#lhs.Digits >= #rhs.Digits) then
				maxDigits = #lhs.Digits
			else
				maxDigits = #rhs.Digits
			end
		
			for digit = 0, maxDigits - 1 do
				local diff = (lhs.Digits[#lhs.Digits - digit] or 0)
						  - (rhs.Digits[#rhs.Digits - digit] or 0)
						  - carry
		
				if (diff < 0) then
					carry = 1
					diff = diff + 10
				else
					carry = 0
				end
		
				result.Digits[maxDigits - digit] = diff
			end
		
			if (carry == 1) then
				table.insert(result.Digits, 1, 1)
			end
		
			return result
		end,
	
		__mul = function(lhs: BigNumber, rhs: BigNumber)
			local result = BigNumber.new(0)
			local larger, smaller 
		
			if (BigNumber.Unserialize(lhs) == 0) or (BigNumber.Unserialize(rhs) == 0) then
				return result
			end
		
			if (#lhs.Digits >= #rhs.Digits) then
				larger = lhs
				smaller = rhs
			else
				larger = rhs
				smaller = lhs
			end
		
			for digit = 0, #smaller.Digits - 1 do
				local this_digit_product = BigNumber.MultiplySingle(larger, BigNumber.new(smaller.Digits[#smaller.Digits - digit]))
		
				if (digit > 0) then
					for placeholder = 1, digit do
						table.insert(this_digit_product.Digits, 0)
					end
				end
		
				result += this_digit_product
			end
		
			if (larger.Sign == smaller.Sign) then
				result.Sign = "+"
			else
				result.Sign = "-"
			end
		
			return result
		end,
	
		__div = function(lhs: BigNumber, rhs: BigNumber)
			BigNumber.Check(lhs)
			BigNumber.Check(rhs)
		
			local result: BigNumber = BigNumber.new()
			local remainder: BigNumber = BigNumber.new()
			local maxDigits = 0
			local carry = 0
		
			if (#lhs.Digits >= #rhs.Digits) then
				maxDigits = #lhs.Digits
			else
				maxDigits = #rhs.Digits
			end
		
			for digit = 0, maxDigits - 1 do
				local quotient = math.floor(((lhs.Digits[#lhs.Digits - digit] or 0) + carry * 10) / (rhs.Digits[#rhs.Digits] or 0))
				local product = quotient * rhs
		
				if (product > lhs) then
					quotient = quotient - 1
					product = quotient * rhs
				end
		
				remainder = lhs - product
		
				result.Digits[maxDigits - digit] = quotient
				carry = remainder.Digits[#remainder.Digits]
			end
		
			return result
		end,
	
		__mod = function(lhs: BigNumber, rhs: BigNumber)
			BigNumber.Check(lhs)
			BigNumber.Check(rhs)
		
			local result: BigNumber = BigNumber.new()
			local remainder: BigNumber = BigNumber.new()
			local maxDigits = 0
			local carry = 0
		
			if (#lhs.Digits >= #rhs.Digits) then
				maxDigits = #lhs.Digits
			else
				maxDigits = #rhs.Digits
			end
		
			for digit = 0, maxDigits - 1 do
				local quotient = math.floor(((lhs.Digits[#lhs.Digits - digit] or 0) + carry * 10) / (rhs.Digits[#rhs.Digits] or 0))
				local product = quotient * rhs
		
				if (product > lhs) then
					quotient = quotient - 1
					product = quotient * rhs
				end
		
				remainder = lhs - product
		
				result.Digits[maxDigits - digit] = quotient
				carry = remainder.Digits[#remainder.Digits]
			end
		
			return remainder
		end,
	
		__pow = function(lhs: BigNumber, rhs: BigNumber)
			BigNumber.Check(lhs)
			BigNumber.Check(rhs)
		
			local result: BigNumber = BigNumber.new("1")
			local maxDigits = 0
		
			if (#lhs.Digits >= #rhs.Digits) then
				maxDigits = #lhs.Digits
			else
				maxDigits = #rhs.Digits
			end
		
			for digit = 0, maxDigits - 1 do
				local product = 0
		
				for digit2 = 0, maxDigits - 1 do
					product = product + (lhs.Digits[#lhs.Digits - digit] or 0) * (lhs.Digits[#lhs.Digits - digit2] or 0)
				end
		
				result = result * product
			end
		
			return result
		end,
	
		__unm = function(lhs: BigNumber)
			BigNumber.Check(lhs)
		
			local result: BigNumber = BigNumber.Clone(lhs)
			result.Sign = (result.Sign == "+" and "-" or "+")
			return result
		end,
	
		__tostring = function(big: BigNumber)
			return big:Unserialize("s")
		end
	})
	

	
	return self
end

function BigNumber:Unserialize(outputType : string?, precision: number?)
	self:Check()

    local num = ""
    if self.Sign == "-" then
        num = "-"
    end

    if (outputType == "number")
    or (outputType == "n")
    or (outputType == "string")
    or (outputType == "s") then


        for _, digit in pairs(self.Digits) do
            num = num .. math.floor(digit) 
        end

        if ((outputType == nil)
        or (outputType == "number")
        or (outputType == "n")) then
            return tonumber(num)
        else
            return num
        end

    else

        if (precision == nil) then
            precision = 3
        else
            assert(precision > 0, "Precision cannot be less than 1")
            assert(math.floor(precision) == precision,
                   "Precision must be a positive integer")
        end


		local count = 0
		for _, n in pairs(Suffixes) do
			count+=1
		end
		
		local walkback = (#self.Digits - 1) % 3

		local suffix = ""
		num = self.Digits[1]

		if count >= (#self.Digits / 3) - (walkback + 1) then
			for i = 1 + walkback, (#self.Digits / 3), 1 do
				suffix = Suffixes[i]
			end

			for i = 2, walkback + 1, 1 do
				num = num .. self.Digits[i]
			end

			if precision and precision > 1 then
				num = num .. "." 
				for i = 1, precision + 1 + walkback do
					num = num .. self.Digits[i] or 0
				end
			end

			return num .. " ".. suffix
		end
		
		if precision and precision > 1 then
			num = num .. "." 
			for i = 1, precision + 1 + walkback do
				num = num .. self.Digits[i] or 0
			end
		end

		return num .. "*10e" .. (#self.Digits - 1)
    end
end

function BigNumber:Check(force: boolean?)
    if (strict or force) then
        assert(#self.Digits > 0, "BigNumber is empty")
        assert(type(self.Sign) == "string", "BigNumber is unSigned")
        for _, digit in pairs(self.Digits) do
            assert(type(digit) == "number", digit .. " is not a number")
            assert(digit < 10, digit .. " is greater than or equal to 10")
        end
    end
    return true
end

function BigNumber:abs()
    self:Check()
    local result = self:Clone()
    result.Sign = "+"
    return result
end

function BigNumber:Clone()
	local newNumber = BigNumber.new()
	newNumber.Sign = self.Sign
	for _, digit in pairs(self.Digits) do
		newNumber.Digits[#newNumber.Digits + 1] = digit
	end
	return newNumber
end

function BigNumber:MultiplySingle(rhs: BigNumber)
    self:Check()
    BigNumber.Check(rhs)

    assert(#rhs.Digits == 1, BigNumber.Unserialize(rhs, "string")
                              .. " has more than one digit")

    local result = BigNumber.new()
    local carry = 0


    for digit = 0, #self.Digits - 1 do
        local this_digit = self.Digits[#self.Digits - digit]
                         * rhs.Digits[1]
                         + carry

        if (this_digit >= 10) then
            carry = math.floor(this_digit / 10)
            this_digit = this_digit - (carry * 10)
        else
            carry = 0
        end

        result.Digits[#self.Digits - digit] = this_digit
    end

    if (carry > 0) then
        table.insert(result.Digits, 1, carry)
    end

    return result
end



return BigNumber
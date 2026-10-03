--!strict

export type Vector3f64Surface = {
	_x: number,
	_y: number,
	_z: number,
}

export type Vector3Input = Vector3f64 | Vector3

export type Vector3f64Static = {
	__index: any,
	__add: any,
	__sub: any,
	__unm: any,
	__mul: any,
	__div: any,
	__idiv: any,
	__eq: any,
	__tostring: any,
	zero: Vector3f64,
	one: Vector3f64,
	xAxis: Vector3f64,
	yAxis: Vector3f64,
	zAxis: Vector3f64,
	X: number,
	Y: number,
	Z: number,
	Magnitude: number,
	Unit: Vector3f64,
	new: (x: number?, y: number?, z: number?) -> Vector3f64,
	FromNormalId: (normal: Enum.NormalId) -> Vector3f64,
	FromAxis: (axis: Enum.Axis) -> Vector3f64,
	fromVector3: (value: Vector3Input) -> Vector3f64,
	toVector3: (self: Vector3f64) -> Vector3,
	Abs: (self: Vector3f64) -> Vector3f64,
	Ceil: (self: Vector3f64) -> Vector3f64,
	Floor: (self: Vector3f64) -> Vector3f64,
	Sign: (self: Vector3f64) -> Vector3f64,
	Cross: (self: Vector3f64, other: Vector3Input) -> Vector3f64,
	Angle: (self: Vector3f64, other: Vector3Input, axis: Vector3Input?) -> number,
	Dot: (self: Vector3f64, other: Vector3Input) -> number,
	FuzzyEq: (self: Vector3f64, other: Vector3Input, epsilon: number?) -> boolean,
	Lerp: (self: Vector3f64, goal: Vector3Input, alpha: number) -> Vector3f64,
	Max: (self: Vector3f64, other: Vector3Input) -> Vector3f64,
	Min: (self: Vector3f64, other: Vector3Input) -> Vector3f64,
}

export type Vector3f64 = typeof(setmetatable({} :: Vector3f64Surface, {} :: Vector3f64Static))

local Vector3f64: Vector3f64Static = {} :: Vector3f64Static

local function make(x: number, y: number, z: number): Vector3f64
	local value: Vector3f64Surface = {
		_x = x,
		_y = y,
		_z = z,
	}
	return table.freeze(setmetatable(value, Vector3f64))
end

local function components(value: Vector3Input): (number, number, number)
	if typeof(value) == "Vector3" then
		return value.X, value.Y, value.Z
	end
	return value._x, value._y, value._z
end

local function scaledMagnitude(x: number, y: number, z: number): number
	local scale = math.max(math.abs(x), math.abs(y), math.abs(z))
	if scale == 0 then
		return 0
	end
	local sx, sy, sz = x / scale, y / scale, z / scale
	return scale * math.sqrt(sx * sx + sy * sy + sz * sz)
end

local function unitComponents(x: number, y: number, z: number): (number, number, number)
	local scale = math.max(math.abs(x), math.abs(y), math.abs(z))
	if scale == 0 then
		return 0, 0, 0
	end
	local sx, sy, sz = x / scale, y / scale, z / scale
	local magnitude = math.sqrt(sx * sx + sy * sy + sz * sz)
	return sx / magnitude, sy / magnitude, sz / magnitude
end

local function index(_self: Vector3f64, key: string): any
	if key == "X" then
		return (_self :: any)._x
	elseif key == "Y" then
		return (_self :: any)._y
	elseif key == "Z" then
		return (_self :: any)._z
	elseif key == "Magnitude" then
		local value = _self :: any
		return scaledMagnitude(value._x, value._y, value._z)
	elseif key == "Unit" then
		local value = _self :: any
		return make(unitComponents(value._x, value._y, value._z))
	end
	return (Vector3f64 :: any)[key]
end

Vector3f64.__index = index

function Vector3f64.new(x: number?, y: number?, z: number?): Vector3f64
	return make(x or 0, y or 0, z or 0)
end

function Vector3f64.fromVector3(value: Vector3Input): Vector3f64
	return make(value.X, value.Y, value.Z)
end

function Vector3f64:toVector3(): Vector3
	return Vector3.new(self._x, self._y, self._z)
end

function Vector3f64.FromNormalId(normal: Enum.NormalId): Vector3f64
	if normal == Enum.NormalId.Front then
		return make(0, 0, -1)
	elseif normal == Enum.NormalId.Back then
		return make(0, 0, 1)
	elseif normal == Enum.NormalId.Top then
		return make(0, 1, 0)
	elseif normal == Enum.NormalId.Bottom then
		return make(0, -1, 0)
	elseif normal == Enum.NormalId.Right then
		return make(1, 0, 0)
	elseif normal == Enum.NormalId.Left then
		return make(-1, 0, 0)
	end
	error("Vector3f64.FromNormalId: invalid NormalId")
end

function Vector3f64.FromAxis(axis: Enum.Axis): Vector3f64
	if axis == Enum.Axis.X then
		return make(1, 0, 0)
	elseif axis == Enum.Axis.Y then
		return make(0, 1, 0)
	elseif axis == Enum.Axis.Z then
		return make(0, 0, 1)
	end
	error("Vector3f64.FromAxis: invalid Axis")
end

function Vector3f64:Abs(): Vector3f64
	return make(math.abs(self._x), math.abs(self._y), math.abs(self._z))
end

function Vector3f64:Ceil(): Vector3f64
	return make(math.ceil(self._x), math.ceil(self._y), math.ceil(self._z))
end

function Vector3f64:Floor(): Vector3f64
	return make(math.floor(self._x), math.floor(self._y), math.floor(self._z))
end

function Vector3f64:Sign(): Vector3f64
	return make(math.sign(self._x), math.sign(self._y), math.sign(self._z))
end

function Vector3f64:Cross(other: Vector3Input): Vector3f64
	local x, y, z = components(other)
	return make(self._y * z - self._z * y, self._z * x - self._x * z, self._x * y - self._y * x)
end

function Vector3f64:Dot(other: Vector3Input): number
	local x, y, z = components(other)
	return self._x * x + self._y * y + self._z * z
end

function Vector3f64:Angle(other: Vector3Input, axis: Vector3Input?): number
	local x, y, z = components(other)
	local ax, ay, az = unitComponents(self._x, self._y, self._z)
	local bx, by, bz = unitComponents(x, y, z)
	local dot = ax * bx + ay * by + az * bz
	local crossX = ay * bz - az * by
	local crossY = az * bx - ax * bz
	local crossZ = ax * by - ay * bx
	local crossMagnitude = scaledMagnitude(crossX, crossY, crossZ)
	local angle = math.atan2(crossMagnitude, dot)
	if axis ~= nil then
		local axisX, axisY, axisZ = components(axis)
		axisX, axisY, axisZ = unitComponents(axisX, axisY, axisZ)
		if axisX * crossX + axisY * crossY + axisZ * crossZ < 0 then
			return -angle
		end
	end
	return angle
end

function Vector3f64:FuzzyEq(other: Vector3Input, epsilon: number?): boolean
	local x, y, z = components(other)
	local tolerance = if epsilon == nil then 1e-5 else epsilon
	return math.abs(self._x - x) <= tolerance and math.abs(self._y - y) <= tolerance and math.abs(self._z - z) <= tolerance
end

function Vector3f64:Lerp(goal: Vector3Input, alpha: number): Vector3f64
	local x, y, z = components(goal)
	return make(self._x + (x - self._x) * alpha, self._y + (y - self._y) * alpha, self._z + (z - self._z) * alpha)
end

function Vector3f64:Max(other: Vector3Input): Vector3f64
	local x, y, z = components(other)
	return make(math.max(self._x, x), math.max(self._y, y), math.max(self._z, z))
end

function Vector3f64:Min(other: Vector3Input): Vector3f64
	local x, y, z = components(other)
	return make(math.min(self._x, x), math.min(self._y, y), math.min(self._z, z))
end

local function operandComponents(value: any): (number, number, number)
	if typeof(value) == "Vector3" then
		return value.X, value.Y, value.Z
	end
	if type(value) == "table" and getmetatable(value) == Vector3f64 then
		return value._x, value._y, value._z
	end
	error("Vector3f64 operation expected a Vector3f64 or Vector3")
end

local function binary(left: any, right: any, operation: (number, number) -> number): Vector3f64
	local ax, ay, az = operandComponents(left)
	local bx, by, bz = operandComponents(right)
	return make(operation(ax, bx), operation(ay, by), operation(az, bz))
end

local function scalarBinary(value: any, scalar: number, operation: (number, number) -> number): Vector3f64
	local x, y, z = operandComponents(value)
	return make(operation(x, scalar), operation(y, scalar), operation(z, scalar))
end

local function equal(left: any, right: any): boolean
	if typeof(right) ~= "Vector3" and not (type(right) == "table" and getmetatable(right) == Vector3f64) then
		return false
	end
	local ax, ay, az = operandComponents(left)
	local bx, by, bz = operandComponents(right)
	return ax == bx and ay == by and az == bz
end

Vector3f64.__add = function(left: any, right: any): Vector3f64
	return binary(left, right, function(a, b)
		return a + b
	end)
end

Vector3f64.__sub = function(left: any, right: any): Vector3f64
	return binary(left, right, function(a, b)
		return a - b
	end)
end

Vector3f64.__unm = function(value: any): Vector3f64
	return scalarBinary(value, -1, function(a, b)
		return a * b
	end)
end

Vector3f64.__mul = function(left: any, right: any): Vector3f64
	if type(right) == "number" then
		return scalarBinary(left, right, function(a, b)
			return a * b
		end)
	elseif type(left) == "number" then
		return scalarBinary(right, left, function(a, b)
			return a * b
		end)
	end
	return binary(left, right, function(a, b)
		return a * b
	end)
end

Vector3f64.__div = function(left: any, right: any): Vector3f64
	if type(right) == "number" then
		return scalarBinary(left, right, function(a, b)
			return a / b
		end)
	end
	return binary(left, right, function(a, b)
		return a / b
	end)
end

Vector3f64.__idiv = function(left: any, right: any): Vector3f64
	if type(right) == "number" then
		return scalarBinary(left, right, function(a, b)
			return math.floor(a / b)
		end)
	end
	return binary(left, right, function(a, b)
		return math.floor(a / b)
	end)
end

Vector3f64.__eq = equal
Vector3f64.__tostring = function(value: any): string
	return string.format("Vector3f64(%.17g, %.17g, %.17g)", value._x, value._y, value._z)
end

setmetatable(Vector3f64, {
	__index = function(_self, key: string): any
		if key == "zero" then
			return make(0, 0, 0)
		elseif key == "one" then
			return make(1, 1, 1)
		elseif key == "xAxis" then
			return make(1, 0, 0)
		elseif key == "yAxis" then
			return make(0, 1, 0)
		elseif key == "zAxis" then
			return make(0, 0, 1)
		end
		return nil
	end,
})

return table.freeze(Vector3f64)

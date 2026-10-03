--!strict

local vector64 = require(script.Parent.vector64)

type Matrix3 = {number}
export type CFrameInput = CFrame64 | CFrame

export type CFrame64Surface = {
	_px: number,
	_py: number,
	_pz: number,
	_r00: number,
	_r01: number,
	_r02: number,
	_r10: number,
	_r11: number,
	_r12: number,
	_r20: number,
	_r21: number,
	_r22: number,
}

export type CFrame64Static = {
	__index: any,
	__mul: any,
	__add: any,
	__sub: any,
	__eq: any,
	__tostring: any,
	identity: CFrame64,
	Position: vector64.Vector3f64,
	Rotation: CFrame64,
	X: number,
	Y: number,
	Z: number,
	LookVector: vector64.Vector3f64,
	RightVector: vector64.Vector3f64,
	UpVector: vector64.Vector3f64,
	XVector: vector64.Vector3f64,
	YVector: vector64.Vector3f64,
	ZVector: vector64.Vector3f64,
	new: (...any) -> CFrame64,
	lookAt: (at: vector64.Vector3Input, target: vector64.Vector3Input, up: vector64.Vector3Input?) -> CFrame64,
	lookAlong: (at: vector64.Vector3Input, direction: vector64.Vector3Input, up: vector64.Vector3Input?) -> CFrame64,
	fromRotationBetweenVectors: (from: vector64.Vector3Input, to: vector64.Vector3Input) -> CFrame64,
	fromEulerAngles: (rx: number, ry: number, rz: number, order: Enum.RotationOrder?) -> CFrame64,
	fromEulerAnglesXYZ: (rx: number, ry: number, rz: number) -> CFrame64,
	fromEulerAnglesYXZ: (rx: number, ry: number, rz: number) -> CFrame64,
	Angles: (rx: number, ry: number, rz: number) -> CFrame64,
	fromOrientation: (rx: number, ry: number, rz: number) -> CFrame64,
	fromAxisAngle: (axis: vector64.Vector3Input, angle: number) -> CFrame64,
	fromMatrix: (position: vector64.Vector3Input, right: vector64.Vector3Input, up: vector64.Vector3Input, back: vector64.Vector3Input?) -> CFrame64,
	fromCFrame: (value: CFrameInput) -> CFrame64,
	Inverse: (self: CFrame64) -> CFrame64,
	Lerp: (self: CFrame64, goal: CFrameInput, alpha: number) -> CFrame64,
	Orthonormalize: (self: CFrame64) -> CFrame64,
	ToWorldSpace: (self: CFrame64, value: CFrameInput) -> CFrame64,
	ToObjectSpace: (self: CFrame64, value: CFrameInput) -> CFrame64,
	PointToWorldSpace: (self: CFrame64, value: vector64.Vector3Input) -> vector64.Vector3f64,
	PointToObjectSpace: (self: CFrame64, value: vector64.Vector3Input) -> vector64.Vector3f64,
	VectorToWorldSpace: (self: CFrame64, value: vector64.Vector3Input) -> vector64.Vector3f64,
	VectorToObjectSpace: (self: CFrame64, value: vector64.Vector3Input) -> vector64.Vector3f64,
	GetComponents: (self: CFrame64) -> (number, number, number, number, number, number, number, number, number, number, number, number),
	components: (self: CFrame64) -> (number, number, number, number, number, number, number, number, number, number, number, number),
	ToEulerAngles: (self: CFrame64, order: Enum.RotationOrder?) -> (number, number, number),
	ToEulerAnglesXYZ: (self: CFrame64) -> (number, number, number),
	ToEulerAnglesYXZ: (self: CFrame64) -> (number, number, number),
	ToOrientation: (self: CFrame64) -> (number, number, number),
	ToAxisAngle: (self: CFrame64) -> (vector64.Vector3f64, number),
	FuzzyEq: (self: CFrame64, other: CFrameInput, epsilon: number?) -> boolean,
	AngleBetween: (self: CFrame64, other: CFrameInput) -> number,
	toCFrame: (self: CFrame64) -> CFrame,
}

export type CFrame64 = typeof(setmetatable({} :: CFrame64Surface, {} :: CFrame64Static))

local CFrame64: CFrame64Static = {} :: CFrame64Static

local function make(px: number, py: number, pz: number, rotation: Matrix3): CFrame64
	local value: CFrame64Surface = {
		_px = px,
		_py = py,
		_pz = pz,
		_r00 = rotation[1],
		_r01 = rotation[2],
		_r02 = rotation[3],
		_r10 = rotation[4],
		_r11 = rotation[5],
		_r12 = rotation[6],
		_r20 = rotation[7],
		_r21 = rotation[8],
		_r22 = rotation[9],
	}
	return table.freeze(setmetatable(value, CFrame64))
end

local function identityRotation(): Matrix3
	return {1, 0, 0, 0, 1, 0, 0, 0, 1}
end

local function matrixOf(value: CFrame64): Matrix3
	return {value._r00, value._r01, value._r02, value._r10, value._r11, value._r12, value._r20, value._r21, value._r22}
end

local function positionOf(value: CFrameInput): (number, number, number)
	if typeof(value) == "CFrame" then
		return value.X, value.Y, value.Z
	end
	return value._px, value._py, value._pz
end

local function matrixInput(value: CFrameInput): Matrix3
	if typeof(value) == "CFrame" then
		local _, _, _, r00, r01, r02, r10, r11, r12, r20, r21, r22 = value:GetComponents()
		return {r00, r01, r02, r10, r11, r12, r20, r21, r22}
	end
	return matrixOf(value)
end

local function multiply(a: Matrix3, b: Matrix3): Matrix3
	local result: Matrix3 = table.create(9, 0)
	for row = 0, 2 do
		for column = 0, 2 do
			local value = 0
			for inner = 0, 2 do
				value += a[row * 3 + inner + 1] * b[inner * 3 + column + 1]
			end
			result[row * 3 + column + 1] = value
		end
	end
	return result
end

local function transform(rotation: Matrix3, x: number, y: number, z: number): (number, number, number)
	return rotation[1] * x + rotation[2] * y + rotation[3] * z,
		rotation[4] * x + rotation[5] * y + rotation[6] * z,
		rotation[7] * x + rotation[8] * y + rotation[9] * z
end

local function vectorComponents(value: vector64.Vector3Input): (number, number, number)
	if typeof(value) == "Vector3" then
		return value.X, value.Y, value.Z
	end
	return value.X, value.Y, value.Z
end

local function cross(ax: number, ay: number, az: number, bx: number, by: number, bz: number): (number, number, number)
	return ay * bz - az * by, az * bx - ax * bz, ax * by - ay * bx
end

local function normalize(x: number, y: number, z: number): (number, number, number)
	local scale = math.max(math.abs(x), math.abs(y), math.abs(z))
	if scale == 0 then
		return 0, 0, 0
	end
	local sx, sy, sz = x / scale, y / scale, z / scale
	local magnitude = math.sqrt(sx * sx + sy * sy + sz * sz)
	return sx / magnitude, sy / magnitude, sz / magnitude
end

local function normalizeQuaternion(x: number, y: number, z: number, w: number): (number, number, number, number)
	local scale = math.max(math.abs(x), math.abs(y), math.abs(z), math.abs(w))
	if scale == 0 then
		return 0, 0, 0, 1
	end
	local sx, sy, sz, sw = x / scale, y / scale, z / scale, w / scale
	local magnitude = math.sqrt(sx * sx + sy * sy + sz * sz + sw * sw)
	return sx / magnitude, sy / magnitude, sz / magnitude, sw / magnitude
end

local function index(_self: CFrame64, key: string): any
	local self = _self :: any
	if key == "Position" then
		return vector64.new(self._px, self._py, self._pz)
	elseif key == "Rotation" then
		return make(0, 0, 0, matrixOf(_self))
	elseif key == "X" then
		return self._px
	elseif key == "Y" then
		return self._py
	elseif key == "Z" then
		return self._pz
	elseif key == "RightVector" or key == "XVector" then
		return vector64.new(self._r00, self._r10, self._r20)
	elseif key == "UpVector" or key == "YVector" then
		return vector64.new(self._r01, self._r11, self._r21)
	elseif key == "ZVector" then
		return vector64.new(self._r02, self._r12, self._r22)
	elseif key == "LookVector" then
		return vector64.new(-self._r02, -self._r12, -self._r22)
	end
	return (CFrame64 :: any)[key]
end

CFrame64.__index = index

local function fromQuaternion(px: number, py: number, pz: number, x: number, y: number, z: number, w: number): CFrame64
	x, y, z, w = normalizeQuaternion(x, y, z, w)
	local xx, yy, zz = x * x, y * y, z * z
	local xy, xz, yz = x * y, x * z, y * z
	local wx, wy, wz = w * x, w * y, w * z
	local rotation: Matrix3 = {
		1 - 2 * (yy + zz), 2 * (xy - wz), 2 * (xz + wy),
		2 * (xy + wz), 1 - 2 * (xx + zz), 2 * (yz - wx),
		2 * (xz - wy), 2 * (yz + wx), 1 - 2 * (xx + yy),
	}
	return make(px, py, pz, rotation)
end

local function axisRotation(axis: string, angle: number): Matrix3
	local c = math.cos(angle)
	local s = math.sin(angle)
	if axis == "X" then
		return {1, 0, 0, 0, c, -s, 0, s, c}
	elseif axis == "Y" then
		return {c, 0, s, 0, 1, 0, -s, 0, c}
	end
	return {c, -s, 0, s, c, 0, 0, 0, 1}
end

local function eulerRotation(rx: number, ry: number, rz: number, order: string): Matrix3
	local angles: {[string]: number} = {X = rx, Y = ry, Z = rz}
	local result = identityRotation()
	for i = 1, #order do
		local axis = string.sub(order, i, i)
		result = multiply(axisRotation(axis, angles[axis]), result)
	end
	return result
end

local function lookFrame(at: vector64.Vector3Input, direction: vector64.Vector3Input, up: vector64.Vector3Input?): CFrame64
	local px, py, pz = vectorComponents(at)
	local dx, dy, dz = vectorComponents(direction)
	local bx, by, bz = normalize(-dx, -dy, -dz)
	if bx == 0 and by == 0 and bz == 0 then
		return make(px, py, pz, identityRotation())
	end
	local ux, uy, uz = 0, 1, 0
	if up ~= nil then
		ux, uy, uz = vectorComponents(up)
	end
	local rx, ry, rz = cross(ux, uy, uz, bx, by, bz)
	rx, ry, rz = normalize(rx, ry, rz)
	if rx == 0 and ry == 0 and rz == 0 then
		if math.abs(by) < 0.9 then
			rx, ry, rz = normalize(-bz, 0, bx)
		else
			rx, ry, rz = normalize(0, bz, -by)
		end
	end
	local realUpX, realUpY, realUpZ = cross(bx, by, bz, rx, ry, rz)
	local rotation: Matrix3 = {
		rx, realUpX, bx,
		ry, realUpY, by,
		rz, realUpZ, bz,
	}
	return make(px, py, pz, rotation)
end

function CFrame64.new(...: any): CFrame64
	local args = {...}
	local count = #args
	local first = args[1]
	if count == 0 then
		return make(0, 0, 0, identityRotation())
	elseif typeof(first) == "Vector3" or (type(first) == "table" and getmetatable(first) == vector64) then
		local px, py, pz = vectorComponents(first)
		if count == 1 then
			return make(px, py, pz, identityRotation())
		end
		local target = args[2]
		local tx, ty, tz = vectorComponents(target)
		return lookFrame(vector64.new(px, py, pz), vector64.new(tx - px, ty - py, tz - pz), nil)
	end

	assert(type(first) == "number", "CFrame64.new: expected no arguments, a Vector3, or numeric components")
	local px, py, pz = first, args[2], args[3]
	assert(type(px) == "number" and type(py) == "number" and type(pz) == "number", "CFrame64.new: expected three position components")
	if count == 3 then
		return make(px, py, pz, identityRotation())
	elseif count == 7 then
		return fromQuaternion(px, py, pz, args[4], args[5], args[6], args[7])
	elseif count == 12 then
		local rotation: Matrix3 = {args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12]}
		for _, value in rotation do
			assert(type(value) == "number", "CFrame64.new: rotation components must be numbers")
		end
		return make(px, py, pz, rotation)
	end
	error("CFrame64.new: expected 0, 1, 2, 3, 7, or 12 arguments")
end

function CFrame64.fromCFrame(value: CFrameInput): CFrame64
	local px, py, pz, r00, r01, r02, r10, r11, r12, r20, r21, r22 = value:GetComponents()
	return make(px, py, pz, {r00, r01, r02, r10, r11, r12, r20, r21, r22})
end

function CFrame64:toCFrame(): CFrame
	return CFrame.new(
		self._px, self._py, self._pz,
		self._r00, self._r01, self._r02,
		self._r10, self._r11, self._r12,
		self._r20, self._r21, self._r22
	)
end

function CFrame64.lookAt(at: vector64.Vector3Input, target: vector64.Vector3Input, up: vector64.Vector3Input?): CFrame64
	local ax, ay, az = vectorComponents(at)
	local tx, ty, tz = vectorComponents(target)
	return lookFrame(at, vector64.new(tx - ax, ty - ay, tz - az), up)
end

function CFrame64.lookAlong(at: vector64.Vector3Input, direction: vector64.Vector3Input, up: vector64.Vector3Input?): CFrame64
	return lookFrame(at, direction, up)
end

function CFrame64.fromRotationBetweenVectors(from: vector64.Vector3Input, to: vector64.Vector3Input): CFrame64
	local fx, fy, fz = vectorComponents(from)
	local tx, ty, tz = vectorComponents(to)
	fx, fy, fz = normalize(fx, fy, fz)
	tx, ty, tz = normalize(tx, ty, tz)
	if (fx == 0 and fy == 0 and fz == 0) or (tx == 0 and ty == 0 and tz == 0) then
		return make(0, 0, 0, identityRotation())
	end
	local dot = math.clamp(fx * tx + fy * ty + fz * tz, -1, 1)
	if dot < -0.999999999 then
		local ax, ay, az = 1, 0, 0
		if math.abs(fy) < math.abs(fx) and math.abs(fy) <= math.abs(fz) then
			ax, ay, az = 0, 1, 0
		elseif math.abs(fz) < math.abs(fx) and math.abs(fz) < math.abs(fy) then
			ax, ay, az = 0, 0, 1
		end
		local bx, by, bz = cross(fx, fy, fz, ax, ay, az)
		bx, by, bz = normalize(bx, by, bz)
		return fromQuaternion(0, 0, 0, bx, by, bz, 0)
	end
	local qx, qy, qz = cross(fx, fy, fz, tx, ty, tz)
	return fromQuaternion(0, 0, 0, qx, qy, qz, 1 + dot)
end

function CFrame64.fromEulerAngles(rx: number, ry: number, rz: number, order: Enum.RotationOrder?): CFrame64
	local rotationOrder = if order == nil then Enum.RotationOrder.XYZ else order
	local orderName = if rotationOrder == Enum.RotationOrder.XYZ then "XYZ"
		elseif rotationOrder == Enum.RotationOrder.XZY then "XZY"
		elseif rotationOrder == Enum.RotationOrder.YXZ then "YXZ"
		elseif rotationOrder == Enum.RotationOrder.YZX then "YZX"
		elseif rotationOrder == Enum.RotationOrder.ZXY then "ZXY"
		elseif rotationOrder == Enum.RotationOrder.ZYX then "ZYX"
		else error("CFrame64.fromEulerAngles: invalid RotationOrder")
	return make(0, 0, 0, eulerRotation(rx, ry, rz, orderName))
end

function CFrame64.fromEulerAnglesXYZ(rx: number, ry: number, rz: number): CFrame64
	return make(0, 0, 0, eulerRotation(rx, ry, rz, "XYZ"))
end

function CFrame64.fromEulerAnglesYXZ(rx: number, ry: number, rz: number): CFrame64
	return make(0, 0, 0, eulerRotation(rx, ry, rz, "YXZ"))
end

function CFrame64.Angles(rx: number, ry: number, rz: number): CFrame64
	return CFrame64.fromEulerAnglesXYZ(rx, ry, rz)
end

function CFrame64.fromOrientation(rx: number, ry: number, rz: number): CFrame64
	return CFrame64.fromEulerAnglesYXZ(rx, ry, rz)
end

function CFrame64.fromAxisAngle(axis: vector64.Vector3Input, angle: number): CFrame64
	local x, y, z = vectorComponents(axis)
	x, y, z = normalize(x, y, z)
	if x == 0 and y == 0 and z == 0 then
		return make(0, 0, 0, identityRotation())
	end
	local cosine = math.cos(angle)
	local sine = math.sin(angle)
	local oneMinusCosine = 1 - cosine
	local rotation: Matrix3 = {
		cosine + x * x * oneMinusCosine, x * y * oneMinusCosine - z * sine, x * z * oneMinusCosine + y * sine,
		y * x * oneMinusCosine + z * sine, cosine + y * y * oneMinusCosine, y * z * oneMinusCosine - x * sine,
		z * x * oneMinusCosine - y * sine, z * y * oneMinusCosine + x * sine, cosine + z * z * oneMinusCosine,
	}
	return make(0, 0, 0, rotation)
end

function CFrame64.fromMatrix(position: vector64.Vector3Input, right: vector64.Vector3Input, up: vector64.Vector3Input, back: vector64.Vector3Input?): CFrame64
	local px, py, pz = vectorComponents(position)
	local rx, ry, rz = vectorComponents(right)
	local ux, uy, uz = vectorComponents(up)
	local bx, by, bz = 0, 0, 0
	if back == nil then
		bx, by, bz = cross(rx, ry, rz, ux, uy, uz)
	else
		bx, by, bz = vectorComponents(back)
	end
	return make(px, py, pz, {rx, ux, bx, ry, uy, by, rz, uz, bz})
end

function CFrame64:Inverse(): CFrame64
	local m = matrixOf(self)
	local determinant = m[1] * (m[5] * m[9] - m[6] * m[8]) - m[2] * (m[4] * m[9] - m[6] * m[7]) + m[3] * (m[4] * m[8] - m[5] * m[7])
	assert(determinant ~= 0, "CFrame64:Inverse: rotation matrix is singular")
	local inverse: Matrix3 = {
		(m[5] * m[9] - m[6] * m[8]) / determinant,
		(m[3] * m[8] - m[2] * m[9]) / determinant,
		(m[2] * m[6] - m[3] * m[5]) / determinant,
		(m[6] * m[7] - m[4] * m[9]) / determinant,
		(m[1] * m[9] - m[3] * m[7]) / determinant,
		(m[3] * m[4] - m[1] * m[6]) / determinant,
		(m[4] * m[8] - m[5] * m[7]) / determinant,
		(m[2] * m[7] - m[1] * m[8]) / determinant,
		(m[1] * m[5] - m[2] * m[4]) / determinant,
	}
	local px, py, pz = transform(inverse, -self._px, -self._py, -self._pz)
	return make(px, py, pz, inverse)
end

local function quaternionOf(m: Matrix3): (number, number, number, number)
	local trace = m[1] + m[5] + m[9]
	local x, y, z, w = 0, 0, 0, 1
	if trace > 0 then
		local s = math.sqrt(trace + 1) * 2
		w = 0.25 * s
		x = (m[8] - m[6]) / s
		y = (m[3] - m[7]) / s
		z = (m[4] - m[2]) / s
	elseif m[1] > m[5] and m[1] > m[9] then
		local s = math.sqrt(1 + m[1] - m[5] - m[9]) * 2
		w = (m[8] - m[6]) / s
		x = 0.25 * s
		y = (m[2] + m[4]) / s
		z = (m[3] + m[7]) / s
	elseif m[5] > m[9] then
		local s = math.sqrt(1 + m[5] - m[1] - m[9]) * 2
		w = (m[3] - m[7]) / s
		x = (m[2] + m[4]) / s
		y = 0.25 * s
		z = (m[6] + m[8]) / s
	else
		local s = math.sqrt(1 + m[9] - m[1] - m[5]) * 2
		w = (m[4] - m[2]) / s
		x = (m[3] + m[7]) / s
		y = (m[6] + m[8]) / s
		z = 0.25 * s
	end
	return x, y, z, w
end

local function matrixFromQuaternion(x: number, y: number, z: number, w: number): Matrix3
	x, y, z, w = normalizeQuaternion(x, y, z, w)
	local xx, yy, zz = x * x, y * y, z * z
	local xy, xz, yz = x * y, x * z, y * z
	local wx, wy, wz = w * x, w * y, w * z
	return {
		1 - 2 * (yy + zz), 2 * (xy - wz), 2 * (xz + wy),
		2 * (xy + wz), 1 - 2 * (xx + zz), 2 * (yz - wx),
		2 * (xz - wy), 2 * (yz + wx), 1 - 2 * (xx + yy),
	}
end

function CFrame64:Lerp(goal: CFrameInput, alpha: number): CFrame64
	local px, py, pz = positionOf(goal)
	local ax, ay, az, aw = quaternionOf(matrixOf(self))
	local bx, by, bz, bw = quaternionOf(matrixInput(goal))
	local dot = ax * bx + ay * by + az * bz + aw * bw
	if dot < 0 then
		bx, by, bz, bw = -bx, -by, -bz, -bw
		dot = -dot
	end
	local x, y, z, w = ax, ay, az, aw
	if dot > 0.9995 then
		x, y, z, w = ax + alpha * (bx - ax), ay + alpha * (by - ay), az + alpha * (bz - az), aw + alpha * (bw - aw)
	else
		local angle = math.acos(math.clamp(dot, -1, 1))
		local sine = math.sin(angle)
		local weightA = math.sin((1 - alpha) * angle) / sine
		local weightB = math.sin(alpha * angle) / sine
		x, y, z, w = ax * weightA + bx * weightB, ay * weightA + by * weightB, az * weightA + bz * weightB, aw * weightA + bw * weightB
	end
	return make(
		self._px + (px - self._px) * alpha,
		self._py + (py - self._py) * alpha,
		self._pz + (pz - self._pz) * alpha,
		matrixFromQuaternion(x, y, z, w)
	)
end

function CFrame64:Orthonormalize(): CFrame64
	local rightX, rightY, rightZ = normalize(self._r00, self._r10, self._r20)
	local upX, upY, upZ = self._r01, self._r11, self._r21
	local projection = rightX * upX + rightY * upY + rightZ * upZ
	upX, upY, upZ = normalize(upX - projection * rightX, upY - projection * rightY, upZ - projection * rightZ)
	local backX, backY, backZ = normalize(cross(rightX, rightY, rightZ, upX, upY, upZ))
	return make(self._px, self._py, self._pz, {
		rightX, upX, backX,
		rightY, upY, backY,
		rightZ, upZ, backZ,
	})
end

function CFrame64:ToWorldSpace(value: CFrameInput): CFrame64
	return self * value
end

function CFrame64:ToObjectSpace(value: CFrameInput): CFrame64
	return self:Inverse() * value
end

function CFrame64:PointToWorldSpace(value: vector64.Vector3Input): vector64.Vector3f64
	local x, y, z = vectorComponents(value)
	local tx, ty, tz = transform(matrixOf(self), x, y, z)
	return vector64.new(tx + self._px, ty + self._py, tz + self._pz)
end

function CFrame64:PointToObjectSpace(value: vector64.Vector3Input): vector64.Vector3f64
	local x, y, z = vectorComponents(value)
	local inverse = self:Inverse()
	local tx, ty, tz = transform(matrixOf(inverse), x - self._px, y - self._py, z - self._pz)
	return vector64.new(tx, ty, tz)
end

function CFrame64:VectorToWorldSpace(value: vector64.Vector3Input): vector64.Vector3f64
	local x, y, z = vectorComponents(value)
	local tx, ty, tz = transform(matrixOf(self), x, y, z)
	return vector64.new(tx, ty, tz)
end

function CFrame64:VectorToObjectSpace(value: vector64.Vector3Input): vector64.Vector3f64
	local x, y, z = vectorComponents(value)
	local inverse = matrixOf(self:Inverse())
	local tx, ty, tz = transform(inverse, x, y, z)
	return vector64.new(tx, ty, tz)
end

function CFrame64:GetComponents(): (number, number, number, number, number, number, number, number, number, number, number, number)
	return self._px, self._py, self._pz,
		self._r00, self._r01, self._r02,
		self._r10, self._r11, self._r12,
		self._r20, self._r21, self._r22
end

function CFrame64:components(): (number, number, number, number, number, number, number, number, number, number, number, number)
	return self:GetComponents()
end

local function toEuler(self: CFrame64, order: string): (number, number, number)
	local m = matrixOf(self)
	local rx, ry, rz = 0, 0, 0
	if order == "XYZ" then
		ry = math.asin(math.clamp(m[3], -1, 1))
		if math.abs(m[3]) < 0.9999999 then
			rx, rz = math.atan2(-m[6], m[9]), math.atan2(-m[2], m[1])
		else
			rx, rz = math.atan2(m[8], m[5]), 0
		end
	elseif order == "YXZ" then
		rx = math.asin(math.clamp(-m[6], -1, 1))
		if math.abs(m[6]) < 0.9999999 then
			ry, rz = math.atan2(m[3], m[9]), math.atan2(m[4], m[5])
		else
			ry, rz = math.atan2(-m[7], m[1]), 0
		end
	elseif order == "ZXY" then
		rx = math.asin(math.clamp(m[8], -1, 1))
		if math.abs(m[8]) < 0.9999999 then
			ry, rz = math.atan2(-m[7], m[9]), math.atan2(-m[2], m[5])
		else
			ry, rz = 0, math.atan2(m[4], m[1])
		end
	elseif order == "ZYX" then
		ry = math.asin(math.clamp(-m[7], -1, 1))
		if math.abs(m[7]) < 0.9999999 then
			rx, rz = math.atan2(m[8], m[9]), math.atan2(m[4], m[1])
		else
			rx, rz = 0, math.atan2(-m[2], m[5])
		end
	elseif order == "YZX" then
		rz = math.asin(math.clamp(m[4], -1, 1))
		if math.abs(m[4]) < 0.9999999 then
			rx, ry = math.atan2(-m[6], m[5]), math.atan2(-m[7], m[1])
		else
			rx, ry = 0, math.atan2(m[3], m[9])
		end
	else
		rz = math.asin(math.clamp(-m[2], -1, 1))
		if math.abs(m[2]) < 0.9999999 then
			rx, ry = math.atan2(m[8], m[5]), math.atan2(m[3], m[1])
		else
			rx, ry = math.atan2(-m[6], m[9]), 0
		end
	end
	return rx, ry, rz
end

function CFrame64:ToEulerAngles(order: Enum.RotationOrder?): (number, number, number)
	local rotationOrder = if order == nil then Enum.RotationOrder.XYZ else order
	if rotationOrder == Enum.RotationOrder.XYZ then
		return toEuler(self, "XYZ")
	elseif rotationOrder == Enum.RotationOrder.XZY then
		return toEuler(self, "XZY")
	elseif rotationOrder == Enum.RotationOrder.YXZ then
		return toEuler(self, "YXZ")
	elseif rotationOrder == Enum.RotationOrder.YZX then
		return toEuler(self, "YZX")
	elseif rotationOrder == Enum.RotationOrder.ZXY then
		return toEuler(self, "ZXY")
	elseif rotationOrder == Enum.RotationOrder.ZYX then
		return toEuler(self, "ZYX")
	end
	error("CFrame64:ToEulerAngles: invalid RotationOrder")
end

function CFrame64:ToEulerAnglesXYZ(): (number, number, number)
	return toEuler(self, "XYZ")
end

function CFrame64:ToEulerAnglesYXZ(): (number, number, number)
	return toEuler(self, "YXZ")
end

function CFrame64:ToOrientation(): (number, number, number)
	return self:ToEulerAnglesYXZ()
end

function CFrame64:ToAxisAngle(): (vector64.Vector3f64, number)
	local x, y, z, w = quaternionOf(matrixOf(self))
	if w < 0 then
		x, y, z, w = -x, -y, -z, -w
	end
	local vectorMagnitude = math.sqrt(x * x + y * y + z * z)
	if vectorMagnitude < 1e-12 then
		return vector64.xAxis, 0
	end
	return vector64.new(x / vectorMagnitude, y / vectorMagnitude, z / vectorMagnitude), 2 * math.atan2(vectorMagnitude, w)
end

function CFrame64:FuzzyEq(other: CFrameInput, epsilon: number?): boolean
	local tolerance = if epsilon == nil then 1e-5 else epsilon
	local own = {self:GetComponents()}
	local theirs: {number} = {other:GetComponents()}
	for i = 1, 12 do
		if math.abs(own[i] - theirs[i]) > tolerance then
			return false
		end
	end
	return true
end

function CFrame64:AngleBetween(other: CFrameInput): number
	local relative = self:Inverse() * other
	local m = matrixOf(relative)
	return math.acos(math.clamp((m[1] + m[5] + m[9] - 1) * 0.5, -1, 1))
end

local function isCFrame(value: any): boolean
	return typeof(value) == "CFrame" or (type(value) == "table" and getmetatable(value) == CFrame64)
end

CFrame64.__mul = function(left: CFrame64, right: any): any
	if isCFrame(right) then
		local ax, ay, az = positionOf(left)
		local bx, by, bz = positionOf(right)
		local leftRotation = matrixOf(left)
		local rightRotation = matrixInput(right)
		local dx, dy, dz = transform(leftRotation, bx, by, bz)
		return make(ax + dx, ay + dy, az + dz, multiply(leftRotation, rightRotation))
	end
	local x, y, z = vectorComponents(right)
	local tx, ty, tz = transform(matrixOf(left), x, y, z)
	return vector64.new(tx + left._px, ty + left._py, tz + left._pz)
end

CFrame64.__add = function(left: CFrame64, right: vector64.Vector3Input): CFrame64
	local x, y, z = vectorComponents(right)
	return make(left._px + x, left._py + y, left._pz + z, matrixOf(left))
end

CFrame64.__sub = function(left: CFrame64, right: vector64.Vector3Input): CFrame64
	local x, y, z = vectorComponents(right)
	return make(left._px - x, left._py - y, left._pz - z, matrixOf(left))
end

CFrame64.__eq = function(left: CFrame64, right: any): boolean
	if not isCFrame(right) then
		return false
	end
	return left:FuzzyEq(right, 0)
end

CFrame64.__tostring = function(value: CFrame64): string
	return string.format("CFrame64(%.17g, %.17g, %.17g)", value._px, value._py, value._pz)
end

setmetatable(CFrame64, {
	__index = function(_self, key: string): any
		if key == "identity" then
			return make(0, 0, 0, identityRotation())
		end
		return nil
	end,
})

return table.freeze(CFrame64)

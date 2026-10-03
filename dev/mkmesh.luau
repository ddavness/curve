--!strict
local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Curve = require(ReplicatedStorage.curve)

local WIDTH = 40
local VOLUME = Vector3.new(0, -4, 0)

local function mkmeshsegment(points: {CFrame}): MeshPart
    local em = AssetService:CreateEditableMesh()
    local vtl, vtr, vbl, vbr
    for seq, p in pairs(points) do
        local tl = p.Position - (p.RightVector.Unit * WIDTH)
        local tr = p.Position + (p.RightVector.Unit * WIDTH)
        local bl, br = tl + VOLUME, tr + VOLUME
        local ctl, ctr = em:AddVertex(tl), em:AddVertex(tr)
        local cbl, cbr = em:AddVertex(bl), em:AddVertex(br)

        if seq ~= 1 then
            -- We can make triangles now
            -- Top
            em:AddTriangle(vtl, vtr, ctr)
            em:AddTriangle(vtl, ctr, ctl)

            -- Bottom
            em:AddTriangle(cbl, cbr, vbr)
            em:AddTriangle(cbl, vbr, vbl)

            -- Left Side
            em:AddTriangle(vbl, vtl, ctl)
            em:AddTriangle(vbl, ctl, cbl)

            -- Right Side
            em:AddTriangle(vbr, ctr, vtr)
            em:AddTriangle(vbr, cbr, ctr)
        end

        if seq == 1 then
            em:AddTriangle(cbl, cbr, ctr)
            em:AddTriangle(cbl, ctr, ctl)
        elseif seq == #points then
            em:AddTriangle(cbl, ctl, ctr)
            em:AddTriangle(cbl, ctr, cbr)
        end

        vtl = ctl
        vtr = ctr
        vbl = cbl
        vbr = cbr
    end

    local mp = AssetService:CreateMeshPartAsync(Content.fromObject(em), {
        CollisionFidelity = Enum.CollisionFidelity.Default
    })
    mp.Anchored = true
    return mp
end

local function mkdtmarker(p: Vector3, v: Vector3, factor: number): Part?
    local adpM = v.Magnitude * factor
    if adpM < 0.01 then
        return nil
    end
    local part = Instance.new("Part")
    part.Anchored = true
    part.Material = Enum.Material.Neon
    part.Size = Vector3.new(1, 1, adpM)
    part.CFrame = CFrame.lookAlong(p, v.Unit) * CFrame.new(0, 0, -adpM * 0.5)
    return part
end

local function derivatives(curve: Curve.Curve3, pts: number): Model
    local m = Instance.new("Model")
    local l: number = curve:lengthAt(1)
    for i = 0, pts do
        local cf: CFrame = curve:locationAt(i/pts):toCFrame()
        local p: Vector3 = cf.Position
        local d1: Vector3 = curve:d1t(i/pts):toVector3() -- Velocity
        local d2: Vector3 = curve:d2t(i/pts):toVector3() -- Acceleration (all components)
        local proj = cf.RightVector
        local d2o: Vector3 = proj * (d2:Dot(proj) / proj:Dot(proj)) -- Lateral acceleration
        local p1 = mkdtmarker(p, d1, 2^-3)
        if p1 then
            p1.Color = Color3.new(0, 0, 1)
            p1.Parent = m
        end
        local p2 = mkdtmarker(p, d2, 2^-5)
        if p2 then
            p2.Color = Color3.new(1, 0.8, 0.8)
            p2.Parent = m
            p2.Transparency = 0.75
        end
        local relative = d2o * (1 / (d1.Magnitude * l))
        local p2o = mkdtmarker(p, relative, 4096)
        if p2o then
            p2o.Color = Color3.new(1, 0, 0)
            p2o.Parent = m
        end
    end
    return m
end

return {
    frompointcloud = mkmeshsegment,
    derivatives = derivatives
}

--!strict

local WIDTH = 40
local VOLUME = Vector3.new(0, -4, 0)

local function mkmeshsegment(points: {CFrame}): MeshPart
    local mp = Instance.new("MeshPart")
    local em = Instance.new("EditableMesh")
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

    em.Parent = mp
    mp.Anchored = true
    mp.Size = Vector3.new(1, 1, 1)
    return mp
end

return {
    frompointcloud = mkmeshsegment
}

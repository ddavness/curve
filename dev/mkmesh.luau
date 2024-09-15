--!strict

local WIDTH = 40

local function mkmeshsegment(points: {CFrame}): MeshPart
    local mp = Instance.new("MeshPart")
    local em = Instance.new("EditableMesh")
    local index = {}
    for seq, p in pairs(points) do
        local vl = p.Position + (p.RightVector.Unit * WIDTH)
        local vr = p.Position - (p.RightVector.Unit * WIDTH)
        local cl, cr = em:AddVertex(vl), em:AddVertex(vr)
        index[2 * seq - 1] = cl
        index[2 * seq] = cr

        if seq ~= 1 then
            -- We can make triangles now
            local pl = index[2 * seq - 3]
            local pr = index[2 * seq - 2]
            em:AddTriangle(pl, pr, cr)
            em:AddTriangle(pl, cr, cl)
        end
    end

    em.Parent = mp
    mp.Anchored = true
    mp.Size = Vector3.new(1, 1, 1)
    return mp
end

return {
    frompointcloud = mkmeshsegment
}

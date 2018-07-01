module Epochs2

using ..TimeScales

export Epoch2

struct Epoch2{S, T}
    epoch::Int64
    offset::T
    Epoch2{S}(epoch, offset::T) where {S, T} = new{S::TimeScale, T}(epoch, offset)
end

function Epoch2{S}(epoch, offset, Δt) where S
    sum = offset + Δt

    if !isfinite(sum)
        offset′ = sum
        epoch′ = sum < 0 ? typemin(Int64) : typemax(Int64)
    else
        o′ = sum - Δt
        d′ = sum - o′
        Δ0 = offset - o′
        Δd = Δt - d′
        residual = Δ0 + Δd
        dl = floor(Int64, sum)
        offset′ = (sum - dl) + residual
        epoch′ = epoch + dl
    end

    Epoch2{S}(epoch′, offset′)
end

Epoch2{S}(ep::Epoch2{S}, Δt) where {S} = Epoch2{S}(ep.epoch, ep.offset, Δt)

end
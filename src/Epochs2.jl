module Epochs2

using LeapSeconds: offset_tai_utc
using EarthOrientation: getΔUT1
using Dates: DateTime, datetime2julian

using ..TimeScales

export Epoch2

const OFFSET_TAI_TT = 32.184
const SECONDS_PER_DAY = 86400.0
const J2000_EPOCH = datetime2julian(DateTime(2000, 1, 1, 12, 0, 0)) * SECONDS_PER_DAY
const REF_EPOCH = datetime2julian(DateTime(1977, 1, 1)) * SECONDS_PER_DAY
const LG_RATE = 6.969290134e-10
const LB_RATE = 1.550519768e-8

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

function Epoch2{S2}(ep::Epoch2{S1}) where {S1, S2}
    Δt = offset(S2, ep) - offset(S1, ep)
    Epoch2{S2}(ep.epoch, ep.offset, Δt)
end

julian(ep::Epoch2) = (ep.epoch + ep.offset) / SECONDS_PER_DAY

offset(::InternationalAtomicTime, ep) = 0.0
offset(::TerrestrialTime, ep) = OFFSET_TAI_TT
offset(::CoordinatedUniversalTime, ep) = offset_tai_utc(julian(ep))
offset(::UniversalTime, ep) = offset(UTC, ep) + getΔUT1(julian(ep))
offset(::GeocentricCoordinateTime, ep) = offset(TT, ep) + LG_RATE * (ep.epoch - REF_EPOCH + ep.offset)
offset(::BarycentricCoordinateTime, ep) = offset(TT, ep) + LB_RATE * (ep.epoch - REF_EPOCH + ep.offset)
function offset(::BarycentricDynamicalTime, ep)
    dt = (ep.epoch - J2000 + ep.offset) / SECONDS_PER_DAY
    g = 357.53 + 0.9856003dt
    offset(TT, ep) + 0.001658sind(g) + 0.000014sind(2g)
end

end

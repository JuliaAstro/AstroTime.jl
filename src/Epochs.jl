module Epochs

using LeapSeconds: offset_tai_utc
using EarthOrientation: getΔUT1

import Base: -, +, <, ==, isapprox
import Dates

using ..TimeScales
using ..AstroDates
using ..Periods

export Epoch, -, julian, j2000,
    JULIAN_EPOCH, J2000_EPOCH, MODIFIED_JULIAN_EPOCH, FIFTIES_EPOCH,
    GALILEO_EPOCH, GPS_EPOCH, CCSDS_EPOCH

const OFFSET_TAI_TT = 32.184
const LG_RATE = 6.969290134e-10
const LB_RATE = 1.550519768e-8

struct Epoch{S, T}
    epoch::Int64
    offset::T
    Epoch{S}(epoch::Int64, offset::T) where {S, T} = new{S::TimeScale, T}(epoch, offset)
end

function Epoch{S}(epoch::Int64, offset, Δt) where S
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

    Epoch{S}(epoch′, offset′)
end

function Epoch{S}(date::Date, time::Time) where S
    seconds = second(time)
    ts_offset = tai_offset(S, date, time)

    sum = seconds + ts_offset
    s′ = sum - ts_offset
    t′ = sum - s′
    Δs = seconds  - s′
    Δt = ts_offset - t′
    residual = Δs + Δt
    dl = floor(Int64, sum)

    offset = (sum - dl) + residual
    epoch  = Int64(60) * ((j2000day(date) * Int64(24) + hour(time)) * Int64(60)
                          + minute(time) - Int64(720)) + dl
    Epoch{S}(epoch, offset)
end

function Epoch{S}(year::Int, month::Int, day::Int, hour::Int=0, minute::Int=0, second::Float64=0.0) where S
    Epoch{S}(Date(year, month, day), Time(hour, minute, second))
end

Epoch{S}(ep::Epoch{S}, Δt) where {S} = Epoch{S}(ep.epoch, ep.offset, Δt)

function Epoch{S2}(ep::Epoch{S1}) where {S1, S2}
    Δt = tai_offset(S2, ep) - tai_offset(S1, ep)
    Epoch{S2}(ep.epoch, ep.offset, Δt)
end

julian(ep::Epoch) = get(days(ep - JULIAN_EPOCH))
j2000(ep::Epoch) = get(days(ep - J2000_EPOCH))

tai_offset(::InternationalAtomicTime, ep) = 0.0
tai_offset(::TerrestrialTime, ep) = OFFSET_TAI_TT
tai_offset(::CoordinatedUniversalTime, ep) = offset_tai_utc(julian(ep))
tai_offset(::UniversalTime, ep) = tai_offset(UTC, ep) + getΔUT1(julian(ep))
tai_offset(::GeocentricCoordinateTime, ep) = tai_offset(TT, ep) + LG_RATE * get(ep - EPOCH_77)
tai_offset(::BarycentricCoordinateTime, ep) = tai_offset(TT, ep) + LB_RATE * get(ep - EPOCH_77)
function tai_offset(::BarycentricDynamicalTime, ep)
    dt = get(days(ep - J2000_EPOCH))
    g = 357.53 + 0.9856003dt
    tai_offset(TT, ep) + 0.001658sind(g) + 0.000014sind(2g)
end

tai_offset(ep::Epoch{S}) where {S} = tai_offset(S, ep)

tai_offset(::InternationalAtomicTime, date, time) = 0.0

function tai_offset(scale, date, time)
    ref = Epoch{TAI}(date, time)
    offset = 0.0
    for _ in 1:8
        offset = -tai_offset(scale, Epoch{TAI}(ref, offset))
    end
    offset
end

function isapprox(a::Epoch, b::Epoch)
    a.epoch == b.epoch && a.offset ≈ b.offset
end

function ==(a::Epoch, b::Epoch)
    a.epoch == b.epoch && a.offset == b.offset
end

<(ep1::Epoch{T}, ep2::Epoch{T}) where {T} = get(ep1 - ep2) < 0.0

+(ep::Epoch{S}, p::Period) where {S} = Epoch{S}(ep, get(seconds(p)))
-(ep::Epoch{S}, p::Period) where {S} = Epoch{S}(ep, -get(seconds(p)))
-(a::Epoch, b::Epoch) = ((a.epoch - b.epoch) + (a.offset - b.offset)) * seconds

const JULIAN_EPOCH = Epoch{TT}(AstroDates.JULIAN_EPOCH, AstroDates.H12)
const J2000_EPOCH = Epoch{TT}(AstroDates.J2000_EPOCH, AstroDates.H12)
const EPOCH_77 = Epoch{TAI}(1977, 1, 1)
const MODIFIED_JULIAN_EPOCH = Epoch{TT}(AstroDates.MODIFIED_JULIAN_EPOCH, AstroDates.H00)
const FIFTIES_EPOCH = Epoch{TT}(AstroDates.FIFTIES_EPOCH, AstroDates.H00)
const CCSDS_EPOCH = Epoch{TT}(AstroDates.CCSDS_EPOCH, AstroDates.H00)
const GALILEO_EPOCH = Epoch{TT}(AstroDates.GALILEO_EPOCH, AstroDates.H00)
const GPS_EPOCH = Epoch{TT}(AstroDates.GPS_EPOCH, AstroDates.H00)

end

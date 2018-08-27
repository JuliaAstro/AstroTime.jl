module Epochs

using LeapSeconds: offset_tai_utc
using EarthOrientation: getΔUT1

import Base: -, +, <, ==, isapprox, isless, show
import Dates
import Dates: format, parse

import ..AstroDates: julian, j2000, julian_split

using ..TimeScales
using ..AstroDates
using ..Periods

const J2000_TO_JULIAN = 2.451545e6
const J2000_TO_MJD = 51544.5

export Epoch,
    JULIAN_EPOCH, J2000_EPOCH, MODIFIED_JULIAN_EPOCH,
    FIFTIES_EPOCH, GALILEO_EPOCH, GPS_EPOCH, CCSDS_EPOCH,
    PAST_INFINITY, FUTURE_INFINITY, UNIX_EPOCH,
    julian, j2000, julian_split, modified_julian

struct Epoch{S, T} <: Dates.AbstractDateTime
    epoch::Int64
    offset::T
    Epoch{S}(epoch::Int64, offset::T) where {S, T} = new{S::TimeScale, T}(epoch, offset)
end

for scale in TimeScales.ACRONYMS
    epoch = Symbol(scale, "Epoch")
    @eval begin
        const $epoch = Epoch{$scale}
        export $epoch
    end
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

Epoch{S}(ep::Epoch, Δt) where {S} = Epoch{S}(ep.epoch, ep.offset, Δt)

function j2000(scale, ep::Epoch)
    (ep.offset + tai_offset(scale, ep) + ep.epoch) / SECONDS_PER_DAY
end
julian(scale, ep::Epoch) = j2000(scale, ep) + J2000_TO_JULIAN
modified_julian(scale, ep::Epoch) = j2000(scale, ep) + J2000_TO_MJD

function julian_split(scale, ep::Epoch)
    jd = julian(scale, ep)
    jd1 = trunc(jd)
    jd2 = jd - jd1
    jd1, jd2
end

j2000(ep::Epoch{S}) where {S} = j2000(S, ep)
julian(ep::Epoch{S}) where {S} = julian(S, ep)
modified_julian(ep::Epoch{S}) where {S} = modified_julian(S, ep)
julian_split(ep::Epoch{S}) where {S} = julian_split(S, ep)

include("offsets.jl")
include("accessors.jl")

show(io::IO, ep::Epoch{S}) where {S} = print(io, DateTime(ep), " ", S)

function Epoch{S}(date::Date, time::Time) where S
    seconds = second(Float64, time)
    ts_offset = tai_offset(S, date, time)

    sum = seconds + ts_offset
    s′ = sum - ts_offset
    t′ = sum - s′
    Δs = seconds  - s′
    Δt = ts_offset - t′
    residual = Δs + Δt
    dl = floor(Int64, sum)

    offset = (sum - dl) + residual
    epoch  = Int64(60) * ((j2000(date) * Int64(24) + hour(time)) * Int64(60)
                          + minute(time) - Int64(720)) + dl
    Epoch{S}(epoch, offset)
end

Epoch(str::AbstractString, df::Dates.DateFormat=ISOEpochFormat) = parse(Epoch, str, df)

Epoch(str::AbstractString, format::AbstractString) = Epoch(str, Dates.DateFormat(format))

Epoch{S}(str::AbstractString,
         df::Dates.DateFormat=Dates.default_format(Epoch{S})) where {S} = parse(Epoch{S}, str, df)

Epoch{S}(str::AbstractString, format::AbstractString) where {S} = Epoch{S}(str, Dates.DateFormat(format))

Epoch{S}(d::Date) where {S} = Epoch{S}(d, AstroDates.H00)

Epoch{S}(dt::DateTime) where {S} = Epoch{S}(date(dt), time(dt))

function Epoch{S}(year::Int, month::Int, day::Int, hour::Int=0,
                  minute::Int=0, second::Float64=0.0) where S
    Epoch{S}(Date(year, month, day), Time(hour, minute, second))
end

function Epoch{S}(year::Int, month::Int, day::Int, hour::Int,
                  minute::Int, second::Int, milliseconds::Int) where S
    Epoch{S}(Date(year, month, day), Time(hour, minute, second + 1e-3milliseconds))
end

function Epoch(year::Int, month::Int, day::Int, hour::Int,
               minute::Int, second::Int, milliseconds::Int,
               scale::S) where S<:TimeScale
    Epoch{scale}(Date(year, month, day), Time(hour, minute, second + 1e-3milliseconds))
end

Epoch{S2}(ep::Epoch{S1}) where {S1, S2} = Epoch{S2}(ep.epoch, ep.offset)

function isapprox(a::Epoch, b::Epoch)
    a.epoch == b.epoch && a.offset ≈ b.offset
end

function ==(a::Epoch, b::Epoch)
    a.epoch == b.epoch && a.offset == b.offset
end

<(ep1::Epoch, ep2::Epoch) = get(ep1 - ep2) < 0.0
isless(ep1::Epoch, ep2::Epoch) = isless(get(ep1 - ep2), 0.0)

+(ep::Epoch{S}, p::Period) where {S} = Epoch{S}(ep, get(seconds(p)))
-(ep::Epoch{S}, p::Period) where {S} = Epoch{S}(ep, -get(seconds(p)))
-(a::Epoch, b::Epoch) = ((a.epoch - b.epoch) + (a.offset - b.offset)) * seconds

include("leapseconds.jl")

const JULIAN_EPOCH = TTEpoch(AstroDates.JULIAN_EPOCH, AstroDates.H12)
const J2000_EPOCH = TTEpoch(AstroDates.J2000_EPOCH, AstroDates.H12)
const MODIFIED_JULIAN_EPOCH = TTEpoch(AstroDates.MODIFIED_JULIAN_EPOCH, AstroDates.H00)
const FIFTIES_EPOCH = TTEpoch(AstroDates.FIFTIES_EPOCH, AstroDates.H00)
const CCSDS_EPOCH = TTEpoch(AstroDates.CCSDS_EPOCH, AstroDates.H00)
const GALILEO_EPOCH = TTEpoch(AstroDates.GALILEO_EPOCH, AstroDates.H00)
const GPS_EPOCH = TTEpoch(AstroDates.GPS_EPOCH, AstroDates.H00)
const UNIX_EPOCH = TAIEpoch(AstroDates.UNIX_EPOCH, Time(0, 0, 10.0))

const PAST_INFINITY = TAIEpoch(UNIX_EPOCH, -Inf)
const FUTURE_INFINITY = TAIEpoch(UNIX_EPOCH, Inf)

const EPOCH_77 = TAIEpoch(1977, 1, 1)

function Dates.validargs(::Type{Epoch}, y::Int64, m::Int64, d::Int64,
                         h::Int64, mi::Int64, s::Int64, ms::Int64, ts::S) where S<:TimeScale
    err = Dates.validargs(Dates.DateTime, y, m, d, h, mi, s, ms)
    err !== nothing || return err
    return Dates.argerror()
end

function Dates.format(io, d::Dates.DatePart{'t'}, ep)
    print(io, timescale(ep))
end

end

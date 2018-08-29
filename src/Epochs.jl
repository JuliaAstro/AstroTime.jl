module Epochs

using EarthOrientation: getΔUT1
using LeapSeconds: offset_tai_utc

import Base: -, +, <, ==, isapprox, isless, show
import Dates
import Dates: format, parse

import ..AstroDates:
    Date,
    DateTime,
    Time,
    calendar,
    date,
    day,
    dayofyear,
    fractionofday,
    hour,
    j2000,
    julian,
    julian_split,
    millisecond,
    minute,
    month,
    second,
    secondinday,
    time,
    year,
    yearmonthday

export Epoch,
    CCSDS_EPOCH,
    FIFTIES_EPOCH,
    FUTURE_INFINITY,
    GALILEO_EPOCH,
    GPS_EPOCH,
    J2000_EPOCH,
    JULIAN_EPOCH,
    MODIFIED_JULIAN_EPOCH,
    PAST_INFINITY,
    UNIX_EPOCH,
    date,
    day,
    dayofyear,
    fractionofday,
    hour,
    j2000,
    julian,
    julian_split,
    millisecond,
    minute,
    modified_julian,
    month,
    now,
    second,
    secondinday,
    time,
    year,
    yearmonthday

using ..TimeScales
using ..AstroDates
using ..Periods

const J2000_TO_JULIAN = 2.451545e6
const J2000_TO_MJD = 51544.5

struct Epoch{S, T} <: Dates.AbstractDateTime
    epoch::Int64
    offset::T
    ts_offset::T
    function Epoch{S}(epoch::Int64, offset::T, ts_offset::T) where {S, T}
        new{S::TimeScale, T}(epoch, offset, ts_offset)
    end
end

function Epoch{S}(epoch::Int64, offset, ts_offset, Δt) where S
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

    Epoch{S}(epoch′, offset′, ts_offset)
end

"""
    Epoch{S}(jd1::T, jd2::T=zero(T); origin=:j2000) where {S, T}

Construct an `Epoch` with time scale `S` from a Julian date
(optionally split into `jd1` and `jd2`).
"""
function Epoch{S}(jd1::T, jd2::T=zero(T); origin=:j2000) where {S, T}
    if jd2 > jd1
        jd1, jd2 = jd2, jd1
    end

    if origin == :j2000
        # pass
    elseif origin == :julian
        jd1 -= J2000_TO_JULIAN
    elseif origin == :mjd
        jd1 -= J2000_TO_MJD
    else
        throw(ArgumentError("Unknown Julian epoch: $epoch"))
    end

    jd1 *= SECONDS_PER_DAY
    jd2 *= SECONDS_PER_DAY

    sum = jd1 + jd2

    o′ = sum - jd2
    d′ = sum - o′
    Δ0 = jd1 - o′
    Δd = jd2 - d′
    residual = Δ0 + Δd
    epoch = floor(Int64, sum)
    offset = (sum - epoch) + residual

    ftype = float(T)
    tai = Epoch{TAI}(epoch, ftype(offset), zero(ftype))
    ts_offset = tai_offset(S, tai)
    ep = Epoch{TAI}(tai, -ts_offset)
    Epoch{S}(ep.epoch, ep.offset, ts_offset)
end

"""
    Epoch{S}(ep::Epoch{S}, Δt) where S

Construct a new `Epoch` with time scale `S` which is `ep` shifted by `Δt`
seconds.

### Example ###

```jldoctest
julia> ep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)
2018-02-06T20:45:00.000 UTC

julia> UTCEpoch(ep, 20.0)
2018-02-06T20:45:20.000 UTC
```
"""
Epoch{S}(ep::Epoch{S}, Δt) where {S} = Epoch{S}(ep.epoch, ep.offset, ep.ts_offset, Δt)

function j2000(ep::Epoch, tai_offset)
    (ep.offset + tai_offset + ep.epoch) / SECONDS_PER_DAY
end
julian(ep::Epoch, tai_offset) = j2000(ep, tai_offset) + J2000_TO_JULIAN
modified_julian(ep::Epoch, tai_offset) = j2000(ep, tai_offset) + J2000_TO_MJD

function julian_split(ep::Epoch, tai_offset)
    jd = julian(ep, tai_offset)
    jd1 = trunc(jd)
    jd2 = jd - jd1
    jd1, jd2
end

j2000(ep::Epoch) = j2000(ep, ep.ts_offset)
julian(ep::Epoch) = julian(ep, ep.ts_offset)
modified_julian(ep::Epoch) = modified_julian(ep, ep.ts_offset)
julian_split(ep::Epoch) = julian_split(ep, ep.ts_offset)

j2000(scale, ep::Epoch) = j2000(ep, tai_offset(scale, ep))
julian(scale, ep::Epoch) = julian(ep, tai_offset(scale, ep))
modified_julian(scale, ep::Epoch) = modified_julian(ep, tai_offset(scale, ep))
julian_split(scale, ep::Epoch) = julian_split(ep, tai_offset(scale, ep))

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
    from_tai = tai_offset(S, Epoch{TAI}(epoch, offset, 0.0))
    Epoch{S}(epoch, offset, from_tai)
end

Epoch(str::AbstractString, format::Dates.DateFormat=ISOEpochFormat) = parse(Epoch, str, format)

Epoch(str::AbstractString, format::AbstractString) = Epoch(str, Dates.DateFormat(format))

Epoch{S}(str::AbstractString,
         format::Dates.DateFormat=Dates.default_format(Epoch{S})) where {S} = parse(Epoch{S}, str, format)

Epoch{S}(str::AbstractString, format::AbstractString) where {S} = Epoch{S}(str, Dates.DateFormat(format))

Epoch{S}(d::Date) where {S} = Epoch{S}(d, AstroDates.H00)

Epoch{S}(dt::DateTime) where {S} = Epoch{S}(date(dt), time(dt))
Epoch{S}(dt::Dates.DateTime) where {S} = Epoch{S}(DateTime(dt))

"""
    now()

Get the current date and time as a `UTCEpoch`.
"""
now() = UTCEpoch(Dates.now())

function Epoch{S}(year::Int, month::Int, day::Int, hour::Int=0,
                  minute::Int=0, second::Float64=0.0) where S
    Epoch{S}(Date(year, month, day), Time(hour, minute, second))
end

function Epoch{S}(year::Int, month::Int, day::Int, dayofyear::Int,
                  hour::Int, minute::Int, second::Int, milliseconds::Int) where S
    if dayofyear != 0
        date = Date(year, dayofyear)
    else
        date = Date(year, month, day)
    end
    Epoch{S}(date, Time(hour, minute, second + 1e-3milliseconds))
end

function Epoch(year::Int, month::Int, day::Int, dayofyear::Int,
               hour::Int, minute::Int, second::Int, milliseconds::Int,
               scale::S) where S<:TimeScale
    if dayofyear != 0
        date = Date(year, dayofyear)
    else
        date = Date(year, month, day)
    end
    Epoch{scale}(date, Time(hour, minute, second + 1e-3milliseconds))
end

function Epoch{S2}(ep::Epoch{S1}, ts_offset) where {S1, S2}
    Epoch{S2}(ep.epoch, ep.offset, ts_offset)
end

function Epoch{S2}(ep::Epoch{S1}) where {S1, S2}
    Epoch{S2}(ep.epoch, ep.offset, tai_offset(S2, ep))
end

Epoch{S, T}(ep::Epoch{S, T}) where {S, T} = ep

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

for scale in TimeScales.ACRONYMS
    epoch = Symbol(scale, "Epoch")
    @eval begin
        const $epoch = Epoch{$scale}
        export $epoch

        @doc @doc(Epoch{$scale}) $epoch
    end
end

function TDBEpoch(ep::TTEpoch, ut, elong, u, v)
    offset = tai_offset(TDB, ep, ut, elong, u, v)
    TDBEpoch(ep, offset)
end

function TTEpoch(ep::TDBEpoch, ut, elong, u, v)
    offset = tai_offset(TDB, ep, ut, elong, u, v)
    TTEpoch(ep, offset)
end

include("leapseconds.jl")
include("range.jl")

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

abstract type DayOfYearToken end

@inline function Dates.tryparsenext(d::Dates.DatePart{'D'}, str, i, len, locale)
    next = Dates.tryparsenext_base10(str, i, len, 1, 3)
    next === nothing && return nothing
    val, i = next
    (val >= 1 && val <= 366) || throw(ArgumentError("Day number must be within 1 and 366."))
    return val, i
end

function Dates.format(io, d::Dates.DatePart{'D'}, ep)
    print(io, dayofyear(ep))
end

function Dates.format(io, d::Dates.DatePart{'t'}, ep)
    print(io, timescale(ep))
end

end

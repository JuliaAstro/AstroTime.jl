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
    julian_twopart,
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
    julian_twopart,
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

const J2000_TO_JULIAN = 2.451545e6days
const J2000_TO_MJD = 51544.5days

@inline function two_sum(a, b)
    hi = a + b
    a1 = hi - b
    b1 = hi - a1
    lo = (a - a1) + (b - b1)
    hi, lo
end

struct Epoch{S, T} <: Dates.AbstractDateTime
    epoch::Int64
    offset::T
    ts_offset::T
    function Epoch{S}(epoch::Int64, offset::T, ts_offset::T) where {S, T}
        new{S::TimeScale, T}(epoch, offset, ts_offset)
    end
end

function Epoch{S}(epoch::Int64, offset, ts_offset, Δt) where S
    sum, residual = two_sum(offset, Δt)

    if !isfinite(sum)
        offset′ = sum
        epoch′ = sum < 0 ? typemin(Int64) : typemax(Int64)
    else
        dl = floor(Int64, sum)
        offset′ = (sum - dl) + residual
        epoch′ = epoch + dl
    end

    Epoch{S}(epoch′, offset′, ts_offset)
end

"""
    Epoch{S}(jd1::T, jd2::T=zero(T); origin=:j2000) where {S, T}

Construct an `Epoch` with time scale `S` from a Julian date
(optionally split into `jd1` and `jd2`). `origin` determines the
variant of Julian date that is used. Possible values are:

- `:j2000`: J2000 Julian date, starts at 2000-01-01T12:00
- `:julian`: Julian date, starts at -4712-01-01T12:00
- `:modified_julian`: Modified Julian date, starts at 1858-11-17T00:00

### Examples ###

```jldoctest
julia> Epoch{UTC}(0.0, 0.5)
2000-01-02T00:00:00.000 UTC

julia> Epoch{UTC}(2.451545e6, origin=:julian)
2000-01-01T12:00:00.000 UTC
```
"""
function Epoch{S}(jd1::T, jd2::T=zero(T), args...; origin=:j2000) where {S, T<:Number}
    if jd2 > jd1
        jd1, jd2 = jd2, jd1
    end

    if origin == :j2000
        # pass
    elseif origin == :julian
        jd1 -= value(J2000_TO_JULIAN)
    elseif origin == :modified_julian
        jd1 -= value(J2000_TO_MJD)
    else
        throw(ArgumentError("Unknown Julian epoch: $origin"))
    end

    jd1 *= SECONDS_PER_DAY
    jd2 *= SECONDS_PER_DAY

    sum, residual = two_sum(jd1, jd2)
    epoch = floor(Int64, sum)
    offset = (sum - epoch) + residual

    ftype = float(T)
    tai = Epoch{TAI}(epoch, ftype(offset), zero(ftype))
    ts_offset = tai_offset(S, tai, args...)
    ep = Epoch{TAI}(tai, -ts_offset)
    Epoch{S}(ep.epoch, ep.offset, ts_offset)
end

Epoch{S}(ep::Epoch{S}, Δt) where {S} = Epoch{S}(ep.epoch, ep.offset, ep.ts_offset, Δt)

function j2000(ep::Epoch, tai_offset)
    (ep.offset + tai_offset + ep.epoch) / SECONDS_PER_DAY * days
end
julian(ep::Epoch, tai_offset) = j2000(ep, tai_offset) + J2000_TO_JULIAN
modified_julian(ep::Epoch, tai_offset) = j2000(ep, tai_offset) + J2000_TO_MJD

function julian_twopart(ep::Epoch, tai_offset)
    jd = value(julian(ep, tai_offset))
    jd1 = trunc(jd)
    jd2 = jd - jd1
    (jd1 * days, jd2 * days)
end

"""
    j2000(ep)

Returns the J2000 Julian date for epoch `ep`.

### Example ###

```jldoctest
julia> j2000(UTCEpoch(2000, 1, 1, 12))
0.0 days
```
"""
j2000(ep::Epoch) = j2000(ep, ep.ts_offset)

"""
    julian(ep)

Returns the Julian Date for epoch `ep`.

### Example ###

```jldoctest
julia> julian(UTCEpoch(2000, 1, 1, 12))
2.451545e6 days
```
"""
julian(ep::Epoch) = julian(ep, ep.ts_offset)

"""
    modified_julian(ep)

Returns the Modified Julian Date for epoch `ep`.

### Example ###

```jldoctest
julia> modified_julian(UTCEpoch(2000, 1, 1, 12))
51544.5 days
```
"""
modified_julian(ep::Epoch) = modified_julian(ep, ep.ts_offset)

"""
    julian_twopart(ep)

Returns the two-part Julian date for epoch `ep`, which is a tuple consisting
of the Julian day number and the fraction of the day.

### Example ###

```jldoctest
julia> julian_twopart(UTCEpoch(2000, 1, 2))
(2.451545e6 days, 0.5 days)
```
"""
julian_twopart(ep::Epoch) = julian_twopart(ep, ep.ts_offset)

"""
    j2000(scale, ep)

Returns the J2000 Julian date for epoch `ep` within a specific time `scale`.

### Example ###

```jldoctest
julia> j2000(TAI, TTEpoch(2000, 1, 1, 12, 0, 32.184))
0.0 days
```
"""
j2000(scale, ep::Epoch) = j2000(ep, tai_offset(scale, ep))

"""
    julian(scale, ep)

Returns the Julian Date for epoch `ep` within a specific time `scale`.

### Example ###

```jldoctest
julia> julian(TAI, TTEpoch(2000, 1, 1, 12, 0, 32.184))
2.451545e6 days
```
"""
julian(scale, ep::Epoch) = julian(ep, tai_offset(scale, ep))

"""
    modified_julian(scale, ep)

Returns the Modified Julian Date for epoch `ep` within a specific time `scale`.

### Example ###

```jldoctest
julia> modified_julian(TAI, TTEpoch(2000, 1, 1, 12, 0, 32.184))
51544.5 days
```
"""
modified_julian(scale, ep::Epoch) = modified_julian(ep, tai_offset(scale, ep))

"""
    julian_twopart(scale, ep)

Returns the two-part Julian date for epoch `ep` within a specific time `scale`,
which is a tuple consisting of the Julian day number and the fraction of the day.

### Example ###

```jldoctest
julia> julian_twopart(TAI, TTEpoch(2000, 1, 1, 12, 0, 32.184))
(2.451545e6 days, 0.0 days)
```
"""
julian_twopart(scale, ep::Epoch) = julian_twopart(ep, tai_offset(scale, ep))

include("offsets.jl")
include("accessors.jl")

show(io::IO, ep::Epoch{S}) where {S} = print(io, DateTime(ep), " ", S)

function Epoch{S}(date::Date, time::Time, args...) where S
    seconds = second(Float64, time)
    ts_offset = tai_offset(S, date, time, args...)

    sum, residual = two_sum(seconds, ts_offset)
    dl = floor(Int64, sum)

    offset = (sum - dl) + residual
    epoch  = Int64(60) * ((j2000(date) * Int64(24) + hour(time)) * Int64(60)
                          + minute(time) - Int64(720)) + dl
    from_tai = tai_offset(S, Epoch{TAI}(epoch, offset, 0.0), args...)
    Epoch{S}(epoch, offset, from_tai)
end

Dates.default_format(::Type{Epoch}) = Dates.DateFormat("yyyy-mm-ddTHH:MM:SS.sss ttt")

"""
    Epoch(str[, format])

Construct an `Epoch` from a string `str`. Optionally a `format` definition can
be passed as a [`DateFormat`](https://docs.julialang.org/en/stable/stdlib/Dates/#Dates.DateFormat)
object or as a string. In addition to the character codes supported by `DateFormat` the character
code `D` is supported which is parsed as "day of year" (see the example below) and the character
code `t` which is parsed as the time scale.  The default format is `yyyy-mm-ddTHH:MM:SS.sss ttt`.

**Note:** Please be aware that this constructor requires that the time scale is part of `str`, e.g.
`2018-02-06T00:00 UTC`. Otherwise use an explicit constructor, e.g. `Epoch{UTC}`.

### Example ###

```jldoctest
julia> Epoch("2018-02-06T20:45:00.0 UTC")
2018-02-06T20:45:00.000 UTC

julia> Epoch("2018-037T00:00 UTC", "yyyy-DDDTHH:MM ttt")
2018-02-06T00:00:00.000 UTC
```
"""
Epoch(str::AbstractString, format::Dates.DateFormat=Dates.default_format(Epoch)) = parse(Epoch, str, format)

Epoch(str::AbstractString, format::AbstractString) = Epoch(str, Dates.DateFormat(format))

Dates.default_format(::Type{Epoch{S}}) where {S} = Dates.ISODateTimeFormat

"""
    Epoch{S}(str[, format]) where S

Construct an `Epoch` with time scale `S` from a string `str`. Optionally a `format` definition can
be passed as a [`DateFormat`](https://docs.julialang.org/en/stable/stdlib/Dates/#Dates.DateFormat)
object or as a string. In addition to the character codes supported by `DateFormat` the code `D` can
be used which is parsed as "day of year" (see the example below).  The default format is
`yyyy-mm-ddTHH:MM:SS.sss`.

### Example ###

```jldoctest
julia> Epoch{UTC}("2018-02-06T20:45:00.0")
2018-02-06T20:45:00.000 UTC

julia> Epoch{UTC}("February 6, 2018", "U d, y")
2018-02-06T00:00:00.000 UTC

julia> Epoch{UTC}("2018-037T00:00", "yyyy-DDDTHH:MM")
2018-02-06T00:00:00.000 UTC
```
"""
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

"""
    Epoch{S}(year, month, day, hour=0, minute=0, second=0.0) where S

Construct an `Epoch` with time scale `S` from date and time components.

### Example ###

```jldoctest
julia> Epoch{UTC}(2018, 2, 6, 20, 45, 0.0)
2018-02-06T20:45:00.000 UTC

julia> Epoch{UTC}(2018, 2, 6)
2018-02-06T00:00:00.000 UTC
```
"""
function Epoch{S}(year::Int, month::Int, day::Int, hour::Int=0,
                  minute::Int=0, second::Float64=0.0, args...) where S
    Epoch{S}(Date(year, month, day), Time(hour, minute, second), args...)
end

function Epoch{S}(year::Int64, month::Int64, day::Int64, dayofyear::Int64,
                  hour::Int64, minute::Int64, second::Int64, milliseconds::Int64) where S
    if dayofyear != 0
        date = Date(year, dayofyear)
    else
        date = Date(year, month, day)
    end
    Epoch{S}(date, Time(hour, minute, second + 1e-3milliseconds))
end

function Epoch(year::Int64, month::Int64, day::Int64, dayofyear::Int64,
               hour::Int64, minute::Int64, second::Int64, milliseconds::Int64,
               scale::S) where S<:TimeScale
    if scale === TimeScales.NotATimeScale()
        throw(ArgumentError("Could not parse the provided string as an `Epoch`." *
                            " No time scale was provided."))
    end

    if dayofyear != 0
        date = Date(year, dayofyear)
    else
        date = Date(year, month, day)
    end
    Epoch{scale}(date, Time(hour, minute, second + 1e-3milliseconds))
end

"""
    Epoch{S}(Δtai, ep::TAIEpoch) where S

Convert `ep`, a `TAIEpoch`, to an `Epoch` with time scale `S` by overriding
the offset between `S2` and `TAI` with `Δtai`.

### Examples ###

```jldoctest
julia> ep = TAIEpoch(2000,1,1)
2000-01-01T00:00:00.000 TAI

julia> TTEpoch(32.184, ep)
2000-01-01T00:00:32.184 TT
```
"""
function Epoch{S}(Δtai, ep::Epoch{TAI}) where S
    Epoch{S}(ep.epoch, ep.offset, Δtai)
end

"""
    Epoch{S2}(ep::Epoch{S1}) where {S1, S2}

Convert `ep`, an `Epoch` with time scale `S1`, to an `Epoch` with time
scale `S2`.

### Examples ###

```jldoctest
julia> ep = TTEpoch(2000,1,1)
2000-01-01T00:00:00.000 TT

julia> TAIEpoch(ep)
1999-12-31T23:59:27.816 TAI
```
"""
function Epoch{S2}(ep::Epoch{S1}, args...) where {S1, S2}
    Epoch{S2}(ep.epoch, ep.offset, tai_offset(S2, ep, args...))
end

Epoch{TAI}(ep::Epoch) = Epoch{TAI}(ep.epoch, ep.offset, 0.0)

Epoch{S, T}(ep::Epoch{S, T}) where {S, T} = ep

function isapprox(a::T, b::T; atol::Real=0, rtol::Real=atol>0 ? 0 : √eps()) where T <: Epoch
    sum_a, residual_a = two_sum(a.ts_offset, a.offset)
    Δep_a = floor(Int64, sum_a)
    epoch_a = a.epoch + Δep_a
    offset_a = (sum_a - Δep_a) + residual_a

    sum_b, residual_b = two_sum(b.ts_offset, b.offset)
    Δep_b = floor(Int64, sum_b)
    epoch_b = b.epoch + Δep_b
    offset_b = (sum_b - Δep_b) + residual_b

    epoch_a == epoch_b && isapprox(offset_a, offset_b; atol=atol, rtol=rtol)
end

function isapprox(a::Epoch, b::Epoch; atol::Real=0, rtol::Real=atol>0 ? 0 : √eps())
    a.epoch == b.epoch && isapprox(a.offset, b.offset; atol=atol, rtol=rtol)
end

function ==(a::Epoch, b::Epoch)
    a.epoch == b.epoch && a.offset == b.offset && a.ts_offset == b.ts_offset
end

<(ep1::Epoch, ep2::Epoch) = value(ep1 - ep2) < 0.0
isless(ep1::Epoch, ep2::Epoch) = isless(value(ep1 - ep2), 0.0)

+(ep::Epoch{S}, p::Period) where {S} = Epoch{S}(ep, value(seconds(p)))
-(ep::Epoch{S}, p::Period) where {S} = Epoch{S}(ep, -value(seconds(p)))

"""
    -(a::Epoch, b::Epoch)

Return the duration between epoch `a` and epoch `b`.

### Examples ###

```jldoctest```
julia> UTCEpoch(2018, 2, 6, 20, 45, 20.0) - UTCEpoch(2018, 2, 6, 20, 45, 0.0)
20.0 seconds
```
"""
function -(a::T, b::T) where T <: Epoch
    sum_a, residual_a = two_sum(a.ts_offset, a.offset)
    Δep_a = floor(Int64, sum_a)
    epoch_a = a.epoch + Δep_a
    offset_a = (sum_a - Δep_a) + residual_a

    sum_b, residual_b = two_sum(b.ts_offset, b.offset)
    Δep_b = floor(Int64, sum_b)
    epoch_b = b.epoch + Δep_b
    offset_b = (sum_b - Δep_b) + residual_b

    ((epoch_a - epoch_b) + (offset_a - offset_b)) * seconds
end

-(a::Epoch, b::Epoch) = ((a.epoch - b.epoch) + (a.offset - b.offset)) * seconds

# Generate aliases for all defined time scales so we can use
# e.g. `TTEpoch` instead of `Epoch{TT}`
for scale in TimeScales.ACRONYMS
    epoch = Symbol(scale, "Epoch")
    name = string(epoch)
    @eval begin
        const $epoch = Epoch{$scale}
        export $epoch

        """
            $($name)(str[, format])

        Construct a $($name) from a string `str`. Optionally a `format` definition can be
        passed as a [`DateFormat`](https://docs.julialang.org/en/stable/stdlib/Dates/#Dates.DateFormat)
        object or as a string. In addition to the character codes supported by `DateFormat`
        the code `D` is supported which is parsed as "day of year" (see the example below).
        The default format is `yyyy-mm-ddTHH:MM:SS.sss`.

        ### Example ###

        ```jldoctest
        julia> $($name)("2018-02-06T20:45:00.0")
        2018-02-06T20:45:00.000 $($scale)

        julia> $($name)("February 6, 2018", "U d, y")
        2018-02-06T00:00:00.000 $($scale)

        julia> $($name)("2018-37T00:00", "yyyy-DDDTHH:MM")
        2018-02-06T00:00:00.000 $($scale)
        ```
        """
        $epoch(::AbstractString)

        """
            $($name)(jd1::T, jd2::T=zero(T); origin=:j2000) where T

        Construct a $($name) from a Julian date (optionally split into
        `jd1` and `jd2`). `origin` determines the variant of Julian
        date that is used. Possible values are:

        - `:j2000`: J2000 Julian date, starts at 2000-01-01T12:00
        - `:julian`: Julian date, starts at -4712-01-01T12:00
        - `:modified_julian`: Modified Julian date, starts at 1858-11-17T00:00

        ### Examples ###

        ```jldoctest
        julia> $($name)(0.0, 0.5)
        2000-01-02T00:00:00.000 $($scale)

        julia> $($name)(2.451545e6, origin=:julian)
        2000-01-01T12:00:00.000 $($scale)
        ```
        """
        $epoch(::Number, ::Number)

        """
            $($name)(year, month, day, hour=0, minute=0, second=0.0)

        Construct a $($name) from date and time components.

        ### Example ###

        ```jldoctest
        julia> $($name)(2018, 2, 6, 20, 45, 0.0)
        2018-02-06T20:45:00.000 $($scale)

        julia> $($name)(2018, 2, 6)
        2018-02-06T00:00:00.000 $($scale)
        ```
        """
        $epoch(::Int, ::Int, ::Int)
    end
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

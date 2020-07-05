module Epochs

using LeapSeconds: offset_tai_utc

import Base: -, +, <, ==, isapprox, isless, show
import Dates
import Dates: format, parse

import ..AstroDates:
    Date,
    DateTime,
    Time,
    calendar,
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
    year,
    yearmonthday

export Epoch,
    CCSDS_EPOCH,
    FIFTIES_EPOCH,
    FUTURE_INFINITY,
    GALILEO_EPOCH,
    GPS_EPOCH,
    J2000_EPOCH,
    J2000_TO_JULIAN,
    J2000_TO_MJD,
    JULIAN_EPOCH,
    MODIFIED_JULIAN_EPOCH,
    PAST_INFINITY,
    UNIX_EPOCH,
    DateTime,
    Date,
    Time,
    day,
    dayofyear,
    fractionofday,
    hour,
    j2000,
    julian,
    julian_period,
    julian_twopart,
    millisecond,
    minute,
    modified_julian,
    month,
    now,
    second,
    secondinday,
    timescale,
    year,
    yearmonthday,
    -

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

struct Epoch{S<:TimeScale, T} <: Dates.AbstractDateTime
    scale::S
    second::Int64
    fraction::T
    function Epoch{S}(second::Int64, fraction::T) where {S<:TimeScale, T}
        return new{S, T}(S(), second, fraction)
    end
end

Epoch{S,T}(ep::Epoch{S,T}) where {S,T} = ep

@inline function apply_offset(second::Int64, fraction, offset)
    sum, residual = two_sum(fraction, offset)
    if !isfinite(sum)
        fraction′ = sum
        second′ = sum < 0 ? typemin(Int64) : typemax(Int64)
    else
        int_secs = floor(Int64, sum)
        fraction′ = sum - int_secs + residual
        second′ = second + int_secs
    end
    return second′, fraction′
end

function Epoch{S}(ep::Epoch{S}, Δt) where {S<:TimeScale}
    second, fraction = apply_offset(ep.second, ep.fraction, Δt)
    Epoch{S}(second, fraction)
end

"""
    Epoch{S}(jd1::T, jd2::T=zero(T); origin=:j2000) where {S, T<:Period}

Construct an `Epoch` with time scale `S` from a Julian date
(optionally split into `jd1` and `jd2`). `origin` determines the
variant of Julian date that is used. Possible values are:

- `:j2000`: J2000 Julian date, starts at `2000-01-01T12:00`
- `:julian`: Julian date, starts at `-4712-01-01T12:00`
- `:modified_julian`: Modified Julian date, starts at `1858-11-17T00:00`

### Examples ###

```jldoctest
julia> Epoch{CoordinatedUniversalTime}(0.0days, 0.5days)
2000-01-02T00:00:00.000 UTC

julia> Epoch{CoordinatedUniversalTime}(2.451545e6days, origin=:julian)
2000-01-01T12:00:00.000 UTC
```
"""
function Epoch{S}(jd1::T, jd2::T=zero(T), args...; origin=:j2000) where {S, T<:Period}
    if jd2 > jd1
        jd1, jd2 = jd2, jd1
    end

    u = unit(jd1)

    if origin == :j2000
        # pass
    elseif origin == :julian
        jd1 -= u(J2000_TO_JULIAN)
    elseif origin == :modified_julian
        jd1 -= u(J2000_TO_MJD)
    else
        throw(ArgumentError("Unknown Julian epoch: $origin"))
    end

    jd1v = jd1 |> seconds |> value
    jd2v = jd2 |> seconds |> value

    sum, residual = two_sum(jd1v, jd2v)
    epoch = floor(Int64, sum)
    offset = (sum - epoch) + residual
    return Epoch{S}(epoch, offset)
end

"""
    julian_period([T,] ep::Epoch; origin=:j2000, scale=timescale(ep), unit=days)

Return the period since Julian Epoch `origin` within the time scale `scale` expressed in
`unit` for a given epoch `ep`. The result is a [`Period`](@ref) object by default.
If the type argument `T` is present, the result is converted to `T` instead.

### Example ###

```jldoctest
julia> ep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)
2018-02-06T20:45:00.000 UTC

julia> julian_period(ep; scale=TAI)
6611.365011574074 days

julia> julian_period(ep; unit=years)
18.100929728496464 years

julia> julian_period(Float64, ep)
6611.364583333333
```
"""
function julian_period(ep::Epoch; origin=:j2000, scale=timescale(ep), unit=days)
    ep1 = Epoch(ep, scale)
    jd1 = unit(ep1.second * seconds)
    jd2 = unit(ep1.fraction * seconds)

    if origin == :j2000
        # pass
    elseif origin == :julian
        jd1 += unit(J2000_TO_JULIAN)
    elseif origin == :modified_julian
        jd1 += unit(J2000_TO_MJD)
    else
        throw(ArgumentError("Unknown Julian epoch: $origin"))
    end

    return jd2 + jd1
end

function julian_period(::Type{T}, ep::Epoch; kwargs...) where T
    jd = julian_period(ep; kwargs...)
    return T(value(jd))
end

"""
    j2000(ep)

Return the J2000 Julian Date for epoch `ep`.

### Example ###

```jldoctest
julia> j2000(UTCEpoch(2000, 1, 1, 12))
0.0 days
```
"""
j2000(ep::Epoch) = julian_period(ep)

"""
    julian(ep)

Return the Julian Date for epoch `ep`.

### Example ###

```jldoctest
julia> julian(UTCEpoch(2000, 1, 1, 12))
2.451545e6 days
```
"""
julian(ep::Epoch) = julian_period(ep; origin=:julian)

"""
    modified_julian(ep)

Return the Modified Julian Date for epoch `ep`.

### Example ###

```jldoctest
julia> modified_julian(UTCEpoch(2000, 1, 1, 12))
51544.5 days
```
"""
modified_julian(ep::Epoch) = julian_period(ep; origin=:modified_julian)

"""
    julian_twopart(ep)

Return the two-part Julian Date for epoch `ep`, which is a tuple consisting
of the Julian day number and the fraction of the day.

### Example ###

```jldoctest
julia> julian_twopart(UTCEpoch(2000, 1, 2))
(2.451545e6 days, 0.5 days)
```
"""
function julian_twopart(ep::Epoch)
    sec_in_days = ep.second / SECONDS_PER_DAY
    frac_in_days = ep.fraction / SECONDS_PER_DAY
    j2k1, j2k2 = divrem(sec_in_days, 1.0)
    jd1 = j2k1 * days + J2000_TO_JULIAN
    jd2 = (frac_in_days + j2k2) * days
    return jd1, jd2
end

include("offsets.jl")
include("accessors.jl")

show(io::IO, ep::Epoch) = print(io, DateTime(ep), " ", timescale(ep))

function Epoch{S}(date::Date, time::Time, args...) where S
    hr = hour(time)
    mn = minute(time)
    leap = getleap(S(), date)
    # We care only about discontinuities
    leap = ifelse(hr == 23 && mn == 59 && abs(leap) == 1.0, leap, 0.0)
    s, fraction = divrem(second(Float64, time) - leap, 1.0)
    daysec = Int64((j2000(date) - 0.5) * SECONDS_PER_DAY)
    hoursec = Int64(hour(time) * SECONDS_PER_HOUR)
    minutesec = Int64(minute(time) * SECONDS_PER_MINUTE)
    sec = Int64(s) + minutesec + hoursec + daysec
    return Epoch{S}(sec, fraction)
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
julia> Epoch{CoordinatedUniversalTime}("2018-02-06T20:45:00.0")
2018-02-06T20:45:00.000 UTC

julia> Epoch{CoordinatedUniversalTime}("February 6, 2018", "U d, y")
2018-02-06T00:00:00.000 UTC

julia> Epoch{CoordinatedUniversalTime}("2018-037T00:00", "yyyy-DDDTHH:MM")
2018-02-06T00:00:00.000 UTC
```
"""
Epoch{S}(str::AbstractString,
         format::Dates.DateFormat=Dates.default_format(Epoch{S})) where {S} = parse(Epoch{S}, str, format)

Epoch{S}(str::AbstractString, format::AbstractString) where {S} = Epoch{S}(str, Dates.DateFormat(format))

Epoch{S}(d::Date) where {S} = Epoch{S}(d, AstroDates.H00)

Epoch{S}(dt::DateTime) where {S} = Epoch{S}(Date(dt), Time(dt))
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
julia> Epoch{CoordinatedUniversalTime}(2018, 2, 6, 20, 45, 0.0)
2018-02-06T20:45:00.000 UTC

julia> Epoch{CoordinatedUniversalTime}(2018, 2, 6)
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
    Epoch{S}(date, Time(hour, minute, second + 1e-3milliseconds))
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
function Epoch{S2}(offset, ep::Epoch{S1}) where {S1<:TimeScale, S2<:TimeScale}
    second, fraction = apply_offset(ep.second, ep.fraction, offset)
    Epoch{S2}(second, fraction)
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
function Epoch{S2}(ep::Epoch{S1}) where {S1<:TimeScale, S2<:TimeScale}
    second, fraction = apply_offset(ep.second, ep.fraction, S1(), S2())
    Epoch{S2}(second, fraction)
end

"""
    Epoch(ep::Epoch{S1}, scale::S2) where {S1, S2}

Convert `ep`, an `Epoch` with time scale `S1`, to an `Epoch` with time
scale `S2`.

### Examples ###

```jldoctest
julia> ep = TTEpoch(2000,1,1)
2000-01-01T00:00:00.000 TT

julia> Epoch(ep, TAI)
1999-12-31T23:59:27.816 TAI
```
"""
function Epoch(ep::Epoch{S1}, scale::S2) where {S1<:TimeScale, S2<:TimeScale}
    second, fraction = apply_offset(ep.second, ep.fraction, S1(), S2())
    Epoch{S2}(second, fraction)
end

function Epoch{S2}(ep::Epoch{S1}, args...) where {S1<:TimeScale, S2<:TimeScale}
    offset = getoffset(S1(), S2(), ep.second, ep.fraction, args...)
    second, fraction = apply_offset(ep.second, ep.fraction, offset)
    Epoch{S2}(second, fraction)
end

Epoch{S}(ep::Epoch{S}) where {S<:TimeScale} = ep
Epoch(ep::Epoch{S}, ::S) where {S<:TimeScale} = ep

function isapprox(a::Epoch{S}, b::Epoch{S}; atol::Real=0, rtol::Real=atol>0 ? 0 : √eps()) where S <: TimeScale
    a.second == b.second && isapprox(a.fraction, b.fraction; atol=atol, rtol=rtol)
end

function ==(a::Epoch, b::Epoch)
    a.second == b.second && a.fraction == b.fraction
end

<(ep1::Epoch, ep2::Epoch) = value(ep1 - ep2) < 0.0
isless(ep1::Epoch, ep2::Epoch) = isless(value(ep1 - ep2), 0.0)

+(ep::Epoch{S}, p::Period) where {S} = Epoch{S}(ep, value(seconds(p)))
-(ep::Epoch{S}, p::Period) where {S} = Epoch{S}(ep, -value(seconds(p)))

"""
    -(a::Epoch, b::Epoch)

Return the duration between epoch `a` and epoch `b`.

### Examples ###

```jldoctest
julia> UTCEpoch(2018, 2, 6, 20, 45, 20.0) - UTCEpoch(2018, 2, 6, 20, 45, 0.0)
20.0 seconds
```
"""
function -(a::Epoch{S}, b::Epoch{S}) where S<:TimeScale
    return ((a.second - b.second) + (a.fraction - b.fraction)) * seconds
end

# Generate aliases for all defined time scales so we can use
# e.g. `TTEpoch` instead of `Epoch{TT}`
for (scale, acronym) in zip(TimeScales.NAMES, TimeScales.ACRONYMS)
    epoch = Symbol(acronym, "Epoch")
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
        2018-02-06T20:45:00.000 $($acronym)

        julia> $($name)("February 6, 2018", "U d, y")
        2018-02-06T00:00:00.000 $($acronym)

        julia> $($name)("2018-37T00:00", "yyyy-DDDTHH:MM")
        2018-02-06T00:00:00.000 $($acronym)
        ```
        """
        $epoch(::AbstractString)

        """
            $($name)(jd1::T, jd2::T=zero(T); origin=:j2000) where T<:Period

        Construct a $($name) from a Julian date (optionally split into
        `jd1` and `jd2`). `origin` determines the variant of Julian
        date that is used. Possible values are:

        - `:j2000`: J2000 Julian date, starts at `2000-01-01T12:00`
        - `:julian`: Julian date, starts at `-4712-01-01T12:00`
        - `:modified_julian`: Modified Julian date, starts at `1858-11-17T00:00`

        ### Examples ###

        ```jldoctest
        julia> $($name)(0.0days, 0.5days)
        2000-01-02T00:00:00.000 $($acronym)

        julia> $($name)(2.451545e6days, origin=:julian)
        2000-01-01T12:00:00.000 $($acronym)
        ```
        """
        $epoch(::Number, ::Number)

        """
            $($name)(year, month, day, hour=0, minute=0, second=0.0)

        Construct a $($name) from date and time components.

        ### Example ###

        ```jldoctest
        julia> $($name)(2018, 2, 6, 20, 45, 0.0)
        2018-02-06T20:45:00.000 $($acronym)

        julia> $($name)(2018, 2, 6)
        2018-02-06T00:00:00.000 $($acronym)
        ```
        """
        $epoch(::Int, ::Int, ::Int)
    end
end

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

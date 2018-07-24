module Epochs

using EarthOrientation
using ERFA

import Base: +, -, ==, isapprox, isless
import Dates
using Dates: DateTime, @dateformat_str

using ..TimeScales, ..Periods
import ..TimeScales: acronyms
import LeapSeconds: offset_tai_utc

export Epoch, julian, julian1, julian2, +, -, ==, isapprox, isless,
    offset_tai_utc, jd2000, jd1950, mjd, timescale

const date_fmt = dateformat"yyyy-mm-ddTHH:MM:SS.sss"

struct Epoch{S,T<:Number}
    jd1::T
    jd2::T
    """
        Epoch{T}(jd1, jd2=0.0) where {T}

    Construct an `Epoch` with timescale `T` from a two-part Julian date.

    # Example

    ```jldoctest
    julia> Epoch{TT}(2.4578265e6, 0.30440190993249416)
    2017-03-14T07:18:20.325 TT
    ```
    """
    function Epoch{S}(jd1::T, jd2::T=zero(T)) where {S, T<:Number}
        new{S::TimeScale,T}(jd1, jd2)
    end
end

function Base.show(io::IO, ep::Epoch)
    print(io, "$(Dates.format(DateTime(ep), date_fmt)) $(timescale(ep))")
end

timescale(ep::Epoch{S}) where {S} = S

"""
    Epoch{T}(year, month, day,
        hour=0, minute=0, seconds=0, milliseconds=0) where {T}

Construct an `Epoch` with timescale `T` at the given date and time.

# Example

```jldoctest
julia> Epoch{TT}(2017, 3, 14, 7, 18, 20, 325)
2017-03-14T07:18:20.325 TT
```
"""
function Epoch{T}(year, month, day,
    hour=0, minute=0, seconds=0, milliseconds=0) where {T}
    jd, jd1 = ERFA.dtf2d(string(T),
    year, month, day, hour, minute, seconds + milliseconds/1000)
    Epoch{T}(jd, jd1)
end

"""
    Epoch{T}(dt::DateTime) where {T}

Convert a `DateTime` object to an `Epoch` with timescale `T`.

# Example

```jldoctest
julia> Epoch{TT}(DateTime(2017, 3, 14, 7, 18, 20, 325))
2017-03-14T07:18:20.325 TT
```
"""
function Epoch{T}(dt::DateTime) where {T}
    Epoch{T}(Dates.year(dt), Dates.month(dt), Dates.day(dt),
        Dates.hour(dt), Dates.minute(dt),
        Dates.second(dt) + Dates.millisecond(dt)/1000)
end

"""
    DateTime(ep::Epoch{T}) where T

Convert an `Epoch` with timescale `T` to a `DateTime` object.

# Example

```jldoctest
julia> DateTime(Epoch{TT}(2017, 3, 14, 7, 18, 20, 325))
2017-03-14T07:18:20.325
```
"""
function DateTime(ep::Epoch{T}) where {T}
    dt = ERFA.d2dtf(string(T), 3, julian1(ep), julian2(ep))
    DateTime(dt...)
end

"""
    Epoch{T}(timestamp::AbstractString,
        fmt::DateFormat=dateformat"yyyy-mm-ddTHH:MM:SS.sss") where {T}

Construct an `Epoch` with timescale `T` from a timestamp. Optionally a `DateFormat`
object can be passed which improves performance if many date strings need to be
parsed and the format is known in advance.

# Example

```jldoctest
julia> Epoch{TT}("2017-03-14T07:18:20.325")
2017-03-14T07:18:20.325 TT
```
"""
Epoch{T}(str::AbstractString, fmt=date_fmt) where {T} = Epoch{T}(DateTime(str, fmt))

for scale in acronyms
    epoch = Symbol(scale, "Epoch")
    @eval begin
        const $epoch = Epoch{$scale}
        export $epoch
    end
end

julian1(ep) = ep.jd1
julian2(ep) = ep.jd2
julian(ep) = julian1(ep) + julian2(ep)
mjd(ep) = julian(ep) - MJD
jd2000(ep) = julian(ep) - J2000
jd1950(ep) = julian(ep) - J1950

(::Second)(ep::Epoch, base=0.0) = seconds((julian1(ep) - base + julian2(ep)) * days)
(::Minute)(ep::Epoch, base=0.0) = minutes((julian1(ep) - base + julian2(ep)) * days)
(::Hour)(ep::Epoch, base=0.0) = hours((julian1(ep) - base + julian2(ep)) * days)
(::Day)(ep::Epoch, base=0.0) = days((julian1(ep) - base + julian2(ep)) * days)
(::Year)(ep::Epoch, base=0.0) = years((julian1(ep) - base + julian2(ep)) * days)
(::Century)(ep::Epoch, base=0.0) = centuries((julian1(ep) - base + julian2(ep)) * days)

dut1(ep::Epoch) = getΔUT1(julian(ep))
offset_tai_utc(ep::Epoch) = offset_tai_utc(julian(ep))

function isapprox(a::Epoch{T}, b::Epoch{T}) where {T}
    return julian(a) ≈ julian(b)
end

function (==)(a::Epoch{T}, b::Epoch{T}) where {T}
    return DateTime(a) == DateTime(b)
end

isless(ep1::Epoch{T}, ep2::Epoch{T}) where {T} = julian(ep1) < julian(ep2)

function (+)(ep::Epoch{S,T1}, p::Period{U,T2}) where {T1,T2,S,U<:TimeUnit}
    delta = get(days(p))
    if delta >= oneunit(T2)
        ep1 = Epoch{S}(julian1(ep) + delta, julian2(ep))
    else
        ep1 = Epoch{S}(julian1(ep), julian2(ep) + delta)
    end
end

function (-)(ep::Epoch{S,T1}, p::Period{U,T2}) where {T1,T2,S,U<:TimeUnit}
    delta = get(days(p))
    if delta >= oneunit(T2)
        ep1 = Epoch{S}(julian1(ep) - delta, julian2(ep))
    else
        ep1 = Epoch{S}(julian1(ep), julian2(ep) - delta)
    end
end

function (-)(ep1::Epoch{T}, ep2::Epoch{T}) where {T}
    ((julian1(ep1) - julian1(ep2)) + (julian2(ep1) - julian2(ep2))) * days
end

include("conversions.jl")

end

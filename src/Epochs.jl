module Epochs

using EarthOrientation
using ERFA

import Base: +, -, ==, isapprox, isless

using ..TimeScales, ..Periods
import ..TimeScales: scales
import ..LeapSeconds: leapseconds

export Epoch, julian, julian1, julian2, +, -, ==, isapprox, isless,
    leapseconds, jd2000, jd1950, mjd

struct Epoch{S<:TimeScale,T<:Number}
    scale::Type{S}
    jd1::T
    jd2::T
    """
        Epoch{T}(jd1, jd2=0.0) where T<:TimeScale

    Construct an `Epoch` with timescale `T` from a two-part Julian date.

    # Example

    ```jldoctest
    julia> Epoch{TT}(2.4578265e6, 0.30440190993249416)
    2017-03-14T07:18:20.325 TT
    ```
    """
    function Epoch{S}(jd1::T, jd2::T=zero(T)) where {S<:TimeScale, T<:Number}
        new{S,T}(S, jd1, jd2)
    end
end

function Base.show(io::IO, ep::Epoch{S}) where S<:TimeScale
    print(io, "$(Dates.format(DateTime(ep),
        "yyyy-mm-ddTHH:MM:SS.sss")) $(S.name.name)")
end


"""
    Epoch{T}(year, month, day,
        hour=0, minute=0, seconds=0, milliseconds=0) where T<:TimeScale

Construct an `Epoch` with timescale `T` at the given date and time.

# Example

```jldoctest
julia> Epoch{TT}(2017, 3, 14, 7, 18, 20, 325)
2017-03-14T07:18:20.325 TT
```
"""
function Epoch{T}(year, month, day,
    hour=0, minute=0, seconds=0, milliseconds=0) where T<:TimeScale
    jd, jd1 = eraDtf2d(string(T.name.name),
    year, month, day, hour, minute, seconds + milliseconds/1000)
    Epoch{T}(jd, jd1)
end

"""
    Epoch{T}(dt::DateTime) where T<:TimeScale

Convert a `DateTime` object to an `Epoch` with timescale `T`.

# Example

```jldoctest
julia> Epoch{TT}(DateTime(2017, 3, 14, 7, 18, 20, 325))
2017-03-14T07:18:20.325 TT
```
"""
function Epoch{T}(dt::DateTime) where T<:TimeScale
    Epoch{T}(Dates.year(dt), Dates.month(dt), Dates.day(dt),
        Dates.hour(dt), Dates.minute(dt),
        Dates.second(dt) + Dates.millisecond(dt)/1000)
end

"""
    DateTime{T<:TimeScale}(ep::Epoch{T})

Convert an `Epoch` with timescale `T` to a `DateTime` object.

# Example

```jldoctest
julia> DateTime(Epoch{TT}(2017, 3, 14, 7, 18, 20, 325))
2017-03-14T07:18:20.325
```
"""
function Base.DateTime(ep::Epoch{T}) where T<:TimeScale
    dt = eraD2dtf(string(T.name.name), 3, julian1(ep), julian2(ep))
    DateTime(dt...)
end

"""
    Epoch{T}(ep::Epoch{S}) where {T<:TimeScale, S<:TimeScale}

Convert an `Epoch` with timescale `S` to an `Epoch` with timescale `T`.

# Example

```jldoctest
julia> Epoch{TT}(Epoch{TAI}(2000, 1, 1))
2000-01-01T00:00:32.184 TT
```
"""
function Epoch{T}(ep::Epoch{S}) where {T<:TimeScale,S<:TimeScale}
    _rescale(Epoch{T}, ep)
end
Epoch{T}(ep::Epoch{T}) where T<:TimeScale = ep

"""
    Epoch{T}(timestamp::AbstractString) where T<:TimeScale

Construct an `Epoch` with timescale `T` from a timestamp.

# Example

```jldoctest
julia> Epoch{TT}("2017-03-14T07:18:20.325")
2017-03-14T07:18:20.325 TT
```
"""
Epoch{T}(str::AbstractString) where T<:TimeScale = Epoch{T}(DateTime(str))

for scale in scales
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
leapseconds(ep::Epoch) = leapseconds(julian(ep))

function isapprox(a::Epoch{T}, b::Epoch{T}) where T<:TimeScale
    return julian(a) ≈ julian(b)
end

function (==)(a::Epoch{T}, b::Epoch{T}) where T<:TimeScale
    return DateTime(a) == DateTime(b)
end

isless(ep1::Epoch{T}, ep2::Epoch{T}) where {T<:TimeScale} = julian(ep1) < julian(ep2)

function (+)(ep::Epoch{S,T1}, p::Period{U,T2}) where {T1,T2,S<:TimeScale,U<:TimeUnit}
    delta = days(p)
    if delta >= oneunit(T2)
        ep1 = Epoch{S}(julian1(ep) + delta, julian2(ep))
    else
        ep1 = Epoch{S}(julian1(ep), julian2(ep) + delta)
    end
end

function (-)(ep::Epoch{S,T1}, p::Period{U,T2}) where {T1,T2,S<:TimeScale,U<:TimeUnit}
    delta = days(p)
    if delta >= oneunit(T2)
        ep1 = Epoch{S}(julian1(ep) - delta, julian2(ep))
    else
        ep1 = Epoch{S}(julian1(ep), julian2(ep) - delta)
    end
end

function (-)(ep1::Epoch{T}, ep2::Epoch{T}) where T<:TimeScale
    ((julian1(ep1) - julian1(ep2)) + (julian2(ep1) - julian2(ep2))) * days
end

include("conversions.jl")

end

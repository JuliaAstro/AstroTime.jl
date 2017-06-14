module AstronomicalTime

__precompile__()

using Convertible
using EarthOrientation
using ERFA
using OptionalData
using RemoteFiles
using Unitful

import Base.Operators: +, -, ==
import Base: convert, isapprox, isless
import Unitful: Time

export Timescale, Epoch, second, seconds, minutes, hours, day, days, +, -,
    julian, julian1, julian2, julian_strip, julian1_strip, julian2_strip,
    mjd, jd2000, jd1950, in_seconds, in_days, in_centuries,
    JULIAN_CENTURY, SEC_PER_DAY, SEC_PER_CENTURY, MJD, J2000, J1950,
    @timescale

const second = u"s"
const seconds = 1.0second
const minutes = 60.0second
const hours = 3600.0second
const day = u"d"
const days = 1.0day

const JULIAN_CENTURY = 36525.0days
const SEC_PER_DAY = 86400.0seconds
const SEC_PER_CENTURY = second(JULIAN_CENTURY)
const MJD = 2400000.5days
const J2000 = Dates.datetime2julian(DateTime(2000, 1, 1, 12, 0, 0)) * days
const J1950 = Dates.datetime2julian(DateTime(1950, 1, 1, 12, 0, 0)) * days

"""
All timescales are subtypes of the abstract type `Timescale`.
The following timescales are defined:

* `UTC` — Coordinated Universal Time
* `UT1` — Universal Time
* `TAI` — International Atomic Time
* `TT` — Terrestrial Time
* `TCG` — Geocentric Coordinate Time
* `TCB` — Barycentric Coordinate Time
* `TDB` — Barycentric Dynamical Time
"""
abstract type Timescale end

Base.show(io::IO, ::Type{T}) where {T<:Timescale} = print(io, T.name.name)

struct Epoch{T<:Timescale}
    jd1::typeof(days)
    jd2::typeof(days)
    function Epoch{T}(jd1::Time, jd2::Time=0.0days) where T<:Timescale
        new{T}(day(jd1), day(jd2))
    end
end

function Base.show(io::IO, ep::Epoch{T}) where T<:Timescale
    print(io, "$(Dates.format(DateTime(ep),
        "yyyy-mm-ddTHH:MM:SS.sss")) $(T.name.name)")
end

"""
    Epoch{T}(jd1, jd2=0.0) where T<:Timescale

Construct an `Epoch` with timescale `T` from a two-part Julian date.

# Example

```jldoctest
julia> Epoch{TT}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 TT
```
"""
function Epoch{T}(jd1::Float64, jd2::Float64=0.0) where T<:Timescale
    Epoch{T}(jd1 * days, jd2 * days)
end

"""
    Epoch{T}(year, month, day,
        hour=0, minute=0, seconds=0, milliseconds=0) where T<:Timescale

Construct an `Epoch` with timescale `T` at the given date and time.

# Example

```jldoctest
julia> Epoch{TT}(2017, 3, 14, 7, 18, 20, 325)
2017-03-14T07:18:20.325 TT
```
"""
function Epoch{T}(year, month, day,
    hour=0, minute=0, seconds=0, milliseconds=0) where T<:Timescale
    jd, jd1 = eraDtf2d(string(T.name.name),
    year, month, day, hour, minute, seconds + milliseconds/1000)
    Epoch{T}(jd, jd1)
end

"""
    Epoch{T}(dt::DateTime) where T<:Timescale

Convert a `DateTime` object to an `Epoch` with timescale `T`.

# Example

```jldoctest
julia> Epoch{TT}(DateTime(2017, 3, 14, 7, 18, 20, 325))
2017-03-14T07:18:20.325 TT
```
"""
function Epoch{T}(dt::DateTime) where T<:Timescale
    Epoch{T}(Dates.year(dt), Dates.month(dt), Dates.day(dt),
        Dates.hour(dt), Dates.minute(dt),
        Dates.second(dt) + Dates.millisecond(dt)/1000)
end

"""
    DateTime{T<:Timescale}(ep::Epoch{T})

Convert an `Epoch` with timescale `T` to a `DateTime` object.

# Example

```jldoctest
julia> DateTime(Epoch{TT}(2017, 3, 14, 7, 18, 20, 325))
2017-03-14T07:18:20.325
```
"""
function Base.DateTime(ep::Epoch{T}) where T<:Timescale
    dt = eraD2dtf(string(T.name.name), 3, julian1_strip(ep), julian2_strip(ep))
    DateTime(dt...)
end

"""
    Epoch{T}(ep::Epoch{S}) where {T<:Timescale, S<:Timescale}

Convert an `Epoch` with timescale `S` to an `Epoch` with timescale `T`.

# Example

```jldoctest
julia> Epoch{TT}(Epoch{TAI}(2000, 1, 1))
2000-01-01T00:00:32.184 TT
```
"""
function Epoch{T}(ep::Epoch{S}) where {T<:Timescale,S<:Timescale}
    @convert convert(Epoch{T}, ep)
end
Epoch{T}(ep::Epoch{T}) where T<:Timescale = ep

"""
    Epoch{T}(timestamp::AbstractString) where T<:Timescale

Construct an `Epoch` with timescale `T` from a timestamp.

# Example

```jldoctest
julia> Epoch{TT}("2017-03-14T07:18:20.325")
2017-03-14T07:18:20.325 TT
```
"""
Epoch{T}(str::AbstractString) where T<:Timescale = Epoch{T}(DateTime(str))

julian1(ep) = ep.jd1
julian2(ep) = ep.jd2
julian1_strip(ep) = ustrip(ep.jd1)
julian2_strip(ep) = ustrip(ep.jd2)
julian(ep) = julian1(ep) + julian2(ep)
julian_strip(ep) = julian1_strip(ep) + julian2_strip(ep)
mjd(ep) = julian(ep) - MJD
jd2000(ep) = julian(ep) - J2000
jd1950(ep) = julian(ep) - J1950
in_centuries(ep::Epoch, base=J2000) = (julian(ep) - base) / JULIAN_CENTURY
in_days(ep, base=J2000) = julian(ep) - base
in_seconds(ep, base=J2000) = second(julian(ep) - base)

dut1(ep::Epoch) = getΔUT1(julian_strip(ep))

function isapprox(a::Epoch{T}, b::Epoch{T}) where T<:Timescale
    return julian(a) ≈ julian(b)
end

function (==)(a::Epoch{T}, b::Epoch{T}) where T<:Timescale
    return DateTime(a) == DateTime(b)
end

isless(ep1::Epoch{T}, ep2::Epoch{T}) where {T<:Timescale} = julian(ep1) < julian(ep2)

function (+)(ep::Epoch{T}, dt::Unitful.Time) where T<:Timescale
    if abs(dt) >= days
        return Epoch{T}(ep.jd1 + day(dt), ep.jd2)
    else
        return Epoch{T}(ep.jd1, ep.jd2 + day(dt))
    end
end

function (-)(ep::Epoch{T}, dt::Unitful.Time) where T<:Timescale
    if abs(dt) >= days
        return Epoch{T}(ep.jd1 - day(dt), ep.jd2)
    else
        return Epoch{T}(ep.jd1, ep.jd2 - day(dt))
    end
end

function (-)(ep1::Epoch{T}, ep2::Epoch{T}) where T<:Timescale
    (ep1.jd1 - ep2.jd1) + (ep1.jd2 - ep2.jd2)
end

const scales = (
    :TAI,
    :TT,
    :UTC,
    :UT1,
    :TCG,
    :TCB,
    :TDB,
)

for scale in scales
    epoch = Symbol(scale, "Epoch")
    @eval begin
        struct $scale <: Timescale end
        @convertible const $epoch = Epoch{$scale}
        export $scale, $epoch
    end
end

"""
    @timescale scale

Define a new timescale and the corresponding `Epoch` type alias.

# Example

```jldoctest
julia> @timescale Custom

julia> Custom <: Timescale
true
julia> CustomEpoch == Epoch{Custom}
true
```
"""
macro timescale(scale)
    if !(scale isa Symbol)
        error("Invalid time scale name.")
    end
    epoch = Symbol(scale, "Epoch")
    return quote
        struct $(esc(scale)) <: Timescale end
        @convertible const $(esc(epoch)) = Epoch{$(esc(scale))}
    end
end

include("leapseconds.jl")
include("conversions.jl")

function update()
    EarthOrientation.update()
    download(LSK_FILE)
    push!(LSK_DATA, path(LSK_FILE))
    nothing
end

end # module

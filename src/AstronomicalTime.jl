module AstronomicalTime

using Compat
using Convertible
using ERFA
using Unitful

import Base.Operators: +,-

export Timescale, Epoch, second, seconds, minutes, hours, day, days, +, -

const JULIAN_CENTURY = 36525
const SEC_PER_DAY = 86400
const SEC_PER_CENTURY = SEC_PER_DAY*JULIAN_CENTURY
const TAI_TO_TT = 32.184/SEC_PER_DAY
const LG = 6.969290134e-10
const TT0 = 2443144.5003725
const MJD0 = 2400000.5
const J2000 = Dates.datetime2julian(DateTime(2000, 1, 1, 12, 0, 0))
const J1950 = Dates.datetime2julian(DateTime(1950, 1, 1, 12, 0, 0))

const second = u"s"
const seconds = 1.0second
const minutes = 60.0second
const hours = 3600.0second
const day = u"d"
const days = 1.0day

@compat abstract type Timescale end
Base.show{T<:Timescale}(io::IO, ::Type{T}) = print(io, T.name.name)

const scales = (
    :TAI,
    :TT,
    :UTC,
    :UT1,
    :TCG,
    :TCB,
    :TDB,
)

immutable Epoch{T<:Timescale}
    jd1::typeof(days)
    jd2::typeof(days)
end
Epoch{T}(jd1::Float64, jd2::Float64=0.0) where T<:Timescale = Epoch{T}(jd1*days, jd2*days)

function (+){T}(ep::Epoch{T}, dt::Unitful.Time)
    if abs(dt) >= days
        return Epoch{T}(ep.jd1 + day(dt), ep.jd2)
    else
        return Epoch{T}(ep.jd1, ep.jd2 + day(dt))
    end
end

function (-){T}(ep::Epoch{T}, dt::Unitful.Time)
    if abs(dt) >= days
        return Epoch{T}(ep.jd1 - day(dt), ep.jd2)
    else
        return Epoch{T}(ep.jd1, ep.jd2 - day(dt))
    end
end

Base.show{T<:Timescale}(io::IO, ep::Epoch{T}) = print(io, "$(DateTime(ep)) $(T.name.name)")

for scale in scales
    epoch = Symbol(scale, "Epoch")
    @eval begin
        immutable $scale <: Timescale end
        @convertible const $epoch = Epoch{$scale}
        export $scale, $epoch
    end
end

function Base.DateTime{T<:Timescale}(ep::Epoch{T})
    dt = eraD2dtf(string(T.name.name), 3, ustrip(ep.jd1), ustrip(ep.jd2))
    DateTime(dt...)
end

end # module

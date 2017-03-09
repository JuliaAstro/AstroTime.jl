module AstronomicalTime

using Compat
using Convertible
using ERFA
using Unitful

import Base.Operators: +,-

export Timescale, Epoch, seconds, minutes, hours, days, +, -

const JULIAN_CENTURY = 36525
const SEC_PER_DAY = 86400
const SEC_PER_CENTURY = SEC_PER_DAY*JULIAN_CENTURY
const TAI_TO_TT = 32.184/SEC_PER_DAY
const LG = 6.969290134e-10
const TT0 = 2443144.5003725
const MJD0 = 2400000.5
const J2000 = Dates.datetime2julian(DateTime(2000, 1, 1, 12, 0, 0))
const J1950 = Dates.datetime2julian(DateTime(1950, 1, 1, 12, 0, 0))

const seconds = 1.0u"s"
const minutes = 60.0u"s"
const hours = 3600.0u"s"
const days = 1.0u"d"

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
    jd1::Float64
    jd2::Float64
end

function (+){T}(ep::Epoch{T}, dt::Unitful.Time)
    if dt > days
        return Epoch{T}(ep.jd1 + ustrip(u"d"(dt)), ep.jd2)
    else
        return Epoch{T}(ep.jd1, ep.jd2 + ustrip(u"d"(dt)))
    end
end

function (-){T}(ep::Epoch{T}, dt::Unitful.Time)
    if dt > days
        return Epoch{T}(ep.jd1 - ustrip(u"d"(dt)), ep.jd2)
    else
        return Epoch{T}(ep.jd1, ep.jd2 - ustrip(u"d"(dt)))
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
    dt = eraD2dtf(string(T.name.name), 3, ep.jd1, ep.jd2)
    DateTime(dt...)
end

end # module

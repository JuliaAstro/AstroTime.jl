module AstronomicalTime

using Compat
using Convertible
using ERFA

export Timescale, Epoch, EpochPeriod

const JULIAN_CENTURY = 36525
const SEC_PER_DAY = 86400
const SEC_PER_CENTURY = SEC_PER_DAY*JULIAN_CENTURY
const TAI_TO_TT = 32.184/SEC_PER_DAY
const LG = 6.969290134e-10
const TT0 = 2443144.5003725
const MJD0 = 2400000.5
const J2000 = Dates.datetime2julian(DateTime(2000, 1, 1, 12, 0, 0))
const J1950 = Dates.datetime2julian(DateTime(1950, 1, 1, 12, 0, 0))

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
Epoch{T<:Timescale}(::Type{T}, args...) = Epoch{T}(args...)

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

immutable EpochPeriod
    djd1::Float64
    djd2::Float64
end
EpochPeriod(;days=0, seconds=0) = EpochPeriod(days, seconds/SEC_PER_DAY)


end # module

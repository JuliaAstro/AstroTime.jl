module TimeScales

import Dates

export TimeScale

"""
All timescales are subtypes of the abstract type `TimeScale`.
The following timescales are defined:

* `UTC` — Coordinated Universal Time
* `UT1` — Universal Time
* `TAI` — International Atomic Time
* `TT` — Terrestrial Time
* `TCG` — Geocentric Coordinate Time
* `TCB` — Barycentric Coordinate Time
* `TDB` — Barycentric Dynamical Time
"""
abstract type TimeScale end

const SCALES = (
    :CoordinatedUniversalTime,
    :UniversalTime,
    :InternationalAtomicTime,
    :TerrestrialTime,
    :GeocentricCoordinateTime,
    :BarycentricCoordinateTime,
    :BarycentricDynamicalTime,
)

const ACRONYMS = (
    :UTC,
    :UT1,
    :TAI,
    :TT,
    :TCG,
    :TCB,
    :TDB,
)

for (acronym, scale) in zip(ACRONYMS, SCALES)
    name = String(acronym)
    @eval begin
        struct $scale <: TimeScale end
        const $acronym = $scale()
        export $scale, $acronym

        Base.show(io::IO, ::$scale) = print(io, $name)
        tryparse(::Val{Symbol($name)}) = $acronym
    end
end

struct NotATimeScale <: TimeScale end

tryparse(s::T) where T<:AbstractString = tryparse(Val(Symbol(s)))
tryparse(::T) where T = nothing

@inline function Dates.tryparsenext(d::Dates.DatePart{'t'}, str, i, len, locale)
    next = Dates.tryparsenext_word(str, i, len, locale, Dates.max_width(d))
    next === nothing && return nothing
    word, i = next
    val = tryparse(word)
    val === nothing && throw(ArgumentError("'$word' is not a recognized time scale."))
    return val, i
end

end

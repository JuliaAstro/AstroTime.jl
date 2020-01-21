module TimeScales

using ItemGraphs: ItemGraph, add_edge!, items

import Dates

export TimeScale, find_path

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

const NAMES = (
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

for (acronym, scale) in zip(ACRONYMS, NAMES)
    name = String(acronym)
    @eval begin
        struct $scale <: TimeScale end
        const $acronym = $scale()
        export $scale, $acronym

        Base.show(io::IO, ::$scale) = print(io, "$($name)")
        tryparse(::Val{Symbol($name)}) = $acronym
    end
end

const SCALES = ItemGraph{TimeScale}()

add_edge!(SCALES, TAI, TT)
add_edge!(SCALES, TT, TAI)
add_edge!(SCALES, TAI, UTC)
add_edge!(SCALES, UTC, TAI)
add_edge!(SCALES, TAI, UT1)
add_edge!(SCALES, UT1, TAI)
add_edge!(SCALES, TT, UTC)
add_edge!(SCALES, UTC, TT)
add_edge!(SCALES, TT, UT1)
add_edge!(SCALES, UT1, TT)
add_edge!(SCALES, TT, TCG)
add_edge!(SCALES, TCG, TT)
add_edge!(SCALES, TT, TDB)
add_edge!(SCALES, TDB, TT)
add_edge!(SCALES, TCB, TDB)
add_edge!(SCALES, TDB, TCB)

find_path(from, to) = items(SCALES, from, to)

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

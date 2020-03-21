module TimeScales

using ItemGraphs: ItemGraph, add_edge!, add_vertex!, items

import Dates

export
    TimeScale,
    find_path,
    link_scales!,
    register_scale!

"""
All timescales are subtypes of the abstract type `TimeScale`.
The following timescales are defined:

* [`UTC`](@ref) — Coordinated Universal Time
* [`UT1`](@ref) — Universal Time
* [`TAI`](@ref) — International Atomic Time
* [`TT`](@ref) — Terrestrial Time
* [`TCG`](@ref) — Geocentric Coordinate Time
* [`TCB`](@ref) — Barycentric Coordinate Time
* [`TDB`](@ref) — Barycentric Dynamical Time
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

for (acronym, name) in zip(ACRONYMS, NAMES)
    acro_str = String(acronym)
    name_str = String(name)
    name_split = join(split(name_str, r"(?=[A-Z])"), " ")
    wiki = replace(name_split, " "=>"_")
    @eval begin
        """
            $($name_str)

        A type representing the $($name_split) ($($acro_str)) time scale.

        # References

        - [Wikipedia](https://en.wikipedia.org/wiki/$($wiki))
        """
        struct $name <: TimeScale end

        """
            $($acro_str)

        The singleton instance of the [`$($name_str)`](@ref) type representing
        the $($name_split) ($($acro_str)) time scale.

        # References

        - [Wikipedia](https://en.wikipedia.org/wiki/$($wiki))
        """
        const $acronym = $name()

        export $name, $acronym

        Base.show(io::IO, ::$name) = print(io, "$($acro_str)")
        tryparse(::Val{Symbol($acro_str)}) = $acronym
    end
end

const SCALES = ItemGraph{TimeScale}()

function register_scale!(s)
    add_vertex!(SCALES, s)
end

function link_scales!(s1, s2; oneway=false)
    add_edge!(SCALES, s1, s2)
    oneway || add_edge!(SCALES, s2, s1)
end

link_scales!(TAI, TT)
link_scales!(TAI, UTC)
link_scales!(UTC, UT1)
link_scales!(TT, TCG)
link_scales!(TT, TDB)
link_scales!(TCB, TDB)

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

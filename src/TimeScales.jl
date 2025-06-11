module TimeScales

using Graphs
import Dates

export
    TimeScale,
    find_path,
    link_scales!,
    register_scale!

"""
All timescales are subtypes of the abstract type `TimeScale`.
The following timescales are defined:

* [`UT1`](@ref) — Universal Time
* [`TAI`](@ref) — International Atomic Time
* [`TT`](@ref) — Terrestrial Time
* [`TCG`](@ref) — Geocentric Coordinate Time
* [`TCB`](@ref) — Barycentric Coordinate Time
* [`TDB`](@ref) — Barycentric Dynamical Time
"""
abstract type TimeScale end

const NAMES = (
    :UniversalTime,
    :InternationalAtomicTime,
    :TerrestrialTime,
    :GeocentricCoordinateTime,
    :BarycentricCoordinateTime,
    :BarycentricDynamicalTime,
)

const ACRONYMS = (
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

# Create a DiGraph to store the time scales
const SCALES = SimpleDiGraph{Int}()
const SCALE_VERTICES = Dict{TimeScale, Int}()
const VERTEX_SCALES = Dict{Int, TimeScale}()

function register_scale!(s::TimeScale)
    if !haskey(SCALE_VERTICES, s)
        add_vertex!(SCALES)
        v = nv(SCALES)
        SCALE_VERTICES[s] = v
        VERTEX_SCALES[v] = s
    end
end

function link_scales!(s1::TimeScale, s2::TimeScale; oneway=false)
    # Ensure both scales are registered
    register_scale!(s1)
    register_scale!(s2)
    
    # Add the edge
    add_edge!(SCALES, SCALE_VERTICES[s1], SCALE_VERTICES[s2])
    oneway || add_edge!(SCALES, SCALE_VERTICES[s2], SCALE_VERTICES[s1])
end

function find_path(from::TimeScale, to::TimeScale)
    # Get vertex indices
    v_from = SCALE_VERTICES[from]
    v_to = SCALE_VERTICES[to]
    
    # Find shortest path
    path = dijkstra_shortest_paths(SCALES, v_from)
    
    # Extract path vertices
    path_vertices = Int[]
    current = v_to
    while current != v_from
        pushfirst!(path_vertices, current)
        current = path.parents[current]
        current == 0 && return TimeScale[] # No path exists
    end
    pushfirst!(path_vertices, v_from)
    
    # Convert vertices back to TimeScales
    return [VERTEX_SCALES[v] for v in path_vertices]
end

struct NotATimeScale <: TimeScale end

tryparse(s::AbstractString) = tryparse(Val(Symbol(s)))
tryparse(::Any) = nothing

@inline function Dates.tryparsenext(d::Dates.DatePart{'t'}, str, i, len, locale)
    next = Dates.tryparsenext_word(str, i, len, locale, Dates.max_width(d))
    next === nothing && return nothing
    word, i = next
    val = tryparse(word)
    val === nothing && throw(ArgumentError("'$word' is not a recognized time scale."))
    return val, i
end

# Initialize the graph with the time scale relationships
link_scales!(TAI, TT)
link_scales!(TAI, UT1)
link_scales!(TT, TCG)
link_scales!(TT, TDB)
link_scales!(TCB, TDB)

end

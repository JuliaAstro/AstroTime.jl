module TimeScales

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

Base.show(io::IO, ::Type{T}) where {T<:TimeScale} = print(io, T.name.name)

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
    @eval begin
        struct $scale <: TimeScale end
        export $scale
    end
end

end

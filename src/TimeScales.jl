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
    end
end

Base.show(io::IO, x::TimeScale) = print(io, string(typeof(x)))

end

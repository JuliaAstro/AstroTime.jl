"""
    Epoch{S}(Δtai, ep::TAIEpoch) where S

Convert `ep`, a `TAIEpoch`, to an `Epoch` with time scale `S` by overriding
the offset between `S2` and `TAI` with `Δtai`.

### Examples ###

```jldoctest; setup = :(using AstroTime)
julia> ep = TAIEpoch(2000,1,1)
2000-01-01T00:00:00.000 TAI

julia> TTEpoch(32.184, ep)
2000-01-01T00:00:32.184 TT
```
"""
function Epoch{S2}(offset, ep::Epoch{S1}) where {S1<:TimeScale, S2<:TimeScale}
    second, fraction = apply_offset(ep.second, ep.fraction, offset)
    Epoch{S2}(second, fraction)
end

"""
    Epoch{S2}(ep::Epoch{S1}) where {S1, S2}

Convert `ep`, an `Epoch` with time scale `S1`, to an `Epoch` with time
scale `S2`.

### Examples ###

```jldoctest; setup = :(using AstroTime)
julia> ep = TTEpoch(2000,1,1)
2000-01-01T00:00:00.000 TT

julia> TAIEpoch(ep)
1999-12-31T23:59:27.816 TAI
```
"""
function Epoch{S2}(ep::Epoch{S1}) where {S1<:TimeScale, S2<:TimeScale}
    second, fraction = apply_offset(ep.second, ep.fraction, S1(), S2())
    Epoch{S2}(second, fraction)
end

"""
    Epoch(ep::Epoch{S1}, scale::S2) where {S1, S2}

Convert `ep`, an `Epoch` with time scale `S1`, to an `Epoch` with time
scale `S2`.

### Examples ###

```jldoctest; setup = :(using AstroTime)
julia> ep = TTEpoch(2000,1,1)
2000-01-01T00:00:00.000 TT

julia> Epoch(ep, TAI)
1999-12-31T23:59:27.816 TAI
```
"""
function Epoch(ep::Epoch{S1}, scale::S2) where {S1<:TimeScale, S2<:TimeScale}
    second, fraction = apply_offset(ep.second, ep.fraction, S1(), S2())
    Epoch{S2}(second, fraction)
end

function Epoch{S2}(ep::Epoch{S1}, args...) where {S1<:TimeScale, S2<:TimeScale}
    offset = getoffset(S1(), S2(), ep.second, ep.fraction, args...)
    second, fraction = apply_offset(ep.second, ep.fraction, offset)
    Epoch{S2}(second, fraction)
end

Epoch{S}(ep::Epoch{S}) where {S<:TimeScale} = ep
Epoch(ep::Epoch{S}, ::S) where {S<:TimeScale} = ep

struct NoPathError <: Base.Exception
    in_scale::String
    out_scale::String
end

function Base.showerror(io::IO, err::NoPathError)
    ins = err.in_scale
    out = err.out_scale
    print(io, "No conversion path between '$ins' and '$out' available.")
end

struct NoOffsetError <: Base.Exception
    in_scale::String
    out_scale::String
    in_type::String
    out_type::String
end

function Base.showerror(io::IO, err::NoOffsetError)
    ins = err.in_scale
    out = err.out_scale
    it = err.in_type
    ot = err.out_type
    print(io, "No conversion '$ins->$out' available. ",
          "If one of these is a custom time scale, you may need to define ",
          "`AstroTime.Epochs.getoffset(::$it, ::$ot, second, fraction, args...)`.")
end

function getoffset(s1::TimeScale, s2::TimeScale, _, _)
    err = NoOffsetError(string(s1), string(s2),
                        string(typeof(s1)), string(typeof(s2)))
    throw(err)
end

function j2000(second, fraction)
    (fraction + second) / SECONDS_PER_DAY * days
end

function getoffset(ep::Epoch{S}, scale::TimeScale) where S<:TimeScale
    path = find_path(S(), scale)
    isempty(path) && throw(NoPathError(string(S()), string(scale)))
    length(path) == 2 && return getoffset(S(), scale, ep.second, ep.fraction)
    total_offset = 0.0
    second = ep.second
    fraction = ep.fraction
    for i in 1:length(path) - 1
        offset::Float64 = getoffset(path[i], path[i+1], second, fraction)
        total_offset += offset
        second, fraction = apply_offset(second, fraction, offset)
    end
    return total_offset
end


"""
    getoffset(ep::Epoch, scale::TimeScale)

For a given epoch `ep` return the offset between its time scale and
another time `scale` in seconds.

# Example

```jldoctest; setup = :(using AstroTime)
julia> tai = TAIEpoch(2000, 1, 1)
2000-01-01T00:00:00.000 TAI

julia> getoffset(tai, TT)
32.184
```
"""
function getoffset(ep::Epoch{S}, scale::TimeScale, args...) where S<:TimeScale
    return getoffset(S(), scale, ep.second, ep.fraction, args...)
end

@inline function apply_offset(second::Int64,
                              fraction::T,
                              from::S1,
                              to::S2)::Tuple{Int64, T} where {T, S1<:TimeScale, S2<:TimeScale}
    path = find_path(from, to)
    isempty(path) && throw(NoPathError(string(from), string(to)))
    length(path) == 2 && return _apply_offset(second, fraction, from, to)
    return _apply_offset((second, fraction), path...)
end

@inline function _apply_offset(second::Int64,
                               fraction::T,
                               from::S1,
                               to::S2)::Tuple{Int64, T} where {T, S1<:TimeScale, S2<:TimeScale}
    return apply_offset(second, fraction, getoffset(from, to, second, fraction))
end

@generated function _apply_offset(sf, path...)
    expr = :(sf)
    for i in 1:length(path) - 1
        s1 = path[i]
        s2 = path[i+1]
        expr = :(_apply_offset($expr..., $s1(), $s2()))
    end
    return quote
        Base.@_inline_meta
        $expr
    end
end

######
# TT #
######

const OFFSET_TAI_TT = 32.184

"""
    getoffset(TAI, TT, args...)

Return the fixed offset between [`TAI`](@ref) and [`TT`](@ref) in seconds.

# Example

```jldoctest; setup = :(using AstroTime)
julia> getoffset(TAI, TT)
32.184
```
"""
getoffset(::InternationalAtomicTime, ::TerrestrialTime, args...) = OFFSET_TAI_TT

"""
    getoffset(TT, TAI, args...)

Return the fixed offset between [`TT`](@ref) and [`TAI`](@ref) in seconds.

# Example

```jldoctest; setup = :(using AstroTime)
julia> getoffset(TT, TAI)
-32.184
```
"""
getoffset(::TerrestrialTime, ::InternationalAtomicTime, args...) = -OFFSET_TAI_TT

#######
# TCG #
#######

const JD77_SEC = -7.25803167816e8
const LG_RATE = 6.969290134e-10

"""
    getoffset(TCG, TT, second, fraction)

Return the linear offset between [`TCG`](@ref) and [`TT`](@ref) for the
current epoch (`second` after J2000 and `fraction`) in seconds.

# Example

```jldoctest; setup = :(using AstroTime)
julia> getoffset(TCG, TT, 0, 0.0)
-0.5058332856685995
```
"""
function getoffset(::GeocentricCoordinateTime, ::TerrestrialTime, second, fraction)
    dt = second - JD77_SEC + fraction
    return -LG_RATE * dt
end

"""
    getoffset(TT, TCG, second, fraction)

Return the linear offset between [`TT`](@ref) and [`TCG`](@ref) for the
current epoch (`second` after J2000 and `fraction`) in seconds.

# Example

```jldoctest; setup = :(using AstroTime)
julia> getoffset(TT, TCG, 0, 0.0)
0.5058332860211293
```
"""
function getoffset(::TerrestrialTime, ::GeocentricCoordinateTime, second, fraction)
    rate = LG_RATE / (1.0 - LG_RATE)
    dt = second - JD77_SEC + fraction
    return rate * dt
end

#######
# TCB #
#######

const LB_RATE = 1.550519768e-8

"""
    getoffset(TCB, TDB, second, fraction)

Return the linear offset between [`TCB`](@ref) and [`TDB`](@ref) for the
current epoch (`second` after J2000 and `fraction`) in seconds.

# Example

```jldoctest; setup = :(using AstroTime)
julia> getoffset(TCB, TDB, 0, 0.0)
-11.253721593757295
```
"""
function getoffset(::BarycentricCoordinateTime, ::BarycentricDynamicalTime, second, fraction)
    dt = second - JD77_SEC + fraction
    return -LB_RATE * dt
end

"""
    getoffset(TDB, TCB, second, fraction)

Return the linear offset between [`TDB`](@ref) and [`TCB`](@ref) for the
current epoch (`second` after J2000 and `fraction`) in seconds.

# Example

```jldoctest; setup = :(using AstroTime)
julia> getoffset(TDB, TCB, 0, 0.0)
11.253721768248475
```
"""
function getoffset(::BarycentricDynamicalTime, ::BarycentricCoordinateTime, second, fraction)
    rate = LB_RATE / (1.0 - LB_RATE)
    dt = second - JD77_SEC + fraction
    return rate * dt
end

#######
# UTC #
#######

function getleap(jd0)
    jd, frac = divrem(jd0, 1.0)
    jd += ifelse(frac >= 0.5, 1, -1) * 0.5
    drift0 = offset_tai_utc(jd)
    drift12 = offset_tai_utc(jd + 0.5)
    drift24 = offset_tai_utc(jd + 1.5)

    return drift24 - (2.0drift12 - drift0)
end

function getleap(::CoordinatedUniversalTime, date::Date)
    getleap(j2000(date) + value(J2000_TO_JULIAN))
end

getleap(::TimeScale, ::Date) = 0.0
getleap(ep::Epoch{CoordinatedUniversalTime}) = getleap(ep |> julian |> value)
getleap(::Epoch) = 0.0

function insideleap(jd0)
    jd1 = jd0 + 1 / SECONDS_PER_DAY
    o1 = offset_tai_utc(jd0)
    o2 = offset_tai_utc(jd1)
    return o1 != o2
end

"""
    insideleap(ep::UTCEpoch)

Check whether the UTC epoch `ep` is located during the introduction of a leap
second.

# Example

```jldoctest; setup = :(using AstroTime)
julia> insideleap(UTCEpoch(2020, 3, 20))
false

julia> insideleap(UTCEpoch(2016, 12, 31, 23, 59, 60.5))
true
```
"""
insideleap(ep::Epoch{CoordinatedUniversalTime}) = insideleap(ep |> julian |> value)

insideleap(::Epoch) = false

"""
    getoffset(UTC, TAI, second, fraction)

Return the offset between [`UTC`](@ref) and [`TAI`](@ref) for the
current epoch (`second` after J2000 and `fraction`) in seconds.
For dates after `1972-01-01` this is the number of leap seconds.

# Example

```jldoctest; setup = :(using AstroTime)
julia> getoffset(UTC, TAI, 0, 0.0)
32.0
```
"""
@inline function getoffset(::CoordinatedUniversalTime, ::InternationalAtomicTime,
                           second, fraction)
    jd = value(j2000(second, fraction) + J2000_TO_JULIAN)
    return -offset_utc_tai(jd)
end

"""
    getoffset(TAI, UTC, second, fraction)

Return the offset between [`TAI`](@ref) and [`UTC`](@ref) for the
current epoch (`second` after J2000 and `fraction`) in seconds.
For dates after `1972-01-01` this is the number of leap seconds.

# Example

```jldoctest; setup = :(using AstroTime)
julia> getoffset(TAI, UTC, 0, 0.0)
-32.0
```
"""
@inline function getoffset(::InternationalAtomicTime, ::CoordinatedUniversalTime,
                           second, fraction)
    jd = value(j2000(second, fraction) + J2000_TO_JULIAN)
    return -offset_tai_utc(jd)
end

#######
# UT1 #
#######

"""
    getoffset(UTC, UT1, second, fraction[, eop])

Return the offset between [`UTC`](@ref) and [`UT1`](@ref) for the
current epoch (`second` after J2000 and `fraction`) in seconds.
Optionally, a custom Earth orientation data struct `eop` can be provided,
see [EarthOrientation.jl](https://github.com/JuliaAstro/EarthOrientation.jl).

# Example

```jldoctest; setup = :(using AstroTime; AstroTime.load_test_eop())
julia> getoffset(UTC, UT1, 0, 0.0)
0.3550253556501879
```
"""
@inline function getoffset(::CoordinatedUniversalTime, ::UniversalTime,
                           second, fraction, eop=get(EOP_DATA))
    utc = value(j2000(second, fraction) + J2000_TO_JULIAN)
    return getΔUT1(eop, utc)
end

"""
    getoffset(UT1, UTC, second, fraction[, eop])

Return the offset between [`UT1`](@ref) and [`UTC`](@ref) for the
current epoch (`second` after J2000 and `fraction`) in seconds.
Optionally, a custom Earth orientation data struct `eop` can be provided,
see [EarthOrientation.jl](https://github.com/JuliaAstro/EarthOrientation.jl).

# Example

```jldoctest; setup = :(using AstroTime; AstroTime.load_test_eop())
julia> getoffset(UT1, UTC, 0, 0.0)
-0.3550253592514352
```
"""
@inline function getoffset(::UniversalTime, ::CoordinatedUniversalTime,
                           second, fraction, eop=get(EOP_DATA))
    ut1 = value(j2000(second, fraction) + J2000_TO_JULIAN)
    utc = ut1 - getΔUT1(eop, ut1) / SECONDS_PER_DAY
    return -getΔUT1(eop, utc)
end

#######
# TDB #
#######

const k = 1.657e-3
const eb = 1.671e-2
const m₀ = 6.239996
const m₁ = 1.99096871e-7

"""
    getoffset(TT, TDB, second, fraction[, eop])

Return the offset between [`TT`](@ref) and [`TDB`](@ref) for the
current epoch (`second` after J2000 and `fraction`) in seconds.
This routine is accurate to ~40 microseconds over the interval 1900-2100.

!!! note
    An accurate transformation between TDB and TT depends on the
    trajectory of the observer. For two observers fixed on Earth's surface
    the quantity TDB-TT can differ by as much as ~4 microseconds. See
    [`here`](@ref getoffset(::TerrestrialTime, ::BarycentricDynamicalTime, second, fraction, elong, u, v)).

# Example

```jldoctest; setup = :(using AstroTime)
julia> getoffset(TT, TDB, 0, 0.0)
-7.273677619130569e-5
```

### References ###

- [https://www.cv.nrao.edu/~rfisher/Ephemerides/times.html#TDB](https://www.cv.nrao.edu/~rfisher/Ephemerides/times.html#TDB)
- [Issue #26](https://github.com/JuliaAstro/AstroTime.jl/issues/26)
"""
@inline function getoffset(::TerrestrialTime, ::BarycentricDynamicalTime,
                           second, fraction)
    tt = fraction + second
    g = m₀ + m₁ * tt
    return k * sin(g + eb * sin(g))
end

"""
    getoffset(TDB, TT, second, fraction[, eop])

Return the offset between [`TDB`](@ref) and [`TT`](@ref) for the
current epoch (`second` after J2000 and `fraction`) in seconds.
This routine is accurate to ~40 microseconds over the interval 1900-2100.

!!! note
    An accurate transformation between TDB and TT depends on the
    trajectory of the observer. For two observers fixed on Earth's surface
    the quantity TDB-TT can differ by as much as ~4 microseconds. See
    [`here`](@ref getoffset(::BarycentricDynamicalTime, ::TerrestrialTime, second, fraction, elong, u, v)).

# Example

```jldoctest; setup = :(using AstroTime)
julia> getoffset(TDB, TT, 0, 0.0)
7.273677616693264e-5
```

### References ###

- [https://www.cv.nrao.edu/~rfisher/Ephemerides/times.html#TDB](https://www.cv.nrao.edu/~rfisher/Ephemerides/times.html#TDB)
- [Issue #26](https://github.com/JuliaAstro/AstroTime.jl/issues/26)
"""
@inline function getoffset(::BarycentricDynamicalTime, ::TerrestrialTime,
                           second, fraction)
    tdb = fraction + second
    tt = tdb
    offset = 0.0
    for _ in 1:3
        g = m₀ + m₁ * tt
        offset = -k * sin(g + eb * sin(g))
        tt = tdb + offset
    end
    return offset
end

"""
    getoffset(TDB, TT, second, fraction[, eop])

Return the offset between [`TDB`](@ref) and [`TT`](@ref) for the
current epoch (`second` after J2000 and `fraction`) for an observer on earth
in seconds.

### Arguments ###

- `second`, `fraction`: Current epoch
- `elong`: Longitude (east positive, radians)
- `u`: Distance from Earth's spin axis (km)
- `v`: Distance north of equatorial plane (km)

# Example

```jldoctest; setup = :(using AstroTime)
julia> getoffset(TDB, TT, 0, 0.0, π, 6371.0, 0.0)
9.928419814101153e-5
```

### References ###

- [ERFA](https://github.com/liberfa/erfa/blob/master/src/dtdb.c)
"""
function getoffset(::BarycentricDynamicalTime, ::TerrestrialTime, second, fraction, elong, u, v)
    tt = TTEpoch(second, fraction)
    ut = fractionofday(UT1Epoch(tt))
    t = (second + fraction) / (SECONDS_PER_CENTURY * 10.0)
    # Convert UT to local solar time in radians.
    tsol = mod(ut, 1.0) * 2π  + elong

    # FUNDAMENTAL ARGUMENTS:  Simon et al. 1994.
    # Combine time argument (millennia) with deg/arcsec factor.
    w = t / 3600.0
    # Sun Mean Longitude.
    elsun = deg2rad(mod(280.46645683 + 1296027711.03429 * w, 360.0))
    # Sun Mean Anomaly.
    emsun = deg2rad(mod(357.52910918 + 1295965810.481 * w, 360.0))
    # Mean Elongation of Moon from Sun.
    d = deg2rad(mod(297.85019547 + 16029616012.090 * w, 360.0))
    # Mean Longitude of Jupiter.
    elj = deg2rad(mod(34.35151874 + 109306899.89453 * w, 360.0))
    # Mean Longitude of Saturn.
    els = deg2rad(mod(50.07744430 + 44046398.47038 * w, 360.0))
    # TOPOCENTRIC TERMS:  Moyer 1981 and Murray 1983.
    wt = 0.00029e-10 * u * sin(tsol + elsun - els) +
        0.00100e-10 * u * sin(tsol - 2.0 * emsun) +
        0.00133e-10 * u * sin(tsol - d) +
        0.00133e-10 * u * sin(tsol + elsun - elj) -
        0.00229e-10 * u * sin(tsol + 2.0 * elsun + emsun) -
        0.02200e-10 * v * cos(elsun + emsun) +
        0.05312e-10 * u * sin(tsol - emsun) -
        0.13677e-10 * u * sin(tsol + 2.0 * elsun) -
        1.31840e-10 * v * cos(elsun) +
        3.17679e-10 * u * sin(tsol)

    # =====================
    # Fairhead et al. model
    # =====================

    # T**0
    w0 = 0.0
    for j in eachindex(fairhd0)
        @muladd w0 += fairhd0[j][1] * sin(fairhd0[j][2] * t + fairhd0[j][3])
    end
    # T**1
    w1 = 0.0
    for j in eachindex(fairhd1)
        @muladd w1 += fairhd1[j][1] * sin(fairhd1[j][2] * t + fairhd1[j][3])
    end
    # T**2
    w2 = 0.0
    for j in eachindex(fairhd2)
        @muladd w2 += fairhd2[j][1] * sin(fairhd2[j][2] * t + fairhd2[j][3])
    end
    # T**3
    w3 = 0.0
    for j in eachindex(fairhd3)
        @muladd w3 += fairhd3[j][1] * sin(fairhd3[j][2] * t + fairhd3[j][3])
    end
    # T**4
    w4 = 0.0
    for j in eachindex(fairhd4)
        @muladd w4 += fairhd4[j][1] * sin(fairhd4[j][2] * t + fairhd4[j][3])
    end

    # Multiply by powers of T and combine.
    wf = @evalpoly t w0 w1 w2 w3 w4

    # Adjustments to use JPL planetary masses instead of IAU.
    wj = 0.00065e-6 * sin(6069.776754 * t + 4.021194) +
        0.00033e-6 * sin(213.299095 * t + 5.543132) +
        (-0.00196e-6 * sin(6208.294251 * t + 5.696701)) +
        (-0.00173e-6 * sin(74.781599 * t + 2.435900)) +
        0.03638e-6 * t * t

    # TDB-TT in seconds.
    return -(wt + wf + wj)
end

"""
    getoffset(TT, TDB, second, fraction[, eop])

Return the offset between [`TT`](@ref) and [`TDB`](@ref) for the
current epoch (`second` after J2000 and `fraction`) for an observer on earth
in seconds.

### Arguments ###

- `second`, `fraction`: Current epoch
- `elong`: Longitude (east positive, radians)
- `u`: Distance from Earth's spin axis (km)
- `v`: Distance north of equatorial plane (km)

# Example

```jldoctest; setup = :(using AstroTime)
julia> getoffset(TT, TDB, 0, 0.0, π, 6371.0, 0.0)
-9.92841981897215e-5
```

### References ###

- [ERFA](https://github.com/liberfa/erfa/blob/master/src/dtdb.c)
"""
@inline function getoffset(::TerrestrialTime, ::BarycentricDynamicalTime,
                           second, fraction, elong, u, v)
    tt1, tt2 = second, fraction
    tdb1, tdb2 = tt1, tt2
    offset = 0.0
    for _ in 1:3
        offset = -getoffset(TDB, TT, tdb1, tdb2, elong, u, v)
        tdb1, tdb2 = apply_offset(tt1, tt2, offset)
    end
    return offset
end


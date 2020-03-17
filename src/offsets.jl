using ..TimeScales: find_path
using EarthOrientation: getΔUT1
using LeapSeconds: offset_tai_utc, offset_utc_tai
using MuladdMacro

export getoffset, insideleap, NoOffsetError

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
    path = find_path(from, to)
    total_offset = 0.0
    for i in 1:length(path) - 1
        offset = getoffset(path[i], path[i+1], second, fraction)
        total_offset += offset
        second, fraction = apply_offset(second, fraction, offset)
    end
    return total_offset
end

function getoffset(ep::Epoch{S}, scale::TimeScale, args...) where S<:TimeScale
    return getoffset(S(), scale, ep.second, ep.fraction, args...)
end

@inline function apply_offset(second::Int64,
                              fraction::T,
                              from::S1,
                              to::S2)::Tuple{Int64, T} where {T, S1<:TimeScale, S2<:TimeScale}
    path = find_path(from, to)
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
    getoffset(second, fraction, TAI, TT)

Returns the difference TT-TAI in seconds at the epoch `ep`.
"""
getoffset(::InternationalAtomicTime, ::TerrestrialTime, _, _) = OFFSET_TAI_TT
getoffset(::TerrestrialTime, ::InternationalAtomicTime, _, _) = -OFFSET_TAI_TT

#######
# TCG #
#######

const JD77_SEC = -7.25803167816e8
const LG_RATE = 6.969290134e-10

"""
    getoffset(TCG, ep)

Returns the difference TCG-TAI in seconds at the epoch `ep`.
"""
function getoffset(::GeocentricCoordinateTime, ::TerrestrialTime, second, fraction)
    dt = second - JD77_SEC + fraction
    return -LG_RATE * dt
end

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
    getoffset(TCB, ep)

Returns the difference TCB-TAI in seconds at the epoch `ep`.
"""
function getoffset(::BarycentricCoordinateTime, ::BarycentricDynamicalTime, second, fraction)
    dt = second - JD77_SEC + fraction
    return -LB_RATE * dt
end

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

insideleap(ep::Epoch{CoordinatedUniversalTime}) = insideleap(ep |> julian |> value)
insideleap(::Epoch) = false

"""
    getoffset(UTC, ep)

Returns the difference UTC-TAI in seconds at the epoch `ep`.
"""
@inline function getoffset(::CoordinatedUniversalTime, ::InternationalAtomicTime,
                           second, fraction)
    jd = value(j2000(second, fraction) + J2000_TO_JULIAN)
    return -offset_utc_tai(jd)
end

@inline function getoffset(::InternationalAtomicTime, ::CoordinatedUniversalTime,
                           second, fraction)
    jd = value(j2000(second, fraction) + J2000_TO_JULIAN)
    return -offset_tai_utc(jd)
end

#######
# UT1 #
#######

"""
    getoffset(UT1, ep)

Returns the difference UT1-TAI in seconds at the epoch `ep`.
"""
@inline function getoffset(::CoordinatedUniversalTime, ::UniversalTime,
                           second, fraction)
    utc = value(j2000(second, fraction) + J2000_TO_JULIAN)
    return getΔUT1(utc)
end

@inline function getoffset(::UniversalTime, ::CoordinatedUniversalTime,
                           second, fraction)
    ut1 = value(j2000(second, fraction) + J2000_TO_JULIAN)
    utc = ut1 - getΔUT1(ut1) / SECONDS_PER_DAY
    return -getΔUT1(utc)
end

#######
# TDB #
#######

const k = 1.657e-3
const eb = 1.671e-2
const m₀ = 6.239996
const m₁ = 1.99096871e-7

"""
    getoffset(TDB, ep)

Returns the difference TDB-TAI in seconds at the epoch `ep`.

This routine is accurate to ~40 microseconds in the interval 1900-2100.

!!! note
    An accurate transformation between TDB and TT depends on the
    trajectory of the observer. For two observers fixed on Earth's surface
    the quantity TDB-TT can differ by as much as ~4 microseconds. See
    [`getoffset(TDB, ep, elong, u, v)`](@ref).

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

include(joinpath("constants", "tdb.jl"))

"""
    getoffset(TDB, ep, elong, u, v)

Returns the difference TDB-TAI in seconds at the epoch `ep` for an observer on Earth.

### Arguments ###

- `ep`: Current epoch
- `elong`: Longitude (east positive, radians)
- `u`: Distance from Earth's spin axis (km)
- `v`: Distance north of equatorial plane (km)

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


using MuladdMacro

export tai_offset

include(joinpath("constants", "tdb.jl"))

const OFFSET_TAI_TT = 32.184
const LG_RATE = 6.969290134e-10
const LB_RATE = 1.550519768e-8


"""
    tai_offset(ep)

Returns the offset from TAI for the epoch `ep`.
"""
tai_offset(ep::Epoch) = ep.ts_offset

tai_offset(::InternationalAtomicTime, ep) = 0.0

"""
    tai_offset(TT, ep)

Returns the difference TT-TAI in seconds at the epoch `ep`.
"""
tai_offset(::TerrestrialTime, ep) = OFFSET_TAI_TT

"""
    tai_offset(TCG, ep)

Returns the difference TCG-TAI in seconds at the epoch `ep`.
"""
tai_offset(::GeocentricCoordinateTime, ep) = tai_offset(TT, ep) + LG_RATE * value(ep - EPOCH_77)

"""
    tai_offset(TCB, ep)

Returns the difference TCB-TAI in seconds at the epoch `ep`.
"""
tai_offset(::BarycentricCoordinateTime, ep) = tai_offset(TDB, ep) + LB_RATE * value(ep - EPOCH_77)


"""
    tai_offset(UTC, ep)

Returns the difference UTC-TAI in seconds at the epoch `ep`.
"""
@inline function tai_offset(::CoordinatedUniversalTime, ep)
    offset = findoffset(ep)
    offset === nothing && return 0.0

    -getoffset(offset, ep)
end

"""
    tai_offset(UT1, ep)

Returns the difference UT1-TAI in seconds at the epoch `ep`.
"""
@inline function tai_offset(::UniversalTime, ep)
    jd = value(julian(UTC, ep))
    tai_offset(UTC, ep) + getΔUT1(jd)
end

"""
    tai_offset(TDB, ep)

Returns the difference TDB-TAI in seconds at the epoch `ep`.

This routine is accurate to ~40 microseconds in the interval 1900-2100.

!!! note
    An accurate transformation between TDB and TT depends on the
    trajectory of the observer. For two observers fixed on Earth's surface
    the quantity TDB-TT can differ by as much as ~4 microseconds. See
    [`tai_offset(TDB, ep, elong, u, v)`](@ref).

### References ###

- [https://www.cv.nrao.edu/~rfisher/Ephemerides/times.html#TDB](https://www.cv.nrao.edu/~rfisher/Ephemerides/times.html#TDB)
- [Issue #26](https://github.com/JuliaAstro/AstroTime.jl/issues/26)

"""
@inline function tai_offset(::BarycentricDynamicalTime, ep)
    dt = value(j2000(TT, ep))
    g = deg2rad(357.53 + 0.9856003dt)
    tai_offset(TT, ep) + 0.001658sin(g) + 0.000014sin(2g)
end

"""
    tai_offset(TDB, ep, elong, u, v)

Returns the difference TDB-TAI in seconds at the epoch `ep` for an observer on Earth.

### Arguments ###

- `ep`: Current epoch
- `elong`: Longitude (east positive, radians)
- `u`: Distance from Earth's spin axis (km)
- `v`: Distance north of equatorial plane (km)

### References ###

- [ERFA](https://github.com/liberfa/erfa/blob/master/src/dtdb.c)
"""
function tai_offset(::BarycentricDynamicalTime, ep, elong, u, v)
    ut = fractionofday(UT1Epoch(ep))
    t = value(centuries(j2000(TT, ep))) / 10.0
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
    w = wt + wf + wj

    tai_offset(TT, ep) + w
end

tai_offset(::InternationalAtomicTime, date::Date, time::Time) = 0.0

@inline function tai_offset(::CoordinatedUniversalTime, date::Date, time::Time)
    minute_in_day = hour(time) * 60 + minute(time)
    correction = minute_in_day < 0 ? (minute_in_day - 1439) ÷ 1440 : minute_in_day ÷ 1440
    offset = findoffset(julian(date) + correction)
    offset === nothing && return 0.0

    getoffset(offset, date, time)
end

@inline function tai_offset(scale, date::Date, time::Time, args...)
    ref = Epoch{TAI}(date, time)
    offset = 0.0
    # TODO: Maybe replace this with a simple convergence check
    for _ in 1:8
        offset = -tai_offset(scale, Epoch{TAI}(ref, offset), args...)
    end
    offset
end

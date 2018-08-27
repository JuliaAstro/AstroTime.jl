using MuladdMacro

export tai_offset

include(joinpath("constants", "tdb.jl"))

const OFFSET_TAI_TT = 32.184
const LG_RATE = 6.969290134e-10
const LB_RATE = 1.550519768e-8

tai_offset(ep::Epoch{S}) where {S} = tai_offset(S, ep)

tai_offset(::InternationalAtomicTime, ep) = 0.0
tai_offset(::TerrestrialTime, ep) = OFFSET_TAI_TT
tai_offset(::GeocentricCoordinateTime, ep) = tai_offset(TT, ep) + LG_RATE * get(ep - EPOCH_77)
tai_offset(::BarycentricCoordinateTime, ep) = tai_offset(TDB, ep) + LB_RATE * get(ep - EPOCH_77)

function tai_offset(::CoordinatedUniversalTime, ep)
    offset = findoffset(ep)
    offset === nothing && return 0.0

    -getoffset(offset, ep)
end

function tai_offset(::UniversalTime, ep)
    jd = julian(UTC, ep)
    tai_offset(UTC, ep) + getΔUT1(jd)
end

"""
    tai_offset(TDB, ep)

Computes difference TDB-TAI in seconds at the epoch `ep`.

The accuracy of this routine is approx 40 microseconds in interval 1900-2100 AD.
Note that an accurate transformation betweem TDB and TT depends on the
trajectory of the observer. For two observers fixed on the earth surface
the quantity TDB-TT can differ by as much as about 4 microseconds.

### References ###

1. [https://www.cv.nrao.edu/~rfisher/Ephemerides/times.html#TDB](https://www.cv.nrao.edu/~rfisher/Ephemerides/times.html#TDB)
2. [Issue #26](https://github.com/JuliaAstro/AstroTime.jl/issues/26)

"""
function tai_offset(::BarycentricDynamicalTime, ep)
    dt = j2000(TT, ep)
    g = 357.53 + 0.9856003dt
    tai_offset(TT, ep) + 0.001658sind(g) + 0.000014sind(2g)
end

function tai_offset(::BarycentricDynamicalTime, ep, ut, elong, u, v)
    t = get(centuries(j2000(TT, ep) * days)) / 10.0
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

tai_offset(::InternationalAtomicTime, date, time) = 0.0

function tai_offset(::CoordinatedUniversalTime, date, time)
    minute_in_day = hour(time) * 60 + minute(time)
    correction  = minute_in_day < 0 ? (minute_in_day - 1439) ÷ 1440 : minute_in_day ÷ 1440;
    offset = findoffset(AstroDates.julian(date) + correction)
    offset === nothing && return 0.0

    getoffset(offset, date, time)
end

function tai_offset(scale, date, time)
    ref = Epoch{TAI}(date, time)
    offset = 0.0
    for _ in 1:8
        offset = -tai_offset(scale, Epoch{TAI}(ref, offset))
    end
    offset
end

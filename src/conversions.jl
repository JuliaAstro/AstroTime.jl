using ItemGraphs: ItemGraph, add_edge!, edgeitems

using MuladdMacro
using LeapSeconds
using ..Periods

export @transform

abstract type Transformation end

const registry = ItemGraph{TimeScale, Transformation}()

macro transform(from::Symbol, to::Symbol, ep::Symbol, args...)
    trans = Symbol(from, "to", to)
    epoch = Expr(:escape, ep)
    func = quote
        @inline function (::$(esc(trans)))($epoch::Epoch{$from})::Epoch{$to}
            $(args[end])
        end
    end

    arglist = func.args[end].args[end].args[1].args[1].args
    for a in args[1:end-1]
        if a isa Expr && a.head == :(=)
            arg = Expr(:kw, Expr(:escape, a.args[1]), a.args[2:end]...)
        else
            arg = Expr(:escape, a)
        end
        push!(arglist, arg)
    end

    quote
        struct $trans <: Transformation end
        add_edge!(registry, $from, $to, $(esc(trans))())
        $func
        $(esc(Epoch)){$(esc(to))}(ep::Epoch{$from, T}, args...) where {T} = $trans()(ep, args...)
    end
end


"""
    taiutc(jd1, jd2)

Transform a two-part Julian date from `TAI` to `UTC`.

# Example

```jldoctest
julia> tai  = Epoch{TAI}(2.4578265e6, 0.30477440993249416)
2017-03-14T07:18:52.509 TAI
julia> AstroTime.Epochs.taiutc(tai.jd1, tai.jd2)
(2.4578265e6, 0.30434616919175345)
```
"""
@inline function taiutc(jd1, jd2)
    big1 = jd1 >= jd2
    if  big1
        a1 = jd1
        a2 = jd2
    else
        a1 = jd2
        a2 = jd1
    end

    u1 = a1
    u2 = a2
    for i in 1:3
        tai1, tai2 = utctai(u1, u2)
        u2 += a1 - tai1
        u2 += a2 - tai2
    end

    if  big1
        date = u1
        date1 = u2
    else
        date = u2
        date1 = u1
    end
    date, date1
end


"""
    tttai(jd1, jd2)

Transform a two-part Julian date from `TT` to `TAI`.

# Example

```jldoctest
julia> tt  = Epoch{TT}(2.4578265e6, 0.30477440993249416)
2017-03-14T07:18:20.325 TT
julia> AstroTime.Epochs.tttai(tt.jd1, tt.jd2)
(2.4578265e6, 0.30440190993249416)
```
"""
@inline function tttai(jd1, jd2)
    dtat = OFFSET_TT_TAI/SECONDS_PER_DAY;
    if jd1 > jd2
        jd1 = jd1
        jd2 -= dtat
    else
        jd1 -= dtat
        jd2 = jd2
    end
    jd1, jd2
end


"""
    taitt(jd1, jd2)

Transform a two-part Julian date from `TAI` to `TT`.

# Example

```jldoctest
julia> tai = Epoch{TAI}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 TAI
julia> AstroTime.Epochs.taitt(tai.jd1, tai.jd2)
(2.4578265e6, 0.30477440993249416)
```
"""
@inline function taitt(jd1, jd2)
    dtat = OFFSET_TT_TAI / SECONDS_PER_DAY
    if jd1 > jd2
        jd1 = jd1
        jd2 = jd2 + dtat
    else
        jd1 = jd1 + dtat
        jd2 = jd2
    end
    jd1, jd2
end


"""
    ut1tai(jd1, jd2, dta)

Transform a two-part Julian date from `UT1` to `TAI`.

# Example

```jldoctest
julia> ut1 = Epoch{UT1}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 UT1
julia> AstroTime.Epochs.ut1tai(ut1.jd1, ut1.jd2, AstroTime.Epochs.dut1(ut1)-AstroTime.Epochs.offset_tai_utc(julian(ut1)))
(2.4578265e6, 0.3048243932182868)
```
"""
@inline function ut1tai(jd1, jd2, dta)
    dtad = dta / SECONDS_PER_DAY
    if jd1 > jd2
        date = jd1
        date1 = jd2 - dtad
    else
        date = jd1 - dtad
        date1 = jd2
    end
    date, date1
end

"""
    taiut1(jd1, jd2, dta)

Transform a two-part Julian date from `TAI` to `UT1`.

# Example

```jldoctest
julia> tai = Epoch{TAI}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 TAI
julia> AstroTime.Epochs.ut1tai(tai.jd1, tai.jd2, AstroTime.Epochs.dut1(tai)-AstroTime.Epochs.offset_tai_utc(julian(tai)))
(2.4578265e6, 0.30477440993249416)
```
"""
@inline function taiut1(jd1, jd2, dta)
    dtad = dta / SECONDS_PER_DAY
    if jd1 > jd2
        date = jd1
        date1 = jd2 + dtad
    else
        date = jd1 + dtad
        date1 = jd2
    end
    date, date1
end


"""
    tcgtt(jd1, jd2)

Transform a two-part Julian date from `TCG` to `TT`.

# Example

```jldoctest
julia> tcg = Epoch{TCG}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 TCG
julia> AstroTime.Epochs.tcgtt(tcg.jd1, tcg.jd2)
(2.4578265e6, 0.30440190993249416)
```
"""
@inline function tcgtt(jd1, jd2)
    t77t = MOD_JD_77 + OFFSET_TT_TAI / SECONDS_PER_DAY
    if jd1 > jd2
        date = jd1
        date1 = jd2 - ((jd1 - MJD) + (jd2 - t77t)) * ELG
    else
        date = jd1 - ((jd2 - MJD) + (jd1 - t77t)) * ELG
        date1 = jd2
    end
    date, date1
end


"""
    tttcg(jd1, jd2)

Transform a two-part Julian date from `TT` to `TCG`.

# Example

```jldoctest
julia> tt = Epoch{TT}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 TT
julia> AstroTime.Epochs.tttgc(tt.jd1, tt.jd2)
(2.4578265e6, 0.30440190993249416)
```
"""
@inline function tttcg(jd1, jd2)
    t77t = MOD_JD_77 + OFFSET_TT_TAI / SECONDS_PER_DAY
    elgg = ELG/(1.0-ELG)
    if jd1 > jd2
        date = jd1
        date1 = jd2 + ((jd1 - MJD) + (jd2 - t77t)) * elgg
    else
        date = jd1 + ((jd2 - MJD) + (jd1 - t77t)) * elgg
        date1 = jd2
    end
    date, date1
end

"""
    tdbtt(jd1, jd2, dtr)

Transform a two-part Julian date from `TDB` to `TT`.

# Example

```jldoctest
julia> tdb = Epoch{TDB}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 TDB
julia> AstroTime.Epochs.tdbtt(tdb.jd1, tdb.jd2, AstroTime.Epochs.deltatr(tdb))
(2.4578265e6, 0.30440190993249416)
```
"""
@inline function tdbtt(jd1, jd2, dtr)
    dtrd = dtr / SECONDS_PER_DAY
    if jd1 > jd2
        date = jd1
        date1 = jd2 - dtrd
    else
        date = jd1 - dtrd
        date1 = jd2
    end
    date, date1
end

"""
    diff_tdb_tt(jd1, jd2)

Computes difference TDB-TT in seconds at time JD (julian days)
The timescale for the input JD can be either TDB or TT.

The accuracy of this routine is approx 40 microseconds in interval 1900-2100 AD.
Note that an accurate transformation betweem TDB and TT depends on the
trajectory of the observer. For two observers fixed on the earth surface
the quantity TDB-TT can differ by as much as about 4 microseconds.

### References ###

1. [https://www.cv.nrao.edu/~rfisher/Ephemerides/times.html#TDB](https://www.cv.nrao.edu/~rfisher/Ephemerides/times.html#TDB)
2. [Issue #26](https://github.com/JuliaAstro/AstroTime.jl/issues/26)

"""
function diff_tdb_tt(jd1, jd2)
    g = 357.53 + 0.9856003((jd1 - J2000) + jd2)
    0.001658sind(g) + 0.000014sind(2g)
end

diff_tdb_tt(ep::Epoch) = diff_tdb_tt(julian1(ep), julian2(ep))

function diff_tdb_tt(jd1, jd2, ut, elong, u, v)
    t = ((jd1 - J2000) + jd2) / DAYS_PER_MILLENNIUM
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
        0.00033e-6 * sin( 213.299095 * t + 5.543132) +
        (-0.00196e-6 * sin(6208.294251 * t + 5.696701)) +
        (-0.00173e-6 * sin(  74.781599 * t + 2.435900)) +
        0.03638e-6 * t * t
    # ============
    # Final result
    # ============
    # TDB-TT in seconds.
    w = wt + wf + wj
end

@inline function diff_ut1_tt(ep::Epoch)
    leapsec = offset_tai_utc(julian(ep))
    ΔUT1 = dut1(ep)
    OFFSET_TT_TAI + leapsec - ΔUT1
end

"""
    tttdb(jd1, jd2, dtr)

Transform a two-part Julian date from `TT` to `TDB`.

# Example

```jldoctest
julia> tt = Epoch{TT}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 TT
julia> AstroTime.Epochs.tttdb(tt.jd1, tt.jd2, AstroTime.Epochs.deltatr(tdb))
(2.4578265e6, 0.30440190993249416)
```
"""
@inline function tttdb(jd1, jd2, dtr)
    dtrd = dtr / SECONDS_PER_DAY
    if jd1 > jd2
        date = jd1
        date1 = jd2 + dtrd
    else
        date = jd1 + dtrd
        date1 = jd2
    end
    date, date1
end

"""
    ttut1(jd1, jd2, dt)

Transform a two-part Julian date from `TT` to `UT1`.

# Example

```jldoctest
julia> tt = Epoch{tt}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 TT
julia> AstroTime.Epochs.ttut1(tt.jd1, tt.jd2, AstroTime.Epochs.deltat(tt))
(2.4578265e6, 0.30440190993249416)
```
"""
@inline function ttut1(jd1, jd2, dt)
    dtd = dt / SECONDS_PER_DAY
    if jd1 > jd2
        date = jd1
        date1 = jd2 - dtd
    else
        date = jd1 - dtd
        date1 = jd2
    end
    date, date1
end

"""
    ut1tt(jd1, jd2, dt)

Transform a two-part Julian date from `UT1` to `TT`.

# Example

julia> ut1 = Epoch{UT1}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 UT1
julia> AstroTime.Epochs.ut1tt(ut1.jd1, ut1.jd2, AstroTime.Epochs.deltat(ut1))
(2.4578265e6, 0.30440190993249416)
```
"""
@inline function ut1tt(jd1, jd2, dt)
    dtd = dt / SECONDS_PER_DAY
    if jd1 > jd2
        date = jd1
        date1 = jd2 + dtd
    else
        date = jd1 + dtd
        date1 = jd2
    end
    date, date1
end

"""
    tdbtcb(jd1, jd2)

Transform a two-part Julian date from `TDB` to `TCB`.

# Example

julia> tdb = Epoch{TDB}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 TDB
julia> AstroTime.Epochs.tdbtcb(tdb.jd1, tdb.jd2)
(2.4578265e6, 0.30440190993249416)
```
"""
@inline function tdbtcb(jd1, jd2)
    t77td = MJD + MOD_JD_77
    t77tf = OFFSET_TT_TAI/SECONDS_PER_DAY
    jd0 = TDB0/SECONDS_PER_DAY
    elbb = ELB/(1.0-ELB)
    if jd1 > jd2
        d = t77td - jd1
        f  = jd2 - jd0
        date = jd1
        date1 = f - ( d - ( f - t77tf ) ) * elbb
    else
        d = t77td - jd2
        f  = jd1 - jd0
        date = f + ( d - ( f - t77tf ) ) * elbb
        date1 = jd2
    end
    date, date1
end

"""
    tcbtdb(jd1, jd2)

Transform a two-part Julian date from `TCB` to `TDB`.

# Example

julia> ut1 = Epoch{TCB}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 TCB1
julia> AstroTime.Epochs.tcbtdb(tcb.jd1, tcb.jd2)
(2.4578265e6, 0.30440190993249416)
```
"""
@inline function tcbtdb(jd1, jd2)
    t77td = MJD + MOD_JD_77
    t77tf = OFFSET_TT_TAI/SECONDS_PER_DAY
    jd0 = TDB0/SECONDS_PER_DAY
    if jd1 > jd2
        d = jd1 - t77td
        date = jd1
        date1 = jd2 + jd0 - ( d + ( jd2 - t77tf ) ) * ELB
    else
        d = jd2 - t77td;
        date = jd1 + jd0 - ( d + ( jd1 - t77tf ) ) * ELB
        date1 = jd2
    end
    date, date1
end

function jd2cal(jd1, jd2)
    dj = jd1 + jd2
    if dj < JD_MIN || dj > JD_MAX
        throw(ArgumentError("Julian date is outside of the representable range ($JD_MIN, $JD_MAX)."))
    end

    if jd1 >= jd2
        date = jd1
        date1 = jd2
    else
        date = jd2
        date1 = jd1
    end

    date1 -= 0.5

    f1 = mod(date, 1.0)
    f2 = mod(date1, 1.0)
    f = mod(f1 + f2, 1.0)
    if f < 0.0
        f += 1.0
    end
    d = round(date-f1) + round(date1-f2) + round(f1+f2-f)
    jd = Int(round(d) + 1)

    l = jd + 68569
    n = (4 * l) ÷ 146097
    l -= (146097 * n + 3) ÷ 4
    i = (4000 * (l + 1)) ÷ 1461001
    l -= (1461 * i) ÷ 4 - 31
    k = (80 * l) ÷ 2447
    id = Int(floor((l - (2447 * k) ÷ 80)))
    l = k ÷ 11
    im = Int(floor((k + 2 - 12 * l)))
    iy = Int(floor((100 * (n - 49) + i + l)))

    iy, im, id, f
end

function cal2jd(iy, im, id)
    EYEAR_ALLOWED = -4799
    MON_LENGTH = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    if iy < EYEAR_ALLOWED
        throw(ArgumentError("Year is outside of the representable range (< $EYEAR_ALLOWED)"))
    end

    if im < 1 || im > 12
        throw(ArgumentError("Month is outside of the range (1,12)"))
    end

    # Check if leap year
    ly = ((im == 2 ) && !(iy % 4 != 0) && ((iy % 100 != 0) || !(iy % 400 != 0))) ? 1 : 0

    if ((id < 1) || (id > (MON_LENGTH[im] + ly)))
        throw(ArgumentError("Day is outside of permissible range (1, $(MON_LENGTH[im]))"))
    end

    my = (im - 14) ÷ 12
    iypmy = trunc(Int,(iy + my))
    jd = MJD
    jd1 = float((((1461 * (iypmy + 4800)) ÷ 4)
        + (367 * trunc(Int,(im - 2 - 12 * my))) ÷ 12
        - (3 * ((iypmy + 4900) ÷ 100)) ÷ 4
        + trunc(Int,id) - 2432076))

    jd, jd1
end

"""
    utctai(jd1, jd2)

Transform a two-part Julian date from `UTC` to `TAI`.

# Example

```jldoctest
julia> utc  = Epoch{UTC}(2.4578265e6, 0.30477440993249416)
2017-03-14T07:18:52.509 UTC
julia> AstroTime.Epochs.utctai(utc.jd1, utc.jd2)
(2.4578265e6, 0.3052026506732349)
```
"""
function utctai(jd1, jd2)
    big1 = jd1 >= jd2
    if big1
        u1 = jd1
        u2 = jd2
    else
        u1 = jd2
        u2 = jd1
    end

    iy, im, id, fd = jd2cal(u1, u2)
    u2 -= fd
    drift0 = offset_tai_utc(u1 +  u2)
    drift12 = offset_tai_utc(u1 + u2 + 0.5)
    drift24 = offset_tai_utc(u1 + u2 + 1.5)

    dlod = 2.0 * (drift12 - drift0)
    dleap = drift24 - (drift0 + dlod)

    fd *= (SECONDS_PER_DAY + dleap)/SECONDS_PER_DAY
    fd *= (SECONDS_PER_DAY + dlod)/SECONDS_PER_DAY

    z1, z2 = cal2jd(iy, im, id)

    a2 = z1 - u1
    a2 += z2
    a2 += fd + drift0 / SECONDS_PER_DAY
    if big1
        date = u1
        date1 = a2
    else
        date = a2
        date1 = u1
    end
    date, date1
end


"""
    datetime2julian(scale::T, year, month, date, hour, min, sec) where {T <: TimeScale}

Transforms DateTime field to two-part Julian Date, special provision for leap seconds is provided.

# Example

```jldoctest
julia> AstroTime.Epochs.datetime2julian(UTC, 2016, 12, 31, 23, 59, 60)
(2.4577535e6, 0.9999884260598836)
julia> AstroTime.Epochs.datetime2julian(TT, 2017, 2, 1, 23, 59, 59)
(2.4577855e6, 0.999988425925926)
```
"""
function datetime2julian(scale::T, year, month, date, hour, min, sec) where {T <: TimeScale}

    jd = sum(cal2jd(year, month, date))
    seclim = 60.0
    adjusted_seconds_per_day = SECONDS_PER_DAY
    if hour < 0 || hour > 23
        throw(ArgumentError("The input hour value should be between 0 and 23"))
    end
    if min < 0 || min > 59
        throw(ArgumentError("The input minute value should be between 0 and 59"))
    end

    if scale == UTC
        dat0 = offset_tai_utc(jd)
        dat12 = offset_tai_utc(jd + 0.5)
        dat24 = offset_tai_utc(jd + 1.5)

        dleap = dat24 - (2.0 * dat12 - dat0)
        adjusted_seconds_per_day = SECONDS_PER_DAY + dleap
        if hour == 23 && min == 59
            seclim += dleap
        end
    end

    if sec < 0
        throw(ArgumentError("The input second value should be greater than 0"))
    end

    if sec >= seclim
        throw(ArgumentError("Time exceeds the maximum seconds in $(year)-$(month)-$(date)"))
    end

    time  = ( 60.0 * ( 60.0 * hour + min )  + sec ) / adjusted_seconds_per_day
    jd, time
end

function d2tf(ndp, days)
    sign = (days >= 0.0 ) ? '+' : '-'
    a = SECONDS_PER_DAY * abs(days)

    if ndp < 0
        nrs = 1
        for n in 1:-ndp
            nrs *= (n == 2 || n == 4) ? 6 : 10
        end
        w = a / nrs
        a = nrs * round(w)
    end

    nrs = 1
    for n in 1:ndp
        nrs *= 10
    end
    rm = nrs * 60.0
    rh = rm * 60.0

    a = round(nrs * a)
    ah = floor(a / rh)
    a -= ah * rh
    am = floor(a / rm)
    a -= am * rm
    as = floor(a / nrs)
    af = floor(a - as * nrs)
    sign, Int(ah), Int(am), Int(as), Int(af)
end

"""
    utcut1(jd1, jd2, dut1, dat)

Transform a two-part Julian date from `UTC` to `UT1`.

# Example

```jldoctest
julia> utc  = Epoch{UTC}(2.4578265e6, 0.30477440993249416)
2017-03-14T07:18:52.509 UTC
julia> AstroTime.Epochs.utcut1(utc.jd1, utc.jd2, Epochs.dut1(utc), offset_tai_utc(julian(utc)))
(2.4578265e6, 0.30477440993249416)
```
"""
@inline function utcut1(jd1, jd2, dut1, dat)
    jd = +(jd1, jd2)
    dta = dut1 - dat
    tai1, tai2 = utctai(jd1, jd2)
    date, date1 = taiut1(tai1, tai2, dta)
    date, date1
end

function julian2datetime(scale::T, ndp, jd1, jd2) where T <: TimeScale
    a1 = jd1
    b1 = jd2
    jd = jd1 + jd2

    year1, month1, day1, frac1 = jd2cal(a1, b1)

    leap = 0

    if scale == UTC
        dat0 = offset_tai_utc(jd - frac1)
        dat12 = offset_tai_utc(jd - frac1 +0.5)
        dat24 = offset_tai_utc(jd + 1.5 - frac1)
        dleap = dat24 - (2.0 * dat12 - dat0)
        leap = dleap != 0.0
        if leap
            frac1 += frac1 * dleap / SECONDS_PER_DAY
        end
    end

    sign, hour, min, sec, fracd = d2tf(ndp, frac1)

    if hour > 23
        year2, month2, day2, frac2 = jd2cal(a1+1.5, b1-frac1)
        if !leap
            year1 = year2
            month1 = month2
            day1 = day2
            hour = 0
            min = 0
            sec = 0
        else
            if min > 0
                year1 = year2
                month1 = month2
                day1 = day2
                hour = 0
                min = 0
                sec = 0
            else
                hour = 23
                min = 59
                sec = 60
            end
            if ndp < 0 && min == 60
                year1 = year2
                month1 = month2
                day1 = day2
                hour = 0
                min = 0
                sec = 0
            end
        end
    end

    year1, month1, day1, hour, min, sec, fracd
end

"""
    ut1utc(jd1, jd2, dut1)

Transform a two-part Julian date from `UT1` to `UTC`.

# Example

```jldoctest
julia> ut1  = Epoch{UT1}(2.4578265e6, 0.30477440993249416)
2017-03-14T07:18:52.509 UT1
julia> AstroTime.Epochs.ut1utc(ut1.jd1, ut1.jd2, Epochs.dut1(ut1))
(2.4578265e6, 0.3047686523910154)
```
"""
function ut1utc(jd1, jd2, dut1)
    duts = dut1
    big1 = jd1 >= jd2
    if big1
        u1 = jd1
        u2 = jd2
    else
        u1 = jd2
        u2 = jd1
    end
    d1 = u1
    dats1 = 0
    for i in -1:3
        d2 = u2 + float(i)
        year, month, day, frac = jd2cal(d1, d2)
        dats2 = offset_tai_utc(d1 + d2 - frac)
        if i == - 1
            dats1 = dats2
        end
        ddats = dats2 - dats1
        if abs(ddats) >= 0.5
            if ddats * duts >= 0
                duts -= ddats
            end
            d1, d2 = cal2jd(year, month, day)
            us1 = d1
            us2 = d2 - 1.0 + duts / SECONDS_PER_DAY
            du = u1 - us1
            du += u2 - us2
            if  du > 0
                fd = du * SECONDS_PER_DAY / ( SECONDS_PER_DAY + ddats )
                duts += ddats * ( frac <= 1.0 ? frac : 1.0 )
            end
            break
        end
        dats1 = dats2
    end
    u2 -= duts / SECONDS_PER_DAY
    if big1
        date = u1
        date1 = u2
    else
        date = u2
        date1 = u1
    end
    date, date1
end

# TAI <-> UTC
@transform UTC TAI ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = utctai(jd1, jd2)
    TAIEpoch(date, date1)
end

@transform TAI UTC ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = taiutc(jd1, jd2)
    UTCEpoch(date, date1)
end

# UTC <-> UT1
@transform UT1 UTC ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ut1utc(jd1, jd2, dut1(ep))
    UTCEpoch(date, date1)
end

@transform UTC UT1 ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = utcut1(jd1, jd2, dut1(ep), offset_tai_utc(julian(ep)))
    UT1Epoch(date, date1)
end

# TAI <-> UT1
@transform UT1 TAI ep Δt=dut1(ep)-offset_tai_utc(ep) begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ut1tai(jd1, jd2, Δt)
    TAIEpoch(date, date1)
end

@transform TAI UT1 ep Δt=dut1(ep)-offset_tai_utc(ep) begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = taiut1(jd1, jd2, Δt)
    UT1Epoch(date, date1)
end

# TT <-> UT1
@transform UT1 TT ep Δt=diff_ut1_tt(ep) begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ut1tt(jd1, jd2, Δt)
    TTEpoch(date, date1)
end

@transform TT UT1 ep Δt=diff_ut1_tt(ep) begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ttut1(jd1, jd2, Δt)
    UT1Epoch(date, date1)
end

# TAI <-> TT
@transform TT TAI ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = tttai(jd1, jd2)
    TAIEpoch(date, date1)
end

@transform TAI TT ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = taitt(jd1, jd2)
    TTEpoch(date, date1)
end

# TT <-> TCG
@transform TCG TT ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = tcgtt(jd1, jd2)
    TTEpoch(date, date1)
end

@transform TT TCG ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = tttcg(jd1, jd2)
    TCGEpoch(date, date1)
end

# TT <-> TDB
@transform TDB TT ep Δtr=diff_tdb_tt(ep) begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = tdbtt(jd1, jd2, Δtr)
    TTEpoch(date, date1)
end

@transform TT TDB ep Δtr=diff_tdb_tt(ep) begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = tttdb(jd1, jd2, Δtr)
    TDBEpoch(date, date1)
end

# TDB <-> TCB
@transform TCB TDB ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = tcbtdb(jd1, jd2)
    TDBEpoch(date, date1)
end

@transform TDB TCB ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = tdbtcb(jd1, jd2)
    TCBEpoch(date, date1)
end

"""
    Epoch{T}(ep::Epoch{S}) where {T}, S}

Convert an `Epoch` with timescale `S` to an `Epoch` with timescale `T`.

# Example

```jldoctest
julia> Epoch{TT}(Epoch{TAI}(2000, 1, 1))
2000-01-01T00:00:32.184 TT
```
"""
function Epoch{T}(ep::Epoch{S}) where {T,S}
    transformations = edgeitems(registry, S, T)
    rescale(ep, transformations...)
end

Epoch{T}(ep::Epoch{T}) where {T} = ep

@generated function rescale(ep, transformations...)
    ex = :(ep)
    for trans in transformations
        ex = :($trans()($ex))
    end
    ex
end

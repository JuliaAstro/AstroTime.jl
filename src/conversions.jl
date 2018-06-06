using ItemGraphs: ItemGraph, add_edge!, edgeitems

using MuladdMacro
using ..Periods
export @transform

using ..LeapSeconds

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
@inline function utctai(jd1, jd2)
    ls = leapseconds(jd1 + jd2)
    dtat = ls/SECONDS_PER_DAY;
    if jd1 > jd2
        jd1 = jd1
        jd2 += dtat
    else
        jd1 += dtat
        jd2 = jd2
    end
    jd1, jd2
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
    ls = leapseconds(jd1 + jd2)
    dtat = ls/SECONDS_PER_DAY;
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
julia> AstroTime.Epochs.ut1tai(ut1.jd1, ut1.jd2, AstroTime.Epochs.dut1(ut1)-AstroTime.Epochs.leapseconds(julian(ut1)))
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
julia> AstroTime.Epochs.ut1tai(tai.jd1, tai.jd2, AstroTime.Epochs.dut1(tai)-AstroTime.Epochs.leapseconds(julian(tai)))
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
    leapsec = leapseconds(julian(ep))
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


function cal2jd(iy, im, id)
    EYEAR_ALLOWED = -4799
    MON_LENGTH = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    if iy < EYEAR_ALLOWED
        throw(ArugumentError("Year is outside of the representable range (< $EYEAR_ALLOWED)"))
    end

    if im < 1 || im > 12
        throw(ArugumentError("Month is outside of the range (1,12)"))
    end

    ly = ((im == 2 ) && !(iy % 4) && (iy % 100 || !(iy % 400))) #check if leap year

    if ((id < 1) || (id > MON_LENGTH[im] + ly)))
         throw(ArugumentError("Day is outside of permissible range (1, $(MON_LENGTH[im]))"))
    end

    my = (im - 14)/12
    iypmy = iy + my
    jd = MJD
    jd1 = ((1461 * (iypmy + 4800))/ 4)
          + (367 * Int(floor(im - 2 - 12 * my))) / 12
          - (3 * ((iypmy + 4900) / 100)) / 4
          + Int(floor(id - 2432076))

    jd, jd1
end



# TAI <-> UTC
@transform UTC TAI ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.utctai(jd1, jd2)
    TAIEpoch(date, date1)
end

@transform TAI UTC ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.taiutc(jd1, jd2)
    UTCEpoch(date, date1)
end

# UTC <-> UT1
@transform UT1 UTC ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.ut1utc(jd1, jd2, dut1(ep))
    UTCEpoch(date, date1)
end

@transform UTC UT1 ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.utcut1(jd1, jd2, dut1(ep))
    UT1Epoch(date, date1)
end

# TAI <-> UT1
@transform UT1 TAI ep Δt=dut1(ep)-leapseconds(ep) begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ut1tai(jd1, jd2, Δt)
    TAIEpoch(date, date1)
end

@transform TAI UT1 ep Δt=dut1(ep)-leapseconds(ep) begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = taiut1(jd1, jd2, Δt)
    UT1Epoch(date, date1)
end

# TT <-> UT1
@transform UT1 TT ep Δt=diff_ut1_tt(ep) begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.ut1tt(jd1, jd2, Δt)
    TTEpoch(date, date1)
end

@transform TT UT1 ep Δt=diff_ut1_tt(ep) begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.ttut1(jd1, jd2, Δt)
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
    date, date1 = ERFA.tcgtt(jd1, jd2)
    TTEpoch(date, date1)
end

@transform TT TCG ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.tttcg(jd1, jd2)
    TCGEpoch(date, date1)
end

# TT <-> TDB
@transform TDB TT ep Δtr=diff_tdb_tt(ep) begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.tdbtt(jd1, jd2, Δtr)
    TTEpoch(date, date1)
end

@transform TT TDB ep Δtr=diff_tdb_tt(ep) begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.tttdb(jd1, jd2, Δtr)
    TDBEpoch(date, date1)
end

# TDB <-> TCB
@transform TCB TDB ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.tcbtdb(jd1, jd2)
    TDBEpoch(date, date1)
end

@transform TDB TCB ep begin
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.tdbtcb(jd1, jd2)
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

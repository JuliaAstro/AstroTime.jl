import Convertible: findpath, haspath

using ..Periods
export rescale

using ..LeapSeconds

"""
    tttai(jd1, jd2)

Transform a two-part Julia date from `TT` to `TAI`.

# Example

```jldoctest
julia> tt  = Epoch{TT}(2.4578265e6, 0.30477440993249416)
2017-03-14T07:18:20.325 TT
julia> AstronomicalTime.Epochs.tttai(tt.jd1, tt.jd2)
(2.4578265e6, 0.30440190993249416)
```
"""
function tttai(jd1, jd2)
    dtat = OFFSET_TT_TAI/SECONDS_PER_DAY
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

Transform a two-part Julia date from `TAI` to `TT`.

# Example

```jldoctest
julia> tai = Epoch{TAI}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 TAI
julia> AstronomicalTime.Epochs.taitt(tai.jd1, tai.jd2)
(2.4578265e6, 0.30477440993249416)
```
"""
function taitt(jd1, jd2)
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

Transform a two-part Julia date from `UT1` to `TAI`.

# Example

```jldoctest
julia> ut1 = Epoch{UT1}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 UT1
julia> AstronomicalTime.Epochs.ut1tai(ut1.jd1, ut1.jd2, AstronomicalTime.Epochs.dut1(ut1)-AstronomicalTime.Epochs.leapseconds(julian(ut1)))
(2.4578265e6, 0.3048243932182868)
```
"""
function ut1tai(jd1, jd2, dta)
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

Transform a two-part Julia date from `TAI` to `UT1`.

# Example

```jldoctest
julia> tai = Epoch{TAI}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 TAI
julia> AstronomicalTime.Epochs.ut1tai(tai.jd1, tai.jd2, AstronomicalTime.Epochs.dut1(tai)-AstronomicalTime.Epochs.leapseconds(julian(tai)))
(2.4578265e6, 0.30477440993249416)
```
"""
function taiut1(jd1, jd2, dta)
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

Transform a two-part Julia date from `TCG` to `TT`.

# Example

```jldoctest
julia> tcg = Epoch{TCG}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 TCG
julia> AstronomicalTime.Epochs.tcgtt(tcg.jd1, tcg.jd2)
(2.4578265e6, 0.30440190993249416)
```
"""
function tcgtt(jd1, jd2)
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

Transform a two-part Julia date from `TT` to `TCG`.

# Example

```jldoctest
julia> tt = Epoch{TT}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 TT
julia> AstronomicalTime.Epochs.tttgc(tt.jd1, tt.jd2)
(2.4578265e6, 0.30440190993249416)
```
"""
function tttcg(jd1, jd2)
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

Transform a two-part Julia date from `TT` to `TCG`.

# Example

```jldoctest
julia> tdb = Epoch{TDB}(2.4578265e6, 0.30440190993249416)
2017-03-14T07:18:20.325 TDB
julia> AstronomicalTime.Epochs.tdbgc(tdb.jd1, tdb.jd2, )
(2.4578265e6, 0.30440190993249416)
```
"""
function tdbtt(jd1, jd2, dtr)
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


function dtdb(jd1, jd2, ut, elong, u, v)

    t = ((jd1 - DJ00) + jd2) / DJM
    # Convert UT to local solar time in radians.
     tsol = mod(ut, 1.0) * 2π  + elong

    # FUNDAMENTAL ARGUMENTS:  Simon et al. 1994.
    # Combine time argument (millennia) with deg/arcsec factor.
     w = t / 3600.0
    # Sun Mean Longitude.
     elsun = mod(280.46645683 + 1296027711.03429 * w, 360.0) * DEG_2R
    # Sun Mean Anomaly.
     emsun = mod(357.52910918 + 1295965810.481 * w, 360.0) * DEG_2R
    # Mean Elongation of Moon from Sun.
     d = mod(297.85019547 + 16029616012.090 * w, 360.0) * DEG_2R
    # Mean Longitude of Jupiter.
     elj = mod(34.35151874 + 109306899.89453 * w, 360.0) * DEG_2R
    # Mean Longitude of Saturn.
     els = mod(50.07744430 + 44046398.47038 * w, 360.0) * DEG_2R
    # TOPOCENTRIC TERMS:  Moyer 1981 and Murray 1983.
     wt =   +  0.00029e-10 * u * sin(tsol + elsun - els)
            +  0.00100e-10 * u * sin(tsol - 2.0 * emsun)
            +  0.00133e-10 * u * sin(tsol - d)
            +  0.00133e-10 * u * sin(tsol + elsun - elj)
            -  0.00229e-10 * u * sin(tsol + 2.0 * elsun + emsun)
            -  0.02200e-10 * v * cos(elsun + emsun)
            +  0.05312e-10 * u * sin(tsol - emsun)
            -  0.13677e-10 * u * sin(tsol + 2.0 * elsun)
            -  1.31840e-10 * v * cos(elsun)
            +  3.17679e-10 * u * sin(tsol)
    # =====================
    # Fairhead et al. model
    # =====================

    # T**0
     w0 = 0
     for j in 474:-1:1
        w0 += fairhd[j][1] * sin(fairhd[j][2] * t + fairhd[j][3])
    end
    # T**1
     w1 = 0
     for j in 679:-1:1
        w1 += fairhd[j][1] * sin(fairhd[j][2] * t + fairhd[j][3])
    end
    # T**2
     w2 = 0
     for j in 764:-1:1
        w2 += fairhd[j][1] * sin(fairhd[j][2] * t + fairhd[j][3])
    end
    # T**3
     w3 = 0
     for j in 784:-1:1
        w3 += fairhd[j][1] * sin(fairhd[j][2] * t + fairhd[j][3])
    end
    # T**4
     w4 = 0
     for j in 787:-1:1
        w4 += fairhd[j][1] * sin(fairhd[j][2] * t + fairhd[j][3])
    end
    # Multiply by powers of T and combine.
     wf = t * (t * (t * (t * w4 + w3) + w2) + w1) + w0
    # Adjustments to use JPL planetary masses instead of IAU.
     wj =   0.00065e-6 * sin(6069.776754 * t + 4.021194) +
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


function deltatr(ep::Epoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    dtdb(jd1, jd2, 0.0, 0.0, 0.0, 0.0)
end

function deltat(ep::Epoch)
    leapsec = leapseconds(julian(ep))
    ΔUT1 = dut1(ep)
    32.184 + leapsec - ΔUT1
end

# TAI <-> UTC
function rescale(::Type{TAIEpoch}, ep::UTCEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.utctai(jd1, jd2)
    TAIEpoch(date, date1)
end

function rescale(::Type{UTCEpoch}, ep::TAIEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.taiutc(jd1, jd2)
    UTCEpoch(date, date1)
end

# UTC <-> UT1
function rescale(::Type{UTCEpoch}, ep::UT1Epoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.ut1utc(jd1, jd2, dut1(ep))
    UTCEpoch(date, date1)
end

function rescale(::Type{UT1Epoch}, ep::UTCEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.utcut1(jd1, jd2, dut1(ep))
    UT1Epoch(date, date1)
end

# TAI <-> UT1
function rescale(::Type{TAIEpoch}, ep::UT1Epoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ut1tai(jd1, jd2, dut1(ep)-leapseconds(julian(ep)))
    TAIEpoch(date, date1)
end

function rescale(::Type{UT1Epoch}, ep::TAIEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = taiut1(jd1, jd2, dut1(ep)-leapseconds(julian(ep)))
    UT1Epoch(date, date1)
end

# TT <-> UT1
function rescale(::Type{TTEpoch}, ep::UT1Epoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    dt = deltat(ep)
    date, date1 = ERFA.ut1tt(jd1, jd2, dt)
    TTEpoch(date, date1)
end

function rescale(::Type{UT1Epoch}, ep::TTEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    dt = deltat(ep)
    date, date1 = ERFA.ttut1(jd1, jd2, dt)
    UT1Epoch(date, date1)
end

# TAI <-> TT
function rescale(::Type{TAIEpoch}, ep::TTEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = tttai(jd1, jd2)
    TAIEpoch(date, date1)
end

function rescale(::Type{TTEpoch}, ep::TAIEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = taitt(jd1, jd2)
    TTEpoch(date, date1)
end

# TT <-> TCG
function rescale(::Type{TTEpoch}, ep::TCGEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.tcgtt(jd1, jd2)
    TTEpoch(date, date1)
end

function rescale(::Type{TCGEpoch}, ep::TTEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.tttcg(jd1, jd2)
    TCGEpoch(date, date1)
end

# TT <-> TDB
function rescale(::Type{TTEpoch}, ep::TDBEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    Δtr = deltatr(ep)
    date, date1 = ERFA.tdbtt(jd1, jd2, Δtr)
    TTEpoch(date, date1)
end

function rescale(::Type{TDBEpoch}, ep::TTEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    Δtr = deltatr(ep)
    date, date1 = ERFA.tttdb(jd1, jd2, Δtr)
    TDBEpoch(date, date1)
end

# TDB <-> TCB
function rescale(::Type{TDBEpoch}, ep::TCBEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.tcbtdb(jd1, jd2)
    TDBEpoch(date, date1)
end

function rescale(::Type{TCBEpoch}, ep::TDBEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = ERFA.tdbtcb(jd1, jd2)
    TCBEpoch(date, date1)
end

function getgraph()
    graph = Dict{DataType,Set{DataType}}()
    for m in methods(rescale)
        from = Base.unwrap_unionall(m.sig.parameters[3]).parameters[1]
        to = Base.unwrap_unionall(m.sig.parameters[2].parameters[1]).parameters[1]

        if !haskey(graph, from)
            merge!(graph, Dict(from=>Set{DataType}()))
        end
        if !haskey(graph, to)
            merge!(graph, Dict(to=>Set{DataType}()))
        end
        push!(graph[from], to)
    end
    graph
end

function gen_rescale(S1, S2, ep)
    graph = getgraph()
    if !haspath(graph, S1, S2)
        error("No conversion path '$S1' -> '$S2' found.")
    end
    path = findpath(graph, S1, S2)
    ex = :(rescale(Epoch{$(path[1])}, ep))
    for scale in path[2:end]
        ex = :(rescale(Epoch{$scale}, $ex))
    end
    return ex
end

@generated function _rescale(::Type{Epoch{S2}}, ep::Epoch{S1}) where {S1<:TimeScale,S2<:TimeScale}
    gen_rescale(S1, S2, ep)
end

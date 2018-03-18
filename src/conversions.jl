import Convertible: findpath, haspath

using ..Periods
export rescale

using ..LeapSeconds

"""
   utctai(jd1, jd2)

Transform a two-part Julia date from `UTC` to `TAI`.

# Example

```jldoctest
julia> utc  = Epoch{UTC}(2.4578265e6, 0.30477440993249416)
2017-03-14T07:18:52.509 UTC
julia> AstronomicalTime.Epochs.utctai(utc.jd1, utc.jd2)
(2.4578265e6, 0.3052026506732349)
```
"""
function utctai(jd1, jd2)
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

Transform a two-part Julia date from `TAI` to `UTC`.

# Example

```jldoctest
julia> tai  = Epoch{TAI}(2.4578265e6, 0.30477440993249416)
2017-03-14T07:18:52.509 TAI
julia> AstronomicalTime.Epochs.taiutc(tai.jd1, tai.jd2)
(2.4578265e6, 0.30434616919175345)
```
"""
function taiutc(jd1, jd2)
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

function deltatr(ep::Epoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    ERFA.dtdb(jd1, jd2, 0.0, 0.0, 0.0, 0.0)
end

function deltat(ep::Epoch)
    leapsec = leapseconds(julian(ep))
    ΔUT1 = dut1(ep)
    32.184 + leapsec - ΔUT1
end

# TAI <-> UTC
function rescale(::Type{TAIEpoch}, ep::UTCEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = utctai(jd1, jd2)
    TAIEpoch(date, date1)
end

function rescale(::Type{UTCEpoch}, ep::TAIEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = taiutc(jd1, jd2)
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

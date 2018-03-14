import Convertible: findpath, haspath

export rescale
export taitt
export tttai

using ..LeapSeconds

function taitt(tai1,tai2)
    dtat = OFFSET_TT_TAI/SECONDS_PER_DAY
    if tai1 > tai2
        tt1 = tai1
        tt2 = tai2 + dtat
    else
        tt1 = tai1 + dtat
        tt2 = tai2
    end
end
function tttai(tt1,tt2)
    dtat = OFFSET_TT_TAI/SECONDS_PER_DAY
    if tt1 > tt2
        tai1 = tt1
        tai2 = tt2 - dtat
    else
        tai1 = tt1 - dtat
        tai2 = tt2
    end
end

function deltatr(ep::Epoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    eraDtdb(jd1, jd2, 0.0, 0.0, 0.0, 0.0)
end

function deltat(ep::Epoch)
    leapsec = leapseconds(julian(ep))
    ΔUT1 = dut1(ep)
    32.184 + leapsec - ΔUT1
end

# TAI <-> UTC
function rescale(::Type{TAIEpoch}, ep::UTCEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = eraUtctai(jd1, jd2)
    TAIEpoch(date, date1)
end

function rescale(::Type{UTCEpoch}, ep::TAIEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = eraTaiutc(jd1, jd2)
    UTCEpoch(date, date1)
end

# UTC <-> UT1
function rescale(::Type{UTCEpoch}, ep::UT1Epoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = eraUt1utc(jd1, jd2, dut1(ep))
    UTCEpoch(date, date1)
end

function rescale(::Type{UT1Epoch}, ep::UTCEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = eraUtcut1(jd1, jd2, dut1(ep))
    UT1Epoch(date, date1)
end

# TAI <-> UT1
function rescale(::Type{TAIEpoch}, ep::UT1Epoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = eraUt1tai(jd1, jd2, dut1(ep)-leapseconds(julian(ep)))
    TAIEpoch(date, date1)
end

function rescale(::Type{UT1Epoch}, ep::TAIEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = eraTaiut1(jd1, jd2, dut1(ep)-leapseconds(julian(ep)))
    UT1Epoch(date, date1)
end

# TT <-> UT1
function rescale(::Type{TTEpoch}, ep::UT1Epoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    dt = deltat(ep)
    date, date1 = eraUt1tt(jd1, jd2, dt)
    TTEpoch(date, date1)
end

function rescale(::Type{UT1Epoch}, ep::TTEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    dt = deltat(ep)
    date, date1 = eraTtut1(jd1, jd2, dt)
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
    date, date1 = eraTcgtt(jd1, jd2)
    TTEpoch(date, date1)
end

function rescale(::Type{TCGEpoch}, ep::TTEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = eraTttcg(jd1, jd2)
    TCGEpoch(date, date1)
end

# TT <-> TDB
function rescale(::Type{TTEpoch}, ep::TDBEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    Δtr = deltatr(ep)
    date, date1 = eraTdbtt(jd1, jd2, Δtr)
    TTEpoch(date, date1)
end

function rescale(::Type{TDBEpoch}, ep::TTEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    Δtr = deltatr(ep)
    date, date1 = eraTttdb(jd1, jd2, Δtr)
    TDBEpoch(date, date1)
end

# TDB <-> TCB
function rescale(::Type{TDBEpoch}, ep::TCBEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = eraTcbtdb(jd1, jd2)
    TDBEpoch(date, date1)
end

function rescale(::Type{TCBEpoch}, ep::TDBEpoch)
    jd1, jd2 = julian1(ep), julian2(ep)
    date, date1 = eraTdbtcb(jd1, jd2)
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


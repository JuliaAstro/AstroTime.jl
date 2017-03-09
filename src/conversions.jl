function deltatr(ep::Epoch)
    eraDtdb(fjd1(ep), fjd2(ep), 0.0, 0.0, 0.0, 0.0)
end

# TAI <-> UTC
function convert(::Type{TAIEpoch}, ep::UTCEpoch)
    date, date1 = eraUtctai(fjd1(ep), fjd2(ep))
    TAIEpoch(date, date1)
end

function convert(::Type{UTCEpoch}, ep::TAIEpoch)
    date, date1 = eraTaiutc(fjd1(ep), fjd2(ep))
    UTCEpoch(date, date1)
end

# UTC <-> UT1
#= function convert(::Type{UTCEpoch}, ep::UT1Epoch) =#
#=     date, date1 = eraUt1utc(fjd1(ep), fjd2(ep), dut1(ep)) =#
#=     UTCEpoch(date, date1, ep.leapseconds, ep.ΔUT1) =#
#= end =#
#=  =#
#= function convert(::Type{UT1Epoch}, ep::UTCEpoch) =#
#=     date, date1 = eraUtcut1(fjd1(ep), fjd2(ep), dut1(ep)) =#
#=     UT1Epoch(date, date1, ep.leapseconds, ep.ΔUT1) =#
#= end =#

# TAI <-> UT1
#= function convert(::Type{TAIEpoch}, ep::UT1Epoch) =#
#=     date, date1 = eraUt1tai(fjd1(ep), fjd2(ep), dut1(ep)-leapseconds(ep)) =#
#=     TAIEpoch(date, date1, ep.leapseconds, ep.ΔUT1) =#
#= end =#
#=  =#
#= function convert(::Type{UT1Epoch}, ep::TAIEpoch) =#
#=     date, date1 = eraTaiut1(fjd1(ep), fjd2(ep), dut1(ep)-leapseconds(ep)) =#
#=     UT1Epoch(date, date1, ep.leapseconds, ep.ΔUT1) =#
#= end =#

# TT <-> UT1
#= function convert(::Type{TTEpoch}, ep::UT1Epoch) =#
#=     dt = deltat(ep) =#
#=     date, date1 = eraUt1tt(fjd1(ep), fjd2(ep), dt) =#
#=     TTEpoch(date, date1, ep.leapseconds, ep.ΔUT1) =#
#= end =#
#=  =#
#= function convert(::Type{UT1Epoch}, ep::TTEpoch) =#
#=     dt = deltat(ep) =#
#=     date, date1 = eraTtut1(fjd1(ep), fjd2(ep), dt) =#
#=     UT1Epoch(date, date1, ep.leapseconds, ep.ΔUT1) =#
#= end =#

# TAI <-> TT
function convert(::Type{TAIEpoch}, ep::TTEpoch)
    date, date1 = eraTttai(fjd1(ep), fjd2(ep))
    TAIEpoch(date, date1)
end

function convert(::Type{TTEpoch}, ep::TAIEpoch)
    date, date1 = eraTaitt(fjd1(ep), fjd2(ep))
    TTEpoch(date, date1)
end

# TT <-> TCG
function convert(::Type{TTEpoch}, ep::TCGEpoch)
    date, date1 = eraTcgtt(fjd1(ep), fjd2(ep))
    TTEpoch(date, date1)
end

function convert(::Type{TCGEpoch}, ep::TTEpoch)
    date, date1 = eraTttcg(fjd1(ep), fjd2(ep))
    TCGEpoch(date, date1)
end

# TT <-> TDB
function convert(::Type{TTEpoch}, ep::TDBEpoch)
    Δtr = deltatr(ep)
    date, date1 = eraTdbtt(fjd1(ep), fjd2(ep), Δtr)
    TTEpoch(date, date1)
end

function convert(::Type{TDBEpoch}, ep::TTEpoch)
    Δtr = deltatr(ep)
    date, date1 = eraTttdb(fjd1(ep), fjd2(ep), Δtr)
    TDBEpoch(date, date1)
end

# TDB <-> TCB
function convert(::Type{TDBEpoch}, ep::TCBEpoch)
    date, date1 = eraTcbtdb(fjd1(ep), fjd2(ep))
    TDBEpoch(date, date1)
end

function convert(::Type{TCBEpoch}, ep::TDBEpoch)
    date, date1 = eraTdbtcb(fjd1(ep), fjd2(ep))
    TCBEpoch(date, date1)
end

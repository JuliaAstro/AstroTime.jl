function deltatr(ep::Epoch)
    eraDtdb(julian1(ep), julian2(ep), 0.0, 0.0, 0.0, 0.0)
end

function deltat(ep::Epoch)
    leapsec = leapseconds(ep)
    ΔUT1 = dut1(ep)
    32.184 + leapsec - ΔUT1
end

# TAI <-> UTC
function convert(::Type{TAIEpoch}, ep::UTCEpoch)
    date, date1 = eraUtctai(julian1(ep), julian2(ep))
    TAIEpoch(date, date1)
end

function convert(::Type{UTCEpoch}, ep::TAIEpoch)
    date, date1 = eraTaiutc(julian1(ep), julian2(ep))
    UTCEpoch(date, date1)
end

# UTC <-> UT1
function convert(::Type{UTCEpoch}, ep::UT1Epoch)
    date, date1 = eraUt1utc(julian1(ep), julian2(ep), dut1(ep))
    UTCEpoch(date, date1)
end

function convert(::Type{UT1Epoch}, ep::UTCEpoch)
    date, date1 = eraUtcut1(julian1(ep), julian2(ep), dut1(ep))
    UT1Epoch(date, date1)
end

# TAI <-> UT1
function convert(::Type{TAIEpoch}, ep::UT1Epoch)
    date, date1 = eraUt1tai(julian1(ep), julian2(ep), dut1(ep)-leapseconds(ep))
    TAIEpoch(date, date1)
end

function convert(::Type{UT1Epoch}, ep::TAIEpoch)
    date, date1 = eraTaiut1(julian1(ep), julian2(ep), dut1(ep)-leapseconds(ep))
    UT1Epoch(date, date1)
end

# TT <-> UT1
function convert(::Type{TTEpoch}, ep::UT1Epoch)
    dt = deltat(ep)
    date, date1 = eraUt1tt(julian1(ep), julian2(ep), dt)
    TTEpoch(date, date1)
end

function convert(::Type{UT1Epoch}, ep::TTEpoch)
    dt = deltat(ep)
    date, date1 = eraTtut1(julian1(ep), julian2(ep), dt)
    UT1Epoch(date, date1)
end

# TAI <-> TT
function convert(::Type{TAIEpoch}, ep::TTEpoch)
    date, date1 = eraTttai(julian1(ep), julian2(ep))
    TAIEpoch(date, date1)
end

function convert(::Type{TTEpoch}, ep::TAIEpoch)
    date, date1 = eraTaitt(julian1(ep), julian2(ep))
    TTEpoch(date, date1)
end

# TT <-> TCG
function convert(::Type{TTEpoch}, ep::TCGEpoch)
    date, date1 = eraTcgtt(julian1(ep), julian2(ep))
    TTEpoch(date, date1)
end

function convert(::Type{TCGEpoch}, ep::TTEpoch)
    date, date1 = eraTttcg(julian1(ep), julian2(ep))
    TCGEpoch(date, date1)
end

# TT <-> TDB
function convert(::Type{TTEpoch}, ep::TDBEpoch)
    Δtr = deltatr(ep)
    date, date1 = eraTdbtt(julian1(ep), julian2(ep), Δtr)
    TTEpoch(date, date1)
end

function convert(::Type{TDBEpoch}, ep::TTEpoch)
    Δtr = deltatr(ep)
    date, date1 = eraTttdb(julian1(ep), julian2(ep), Δtr)
    TDBEpoch(date, date1)
end

# TDB <-> TCB
function convert(::Type{TDBEpoch}, ep::TCBEpoch)
    date, date1 = eraTcbtdb(julian1(ep), julian2(ep))
    TDBEpoch(date, date1)
end

function convert(::Type{TCBEpoch}, ep::TDBEpoch)
    date, date1 = eraTdbtcb(julian1(ep), julian2(ep))
    TCBEpoch(date, date1)
end

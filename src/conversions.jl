function deltatr(ep::Epoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    eraDtdb(jd1, jd2, 0.0, 0.0, 0.0, 0.0)
end

function deltat(ep::Epoch)
    leapsec = leapseconds(ep)
    ΔUT1 = dut1(ep)
    32.184 + leapsec - ΔUT1
end

# TAI <-> UTC
function convert(::Type{TAIEpoch}, ep::UTCEpoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    date, date1 = eraUtctai(jd1, jd2)
    TAIEpoch(date, date1)
end

function convert(::Type{UTCEpoch}, ep::TAIEpoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    date, date1 = eraTaiutc(jd1, jd2)
    UTCEpoch(date, date1)
end

# UTC <-> UT1
function convert(::Type{UTCEpoch}, ep::UT1Epoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    date, date1 = eraUt1utc(jd1, jd2, dut1(ep))
    UTCEpoch(date, date1)
end

function convert(::Type{UT1Epoch}, ep::UTCEpoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    date, date1 = eraUtcut1(jd1, jd2, dut1(ep))
    UT1Epoch(date, date1)
end

# TAI <-> UT1
function convert(::Type{TAIEpoch}, ep::UT1Epoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    date, date1 = eraUt1tai(jd1, jd2, dut1(ep)-leapseconds(ep))
    TAIEpoch(date, date1)
end

function convert(::Type{UT1Epoch}, ep::TAIEpoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    date, date1 = eraTaiut1(jd1, jd2, dut1(ep)-leapseconds(ep))
    UT1Epoch(date, date1)
end

# TT <-> UT1
function convert(::Type{TTEpoch}, ep::UT1Epoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    dt = deltat(ep)
    date, date1 = eraUt1tt(jd1, jd2, dt)
    TTEpoch(date, date1)
end

function convert(::Type{UT1Epoch}, ep::TTEpoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    dt = deltat(ep)
    date, date1 = eraTtut1(jd1, jd2, dt)
    UT1Epoch(date, date1)
end

# TAI <-> TT
function convert(::Type{TAIEpoch}, ep::TTEpoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    date, date1 = eraTttai(jd1, jd2)
    TAIEpoch(date, date1)
end

function convert(::Type{TTEpoch}, ep::TAIEpoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    date, date1 = eraTaitt(jd1, jd2)
    TTEpoch(date, date1)
end

# TT <-> TCG
function convert(::Type{TTEpoch}, ep::TCGEpoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    date, date1 = eraTcgtt(jd1, jd2)
    TTEpoch(date, date1)
end

function convert(::Type{TCGEpoch}, ep::TTEpoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    date, date1 = eraTttcg(jd1, jd2)
    TCGEpoch(date, date1)
end

# TT <-> TDB
function convert(::Type{TTEpoch}, ep::TDBEpoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    Δtr = deltatr(ep)
    date, date1 = eraTdbtt(jd1, jd2, Δtr)
    TTEpoch(date, date1)
end

function convert(::Type{TDBEpoch}, ep::TTEpoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    Δtr = deltatr(ep)
    date, date1 = eraTttdb(jd1, jd2, Δtr)
    TDBEpoch(date, date1)
end

# TDB <-> TCB
function convert(::Type{TDBEpoch}, ep::TCBEpoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    date, date1 = eraTcbtdb(jd1, jd2)
    TDBEpoch(date, date1)
end

function convert(::Type{TCBEpoch}, ep::TDBEpoch)
    jd1, jd2 = julian1_strip(ep), julian2_strip(ep)
    date, date1 = eraTdbtcb(jd1, jd2)
    TCBEpoch(date, date1)
end

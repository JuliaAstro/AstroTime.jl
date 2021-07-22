using Measurements

import Dates
import ERFA

@testset "Epochs" begin
    @testset "UTC" begin
        before = "2012-06-30T23:59:59.000"
        start = "2012-06-30T23:59:60.000"
        during = "2012-06-30T23:59:60.300"
        after = "2012-07-01T00:00:00.000"

        before_exp = (second=394372833, fraction=0.0)
        start_exp = (second=394372834, fraction=0.0)
        during_exp = (second=394372834, fraction=0.3)
        after_exp = (second=394372835, fraction=0.0)

        before_act = from_utc(before)
        start_act = from_utc(start)
        during_act = from_utc(during)
        after_act = from_utc(after)

        @test before_act.second == before_exp.second
        @test before_act.fraction ≈ before_exp.fraction
        @test start_act.second == start_exp.second
        @test start_act.fraction ≈ start_exp.fraction
        @test during_act.second == during_exp.second
        @test during_act.fraction ≈ during_exp.fraction
        @test after_act.second == after_exp.second
        @test after_act.fraction ≈ after_exp.fraction

        during_dt = from_utc(2012, 6, 30, 23, 59, 60.3)
        during_dt1 = from_utc(2012, 6, 30, 23, 59, 60, 0.3)
        @test during_dt.second == during_exp.second
        @test during_dt.fraction ≈ during_exp.fraction
        @test during_dt1.second == during_exp.second
        @test during_dt1.fraction ≈ during_exp.fraction

        @test to_utc(before_act) == before
        @test to_utc(start_act) == start
        @test to_utc(during_act) == during
        @test to_utc(after_act) == after

        sixties = AstroTime.DateTime(1961, 3, 5, 23, 4, 12.0)
        sixties_exp = (second=-1225198547, fraction=0.5057117799999999)
        sixties_act = from_utc(sixties)
        sixties_utc = to_utc(AstroTime.DateTime, sixties_act)

        @test sixties_act.second == sixties_exp.second
        @test sixties_act.fraction ≈ sixties_exp.fraction
        @test sixties_utc ≈ sixties
    end
    @testset "Precision" begin
        ep = TAIEpoch(TAIEpoch(2000, 1, 1, 12), 2eps())
        @test ep.second == 0
        @test ep.fraction == 2eps()

        ep += 10000centuries
        @test ep.second == value(seconds(10000centuries))
        @test ep.fraction == 2eps()

        # Issue 44
        elong1 = 0.0
        elong2 = π
        u = 6371.0
        tt = TTEpoch(2000, 1, 1)
        tdb_tt1 = getoffset(TT, TDB, tt.second, tt.fraction, elong1, u, 0.0)
        tdb_tt2 = getoffset(TT, TDB, tt.second, tt.fraction, elong2, u, 0.0)
        Δtdb = tdb_tt2 - tdb_tt1
        tdb1 = TDBEpoch(tdb_tt1, tt)
        tdb2 = TDBEpoch(tdb_tt2, tt)
        @test value(tdb2 - tdb1) ≈ Δtdb
        @test tdb1 != tdb2
        tdb1 = TDBEpoch(tt, elong1, u, 0.0)
        tdb2 = TDBEpoch(tt, elong2, u, 0.0)
        @test value(tdb2 - tdb1) ≈ Δtdb
        @test tdb1 != tdb2

        t0 = TTEpoch(2000, 1, 1, 12, 0, 32.0)
        t1 = TAIEpoch(2000, 1, 1, 12, 0, 32.0)
        t2 = TAIEpoch(2000, 1, 1, 12, 0, 0.0)
        @test_throws MethodError t1 - t0
        @test_throws MethodError t1 < t0
        @test t2 - t1 == -32.0seconds
        @test t2 < t1

        today = TTEpoch(2000, 1, 1, 12, 0, 13.123)
        age_of_the_universe = 13.772e9years
        big_bang = today - age_of_the_universe
        baryons = big_bang + 1e-11seconds
        @test baryons + age_of_the_universe - today == 1e-11seconds

        reception_time = TDBEpoch("2021-07-01T00:00:00.00")
        rtlt_a = seconds(1.5days)
        rtlt_b = rtlt_a + 1e-6seconds
        transmission_time_a = reception_time + rtlt_a
        transmission_time_b = reception_time + rtlt_b
        @test transmission_time_b - transmission_time_a == 1e-6seconds
    end
    @testset "Parsing" begin
        @test AstroTime.TimeScales.tryparse(1.0) === nothing
        @test TAIEpoch("2000-01-01T00:00:00.000") == TAIEpoch(2000, 1, 1)
        @test UT1Epoch("2000-01-01T00:00:00.000") == UT1Epoch(2000, 1, 1)
        @test TTEpoch("2000-01-01T00:00:00.000") == TTEpoch(2000, 1, 1)
        @test TCGEpoch("2000-01-01T00:00:00.000") == TCGEpoch(2000, 1, 1)
        @test TCBEpoch("2000-01-01T00:00:00.000") == TCBEpoch(2000, 1, 1)
        @test TDBEpoch("2000-01-01T00:00:00.000") == TDBEpoch(2000, 1, 1)
        @test Epoch("2000-01-01T00:00:00.000 TAI") == TAIEpoch(2000, 1, 1)
        @test TAIEpoch("2000-001", "yyyy-DDD") == TAIEpoch(2000, 1, 1)
        @test Epoch("2000-001 TAI", "yyyy-DDD ttt") == TAIEpoch(2000, 1, 1)
        @test_throws ArgumentError Epoch("2000-01-01T00:00:00.000")
    end
    @testset "Output" begin
        ep = TAIEpoch(2018, 8, 14, 10, 2, 51.551247436378276)
        @test AstroTime.format(ep, "yyyy-DDDTHH:MM:SS.sss") == "2018-226T10:02:51.551"
        @test AstroTime.format(ep, "HH:MM ttt") == "10:02 TAI"
        @test string(TAI) == "TAI"
        @test string(TT) == "TT"
        @test string(UT1) == "UT1"
        @test string(TCG) == "TCG"
        @test string(TDB) == "TDB"
        @test string(TCB) == "TCB"
    end
    @testset "Arithmetic" begin
        ep = TAIEpoch(2000, 1, 1)
        ep1 = TAIEpoch(2000, 1, 2)
        @test (ep + 1.0seconds) - ep   == 1.0seconds
        @test (ep + 1.0minutes) - ep   == seconds(1.0minutes)
        @test (ep + 1.0hours) - ep     == seconds(1.0hours)
        @test (ep + 1.0days) - ep      == seconds(1.0days)
        @test (ep + 1.0years) - ep     == seconds(1.0years)
        @test (ep + 1.0centuries) - ep == seconds(1.0centuries)
        @test ep < ep1
        @test isless(ep, ep1)
    end
    @testset "Conversion" begin
        include("conversions.jl")
        dt = AstroTime.DateTime(2018, 8, 14, 10, 2, 51.551247436378276)
        ep = TAIEpoch(2018, 8, 14, 10, 2, 51.551247436378276)
        @test TAIEpoch(dt) == ep
        @test TAIEpoch(Dates.DateTime(dt)) == TAIEpoch(2018, 8, 14, 10, 2, 51.551)
        @test TAIEpoch(AstroTime.Date(2018, 8, 14)) == TAIEpoch(2018, 8, 14, 0, 0, 0.0)
        @test now(Epoch) isa TAIEpoch
        @test now(TDBEpoch) isa TDBEpoch

        tt = TTEpoch(2000, 1, 1, 12)
        @test TTEpoch(tt) == tt
        @test Epoch{TerrestrialTime,Float64}(tt) == tt
        @test tt - J2000_EPOCH == 0.0seconds
        tai = TAIEpoch(2000, 1, 1, 12)
        @test tai.second == 0
        @test tai.fraction == 0.0
        @test TTEpoch(tai) ≈ TTEpoch(2000, 1, 1, 12, 0, 32.184)
        @test Epoch(tai, TT) ≈ TTEpoch(2000, 1, 1, 12, 0, 32.184)
        @test TTEpoch(32.184, tai) == TTEpoch(tai)

        ut1 = UT1Epoch(2000, 1, 1)
        ut1_tai = getoffset(ut1, TAI)
        tai = TAIEpoch(ut1)
        tai_tt = getoffset(tai, TT)
        tt = TTEpoch(tai)
        tt_tdb = getoffset(tt, TDB)
        tdb = TDBEpoch(tt)
        tdb_tcb = getoffset(tdb, TCB)
        tcb = TCBEpoch(tdb)
        @test getoffset(ut1, TCB) == ut1_tai + tai_tt + tt_tdb + tdb_tcb
    end
    @testset "TDB" begin
        ep = TTEpoch(2000, 1, 1)
        @test TDBEpoch(ep) ≈ TDBEpoch(ep, 0.0, 0.0, 0.0) rtol=1e-3
        jd1, jd2 = value.(julian_twopart(ep))
        ut = fractionofday(UT1Epoch(ep))
        elong, u, v = abs.(randn(3)) * 1000
        exp = ERFA.dtdb(jd1, jd2, ut, elong, u, v)
        act = getoffset(ep, TDB, elong, u, v)
        @test act ≈ exp
        second, fraction = 394372865, 0.1839999999999975
        offset = getoffset(TT, TDB, second, fraction)
        @test offset ≈ 0.105187547186749e-3
    end
    @testset "Julian Dates" begin
        jd = 0.0days
        ep = TAIEpoch(jd)
        @test ep == TAIEpoch(2000, 1, 1, 12)
        @test julian_period(ep) == 0.0days
        @test julian_period(ep; scale=TT, unit=seconds) == 32.184seconds
        @test julian_period(Float64, ep) == 0.0
        @test j2000(ep) == jd
        jd = 86400.0seconds
        ep = TAIEpoch(jd)
        @test ep == TAIEpoch(2000, 1, 2, 12)
        @test j2000(ep) == days(jd)
        jd = 2.451545e6days
        ep = TAIEpoch(jd, origin=:julian)
        @test ep == TAIEpoch(2000, 1, 1, 12)
        @test julian(ep) == jd
        jd = 51544.5days
        ep = TAIEpoch(jd, origin=:modified_julian)
        @test ep == TAIEpoch(2000, 1, 1, 12)
        @test modified_julian(ep) == jd
        @test_throws ArgumentError TAIEpoch(jd, origin=:julia)
    end
    @testset "Accessors" begin
        @test TAIEpoch(JULIAN_EPOCH - Inf * seconds) == PAST_INFINITY
        @test TAIEpoch(JULIAN_EPOCH + Inf * seconds) == FUTURE_INFINITY
        @test string(PAST_INFINITY) == "-5877490-03-03T00:00:00.000 TAI"
        @test string(FUTURE_INFINITY) == "5881610-07-11T23:59:59.999 TAI"
        y = 2018
        m = 2
        d = 6
        hr = 20
        mn = 45
        sec = 59.371248965
        ep = TAIEpoch(y, m, d, hr, mn, sec)
        @test year(ep) == y
        @test month(ep) == m
        @test day(ep) == d
        @test hour(ep) == hr
        @test minute(ep) == mn
        @test second(Float64, ep) == sec
        @test second(Int, ep) == 59
        @test millisecond(ep) == 371
        @test microsecond(ep) == 248
        @test nanosecond(ep) == 965
        @test subsecond(ep, 9) == nanosecond(ep)
        @test yearmonthday(ep) == (y, m, d)
        @test fractionofsecond(ep) ≈ 0.371248965
        @test AstroTime.Date(ep) == AstroTime.Date(y, m, d)
        @test AstroTime.Time(ep) == AstroTime.Time(hr, mn, sec)
        @test AstroTime.DateTime(ep) == AstroTime.DateTime(y, m, d, hr, mn, sec)
        @test Dates.Date(ep) == Dates.Date(y, m, d)
        @test Dates.Time(ep) == Dates.Time(hr, mn, 59, 371, 248, 965)
        @test Dates.DateTime(ep) == Dates.DateTime(y, m, d, hr, mn, 59, 371)
    end
    @testset "Ranges" begin
        rng = TAIEpoch(2018, 1, 1):TAIEpoch(2018, 2, 1)
        @test step(rng) == 86400.0seconds
        @test length(rng) == 32
        @test first(rng) == TAIEpoch(2018, 1, 1)
        @test last(rng) == TAIEpoch(2018, 2, 1)
        rng = TAIEpoch(2018, 1, 1):13seconds:TAIEpoch(2018, 1, 1, 0, 1)
        @test step(rng) == 13seconds
        @test last(rng) == TAIEpoch(2018, 1, 1, 0, 0, 52.0)
    end
    @testset "Parametrization" begin
        ep_f64 = TAIEpoch(2000, 1, 1)
        ep_err = TAIEpoch(ep_f64.second, 1.0 ± 1.1)
        Δt = (30 ± 0.1) * seconds
        @test typeof(Δt) == AstroPeriod{AstroTime.Periods.Second,Measurement{Float64}}
        @test typeof(ep_f64) == Epoch{InternationalAtomicTime,Float64}
        @test typeof(ep_err) == Epoch{InternationalAtomicTime,Measurement{Float64}}
        @test typeof(ep_f64 + Δt) == Epoch{InternationalAtomicTime,Measurement{Float64}}
        @test typeof(ep_err + Δt) == Epoch{InternationalAtomicTime,Measurement{Float64}}
        jd1_err = (0.0 ± 0.001) * days
        jd2_err = (0.5 ± 0.001) * days
        ep_jd1 = TAIEpoch(jd1_err)
        @test typeof(ep_jd1) == Epoch{InternationalAtomicTime,Measurement{Float64}}
        ep_jd2 = TAIEpoch(jd1_err, jd2_err)
        @test typeof(ep_jd2) == Epoch{InternationalAtomicTime,Measurement{Float64}}
        ut1_err = UT1Epoch(ep_f64.second, 1.0 ± 1.1)
        tcg_err = TCGEpoch(ut1_err)
        tcb_err = TCBEpoch(ut1_err)
        @test typeof(ut1_err) == Epoch{UniversalTime,Measurement{Float64}}
        @test typeof(tcg_err) == Epoch{GeocentricCoordinateTime,Measurement{Float64}}
        @test typeof(tcb_err) == Epoch{BarycentricCoordinateTime,Measurement{Float64}}
        @test typeof(UT1Epoch(tcg_err)) == Epoch{UniversalTime,Measurement{Float64}}
        @test typeof(UT1Epoch(tcb_err)) == Epoch{UniversalTime,Measurement{Float64}}
    end
end


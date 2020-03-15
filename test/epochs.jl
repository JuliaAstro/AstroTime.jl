function spice_utc_tdb(str)
    et = utc2et(str)
    second, fraction = divrem(et, 1.0)
    return (second=Int64(second), fraction=fraction)
end

function twopart_secondfraction(jd1, jd2)
    jd1 -= value(J2000_TO_JULIAN)
    jd1 *= SECONDS_PER_DAY
    jd2 *= SECONDS_PER_DAY
    s1, f1 = divrem(jd1, 1.0)
    s2, f2 = divrem(jd2, 1.0)
    f, residual = AstroTime.Epochs.two_sum(f1, f2)
    s3, fraction = divrem(f, 1.0)
    second = Int64(s1 + s2 + s3)
    fraction += residual
    return (second=second, fraction=fraction)
end

function erfa_second_fraction(scale, year, month, day, hour, minute, second)
    jd1, jd2 = ERFA.dtf2d(scale, year, month, day, hour, minute, second)
    return twopart_secondfraction(jd1, jd2)
end

@testset "Epochs" begin
    @testset "Precision" begin
        ep = TAIEpoch(TAIEpoch(2000, 1, 1, 12), 2eps())
        @test ep.second == 0
        @test ep.fraction ≈ 2eps()

        ep += 10000centuries
        @test ep.second == value(seconds(10000centuries))
        @test ep.fraction ≈ 2eps()

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

        t0 = UTCEpoch(2000, 1, 1, 12, 0, 32.0)
        t1 = TAIEpoch(2000, 1, 1, 12, 0, 32.0)
        t2 = TAIEpoch(2000, 1, 1, 12, 0, 0.0)
        @test_throws MethodError t1 - t0 == -32.0seconds
        @test_throws MethodError t1 < t0
        @test t2 - t1 == -32.0seconds
        @test t2 < t1
    end
    @testset "Parsing" begin
        @test TAIEpoch("2000-01-01T00:00:00.000") == TAIEpoch(2000, 1, 1)
        @test UTCEpoch("2000-01-01T00:00:00.000") == UTCEpoch(2000, 1, 1)
        @test UT1Epoch("2000-01-01T00:00:00.000") == UT1Epoch(2000, 1, 1)
        @test TTEpoch("2000-01-01T00:00:00.000") == TTEpoch(2000, 1, 1)
        @test TCGEpoch("2000-01-01T00:00:00.000") == TCGEpoch(2000, 1, 1)
        @test TCBEpoch("2000-01-01T00:00:00.000") == TCBEpoch(2000, 1, 1)
        @test TDBEpoch("2000-01-01T00:00:00.000") == TDBEpoch(2000, 1, 1)
        @test Epoch("2000-01-01T00:00:00.000 UTC") == UTCEpoch(2000, 1, 1)
        @test UTCEpoch("2000-001", "yyyy-DDD") == UTCEpoch(2000, 1, 1)
        @test Epoch("2000-001 UTC", "yyyy-DDD ttt") == UTCEpoch(2000, 1, 1)
        @test_throws ArgumentError Epoch("2000-01-01T00:00:00.000")
    end
    @testset "Output" begin
        ep = TAIEpoch(2018, 8, 14, 10, 2, 51.551247436378276)
        @test AstroTime.format(ep, "yyyy-DDDTHH:MM:SS.sss") == "2018-226T10:02:51.551"
        @test AstroTime.format(ep, "HH:MM ttt") == "10:02 TAI"
    end
    @testset "Arithmetic" begin
        ep = UTCEpoch(2000, 1, 1)
        @test (ep + 1.0seconds) - ep   == 1.0seconds
        @test (ep + 1.0minutes) - ep   == seconds(1.0minutes)
        @test (ep + 1.0hours) - ep     == seconds(1.0hours)
        @test (ep + 1.0days) - ep      == seconds(1.0days)
        @test (ep + 1.0years) - ep     == seconds(1.0years)
        @test (ep + 1.0centuries) - ep == seconds(1.0centuries)
    end
    @testset "Conversion" begin
        include("conversions.jl")

        tt = TTEpoch(2000, 1, 1, 12)
        @test tt - J2000_EPOCH == 0.0seconds
        tai = TAIEpoch(2000, 1, 1, 12)
        @test tai.second == 0
        @test tai.fraction == 0.0
        @test UTCEpoch(tai) == UTCEpoch(2000, 1, 1, 11, 59, 28.0)
        @test UTCEpoch(-32.0, tai) == UTCEpoch(tai)
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
        ep = UTCEpoch(jd)
        @test ep == UTCEpoch(2000, 1, 1, 12)
        @test j2000(ep) == jd
        jd = 86400.0seconds
        ep = UTCEpoch(jd)
        @test ep == UTCEpoch(2000, 1, 2, 12)
        @test j2000(ep) == days(jd)
        @test j2000(ep, seconds) == jd
        jd = 2.451545e6days
        ep = UTCEpoch(jd, origin=:julian)
        @test ep == UTCEpoch(2000, 1, 1, 12)
        @test julian(ep) == jd
        @test julian(ep, seconds) == seconds(jd)
        jd = 51544.5days
        ep = UTCEpoch(jd, origin=:modified_julian)
        @test ep == UTCEpoch(2000, 1, 1, 12)
        @test modified_julian(ep) == jd
        @test modified_julian(ep, seconds) == seconds(jd)
        @test_throws ArgumentError UTCEpoch(jd, origin=:julia)
    end
    @testset "Accessors" begin
        @test TAIEpoch(JULIAN_EPOCH - Inf * seconds) == PAST_INFINITY
        @test TAIEpoch(JULIAN_EPOCH + Inf * seconds) == FUTURE_INFINITY
        @test string(PAST_INFINITY) == "-5877490-03-03T00:00:00.000 TAI"
        @test string(FUTURE_INFINITY) == "5881610-07-11T23:59:59.999 TAI"
        ep = UTCEpoch(2018, 2, 6, 20, 45, 59.371)
        @test year(ep) == 2018
        @test month(ep) == 2
        @test day(ep) == 6
        @test hour(ep) == 20
        @test minute(ep) == 45
        @test second(Float64, ep) == 59.371
        @test second(Int, ep) == 59
        @test millisecond(ep) == 371
    end
    # @testset "Ranges" begin
    #     rng = UTCEpoch(2018, 1, 1):UTCEpoch(2018, 2, 1)
    #     @test length(rng) == 32
    #     @test first(rng) == UTCEpoch(2018, 1, 1)
    #     @test last(rng) == UTCEpoch(2018, 2, 1)
    #     rng = UTCEpoch(2018, 1, 1):13seconds:UTCEpoch(2018, 1, 1, 0, 1)
    #     @test last(rng) == UTCEpoch(2018, 1, 1, 0, 0, 52.0)
    # end
    @testset "Leap Seconds" begin
        @test string(UTCEpoch(2018, 8, 8, 0, 0, 0.0)) == "2018-08-08T00:00:00.000 UTC"

        # Test transformation to calendar date during pre-leap second era
        ep61 = UTCEpoch(1961, 3, 5, 23, 4, 12.0)
        ep61_exp = erfa_second_fraction("UTC", 1961, 3, 5, 23, 4, 12.0)
        @test ep61.second == ep61_exp.second
        @test ep61.fraction ≈ ep61_exp.fraction
        @test string(UTCEpoch(1961, 3, 5, 23, 4, 12.0)) == "1961-03-05T23:04:12.000 UTC"

        ep61_tai = TAIEpoch(ep61)
        jd_utc = ERFA.dtf2d("UTC", 1961, 3, 5, 23, 4, 12.0)
        jd_tai = ERFA.utctai(jd_utc...)
        ep61_tai_exp = twopart_secondfraction(jd_tai...)
        @test ep61_tai.second == ep61_tai_exp.second
        @test ep61_tai.fraction ≈ ep61_tai_exp.fraction

        before_utc = UTCEpoch(2012, 6, 30, 23, 59, 59.0)
        start_utc = UTCEpoch(2012, 6, 30, 23, 59, 60.0)
        during_utc = UTCEpoch(2012, 6, 30, 23, 59, 60.5)
        after_utc = UTCEpoch(2012, 7, 1, 0, 0, 0.0)
        before_tdb = TDBEpoch(UTCEpoch(2012, 6, 30, 23, 59, 59.0))
        start_tdb = TDBEpoch(UTCEpoch(2012, 6, 30, 23, 59, 60.0))
        during_tdb = TDBEpoch(UTCEpoch(2012, 6, 30, 23, 59, 60.5))
        after_tdb = TDBEpoch(UTCEpoch(2012, 7, 1, 0, 0, 0.0))

        before_exp = spice_utc_tdb("2012-06-30T23:59:59.0")
        start_exp = spice_utc_tdb("2012-06-30T23:59:60.0")
        during_exp = spice_utc_tdb("2012-06-30T23:59:60.5")
        after_exp = spice_utc_tdb("2012-07-01T00:00:00.0")

        # SPICE is a lot less precise
        @test before_tdb.second == before_exp.second
        @test before_tdb.fraction ≈ before_exp.fraction atol=1e-7
        @test start_tdb.second == start_exp.second
        @test start_tdb.fraction ≈ start_exp.fraction atol=1e-7
        @test during_tdb.second == during_exp.second
        @test during_tdb.fraction ≈ during_exp.fraction atol=1e-7
        @test after_tdb.second == after_exp.second
        @test after_tdb.fraction ≈ after_exp.fraction atol=1e-7

        @test !insideleap(before_utc)
        @test insideleap(start_utc)
        @test insideleap(during_utc)
        @test !insideleap(after_utc)

        # Test transformation to calendar date during leap second
        @test string(before_utc) == "2012-06-30T23:59:59.000 UTC"
        @test string(start_utc) == "2012-06-30T23:59:60.000 UTC"
        @test string(during_utc) == "2012-06-30T23:59:60.500 UTC"
        @test string(after_utc) == "2012-07-01T00:00:00.000 UTC"
    end
end


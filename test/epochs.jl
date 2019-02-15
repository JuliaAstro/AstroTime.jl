@testset "Epochs" begin
    @testset "Precision" begin
        ep = TAIEpoch(TAIEpoch(2000, 1, 1, 12), 2eps())
        @test ep.epoch == 0
        @test ep.offset ≈ 2eps()

        ep += 10000centuries
        @test ep.epoch == value(seconds(10000centuries))
        @test ep.offset ≈ 2eps()

        # Issue 44
        elong1 = 0.0
        elong2 = π
        u = 6371.0
        tai = TAIEpoch(2000, 1, 1)
        tdb_tai1 = tai_offset(TDB, tai, elong1, u, 0.0)
        tdb_tai2 = tai_offset(TDB, tai, elong2, u, 0.0)
        Δtdb = tdb_tai2 - tdb_tai1
        tdb1 = TDBEpoch(tdb_tai1, tai)
        tdb2 = TDBEpoch(tdb_tai2, tai)
        @test value(tdb2 - tdb1) ≈ Δtdb
        @test tdb1 != tdb2
        tdb1 = TDBEpoch(tai, elong1, u, 0.0)
        tdb2 = TDBEpoch(tai, elong2, u, 0.0)
        @test value(tdb2 - tdb1) ≈ Δtdb
        @test tdb1 != tdb2

        t0 = UTCEpoch(2000, 1, 1, 12, 0, 32.0)
        t1 = TAIEpoch(2000, 1, 1, 12, 0, 32.0)
        t2 = TAIEpoch(2000, 1, 1, 12, 0, 0.0)
        @test t1 - t0 == -32.0seconds
        @test t1 < t0
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
        tai = TAIEpoch(2000, 1, 1, 12)
        @test tai.epoch == 0
        @test tai.offset == 0.0
        @test UTCEpoch(tai) == UTCEpoch(2000, 1, 1, 11, 59, 28.0)
        @test UTCEpoch(-32.0, tai) == UTCEpoch(tai)
        @test_throws MethodError UTCEpoch(-32.0, TTEpoch(tai))
    end
    @testset "Julian Dates" begin
        jd = 0.0
        ep = UTCEpoch(jd)
        @test ep == UTCEpoch(2000, 1, 1, 12)
        @test j2000(ep) == jd * days
        jd = 2.451545e6
        ep = UTCEpoch(jd, origin=:julian)
        @test ep == UTCEpoch(2000, 1, 1, 12)
        @test julian(ep) == jd * days
        jd = 51544.5
        ep = UTCEpoch(jd, origin=:modified_julian)
        @test ep == UTCEpoch(2000, 1, 1, 12)
        @test modified_julian(ep) == jd * days
        @test_throws ArgumentError UTCEpoch(jd, origin=:julia)
    end
    @testset "Time Scales" begin
        tai = TAIEpoch(2018, 8, 14, 10, 2, 51.551247436378276)
        tt = TTEpoch(2018, 8, 14, 10, 2, 51.551247436378276)
        utc = UTCEpoch(2018, 8, 14, 10, 2, 51.551247436378276)
        ut1 = UT1Epoch(2018, 8, 14, 10, 2, 51.551247436378276)
        tdb = TDBEpoch(2018, 8, 14, 10, 2, 51.551247436378276)
        tcb = TCBEpoch(2018, 8, 14, 10, 2, 51.551247436378276)
        tcg = TCGEpoch(2018, 8, 14, 10, 2, 51.551247436378276)

        @test tai.epoch == 587512971
        @test tai.offset == 0.5512474363782758
        @test tt.epoch ==  587512939
        @test tt.offset == 0.3672474363782783
        @test utc.epoch == 587513008
        @test utc.offset == 0.5512474363782758
        @test ut1.epoch == 587513008
        @test ut1.offset ≈ 0.48504859616502927 rtol=1e-3
        @test tdb.epoch == 587512939
        @test tdb.offset ≈ 0.3682890196414874 atol=1e-14
        @test tcb.epoch == 587512919
        @test tcb.offset == 0.005062972974656077
        @test tcg.epoch == 587512938
        @test tcg.offset == 0.45195931572465753

        tt = TTEpoch(2000, 1, 1, 12)
        @test tt - J2000_EPOCH == 0.0seconds
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
    @testset "Ranges" begin
        rng = UTCEpoch(2018, 1, 1):UTCEpoch(2018, 2, 1)
        @test length(rng) == 32
        @test first(rng) == UTCEpoch(2018, 1, 1)
        @test last(rng) == UTCEpoch(2018, 2, 1)
        rng = UTCEpoch(2018, 1, 1):13seconds:UTCEpoch(2018, 1, 1, 0, 1)
        @test last(rng) == UTCEpoch(2018, 1, 1, 0, 0, 52.0)
    end
    @testset "Leap Seconds" begin
        @test string(UTCEpoch(2018, 8, 8, 0, 0, 0.0)) == "2018-08-08T00:00:00.000 UTC"

        # Test transformation to calendar date during pre-leap second era
        @test string(UTCEpoch(1961, 3, 5, 23, 4, 12.0)) == "1961-03-05T23:04:12.000 UTC"

        let
            before = UTCEpoch(2012, 6, 30, 23, 59, 59.0)
            start = UTCEpoch(2012, 6, 30, 23, 59, 60.0)
            during = UTCEpoch(2012, 6, 30, 23, 59, 60.5)
            after = UTCEpoch(2012, 7, 1, 0, 0, 0.0)

            @test before.epoch == 394372833
            @test before.offset == 0.0
            @test before.ts_offset == -34.0

            @test start.epoch == 394372834
            @test start.offset == 0.0
            @test start.ts_offset == -35.0

            @test during.epoch == 394372834
            @test during.offset == 0.5
            @test during.ts_offset == -35.0

            @test after.epoch == 394372835
            @test after.offset == 0.0
            @test after.ts_offset == -35.0

            @test !insideleap(before)
            @test insideleap(start)
            @test insideleap(during)
            @test !insideleap(after)

            # Test transformation to calendar date during leap second
            @test string(before) == "2012-06-30T23:59:59.000 UTC"
            @test string(start) == "2012-06-30T23:59:60.000 UTC"
            @test string(during) == "2012-06-30T23:59:60.500 UTC"
            @test string(after) == "2012-07-01T00:00:00.000 UTC"
        end
    end
end


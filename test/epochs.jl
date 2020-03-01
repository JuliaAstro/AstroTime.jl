function spice_utc_tdb(str)
    et = utc2et(str)
    second, fraction = divrem(et, 1.0)
    return (second=Int64(second), fraction=fraction)
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
        tai = TAIEpoch(2000, 1, 1)
        # tdb_tai1 = tai_offset(TDB, tai, elong1, u, 0.0)
        # tdb_tai2 = tai_offset(TDB, tai, elong2, u, 0.0)
        # Δtdb = tdb_tai2 - tdb_tai1
        # tdb1 = TDBEpoch(tdb_tai1, tai)
        # tdb2 = TDBEpoch(tdb_tai2, tai)
        # @test value(tdb2 - tdb1) ≈ Δtdb
        # @test tdb1 != tdb2
        # tdb1 = TDBEpoch(tai, elong1, u, 0.0)
        # tdb2 = TDBEpoch(tai, elong2, u, 0.0)
        # @test value(tdb2 - tdb1) ≈ Δtdb
        # @test tdb1 != tdb2
        #
        # t0 = UTCEpoch(2000, 1, 1, 12, 0, 32.0)
        # t1 = TAIEpoch(2000, 1, 1, 12, 0, 32.0)
        # t2 = TAIEpoch(2000, 1, 1, 12, 0, 0.0)
        # @test t1 - t0 == -32.0seconds
        # @test t1 < t0
        # @test t2 - t1 == -32.0seconds
        # @test t2 < t1
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
    # @testset "Conversion" begin
    #     tai = TAIEpoch(2000, 1, 1, 12)
    #     @test tai.epoch == 0
    #     @test tai.offset == 0.0
    #     @test UTCEpoch(tai) == UTCEpoch(2000, 1, 1, 11, 59, 28.0)
    #     @test UTCEpoch(-32.0, tai) == UTCEpoch(tai)
    #     @test_throws MethodError UTCEpoch(-32.0, TTEpoch(tai))
    # end
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
    @testset "Time Scales" begin
        # @testset "TAI<->TT" begin
        #     ep = TAIEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TTEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 3
        #     @test second(Float64, out_ep) ≈ 2.3735247436378273e+01 atol=1e-12
        #     in_ep = TAIEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TAI<->UTC" begin
        #     ep = TAIEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = UTCEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 2
        #     @test second(Float64, out_ep) ≈ 1.4551247436378276e+01 atol=1e-12
        #     in_ep = TAIEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TAI<->TDB" begin
        #     ep = TAIEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TDBEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 3
        #     @test second(Float64, out_ep) ≈ 2.3734205844955390e+01 atol=1e-12
        #     in_ep = TAIEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TAI<->TCB" begin
        #     ep = TAIEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TCBEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 3
        #     @test second(Float64, out_ep) ≈ 4.4097432701198270e+01 atol=1e-12
        #     in_ep = TAIEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TAI<->TCG" begin
        #     ep = TAIEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TCGEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 3
        #     @test second(Float64, out_ep) ≈ 2.4650535580099750e+01 atol=1e-12
        #     in_ep = TAIEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TAI<->UT1" begin
        #     ep = TAIEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = UT1Epoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 2
        #     @test second(Float64, out_ep) ≈ 1.4617328996852756e+01 atol=1e-12
        #     in_ep = TAIEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TT<->TAI" begin
        #     ep = TTEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TAIEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 2
        #     @test second(Float64, out_ep) ≈ 1.9367247436378280e+01 atol=1e-12
        #     in_ep = TTEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TT<->UTC" begin
        #     ep = TTEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = UTCEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 1
        #     @test second(Float64, out_ep) ≈ 4.2367247436378280e+01 atol=1e-12
        #     in_ep = TTEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TT<->TDB" begin
        #     ep = TTEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TDBEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 2
        #     @test second(Float64, out_ep) ≈ 5.1550205853115330e+01 atol=1e-12
        #     in_ep = TTEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TT<->TCB" begin
        #     ep = TTEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TCBEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 3
        #     @test second(Float64, out_ep) ≈ 1.1913432210338932e+01 atol=1e-12
        #     in_ep = TTEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TT<->TCG" begin
        #     ep = TTEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TCGEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 2
        #     @test second(Float64, out_ep) ≈ 5.2466535557669786e+01 atol=1e-12
        #     in_ep = TTEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TT<->UT1" begin
        #     ep = TTEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = UT1Epoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 1
        #     @test second(Float64, out_ep) ≈ 4.2433329223481640e+01 atol=1e-12
        #     in_ep = TTEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "UTC<->TAI" begin
        #     ep = UTCEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TAIEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 3
        #     @test second(Float64, out_ep) ≈ 2.8551247436378276e+01 atol=1e-12
        #     in_ep = UTCEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "UTC<->TT" begin
        #     ep = UTCEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TTEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 4
        #     @test second(Float64, out_ep) ≈ 7.3524743637827330e-01 atol=1e-12
        #     in_ep = UTCEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "UTC<->TDB" begin
        #     ep = UTCEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TDBEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 4
        #     @test second(Float64, out_ep) ≈ 7.3420583557444980e-01 atol=1e-12
        #     in_ep = UTCEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "UTC<->TCB" begin
        #     ep = UTCEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TCBEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 4
        #     @test second(Float64, out_ep) ≈ 2.1097433265509650e+01 atol=1e-12
        #     in_ep = UTCEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "UTC<->TCG" begin
        #     ep = UTCEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TCGEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 4
        #     @test second(Float64, out_ep) ≈ 1.6505356058861196e+00 atol=1e-12
        #     in_ep = UTCEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "UTC<->UT1" begin
        #     ep = UTCEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = UT1Epoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 2
        #     @test second(Float64, out_ep) ≈ 5.1617328736316390e+01 atol=1e-12
        #     in_ep = UTCEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TDB<->TAI" begin
        #     ep = TDBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TAIEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 2
        #     @test second(Float64, out_ep) ≈ 1.9368289019641487e+01 atol=1e-12
        #     in_ep = TDBEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TDB<->TT" begin
        #     ep = TDBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TTEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 2
        #     @test second(Float64, out_ep) ≈ 5.1552289019641485e+01 atol=1e-12
        #     in_ep = TDBEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TDB<->UTC" begin
        #     ep = TDBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = UTCEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 1
        #     @test second(Float64, out_ep) ≈ 4.2368289019641490e+01 atol=1e-12
        #     in_ep = TDBEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TDB<->TCB" begin
        #     ep = TDBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TCBEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 3
        #     @test second(Float64, out_ep) ≈ 1.1914473793618030e+01 atol=1e-12
        #     in_ep = TDBEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TDB<->TCG" begin
        #     ep = TDBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TCGEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 2
        #     @test second(Float64, out_ep) ≈ 5.2467577140933720e+01 atol=1e-12
        #     in_ep = TDBEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TDB<->UT1" begin
        #     ep = TDBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = UT1Epoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 1
        #     @test second(Float64, out_ep) ≈ 4.2434370806737520e+01 atol=1e-12
        #     in_ep = TDBEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TCB<->TAI" begin
        #     ep = TCBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TAIEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 1
        #     @test second(Float64, out_ep) ≈ 5.9005062972974656e+01 atol=1e-12
        #     in_ep = TCBEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TCB<->TT" begin
        #     ep = TCBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TTEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 2
        #     @test second(Float64, out_ep) ≈ 3.1189062972974654e+01 atol=1e-12
        #     in_ep = TCBEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TCB<->UTC" begin
        #     ep = TCBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = UTCEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 1
        #     @test second(Float64, out_ep) ≈ 2.2005062972974656e+01 atol=1e-12
        #     in_ep = TCBEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TCB<->TDB" begin
        #     ep = TCBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TDBEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 2
        #     @test second(Float64, out_ep) ≈ 3.1188021394874360e+01 atol=1e-12
        #     in_ep = TCBEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TCB<->TCG" begin
        #     ep = TCBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TCGEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 2
        #     @test second(Float64, out_ep) ≈ 3.2104351080075170e+01 atol=1e-12
        #     in_ep = TCBEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TCB<->UT1" begin
        #     ep = TCBEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = UT1Epoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 1
        #     @test second(Float64, out_ep) ≈ 2.2071144903463825e+01 atol=1e-12
        #     in_ep = TCBEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TCG<->TAI" begin
        #     ep = TCGEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TAIEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 2
        #     @test second(Float64, out_ep) ≈ 1.8451959315724658e+01 atol=1e-12
        #     in_ep = TCGEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TCG<->TT" begin
        #     ep = TCGEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TTEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 2
        #     @test second(Float64, out_ep) ≈ 5.0635959315724655e+01 atol=1e-12
        #     in_ep = TCGEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TCG<->UTC" begin
        #     ep = TCGEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = UTCEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 1
        #     @test second(Float64, out_ep) ≈ 4.1451959315724660e+01 atol=1e-12
        #     in_ep = TCGEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TCG<->TDB" begin
        #     ep = TCGEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TDBEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 2
        #     @test second(Float64, out_ep) ≈ 5.0634917732693770e+01 atol=1e-12
        #     in_ep = TCGEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TCG<->TCB" begin
        #     ep = TCGEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TCBEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 3
        #     @test second(Float64, out_ep) ≈ 1.0998144075725655e+01 atol=1e-12
        #     in_ep = TCGEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "TCG<->UT1" begin
        #     ep = TCGEpoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = UT1Epoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 1
        #     @test second(Float64, out_ep) ≈ 4.1518041109273234e+01 atol=1e-12
        #     in_ep = TCGEpoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "UT1<->TAI" begin
        #     ep = UT1Epoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TAIEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 3
        #     @test second(Float64, out_ep) ≈ 2.8485166135974850e+01 atol=1e-12
        #     in_ep = UT1Epoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "UT1<->TT" begin
        #     ep = UT1Epoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TTEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 4
        #     @test second(Float64, out_ep) ≈ 6.6916613597484800e-01 atol=1e-12
        #     in_ep = UT1Epoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "UT1<->UTC" begin
        #     ep = UT1Epoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = UTCEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 2
        #     @test second(Float64, out_ep) ≈ 5.1485166135974850e+01 atol=1e-12
        #     in_ep = UT1Epoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "UT1<->TDB" begin
        #     ep = UT1Epoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TDBEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 4
        #     @test second(Float64, out_ep) ≈ 6.6812453518777910e-01 atol=1e-12
        #     in_ep = UT1Epoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "UT1<->TCB" begin
        #     ep = UT1Epoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TCBEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 4
        #     @test second(Float64, out_ep) ≈ 2.1031351964098377e+01 atol=1e-12
        #     in_ep = UT1Epoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        # @testset "UT1<->TCG" begin
        #     ep = UT1Epoch(2018, 8, 14, 10, 2, 5.1551247436378276e+01)
        #     out_ep = TCGEpoch(ep)
        #     @test year(out_ep) == 2018
        #     @test month(out_ep) == 8
        #     @test day(out_ep) == 14
        #     @test hour(out_ep) == 10
        #     @test minute(out_ep) == 4
        #     @test second(Float64, out_ep) ≈ 1.5844543054366440e+00 atol=1e-12
        #     in_ep = UT1Epoch(out_ep)
        #     @test year(in_ep) == 2018
        #     @test month(in_ep) == 8
        #     @test day(in_ep) == 14
        #     @test hour(in_ep) == 10
        #     @test minute(in_ep) == 2
        #     @test second(Float64, in_ep) ≈ 5.1551247436378276e+01 atol=1e-12
        # end
        #
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
    # @testset "Ranges" begin
    #     rng = UTCEpoch(2018, 1, 1):UTCEpoch(2018, 2, 1)
    #     @test length(rng) == 32
    #     @test first(rng) == UTCEpoch(2018, 1, 1)
    #     @test last(rng) == UTCEpoch(2018, 2, 1)
    #     rng = UTCEpoch(2018, 1, 1):13seconds:UTCEpoch(2018, 1, 1, 0, 1)
    #     @test last(rng) == UTCEpoch(2018, 1, 1, 0, 0, 52.0)
    # end
    @testset "Leap Seconds" begin
        # @test string(UTCEpoch(2018, 8, 8, 0, 0, 0.0)) == "2018-08-08T00:00:00.000 UTC"

        # Test transformation to calendar date during pre-leap second era
        @test string(UTCEpoch(1961, 3, 5, 23, 4, 12.0)) == "1961-03-05T23:04:12.000 UTC"

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


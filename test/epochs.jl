@testset "Epochs" begin
    @testset "Precision" begin
        ep = TAIEpoch(TAIEpoch(2000, 1, 1, 12), 2eps())
        @test ep.epoch == 0
        @test ep.offset ≈ 2eps()

        ep += 10000centuries
        @test ep.epoch == get(seconds(10000centuries))
        @test ep.offset ≈ 2eps()
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
            @test start.epoch == 394372834
            @test start.offset == 0.0
            @test during.epoch == 394372834
            @test during.offset == 0.5
            @test after.epoch == 394372835
            @test after.offset == 0.0

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


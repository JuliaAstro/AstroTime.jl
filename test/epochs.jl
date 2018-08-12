@testset "Epochs" begin
    ep = Epoch{TDB}(Int64(100000), 1e-18)
    ep1 = Epoch{TDB}(ep, 100 * 365.25 * 86400)
    @test ep.offset == ep1.offset

    ep1 = Epoch{TDB}(ep, Inf)
    @test ep1.epoch == typemax(Int64)
    @test ep1.offset == Inf
    ep1 = Epoch{TDB}(ep, -Inf)
    @test ep1.epoch == typemin(Int64)
    @test ep1.offset == -Inf

    tai = Epoch{TAI}(Int64(100000), 0.0)
    tt = Epoch{TT}(tai)
    @test tt.epoch == 100032
    @test tt.offset ≈ 0.184
    tai1 = Epoch{TAI}(tt)
    @test tai1.epoch == 100000
    @test tai1.offset ≈ 0.0

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


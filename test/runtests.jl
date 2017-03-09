using AstronomicalTime
using Base.Test

@testset "AstronomicalTime" begin
    ep0 = TTEpoch(0.0)
    ep1 = ep0 - 1days
    @test ep1.jd1 == -1days
    ep1 = ep0 + 2minutes
    @test ep1.jd2 == day(2minutes)

    ep0 = TTEpoch(2000, 1, 1)
    @test ep0.jd1 == (J2000 - 0.5)*days

    @testset "Conversions" begin
        ref = TDBEpoch(2013, 3, 18, 12)
        @test_skip UT1Epoch(ref) == UT1Epoch("2013-03-18T11:58:52.994")
        @test_skip UTCEpoch(ref) == UTCEpoch("2013-03-18T11:58:52.814")
        @test TAIEpoch(ref) == TAIEpoch("2013-03-18T11:59:27.814")
        @test TTEpoch(ref) == TTEpoch("2013-03-18T11:59:59.998")
        @test TCBEpoch(ref) == TCBEpoch("2013-03-18T12:00:17.718")
        @test TCGEpoch(ref) == TCGEpoch("2013-03-18T12:00:00.795")
        @test_skip ref == TDBEpoch(UT1Epoch("2013-03-18T11:58:52.994"))
        @test_skip ref == TDBEpoch(UTCEpoch("2013-03-18T11:58:52.814"))
        @test ref == TDBEpoch(TAIEpoch("2013-03-18T11:59:27.814"))
        @test ref == TDBEpoch(TTEpoch("2013-03-18T11:59:59.998"))
        @test ref == TDBEpoch(TCBEpoch("2013-03-18T12:00:17.718"))
        @test ref == TDBEpoch(TCGEpoch("2013-03-18T12:00:00.795"))
    end
end

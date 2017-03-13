using AstronomicalTime
using Base.Test
import ERFA: eraDat

AstronomicalTime.update()

@testset "AstronomicalTime" begin
    @testset "Epoch Type" begin
        ep0 = TTEpoch(0.0)
        ep1 = ep0 - 1days
        @test ep1.jd1 == -1days
        ep1 = ep0 + 2minutes
        @test ep1.jd2 == day(2minutes)

        ep0 = TTEpoch(2000, 1, 1)
        @test ep0.jd1 == (J2000 - 0.5)*days
    end
    @testset "Conversions" begin
        dt = DateTime(2000, 1, 1, 12, 0, 0.0)
        tt = TTEpoch(2000, 1, 1, 12, 0, 0.0)
        @test_skip string(tt) == "2000-01-01T12:00:00.000 TT"
        tdb = TDBEpoch(tt)
        tcb = TCBEpoch(tt)
        tcg = TCGEpoch(tt)
        tai = TAIEpoch(tt)
        utc = UTCEpoch(tt)
        #= ut1 = UT1Epoch(tt) =#

        @test TTEpoch(J2000) ≈ tt
        @test jd2000(tt) ≈ 0
        @test jd1950(TTEpoch(1950, 1, 1, 12)) ≈ 0
        @test in_centuries(TTEpoch(2010, 1, 1)) == 0.1
        @test in_days(TTEpoch(2000, 1, 2, 12)) == 1

        @test tai ≈ TAIEpoch(utc)
        @test utc ≈ UTCEpoch(tai)
        @test_skip utc ≈ UTCEpoch(ut1)
        @test_skip ut1 ≈ UT1Epoch(utc)
        @test_skip tai ≈ TAIEpoch(ut1)
        @test_skip ut1 ≈ UT1Epoch(tai)
        @test_skip tt ≈ TTEpoch(ut1)
        @test_skip ut1 ≈ UT1Epoch(tt)
        @test tt ≈ TTEpoch(tai)
        @test tai ≈ TAIEpoch(tt)
        @test tt ≈ TTEpoch(tcg)
        @test tcg ≈ TCGEpoch(tt)
        @test tt ≈ TTEpoch(tdb)
        @test tdb ≈ TDBEpoch(tt)
        @test tdb ≈ TDBEpoch(tcb)
        @test tcb ≈ TCBEpoch(tdb)

        @test tt ≈ TTEpoch(tcb)
        @test tcb ≈ TCBEpoch(tt)

        @test tt == TTEpoch(tt)

        # Reference values from Orekit
        ref = TDBEpoch(2013, 3, 18, 12)
        @test_skip UT1Epoch(ref) == UT1Epoch("2013-03-18T11:58:52.994")
        @test UTCEpoch(ref) == UTCEpoch("2013-03-18T11:58:52.814")
        @test TAIEpoch(ref) == TAIEpoch("2013-03-18T11:59:27.814")
        @test TTEpoch(ref) == TTEpoch("2013-03-18T11:59:59.998")
        @test TCBEpoch(ref) == TCBEpoch("2013-03-18T12:00:17.718")
        @test TCGEpoch(ref) == TCGEpoch("2013-03-18T12:00:00.795")
        @test_skip ref == TDBEpoch(UT1Epoch("2013-03-18T11:58:52.994"))
        @test ref == TDBEpoch(UTCEpoch("2013-03-18T11:58:52.814"))
        @test ref == TDBEpoch(TAIEpoch("2013-03-18T11:59:27.814"))
        @test ref == TDBEpoch(TTEpoch("2013-03-18T11:59:59.998"))
        @test ref == TDBEpoch(TCBEpoch("2013-03-18T12:00:17.718"))
        @test ref == TDBEpoch(TCGEpoch("2013-03-18T12:00:00.795"))
    end
    @testset "Leap Seconds" begin
        for year = 1970:Dates.year(now())
            @test leapseconds(TTEpoch(year, 4, 1)) == eraDat(year, 4, 1, 0.0)
        end
    end
end

import AstroTime.AstroDates: DateTime, date, time
import ERFA

@testset "Offsets" begin
    @testset "UTC" begin
        before_leap = UTCEpoch(2012, 6, 30, 23, 59, 59.0)
        before_leap_dt = DateTime(2012, 6, 30, 23, 59, 59.0)
        start_leap = UTCEpoch(2012, 6, 30, 23, 59, 60.0)
        start_leap_dt = DateTime(2012, 6, 30, 23, 59, 60.0)
        during_leap = UTCEpoch(2012, 6, 30, 23, 59, 60.3)
        during_leap_dt = DateTime(2012, 6, 30, 23, 59, 60.3)
        after_leap = UTCEpoch(2012, 7, 1)
        after_leap_dt = DateTime(2012, 7, 1)

        @test tai_offset(UTC, date(before_leap_dt), time(before_leap_dt)) == 34.0
        @test tai_offset(UTC, date(start_leap_dt), time(start_leap_dt)) == 34.0
        @test tai_offset(UTC, date(during_leap_dt), time(during_leap_dt)) == 34.0
        @test tai_offset(UTC, date(after_leap_dt), time(after_leap_dt)) == 35.0
    end
    @testset "TDB" begin
        ep = UTCEpoch(2000, 1, 1)
        @test TDBEpoch(ep) ≈ TDBEpoch(ep, 0.0, 0.0, 0.0) rtol=1e-3
        jd1, jd2 = value.(julian_twopart(ep))
        ut = fractionofday(UT1Epoch(ep))
        elong, u, v = abs.(randn(3)) * 1000
        exp = tai_offset(TT, ep) + ERFA.dtdb(jd1, jd2, ut, elong, u, v)
        act = tai_offset(TDB, ep, elong, u, v)
        @test act ≈ exp
    end
end

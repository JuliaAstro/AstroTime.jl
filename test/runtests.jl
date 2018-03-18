using AstronomicalTime
using Base.Test
using ERFA

AstronomicalTime.update()

@testset "AstronomicalTime" begin
    @testset "Periods" begin
        s = 1.0seconds
        m = 1.0minutes
        h = 1.0hours
        d = 1.0days
        y = 1.0years
        c = 1.0centuries
        @test s == Period{Second}(1.0)
        @test m == Period{Minute}(1.0)
        @test h == Period{Hour}(1.0)
        @test d == Period{Day}(1.0)
        @test y == Period{Year}(1.0)
        @test c == Period{Century}(1.0)

        @test seconds(s) == 1.0seconds
        @test seconds(m) == 60.0seconds
        @test seconds(h) == 3600.0seconds
        @test seconds(d) == 86400.0seconds
        @test seconds(y) == 3.15576e7seconds
        @test seconds(c) == 3.15576e9seconds

        @test minutes(s) == (1.0 / 60.0)minutes
        @test minutes(m) == 1.0minutes
        @test minutes(h) == 60.0minutes
        @test minutes(d) == 1440.0minutes
        @test minutes(y) == 525960.0minutes
        @test minutes(c) == 5.2596e7minutes

        @test hours(s) == (1.0 / 3600.0)hours
        @test hours(m) == (1.0 / 60.0)hours
        @test hours(h) == 1.0hours
        @test hours(d) == 24.0hours
        @test hours(y) == 8766.0hours
        @test hours(c) == 876600.0hours

        @test days(s) == (1.0 / 86400.0)days
        @test days(m) == (1.0 / 1440.0)days
        @test days(h) == (1.0 / 24.0)days
        @test days(d) == 1.0days
        @test days(y) == 365.25days
        @test days(c) == 36525.0days

        @test years(s) == (1.0 / 3.15576e7)years
        @test years(m) == (1.0 / 525960.0)years
        @test years(h) == (1.0 / 8766.0)years
        @test years(d) == (1.0 / 365.25)years
        @test years(y) == 1.0years
        @test years(c) == 100.0years

        @test centuries(s) == (1.0 / 3.15576e9)centuries
        @test centuries(m) == (1.0 / 5.2596e7)centuries
        @test centuries(h) == (1.0 / 876600.0)centuries
        @test centuries(d) == (1.0 / 36525.0)centuries
        @test centuries(y) == (1.0 / 100.0)centuries
        @test centuries(c) == 1.0centuries
    end
    @testset "Epoch Type" begin
        ep0 = TTEpoch(0.0)

        ep1 = ep0 - 1days
        @test ep1.jd1 == -1
        ep1 = ep0 - 2minutes
        @test ep1.jd2 == -2 / 1440

        ep1 = ep0 + 1days
        @test ep1.jd1 == 1
        ep1 = ep0 + 2minutes
        @test ep1.jd2 == 2 / 1440

        ep0 = TTEpoch(2000, 1, 1)
        @test ep0.jd1 == J2000 - 0.5

        @test TTEpoch(2000,1,1) < TTEpoch(2001,1,1)
        @test TTEpoch(2000,1,1) <= TTEpoch(2001,1,1)
        @test TTEpoch(2001,1,1) > TTEpoch(2000,1,1)
        @test TTEpoch(2001,1,1) >= TTEpoch(2000,1,1)

        ep0 = TTEpoch(2000,1,1,12,0,0,123)
        @test string(ep0) == "2000-01-01T12:00:00.123 TT"
    end
    @testset "Conversions" begin
        dt = DateTime(2000, 1, 1, 12, 0, 0.0)
        tt = TTEpoch(2000, 1, 1, 12, 0, 0.0)
        @test string(tt) == "2000-01-01T12:00:00.000 TT"

        tdb = TDBEpoch(tt)
        tcb = TCBEpoch(tt)
        tcg = TCGEpoch(tt)
        tai = TAIEpoch(tt)
        utc = UTCEpoch(tt)
        ut1 = UT1Epoch(tt)

        @test TTEpoch(J2000) ≈ tt
        @test jd2000(tt) == 0
        @test jd1950(TTEpoch(1950, 1, 1, 12)) == 0
        @test mjd(TTEpoch(1858, 11, 17)) == 0


        @test seconds(tt + 1seconds, J2000) ≈ 1.0seconds
        @test minutes(tt + 1minutes, J2000) ≈ 1.0minutes
        @test hours(tt + 1hours, J2000) ≈ 1.0hours
        @test days(tt + 1days, J2000) ≈ 1.0days
        @test years(tt + 1years, J2000) ≈ 1.0years
        @test centuries(tt + 1centuries, J2000) ≈ 1.0centuries

        @test tai ≈ TAIEpoch(utc)
        @test utc ≈ UTCEpoch(tai)
        @test utc ≈ UTCEpoch(ut1)
        @test ut1 ≈ UT1Epoch(utc)
        @test tai ≈ TAIEpoch(ut1)
        @test ut1 ≈ UT1Epoch(tai)
        @test tt ≈ TTEpoch(ut1)
        @test ut1 ≈ UT1Epoch(tt)
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
        @test UT1Epoch(ref) == UT1Epoch("2013-03-18T11:58:52.994")
        @test UTCEpoch(ref) == UTCEpoch("2013-03-18T11:58:52.814")
        @test TAIEpoch(ref) == TAIEpoch("2013-03-18T11:59:27.814")
        @test TTEpoch(ref) == TTEpoch("2013-03-18T11:59:59.998")
        @test TCBEpoch(ref) == TCBEpoch("2013-03-18T12:00:17.718")
        @test TCGEpoch(ref) == TCGEpoch("2013-03-18T12:00:00.795")
        @test ref == TDBEpoch(UT1Epoch("2013-03-18T11:58:52.994"))
        @test ref == TDBEpoch(UTCEpoch("2013-03-18T11:58:52.814"))
        @test ref == TDBEpoch(TAIEpoch("2013-03-18T11:59:27.814"))
        @test ref == TDBEpoch(TTEpoch("2013-03-18T11:59:59.998"))
        @test ref == TDBEpoch(TCBEpoch("2013-03-18T12:00:17.718"))
        @test ref == TDBEpoch(TCGEpoch("2013-03-18T12:00:00.795"))
    end
    @testset "PortedFunctions" begin

        tai = TAIEpoch(2000, 1, 1, 12, 0, 0.0)
        utc = UTCEpoch(2000, 1, 1, 12, 0, 0.0)
        ut1 = UT1Epoch(2000, 1, 1, 12, 0, 0.0)
        tcg = TCGEpoch(2000, 1, 1, 12, 0, 0.0)
        tt = TTEpoch(2000, 1, 1, 12, 0, 0.0)
        dat_ut1 = AstronomicalTime.Epochs.dut1(ut1)-AstronomicalTime.Epochs.leapseconds(julian(ut1))
        dat_tai = AstronomicalTime.Epochs.dut1(tai)-AstronomicalTime.Epochs.leapseconds(julian(tai))
        @test AstronomicalTime.Epochs.tttai(julian1(tt), julian2(tt)) == ERFA.tttai(julian1(tt), julian2(tt))
        @test AstronomicalTime.Epochs.tttai(julian2(tt), julian1(tt)) == ERFA.tttai(julian2(tt), julian1(tt))
        @test AstronomicalTime.Epochs.taitt(julian1(tai), julian2(tai)) == ERFA.taitt(julian1(tai), julian2(tai))
        @test AstronomicalTime.Epochs.taitt(julian2(tai), julian1(tai)) == ERFA.taitt(julian2(tai), julian1(tai))
        @test AstronomicalTime.Epochs.ut1tai(julian1(ut1), julian2(ut1), dat_ut1) == ERFA.ut1tai(julian1(ut1), julian2(ut1), dat_ut1)
        @test AstronomicalTime.Epochs.ut1tai(julian2(ut1), julian1(ut1), dat_ut1) == ERFA.ut1tai(julian2(ut1), julian1(ut1), dat_ut1)
        @test AstronomicalTime.Epochs.taiut1(julian1(tai), julian2(tai), dat_tai) == ERFA.taiut1(julian1(tai), julian2(tai), dat_tai)
        @test AstronomicalTime.Epochs.taiut1(julian2(tai), julian1(tai), dat_tai) == ERFA.taiut1(julian2(tai), julian1(tai), dat_tai)
        @test AstronomicalTime.Epochs.tcgtt(julian1(tcg), julian2(tcg)) == ERFA.tcgtt(julian1(tcg), julian2(tcg))
        @test AstronomicalTime.Epochs.tcgtt(julian2(tcg), julian1(tcg)) == ERFA.tcgtt(julian2(tcg), julian1(tcg))
        @test AstronomicalTime.Epochs.tttcg(julian1(tt), julian2(tt)) == ERFA.tttcg(julian1(tt), julian2(tt))
        @test AstronomicalTime.Epochs.tttcg(julian2(tt), julian1(tt)) == ERFA.tttcg(julian2(tt), julian1(tt))
        @test AstronomicalTime.Epochs.taiutc(julian1(tai), julian2(tai)) == ERFA.taiutc(julian1(tai), julian2(tai))
        @test AstronomicalTime.Epochs.taiutc(julian2(tai), julian1(tai)) == ERFA.taiutc(julian2(tai), julian1(tai))
        @test AstronomicalTime.Epochs.utctai(julian1(utc), julian2(utc)) == ERFA.utctai(julian1(utc), julian2(utc))
        @test AstronomicalTime.Epochs.utctai(julian2(utc), julian1(utc)) == ERFA.utctai(julian2(utc), julian1(utc))
    end
    @testset "Leap Seconds" begin
        @test leapseconds(TTEpoch(1959,1,1)) == 0
        for year = 1960:Dates.year(now())
            @test leapseconds(TTEpoch(year, 4, 1)) == ERFA.dat(year, 4, 1, 0.0)
        end
    end
end

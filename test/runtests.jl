using AstroTime
#= using AstroTime.Epochs =#
using Test
using ERFA
import Dates
using Dates: DateTime

AstroTime.update()

function fractionofday(dt)
    Dates.hour(dt)/24 + Dates.minute(dt)/(24*60) + Dates.second(dt)/86400 + Dates.millisecond(dt)/8.64e7
end

@testset "AstroTime" begin
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
    #= @testset "Epoch Type" begin =#
    #=     ep0 = TTEpoch(0.0) =#
    #=  =#
    #=     ep1 = ep0 - 1days =#
    #=     @test ep1.jd1 == -1 =#
    #=     ep1 = ep0 - 2minutes =#
    #=     @test ep1.jd2 == -2 / 1440 =#
    #=  =#
    #=     ep1 = ep0 + 1days =#
    #=     @test ep1.jd1 == 1 =#
    #=     ep1 = ep0 + 2minutes =#
    #=     @test ep1.jd2 == 2 / 1440 =#
    #=  =#
    #=     ep0 = TTEpoch(2000, 1, 1) =#
    #=     @test ep0.jd1 == J2000 - 0.5 =#
    #=  =#
    #=     @test TTEpoch(2000,1,1) < TTEpoch(2001,1,1) =#
    #=     @test TTEpoch(2000,1,1) <= TTEpoch(2001,1,1) =#
    #=     @test TTEpoch(2001,1,1) > TTEpoch(2000,1,1) =#
    #=     @test TTEpoch(2001,1,1) >= TTEpoch(2000,1,1) =#
    #=  =#
    #=     ep0 = TTEpoch(2000,1,1,12,0,0,123) =#
    #=     @test string(ep0) == "2000-01-01T12:00:00.123 TT" =#
    #= end =#
    #= @testset "Constructors" begin =#
    #=     dt = DateTime(2000, 1, 1, 12, 0, 0.0) =#
    #=     tt = TTEpoch(2000, 1, 1, 12, 0, 0.0) =#
    #=     @test string(tt) == "2000-01-01T12:00:00.000 TT" =#
    #=  =#
    #=     tdb = TDBEpoch(tt) =#
    #=     tcb = TCBEpoch(tt) =#
    #=     tcg = TCGEpoch(tt) =#
    #=     tai = TAIEpoch(tt) =#
    #=     utc = UTCEpoch(tt) =#
    #=     ut1 = UT1Epoch(tt) =#
    #=  =#
    #=     @test TTEpoch(J2000) ≈ tt =#
    #=     @test jd2000(tt) == 0 =#
    #=     @test jd1950(TTEpoch(1950, 1, 1, 12)) == 0 =#
    #=     @test mjd(TTEpoch(1858, 11, 17)) == 0 =#
    #=  =#
    #=     @test seconds(tt + 1seconds, J2000) ≈ 1.0seconds =#
    #=     @test minutes(tt + 1minutes, J2000) ≈ 1.0minutes =#
    #=     @test hours(tt + 1hours, J2000) ≈ 1.0hours =#
    #=     @test days(tt + 1days, J2000) ≈ 1.0days =#
    #=     @test years(tt + 1years, J2000) ≈ 1.0years =#
    #=     @test centuries(tt + 1centuries, J2000) ≈ 1.0centuries =#
    #=  =#
    #=     @test tai ≈ TAIEpoch(utc) =#
    #=     @test utc ≈ UTCEpoch(tai) =#
    #=     @test utc ≈ UTCEpoch(ut1) =#
    #=     @test ut1 ≈ UT1Epoch(utc) =#
    #=     @test tai ≈ TAIEpoch(ut1) =#
    #=     @test ut1 ≈ UT1Epoch(tai) =#
    #=     @test tt ≈ TTEpoch(ut1) =#
    #=     @test ut1 ≈ UT1Epoch(tt) =#
    #=     @test tt ≈ TTEpoch(tai) =#
    #=     @test tai ≈ TAIEpoch(tt) =#
    #=     @test tt ≈ TTEpoch(tcg) =#
    #=     @test tcg ≈ TCGEpoch(tt) =#
    #=     @test tt ≈ TTEpoch(tdb) =#
    #=     @test tdb ≈ TDBEpoch(tt) =#
    #=     @test tdb ≈ TDBEpoch(tcb) =#
    #=     @test tcb ≈ TCBEpoch(tdb) =#
    #=  =#
    #=     @test tt ≈ TTEpoch(tcb) =#
    #=     @test tcb ≈ TCBEpoch(tt) =#
    #=     @test tt == TTEpoch(tt) =#
    #=  =#
    #=     # Reference values from Orekit =#
    #=     ref = TDBEpoch(2013, 3, 18, 12) =#
    #=     @test UT1Epoch(ref) == UT1Epoch("2013-03-18T11:58:52.994") =#
    #=     @test UTCEpoch(ref) == UTCEpoch("2013-03-18T11:58:52.814") =#
    #=     @test TAIEpoch(ref) == TAIEpoch("2013-03-18T11:59:27.814") =#
    #=     @test TTEpoch(ref) == TTEpoch("2013-03-18T11:59:59.998") =#
    #=     @test TCBEpoch(ref) == TCBEpoch("2013-03-18T12:00:17.718") =#
    #=     @test TCGEpoch(ref) == TCGEpoch("2013-03-18T12:00:00.795") =#
    #=     @test ref == TDBEpoch(UT1Epoch("2013-03-18T11:58:52.994")) =#
    #=     @test ref == TDBEpoch(UTCEpoch("2013-03-18T11:58:52.814")) =#
    #=     @test ref == TDBEpoch(TAIEpoch("2013-03-18T11:59:27.814")) =#
    #=     @test ref == TDBEpoch(TTEpoch("2013-03-18T11:59:59.998")) =#
    #=     @test ref == TDBEpoch(TCBEpoch("2013-03-18T12:00:17.718")) =#
    #=     @test ref == TDBEpoch(TCGEpoch("2013-03-18T12:00:00.795")) =#
    #= end =#
    #= @testset "Conversions" begin =#
    #=     tai = TAIEpoch(2000, 1, 1, 12, 0, 0.0) =#
    #=     utc = UTCEpoch(2000, 1, 1, 12, 0, 0.0) =#
    #=     ut1 = UT1Epoch(2000, 1, 1, 12, 0, 0.0) =#
    #=     tcg = TCGEpoch(2000, 1, 1, 12, 0, 0.0) =#
    #=     tt = TTEpoch(2000, 1, 1, 12, 0, 0.0) =#
    #=     tdb = TDBEpoch(2000, 1, 1, 12, 0, 0.0) =#
    #=     tcb = TCBEpoch(2000, 1, 1, 12, 0, 0.0) =#
    #=     Δtr(ep) = Epochs.diff_tdb_tt(julian1(ep), julian2(ep)) =#
    #=     dut1(ep) = Epochs.dut1(ep) =#
    #=     dat(ep) = dut1(ep) - Epochs.offset_tai_utc(julian(ep)) =#
    #=  =#
    #=     @test Epochs.tttai(julian1(tt), julian2(tt)) == ERFA.tttai(julian1(tt), julian2(tt)) =#
    #=     @test Epochs.tttai(julian2(tt), julian1(tt)) == ERFA.tttai(julian2(tt), julian1(tt)) =#
    #=     @test Epochs.taitt(julian1(tai), julian2(tai)) == ERFA.taitt(julian1(tai), julian2(tai)) =#
    #=     @test Epochs.taitt(julian2(tai), julian1(tai)) == ERFA.taitt(julian2(tai), julian1(tai)) =#
    #=  =#
    #=     @test Epochs.ut1tai(julian1(ut1), julian2(ut1), dat(ut1)) == ERFA.ut1tai(julian1(ut1), julian2(ut1), dat(ut1)) =#
    #=     @test Epochs.ut1tai(julian2(ut1), julian1(ut1), dat(ut1)) == ERFA.ut1tai(julian2(ut1), julian1(ut1), dat(ut1)) =#
    #=     @test Epochs.taiut1(julian1(tai), julian2(tai), dat(tai)) == ERFA.taiut1(julian1(tai), julian2(tai), dat(tai)) =#
    #=     @test Epochs.taiut1(julian2(tai), julian1(tai), dat(tai)) == ERFA.taiut1(julian2(tai), julian1(tai), dat(tai)) =#
    #=  =#
    #=     @test Epochs.tcgtt(julian1(tcg), julian2(tcg)) == ERFA.tcgtt(julian1(tcg), julian2(tcg)) =#
    #=     @test Epochs.tcgtt(julian2(tcg), julian1(tcg)) == ERFA.tcgtt(julian2(tcg), julian1(tcg)) =#
    #=     @test Epochs.tttcg(julian1(tt), julian2(tt)) == ERFA.tttcg(julian1(tt), julian2(tt)) =#
    #=     @test Epochs.tttcg(julian2(tt), julian1(tt)) == ERFA.tttcg(julian2(tt), julian1(tt)) =#
    #=  =#
    #=     @test Epochs.taiutc(julian1(tai), julian2(tai)) == ERFA.taiutc(julian1(tai), julian2(tai)) =#
    #=     @test Epochs.taiutc(julian2(tai), julian1(tai)) == ERFA.taiutc(julian2(tai), julian1(tai)) =#
    #=     @test Epochs.utctai(julian1(utc), julian2(utc)) == ERFA.utctai(julian1(utc), julian2(utc)) =#
    #=     @test Epochs.utctai(julian2(utc), julian1(utc)) == ERFA.utctai(julian2(utc), julian1(utc)) =#
    #=  =#
    #=     leap = UTCEpoch(2016, 12, 31, 23, 59, 60) =#
    #=     tai1, tai2 = ERFA.utctai(julian1(leap), julian2(leap)) =#
    #=     @test Epochs.utctai(julian1(leap), julian2(leap)) == ERFA.utctai(julian1(leap), julian2(leap)) =#
    #=     let (jd2, jd1) = Epochs.taiutc(tai1, tai2) =#
    #=         erfa_jd2, erfa_jd1 =  ERFA.taiutc(tai1, tai2) =#
    #=         @test jd2 ≈ erfa_jd2 =#
    #=         @test jd1 ≈ erfa_jd1 =#
    #=     end =#
    #=     @test Epochs.diff_tdb_tt(julian1(tdb), julian2(tdb), 1.0, 2.0, 3.0, 4.0) == ERFA.dtdb(julian1(tdb), julian2(tdb), 1.0, 2.0, 3.0, 4.0) =#
    #=     @test Epochs.tdbtt(julian1(tdb), julian2(tdb), Δtr(tdb)) == ERFA.tdbtt(julian1(tdb), julian2(tdb), Δtr(tdb)) =#
    #=     @test Epochs.tdbtt(julian2(tdb), julian1(tdb), Δtr(tdb)) == ERFA.tdbtt(julian2(tdb), julian1(tdb), Δtr(tdb)) =#
    #=     @test Epochs.tttdb(julian1(tt), julian2(tt), Δtr(tdb)) == ERFA.tttdb(julian1(tt), julian2(tt), Δtr(tdb)) =#
    #=     @test Epochs.tttdb(julian2(tt), julian1(tt), Δtr(tdb)) == ERFA.tttdb(julian2(tt), julian1(tt), Δtr(tdb)) =#
    #=  =#
    #=     dt(ep) = Epochs.diff_ut1_tt(ep) =#
    #=     @test Epochs.ttut1(julian1(tt), julian2(tt), dt(tt)) == ERFA.ttut1(julian1(tt), julian2(tt), dt(tt)) =#
    #=     @test Epochs.ttut1(julian2(tt), julian1(tt), dt(tt)) == ERFA.ttut1(julian2(tt), julian1(tt), dt(tt)) =#
    #=     @test Epochs.ut1tt(julian1(ut1), julian2(ut1), dt(ut1)) == ERFA.tttdb(julian1(ut1), julian2(ut1), dt(ut1)) =#
    #=     @test Epochs.ut1tt(julian2(ut1), julian1(ut1), dt(ut1)) == ERFA.tttdb(julian2(ut1), julian1(ut1), dt(ut1)) =#
    #=  =#
    #=     # Doing approximate checking due to small machine epsilon. (fails on windows 32-bit) =#
    #=     let (jd1, jd2) = Epochs.tdbtcb(julian1(tdb), julian2(tdb)) =#
    #=         erfa_jd1, erfa_jd2 = ERFA.tdbtcb(julian1(tdb), julian2(tdb)) =#
    #=         @test jd1 ≈ erfa_jd1 =#
    #=         @test jd2 == erfa_jd2 =#
    #=     end =#
    #=  =#
    #=     let (jd2, jd1) = Epochs.tdbtcb(julian2(tdb), julian1(tdb)) =#
    #=         erfa_jd2, erfa_jd1 = ERFA.tdbtcb(julian2(tdb), julian1(tdb)) =#
    #=         @test jd2 ≈ erfa_jd2 =#
    #=         @test jd1 == erfa_jd1 =#
    #=     end =#
    #=  =#
    #=     @test Epochs.tcbtdb(julian1(tcb), julian2(tcb)) == ERFA.tcbtdb(julian1(tcb), julian2(tcb)) =#
    #=     @test Epochs.tcbtdb(julian2(tcb), julian1(tcb)) == ERFA.tcbtdb(julian2(tcb), julian1(tcb)) =#
    #=  =#
    #=     for jd in 2414105.0:10.0:2488985.0 =#
    #=         @test Epochs.diff_tdb_tt(jd, 0.5) ≈ Epochs.diff_tdb_tt(jd,0.5,0.0,0.0,0.0,0.0) atol=40e-6 =#
    #=     end =#
    #=  =#
    #=     @test Epochs.cal2jd(2000, 1, 1) == ERFA.cal2jd(2000, 1, 1) =#
    #=     @test Epochs.cal2jd(2016, 2, 29) == ERFA.cal2jd(2016, 2, 29) =#
    #=     @test TTEpoch(Epochs.cal2jd(2000, 1, 1)...) == TTEpoch(2000, 1, 1) =#
    #=     @test_throws ArgumentError Epochs.cal2jd(-4800, 1, 1) =#
    #=     @test_throws ArgumentError Epochs.cal2jd(2000, 15, 1) =#
    #=     @test_throws ArgumentError Epochs.cal2jd(2000, 1, 40) =#
    #=  =#
    #=     @test Epochs.jd2cal(julian1(tt), julian2(tt)) == ERFA.jd2cal(julian1(tt), julian2(tt)) =#
    #=     @test Epochs.jd2cal(julian2(tt), julian1(tt)) == ERFA.jd2cal(julian2(tt), julian1(tt)) =#
    #=  =#
    #=     @test Epochs.d2tf(1, -1.7) == ERFA.d2tf(1, -1.7) =#
    #=     @test Epochs.d2tf(-1, 1.7) == ERFA.d2tf(-1, 1.7) =#
    #=  =#
    #=     @test Epochs.utcut1(julian1(utc), julian2(utc), dut1(utc),offset_tai_utc(julian(utc))) == ERFA.utcut1(julian1(utc), julian2(utc), dut1(utc)) =#
    #=     @test Epochs.utcut1(julian2(utc), julian1(utc),dut1(utc),offset_tai_utc(julian(utc))) == ERFA.utcut1(julian2(utc), julian1(utc), dut1(utc)) =#
    #=     ut1_nearleap = UT1Epoch(2016, 12, 31, 23, 59, 59) =#
    #=     @test Epochs.ut1utc(julian1(ut1), julian2(ut1), dut1(ut1)) == ERFA.ut1utc(julian1(ut1), julian2(ut1), dut1(ut1)) =#
    #=     @test Epochs.ut1utc(julian2(ut1), julian1(ut1), dut1(ut1)) == ERFA.ut1utc(julian2(ut1), julian1(ut1), dut1(ut1)) =#
    #=     let (jd1, jd2) = Epochs.ut1utc(julian1(ut1_nearleap), julian2(ut1_nearleap), dut1(ut1_nearleap)) =#
    #=         erfa_jd1, erfa_jd2 = ERFA.ut1utc(julian1(ut1_nearleap), julian2(ut1_nearleap), dut1(ut1_nearleap)) =#
    #=         @test jd1 == erfa_jd1 =#
    #=         @test jd2 ≈ erfa_jd2 =#
    #=     end =#
    #=     let (jd2, jd1) = Epochs.ut1utc(julian2(ut1_nearleap), julian1(ut1_nearleap), dut1(ut1_nearleap)) =#
    #=         erfa_jd2, erfa_jd1 = ERFA.ut1utc(julian2(ut1_nearleap), julian1(ut1_nearleap), dut1(ut1_nearleap)) =#
    #=         @test jd2 ≈ erfa_jd2 =#
    #=         @test jd1 == erfa_jd1 =#
    #=     end =#
    #=  =#
    #=     @test Epochs.datetime2julian(UTC, 2016, 12, 31, 23, 59, 60) == ERFA.dtf2d("UTC", 2016, 12, 31, 23, 59, 60) =#
    #=     @test Epochs.datetime2julian(TT, 2016, 12, 31, 23, 59, 59) == ERFA.dtf2d("TT", 2016, 12, 31, 23, 59, 59) =#
    #=     @test_throws ArgumentError Epochs.datetime2julian(TT, 2016, 12, 31, 23, 59, 60) =#
    #=     @test_throws ArgumentError Epochs.datetime2julian(UTC, 2016, 12, 31, 25, 59, 60) =#
    #=     @test_throws ArgumentError Epochs.datetime2julian(UTC, 2016, 12, 31, 23, 61, 60) =#
    #=     @test_throws ArgumentError Epochs.datetime2julian(UTC, 2016, 12, 31, 23, 59, 61) =#
    #=  =#
    #=     utc2 = UTCEpoch(2001, 03, 01, 23, 30, 0) =#
    #=     @test Epochs.julian2datetime(timescale(leap), 3, leap.jd1, leap.jd2) == ERFA.d2dtf("UTC", 3, leap.jd1, leap.jd2) =#
    #=     @test Epochs.julian2datetime(timescale(tt), 3, tt.jd1, tt.jd2) == ERFA.d2dtf("TT", 3, tt.jd1, tt.jd2) =#
    #=     @test Epochs.julian2datetime(timescale(utc2), 3, utc2.jd1, utc2.jd2) == ERFA.d2dtf("UTC", 3, utc2.jd1, utc2.jd2) =#
    #= end =#

    include("epochs.jl")
end

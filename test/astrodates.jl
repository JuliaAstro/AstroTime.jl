using AstroTime.AstroDates
import Dates

const REFERENCES = (
    (-4713, 12, 31, -2451546),
    (-4712, 01, 01, -2451545),
    ( 0000, 12, 31,  -730122),
    ( 0001, 01, 01,  -730121),
    ( 1500, 02, 28,  -182554),
    ( 1500, 02, 29,  -182553),
    ( 1500, 03, 01,  -182552),
    ( 1582, 10, 04,  -152385),
    ( 1582, 10, 15,  -152384),
    ( 1600, 02, 28,  -146039),
    ( 1600, 02, 29,  -146038),
    ( 1600, 03, 01,  -146037),
    ( 1700, 02, 28,  -109514),
    ( 1700, 03, 01,  -109513),
    ( 1800, 02, 28,   -72990),
    ( 1800, 03, 01,   -72989),
    ( 1858, 11, 15,   -51546),
    ( 1858, 11, 16,   -51545),
    ( 1999, 12, 31,       -1),
    ( 2000, 01, 01,        0),
    ( 2000, 02, 28,       58),
    ( 2000, 02, 29,       59),
    ( 2000, 03, 01,       60),
)

@testset "DateTime" begin
    @testset for ref in REFERENCES
        s = AstroTime.Date(ref[end])
        @test year(s) == ref[1]
        @test month(s) == ref[2]
        @test day(s) == ref[3]
        @test j2000(s) == ref[end]
        @test j2000(AstroTime.Date(ref[1:3]...)) == ref[end]
    end

    @test_throws ArgumentError AstroTime.Date(2018, 2, 29)
    @test_throws ArgumentError AstroTime.Date(2018, 0, 1)
    @test_throws ArgumentError AstroTime.Date(2018, 13, 1)
    @test_throws ArgumentError AstroTime.Time(24, 59, 59.0)
    @test_throws ArgumentError AstroTime.Time(23, 60, 59.0)
    @test_throws ArgumentError AstroTime.Time(23, 59, 61.0)
    @test_throws ArgumentError AstroTime.Time(86401, 0)

    @test AstroTime.Date(2000, 1) == AstroTime.Date(2000, 1, 1)
    @test AstroTime.Date(-2000, 1) == AstroTime.Date(-2000, 1, 1)
    @test AstroTime.Date(1000, 1) == AstroTime.Date(1000, 1, 1)

    dt = AstroTime.DateTime(2020, 3, 21, 10, 15, 37.245)
    d = AstroTime.Date(dt)
    t = AstroTime.Time(dt)

    @test AstroTime.DateTime(Dates.DateTime(dt)) == dt
    @test AstroTime.Date(Dates.Date(d)) == d
    @test AstroTime.Time(Dates.Time(t)) ≈ t

    @test year(dt) == 2020
    @test year(d) == 2020
    @test month(dt) == 3
    @test month(d) == 3
    @test day(dt) == 21
    @test day(d) == 21
    @test hour(dt) == 10
    @test hour(t) == 10
    @test minute(dt) == 15
    @test minute(t) == 15
    @test second(dt) == 37
    @test second(t) == 37
    @test second(Float64, dt) == 37.245
    @test second(Float64, t) == 37.245
    @test millisecond(dt) == 245
    @test millisecond(t) == 245

    @test secondinday(t) == 36937.245

    jd = Dates.datetime2julian(Dates.DateTime(dt))
    @test julian(dt) ≈ jd
    @test sum(julian_twopart(dt)) ≈ jd
    @test j2000(dt) ≈ jd - AstroTime.AstroDates.J2000

    pt = AstroTime.Time(12, 12, 12, 0.123456789)
    @test millisecond(pt) == 123
    @test microsecond(pt) == 456
    @test nanosecond(pt) == 789
end

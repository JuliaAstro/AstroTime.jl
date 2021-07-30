@testset "Periods" begin
    s = 1.0seconds
    m = 1.0minutes
    h = 1.0hours
    d = 1.0days
    y = 1.0years
    c = 1.0centuries
    @test s == AstroPeriod(seconds, 1.0)
    @test m == AstroPeriod(minutes, 1.0)
    @test h == AstroPeriod(hours, 1.0)
    @test d == AstroPeriod(days, 1.0)
    @test y == AstroPeriod(years, 1.0)
    @test c == AstroPeriod(centuries, 1.0)

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

    @test zero(AstroPeriod{AstroTime.Periods.Year}) == 0.0years
    @test zero(1years) == 0years
    @test zero(1.0years) == 0.0years

    @test eltype(1.0years) == Float64
    @test eltype(typeof(1.0years)) == Float64

    @test 1.0seconds ≈ 1.0seconds
    @test 1.0 * seconds == seconds * 1.0
    @test 3 * 3.0seconds == 3.0seconds * 3
    @test 4.0seconds / 2 == 2.0seconds
    p = 1.0seconds
    @test -p == -1.0seconds
    @test 3.0seconds - 2.0seconds == 1.0seconds

    a = [1.0, 2.0, 3.0]
    @test a * seconds == [1.0seconds, 2.0seconds, 3.0seconds]
    @test a .* seconds == [1.0seconds, 2.0seconds, 3.0seconds]
    @test seconds * a == [1.0seconds, 2.0seconds, 3.0seconds]
    @test seconds .* a == [1.0seconds, 2.0seconds, 3.0seconds]
    @test Base.broadcastable(seconds) isa typeof(Ref(seconds))

    @test unit(1years) == years
    int_rng = 1seconds:3seconds
    @test step(int_rng) == 1seconds
    @test collect(int_rng) == [1seconds, 2seconds, 3seconds]
    float_rng = 1.0seconds:3.0seconds
    @test step(float_rng) == 1.0seconds
    @test collect(float_rng) == [1.0seconds, 2.0seconds, 3.0seconds]
    @test AstroPeriod{AstroTime.Periods.Second,Float64}(1.0seconds) == 1.0seconds

    @test Periods.name(seconds) == "seconds"
    @test Periods.name(minutes) == "minutes"
    @test Periods.name(hours) == "hours"
    @test Periods.name(days) == "days"
    @test Periods.name(years) == "years"
    @test Periods.name(centuries) == "centuries"

    @test string(1seconds) == "1.0 seconds"
    @test string(1minutes) == "1.0 minutes"
    @test string(1hours) == "1.0 hours"
    @test string(1days) == "1.0 days"
    @test string(1years) == "1.0 years"
    @test string(1centuries) == "1.0 centuries"
end


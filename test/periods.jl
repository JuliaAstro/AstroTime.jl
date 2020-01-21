@testset "Periods" begin
    s = 1.0seconds
    m = 1.0minutes
    h = 1.0hours
    d = 1.0days
    y = 1.0years
    c = 1.0centuries
    @test s == Period(seconds, 1.0)
    @test m == Period(minutes, 1.0)
    @test h == Period(hours, 1.0)
    @test d == Period(days, 1.0)
    @test y == Period(years, 1.0)
    @test c == Period(centuries, 1.0)

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

    @test zero(Period{Year}) == 0.0years
    @test zero(1years) == 0years
    @test zero(1.0years) == 0.0years

    @test unit(1years) == years
    @test collect(1seconds:3seconds) == [1seconds, 2seconds, 3seconds]
    @test collect(1.0seconds:3.0seconds) == [1.0seconds, 2.0seconds, 3.0seconds]

    @test string(1seconds) == "1 second"
    @test string(2seconds) == "2 seconds"
    @test string(1minutes) == "1 minute"
    @test string(2minutes) == "2 minutes"
    @test string(1hours) == "1 hour"
    @test string(2hours) == "2 hours"
    @test string(1days) == "1 day"
    @test string(2days) == "2 days"
    @test string(1years) == "1 year"
    @test string(2years) == "2 years"
    @test string(1centuries) == "1 century"
    @test string(2centuries) == "2 centuries"
end


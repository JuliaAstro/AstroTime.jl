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
end

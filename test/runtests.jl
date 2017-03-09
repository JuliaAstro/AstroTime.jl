using AstronomicalTime
using Base.Test

@testset "AstronomicalTime" begin
    ep0 = TTEpoch(0.0)
    ep1 = ep0 - 1days
    @test ep1.jd1 == -1days
    ep1 = ep0 + 2minutes
    @test ep1.jd2 == day(2minutes)
end

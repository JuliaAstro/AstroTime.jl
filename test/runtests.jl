using AstronomicalTime
using Base.Test

@testset "AstronomicalTime" begin
    ep = TTEpoch(0.0, 0.0)
    ep - 1days
    ep + 60seconds
end

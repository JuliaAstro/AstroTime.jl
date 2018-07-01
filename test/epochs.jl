@testset "Epochs" begin
    ep = Epoch2{TDB}(100000, 1e-18)
    ep1 = Epoch2{TDB}(ep, 100 * 365.25 * 86400)
    @test ep.offset == ep1.offset
end
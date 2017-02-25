using AstronomicalTime
using Base.Test

@testset "AstronomicalTime" begin
    @testset "Low-Level" begin
        tai = Epoch(TAI, Base.Dates.datetime2julian(DateTime(2000,1,1)), 0.0)
        taitt = Offset(TAI, TT, 32.184/86400)
        tt = taitt(tai)
        @test tai ≈ inv(taitt)(tt)
    end
    @testset "High-Level" begin
    end
end

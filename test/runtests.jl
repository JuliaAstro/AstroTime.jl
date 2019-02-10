using AstroTime
using Test
using ERFA

AstroTime.update()

const speed_of_light = 299792458.0 # m/s
const astronomical_unit = 149597870700.0 # m

@timescale GMT ep tai_offset(UTC, ep)

@timescale SCET ep distance begin
    tai_offset(UTC, ep) + distance / speed_of_light
end

@testset "AstroTime" begin
    include("periods.jl")
    include("astrodates.jl")
    include("offsets.jl")
    include("epochs.jl")
    @testset "Custom Time Scales" begin
        utc = UTCEpoch(2000, 1, 1, 0, 0, 0.1)
        gmt = GMTEpoch(2000, 1, 1, 0, 0, 0.1)
        @test utc == gmt

        @test string(GMT) == "GMT"
        @test typeof(GMT) == GMTType
        @test string(gmt) == "2000-01-01T00:00:00.100 GMT"

        @test string(SCET) == "SCET"
        @test typeof(SCET) == SCETType
        scet = SCETEpoch(2000, 1, 1, 0, 8, 19.10478383615643, astronomical_unit)
        @test TAIEpoch(scet) ≈ TAIEpoch(utc)
        @test SCETEpoch(value(j2000(scet)), 0.0, astronomical_unit) ≈ scet
    end
end

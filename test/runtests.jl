using AstroTime
using Test
using ERFA
using SPICE: furnsh, et2utc, utc2et

furnsh(joinpath("data", "naif0012.tls"))
AstroTime.load_eop(joinpath("data", "finals.csv"),
                   joinpath("data", "finals2000A.csv"))

const speed_of_light = 299792458.0 # m/s
const astronomical_unit = 149597870700.0 # m

@timescale GMT UTC
AstroTime.Epochs.getoffset(::GMTScale, ::CoordinatedUniversalTime, _, _) = 0.0
AstroTime.Epochs.getoffset(::CoordinatedUniversalTime, ::GMTScale, _, _) = 0.0

@timescale SCET UTC
function AstroTime.Epochs.getoffset(::SCETScale, ::CoordinatedUniversalTime,
                                    _, _, distance)
    return distance / speed_of_light
end
function AstroTime.Epochs.getoffset(::CoordinatedUniversalTime, ::SCETScale,
                                    _, _, distance)
    return -distance / speed_of_light
end

@timescale Dummy TDB

@timescale Lonely
@timescale Together Lonely
function AstroTime.Epochs.getoffset(::LonelyScale, ::TogetherScale, _, _)
    return 5.0
end
function AstroTime.Epochs.getoffset(::TogetherScale, ::LonelyScale, _, _)
    return -5.0
end

@timescale OneWay TDB true

@testset "AstroTime" begin
    include("periods.jl")
    include("astrodates.jl")
    include("epochs.jl")
    @testset "Custom Time Scales" begin
        utc = UTCEpoch(2000, 1, 1, 0, 0, 0.1)
        gmt = GMTEpoch(2000, 1, 1, 0, 0, 0.1)
        @test utc == UTCEpoch(gmt)
        @test gmt == GMTEpoch(utc)

        @test string(GMT) == "GMT"
        @test typeof(GMT) == GMTScale
        @test string(gmt) == "2000-01-01T00:00:00.100 GMT"
        @test find_path(GMT, UTC) == [GMT, UTC]

        @test string(SCET) == "SCET"
        @test typeof(SCET) == SCETScale
        @test find_path(SCET, UTC) == [SCET, UTC]
        scet = SCETEpoch(2000, 1, 1, 0, 0, 0.1)
        utc_exp = UTCEpoch(2000, 1, 1, 0, 8, 19.10478383615643)
        @test UTCEpoch(scet, astronomical_unit) ≈ utc_exp
        @test SCETEpoch(utc_exp, astronomical_unit) ≈ scet

        @test string(Dummy) == "Dummy"
        @test typeof(Dummy) == DummyScale
        @test find_path(Dummy, UTC) == [Dummy, TDB, TT, TAI, UTC]
        dummy = DummyEpoch(2000, 1, 1)
        @test_throws NoOffsetError UTCEpoch(dummy)
        @test_throws NoOffsetError TDBEpoch(dummy)

        lonely = LonelyEpoch(2000, 1, 1)
        together = TogetherEpoch(lonely)
        @test together == TogetherEpoch(2000, 1, 1, 0, 0, 5.0)
        @test lonely == LonelyEpoch(together)
        @test find_path(Lonely, TDB) == []

        @test find_path(TDB, OneWay) == [TDB, OneWay]
        @test find_path(OneWay, TDB) == []
        @test_throws NoPathError TDBEpoch(OneWayEpoch(2000, 1, 1))
    end
end

using AstroTime
using Dates
using Test

AstroTime.load_test_eop()

const speed_of_light = 299792458.0 # m/s
const astronomical_unit = 149597870700.0 # m

# TODO: Change me
@timescale GMT TAI
AstroTime.Epochs.getoffset(::GMTScale, ::InternationalAtomicTime, _, _) = 0.0
AstroTime.Epochs.getoffset(::InternationalAtomicTime, ::GMTScale, _, _) = 0.0

@timescale SCET TAI
function AstroTime.Epochs.getoffset(::SCETScale, ::InternationalAtomicTime,
                                    _, _, distance)
    return distance / speed_of_light
end
function AstroTime.Epochs.getoffset(::InternationalAtomicTime, ::SCETScale,
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
        # TODO: Change me
        tai = TAIEpoch(2000, 1, 1, 0, 0, 0.1)
        gmt = GMTEpoch(2000, 1, 1, 0, 0, 0.1)
        @test tai == TAIEpoch(gmt)
        @test gmt == GMTEpoch(tai)

        @test string(GMT) == "GMT"
        @test typeof(GMT) == GMTScale
        @test string(gmt) == "2000-01-01T00:00:00.100 GMT"
        @test find_path(GMT, TAI) == [GMT, TAI]

        @test string(SCET) == "SCET"
        @test typeof(SCET) == SCETScale
        @test find_path(SCET, TAI) == [SCET, TAI]
        scet = SCETEpoch(2000, 1, 1, 0, 0, 0.1)
        tai_exp = TAIEpoch(2000, 1, 1, 0, 8, 19.10478383615643)
        @test TAIEpoch(scet, astronomical_unit) ≈ tai_exp
        @test SCETEpoch(tai_exp, astronomical_unit) ≈ scet

        @test Dates.default_format(SCETEpoch) == AstroTime.EPOCH_ISO_FORMAT[]

        @test string(Dummy) == "Dummy"
        @test typeof(Dummy) == DummyScale
        @test find_path(Dummy, TAI) == [Dummy, TDB, TT, TAI]
        dummy = DummyEpoch(2000, 1, 1)
        @test_throws NoOffsetError TAIEpoch(dummy)
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

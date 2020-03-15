using AstroTime
using Test
using ERFA
using RemoteFiles: @RemoteFile, download, path
using SPICE: furnsh, et2utc, utc2et


const BASE_URL = "https://raw.githubusercontent.com/AndrewAnnex/SpiceyPyTestKernels/master/"
const KERNEL_DIR = joinpath(@__DIR__, "kernels")
@RemoteFile LSK BASE_URL * "naif0012.tls" dir=KERNEL_DIR

download(LSK)
furnsh(path(LSK))

AstroTime.update()

const speed_of_light = 299792458.0 # m/s
const astronomical_unit = 149597870700.0 # m

@timescale GMT UTC
AstroTime.Epochs.getoffset(::GMTType, ::CoordinatedUniversalTime, _, _) = 0.0
AstroTime.Epochs.getoffset(::CoordinatedUniversalTime, ::GMTType, _, _) = 0.0

@timescale SCET UTC
function AstroTime.Epochs.getoffset(::SCETType, ::CoordinatedUniversalTime,
                                    _, _, distance)
    return distance / speed_of_light
end
function AstroTime.Epochs.getoffset(::CoordinatedUniversalTime, ::SCETType,
                                    _, _, distance)
    return -distance / speed_of_light
end

@timescale Dummy TDB

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
        @test typeof(GMT) == GMTType
        @test string(gmt) == "2000-01-01T00:00:00.100 GMT"
        @test find_path(GMT, UTC) == [GMT, UTC]

        @test string(SCET) == "SCET"
        @test typeof(SCET) == SCETType
        @test find_path(SCET, UTC) == [SCET, UTC]
        scet = SCETEpoch(2000, 1, 1, 0, 0, 0.1)
        utc_exp = UTCEpoch(2000, 1, 1, 0, 8, 19.10478383615643)
        @test UTCEpoch(scet, astronomical_unit) ≈ utc_exp
        @test SCETEpoch(utc_exp, astronomical_unit) ≈ scet

        @test string(Dummy) == "Dummy"
        @test typeof(Dummy) == DummyType
        @test find_path(Dummy, UTC) == [Dummy, TDB, TT, TAI, UTC]
        dummy = DummyEpoch(2000, 1, 1)
        @test_throws NoOffsetError UTCEpoch(dummy)
        @test_throws NoOffsetError TDBEpoch(dummy)
    end
end

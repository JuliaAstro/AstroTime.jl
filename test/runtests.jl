using AstroTime
using Test
using ERFA

AstroTime.update()

@testset "AstroTime" begin
    include("periods.jl")
    include("astrodates.jl")
    include("offsets.jl")
    include("epochs.jl")
end

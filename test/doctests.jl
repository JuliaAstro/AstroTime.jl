using Documenter

@testset "Doctests" begin
    setup = quote
        using AstroTime
    end
    DocMeta.setdocmeta!(AstroTime, :DocTestSetup, setup; recursive = true)

    doctest(AstroTime)
end

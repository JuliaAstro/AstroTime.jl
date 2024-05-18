using Documenter

setup = quote
    using AstroTime
end
DocMeta.setdocmeta!(AstroTime, :DocTestSetup, setup; recursive = true)
doctest(AstroTime)


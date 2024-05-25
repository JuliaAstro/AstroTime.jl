using Documenter

setup = quote
    using AstroTime
end
if VERSION >= v"1.6.0"
    DocMeta.setdocmeta!(AstroTime, :DocTestSetup, setup; recursive=true)
    doctest(AstroTime)
end

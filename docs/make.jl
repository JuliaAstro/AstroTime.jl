using Documenter, AstroTime

setup = quote
    using AstroTime
end
DocMeta.setdocmeta!(AstroTime, :DocTestSetup, setup; recursive = true)
include("pages.jl")
makedocs(
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
    ),
    modules = [AstroTime],
    sitename = "AstroTime.jl",
    authors = "Helge Eichhorn and the AstroTime.jl contributors",
    pages = pages,
    strict = true,
    checkdocs = :exports,
)

deploydocs(
    repo = "github.com/JuliaAstro/AstroTime.jl.git",
    push_preview = true,
)

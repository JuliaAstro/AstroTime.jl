using Documenter, AstronomicalTime

makedocs(
    format = :html,
    sitename = "AstronomicalTime.jl",
    authors = "Helge Eichhorn",
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
    ],
    doctest = false,
)

deploydocs(
    repo = "github.com/JuliaAstro/AstronomicalTime.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
    julia = "0.6",
)

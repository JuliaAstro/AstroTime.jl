using Documenter, AstroTime

makedocs(
    format = :html,
    sitename = "AstroTime.jl",
    authors = "Helge Eichhorn",
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
    ],
)

deploydocs(
    repo = "github.com/JuliaAstro/AstroTime.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
    julia = "nightly",
)

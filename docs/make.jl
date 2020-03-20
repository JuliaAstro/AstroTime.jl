using Documenter, AstroTime

setup = quote
    using AstroTime
end
DocMeta.setdocmeta!(AstroTime, :DocTestSetup, setup; recursive = true)

makedocs(
    format = Documenter.HTML(
	prettyurls = get(ENV, "CI", nothing) == "true",
    ),
    modules = [AstroTime],
    sitename = "AstroTime.jl",
    authors = "Helge Eichhorn and the AstroTime.jl contributors",
    pages = [
	"Home" => "index.md",
	"Tutorial" => "tutorial.md",
	"API" => [
	    "Time Scales" => joinpath("api", "timescales.md"),
	    "Periods" => joinpath("api", "periods.md"),
	    "Epochs" => joinpath("api", "epochs.md"),
	],
    ],
    strict = true,
)

deploydocs(
    repo = "github.com/JuliaAstro/AstroTime.jl.git",
    push_preview = true,
)

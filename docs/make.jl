using Documenter, AstroTime

makedocs(
    format = Documenter.HTML(
		prettyurls = get(ENV, "CI", nothing) == "true",
	),
	sitename = "AstroTime.jl",
	authors = "Helge Eichhorn and the AstroTime.jl contributors",
	pages = [
		"Home" => "index.md",
		"Tutorial" => "tutorial.md",
		"API" => "api.md",
	],
)

deploydocs(
	repo = "github.com/JuliaAstro/AstroTime.jl.git",
	target = "build",
)

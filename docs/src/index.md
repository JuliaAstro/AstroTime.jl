# AstronomicalTime

*Astronomical time keeping in Julia*

[![Build Status Unix][travis-badge]][travis-url] [![Build Status Windows][av-badge]][av-url] [![Coveralls][coveralls-badge]][coveralls-url] [![Codecov][codecov-badge]][codecov-url] [![Docs Stable][docs-badge-stable]][docs-url-stable] [![Docs Latest][docs-badge-latest]][docs-url-latest]

## Installation

The package can be installed through Julia's package manager:

```julia
Pkg.clone("https://github.com/JuliaAstro/AstronomicalTime.jl")
```

## Quickstart

```julia
# Create an Epoch based on the TT (Terrestial Time) scale
tt = TTEpoch("2018-01-01T12:00:00")

# Transform to UTC (Universal Time Coordinated)
utc = UTCEpoch(tt)

# Transform to TDB (Barycentric Dynamical Time)
utc = TDBEpoch(utc)
```

Read the [API](@ref) docs.

[travis-badge]: https://travis-ci.org/JuliaAstro/AstronomicalTime.jl.svg?branch=master
[travis-url]: https://travis-ci.org/JuliaAstro/AstronomicalTime.jl
[av-badge]: https://ci.appveyor.com/api/projects/status/13l2bwswxbl1g8cq?svg=true
[av-url]: https://ci.appveyor.com/project/helgee/astronomicaltime-jl
[coveralls-badge]: https://coveralls.io/repos/github/JuliaAstro/AstronomicalTime.jl/badge.svg?branch=master
[coveralls-url]: https://coveralls.io/github/JuliaAstro/AstronomicalTime.jl?branch=master
[codecov-badge]: http://codecov.io/github/JuliaAstro/AstronomicalTime.jl/coverage.svg?branch=master
[codecov-url]: http://codecov.io/github/JuliaAstro/AstronomicalTime.jl?branch=master
[docs-badge-latest]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-url-latest]: https://juliaastro.github.io/AstronomicalTime.jl/latest
[docs-badge-stable]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-url-stable]: https://juliaastro.github.io/AstronomicalTime.jl/stable
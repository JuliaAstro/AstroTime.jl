# AstroTime

*Astronomical time keeping in Julia*

[![Build Status Unix][travis-badge]][travis-url] [![Build Status Windows][av-badge]][av-url] [![Coveralls][coveralls-badge]][coveralls-url] [![Codecov][codecov-badge]][codecov-url] [![Docs Stable][docs-badge-stable]][docs-url-stable] [![Docs Dev][docs-badge-dev]][docs-url-dev]

AstroTime.jl provides a high-precision, time-scale aware, `DateTime`-like data type which supports
all commonly used astronomical time scales.

## Installation

The package can be installed through Julia's package manager:

```julia
julia> import Pkg; Pkg.add("AstroTime")
```

## Quickstart

```julia
# Create an Epoch based on the TT (Terrestial Time) scale
tt = TTEpoch("2018-01-01T12:00:00")

# Transform to UTC (Universal Time Coordinated)
utc = UTCEpoch(tt)

# Transform to TDB (Barycentric Dynamical Time)
utc = TDBEpoch(utc)

# Shift an Epoch by one day
another_day = tt + 1days
```

## Documentation

Please refer to the [documentation][docs-url-stable] for additional
information.

[travis-badge]: https://travis-ci.org/JuliaAstro/AstroTime.jl.svg?branch=master
[travis-url]: https://travis-ci.org/JuliaAstro/AstroTime.jl
[av-badge]: https://ci.appveyor.com/api/projects/status/13l2bwswxbl1g8cq?svg=true
[av-url]: https://ci.appveyor.com/project/helgee/astronomicaltime-jl
[coveralls-badge]: https://coveralls.io/repos/github/JuliaAstro/AstroTime.jl/badge.svg?branch=master
[coveralls-url]: https://coveralls.io/github/JuliaAstro/AstroTime.jl?branch=master
[codecov-badge]: http://codecov.io/github/JuliaAstro/AstroTime.jl/coverage.svg?branch=master
[codecov-url]: http://codecov.io/github/JuliaAstro/AstroTime.jl?branch=master
[docs-badge-dev]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-url-dev]: https://juliaastro.github.io/AstroTime.jl/dev/
[docs-badge-stable]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-url-stable]: https://juliaastro.github.io/AstroTime.jl/stable/

# AstroTime

*Astronomical time keeping in Julia*

## Installation

The package can be installed through Julia's package manager:

```julia
Pkg.clone("https://github.com/JuliaAstro/AstroTime.jl")
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


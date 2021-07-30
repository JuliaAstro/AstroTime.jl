# AstroTime

*Astronomical time keeping in Julia*

[![Build Status](https://github.com/JuliaAstro/AstroTime.jl/workflows/CI/badge.svg?branch=master)](https://github.com/JuliaAstro/AstroTime.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaAstro/AstroTime.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaAstro/AstroTime.jl)
[![Stable Docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaAstro.github.io/AstroTime.jl/stable)
[![Dev Docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaAstro.github.io/AstroTime.jl/dev)

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

# Transform to TAI (International Atomic Time)
tai = TAIEpoch(tt)

# Transform to TDB (Barycentric Dynamical Time)
tdb = TDBEpoch(tai)

# Shift an Epoch by one day
another_day = tt + 1days
```

## Documentation

Please refer to the [documentation](https://JuliaAstro.github.io/AstroTime.jl/stable)
for additional information.


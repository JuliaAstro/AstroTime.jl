# AstroTime

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliaastro.org/AstroTime/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliaastro.org/AstroTime.jl/dev)

[![Test](https://github.com/JuliaAstro/AstroTime.jl/actions/workflows/Test.yml/badge.svg)](https://github.com/JuliaAstro/AstroTime.jl/actions/workflows/Test.yml)
[![Coverage](https://codecov.io/gh/JuliaAstro/AstroTime.jl/graph/badge.svg)](https://codecov.io/gh/JuliaAstro/AstroTime.jl)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

*Astronomical time keeping in Julia*

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


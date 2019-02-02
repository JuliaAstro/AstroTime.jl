# AstroTime

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

# Transform to UTC (Universal Time Coordinated)
utc = UTCEpoch(tt)

# Transform to TDB (Barycentric Dynamical Time)
utc = TDBEpoch(utc)

# Shift an Epoch by one day
another_day = tt + 1days
```

## Next Steps

You can either follow the [Tutorial](@ref) or jump straight into the [API](@ref) reference.


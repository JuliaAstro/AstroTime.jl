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

# Transform to TAI (International Atomic Time)
tai = TAIEpoch(tt)

# Transform to TDB (Barycentric Dynamical Time)
tdb = TDBEpoch(tai)

# Shift an Epoch by one day
another_day = tt + 1days
```

## Next Steps

Follow the [Tutorial](@ref) to get an in-depth look at AstroTime.jl's functionality.


```@meta
DocTestSetup = quote
    using AstroTime
end
```
# AstroTime

*Astronomical time keeping in Julia*

AstroTime.jl provides a high-precision, time-scale aware, `DateTime`-like data type which supports
all commonly used astronomical time scales.

## Installation

The package can be installed through Julia's package manager:

```julia-repl
julia> import Pkg; Pkg.add("AstroTime")
```

## Quickstart

Create an Epoch based on the TT (Terrestial Time) scale
```jldoctest quickstart
julia> tt = TTEpoch("2018-01-01T12:00:00")
2018-01-01T12:00:00.000 TT
```

Transform to TAI (International Atomic Time)
```jldoctest quickstart
julia> tai = TAIEpoch(tt)
2018-01-01T11:59:27.816 TAI
```

Transform to TDB (Barycentric Dynamical Time)
```jldoctest quickstart
julia> tdb = TDBEpoch(tai)
2018-01-01T11:59:59.999 TDB
```

Shift an Epoch by one day
```jldoctest quickstart
julia> another_day = tt + 1days
2018-01-02T12:00:00.000 TT
```

## Next Steps

Follow the [Tutorial](@ref) to get an in-depth look at AstroTime.jl's functionality.


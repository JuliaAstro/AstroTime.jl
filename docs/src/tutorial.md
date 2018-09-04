# Tutorial

This tutorial will walk you through the features and functionality of AstroTime.jl.
Everything in AstroTime.jl revolves around the `Epoch` data type.
`Epochs` are basically a high-precision, time scale-aware version of the [`DateTime`](https://docs.julialang.org/en/stable/stdlib/Dates/#Dates-1) type from Julia's standard library.
This means that while `DateTime` timestamps are always assumed to be based on Universal Time (UT), `Epochs` can be based on several pre-defined time scales, e.g. International Atomic Time (TAI) or Terrestrial Time (TT), or custom user-defined time scales.
`Epochs` are future-proof, they can cover a range of ten times the age of the universe, and offer sub-nanosecond precision.

## Creating Epochs

You construct `Epoch` instances similar to `DateTime` instance, for example by using date and time components.
The main difference is that you need to supply the time scale to be used.

```julia
using AstroTime

ep = Epoch{UTC}(2018, 2, 6, 20, 45, 0.0)

# The following shorthand also works
ep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)
```

## Working with Epochs and Periods

## Converting Between Time Scales

## Working with Julian Dates

## Converting to Standard Library Types

module AstroTime

using EarthOrientation
using Reexport

import Dates

export @timescale

include("TimeScales.jl")
include("Periods.jl")
include("AstroDates.jl")
include("Epochs.jl")

@reexport using .TimeScales
@reexport using .Periods
@reexport using .AstroDates
@reexport using .Epochs

import .Epochs: format

function __init__()
    Dates.CONVERSION_SPECIFIERS['t'] = TimeScale
    Dates.CONVERSION_SPECIFIERS['D'] = Epochs.DayOfYearToken
    Dates.CONVERSION_DEFAULTS[TimeScale] = TimeScales.NotATimeScale()
    Dates.CONVERSION_DEFAULTS[Epochs.DayOfYearToken] = Int64(0)

    Dates.CONVERSION_TRANSLATIONS[Epoch] = (
        Dates.Year,
        Dates.Month,
        Dates.Day,
        Epochs.DayOfYearToken,
        Dates.Hour,
        Dates.Minute,
        Dates.Second,
        Dates.Millisecond,
        TimeScale,
    )

    Dates.CONVERSION_TRANSLATIONS[TAIEpoch] = (
        Dates.Year,
        Dates.Month,
        Dates.Day,
        Epochs.DayOfYearToken,
        Dates.Hour,
        Dates.Minute,
        Dates.Second,
        Dates.Millisecond,
    )

    Dates.CONVERSION_TRANSLATIONS[UTCEpoch] = (
        Dates.Year,
        Dates.Month,
        Dates.Day,
        Epochs.DayOfYearToken,
        Dates.Hour,
        Dates.Minute,
        Dates.Second,
        Dates.Millisecond,
    )

    Dates.CONVERSION_TRANSLATIONS[UT1Epoch] = (
        Dates.Year,
        Dates.Month,
        Dates.Day,
        Epochs.DayOfYearToken,
        Dates.Hour,
        Dates.Minute,
        Dates.Second,
        Dates.Millisecond,
    )

    Dates.CONVERSION_TRANSLATIONS[TTEpoch] = (
        Dates.Year,
        Dates.Month,
        Dates.Day,
        Epochs.DayOfYearToken,
        Dates.Hour,
        Dates.Minute,
        Dates.Second,
        Dates.Millisecond,
    )

    Dates.CONVERSION_TRANSLATIONS[TCGEpoch] = (
        Dates.Year,
        Dates.Month,
        Dates.Day,
        Epochs.DayOfYearToken,
        Dates.Hour,
        Dates.Minute,
        Dates.Second,
        Dates.Millisecond,
    )

    Dates.CONVERSION_TRANSLATIONS[TCBEpoch] = (
        Dates.Year,
        Dates.Month,
        Dates.Day,
        Epochs.DayOfYearToken,
        Dates.Hour,
        Dates.Minute,
        Dates.Second,
        Dates.Millisecond,
    )

    Dates.CONVERSION_TRANSLATIONS[TDBEpoch] = (
        Dates.Year,
        Dates.Month,
        Dates.Day,
        Epochs.DayOfYearToken,
        Dates.Hour,
        Dates.Minute,
        Dates.Second,
        Dates.Millisecond,
    )
end

"""
    @timescale scale

Define a new timescale and the corresponding `Epoch` type alias.

# Example

```jldoctest
julia> @timescale GMT ep tai_offset(UTC, ep)

julia> GMT <: TimeScale
true

julia> GMTEpoch
Epoch{GMT,T} where T
```
"""
macro timescale(scale::Symbol, ep::Symbol, args...)
    epoch = Expr(:escape, Symbol(scale, "Epoch"))
    sc = Expr(:escape, scale)
    name = String(scale)
    return quote
        struct $sc <: TimeScale end
        const $epoch = Epoch{$sc()}
        Base.show(io::IO, $sc) = print(io, string(typeof($sc)))
        AstroTime.TimeScales.tryparse(::Val{Symbol($name)}) = $sc()

        Dates.CONVERSION_TRANSLATIONS[$epoch] = (
            Dates.Year,
            Dates.Month,
            Dates.Day,
            Dates.Hour,
            Dates.Minute,
            Dates.Second,
            Dates.Millisecond,
        )
        Dates.default_format(::Type{$epoch}) = Dates.ISODateTimeFormat
        function AstroTime.Epochs.tai_offset(::$sc, $ep)
            $args[end]
        end

        nothing
    end
end

function update()
    EarthOrientation.update()
    nothing
end

end # module

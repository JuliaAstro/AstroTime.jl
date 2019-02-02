module AstroTime

using EarthOrientation
using Reexport

import Dates
import MacroTools

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
    @timescale scale epoch [args...] body

Define a new time scale, the corresponding `Epoch` type alias, and a function that calculates
the offset from TAI for the new time scale.

### Arguments ###

- `scale`: The name of the time scale
- `epoch`: The name of the `Epoch` parameter that is passed to the `tai_offset` function
- `args`: Optional additional parameters that are passed to the `tai_offset` function
- `body`: The body of the `tai_offset` function

# Example

```jldoctest
julia> @timescale GMT ep tai_offset(UTC, ep)

julia> GMT isa TimeScale
true

julia> GMTEpoch
Epoch{GMT,T} where T
```
"""
macro timescale(scale::Symbol, ep::Symbol, args...)
    scale_type = Symbol(scale, "Type")
    epoch_type = Symbol(scale, "Epoch")
    name = String(scale)

    arglist = [
        (nothing, scale_type, false, nothing),
        (ep, Epoch, false, nothing),
    ]
    body = args[end]
    append!(arglist, MacroTools.splitarg.(args[1:end-1]))
    args = map(x->MacroTools.combinearg(x...), arglist)
    def = Dict{Symbol, Any}(
        :name => :((AstroTime.Epochs).tai_offset),
        :args => map(x->MacroTools.combinearg(x...), arglist),
        :body => body,
        :kwargs => Any[],
        :whereparams => (),
    )
    func = esc(MacroTools.combinedef(def))

    MacroTools.@esc scale scale_type epoch_type

    MacroTools.@q begin
        struct $scale_type <: TimeScale end
        const $scale = $scale_type()
        const $epoch_type = Epoch{$scale}
        Base.show(io::IO, ::$scale_type) = print(io, $name)
        AstroTime.TimeScales.tryparse(::Val{Symbol($name)}) = $scale

        Dates.CONVERSION_TRANSLATIONS[$epoch_type] = (
            Dates.Year,
            Dates.Month,
            Dates.Day,
            Dates.Hour,
            Dates.Minute,
            Dates.Second,
            Dates.Millisecond,
        )
        Dates.default_format(::Type{$epoch_type}) = Dates.ISODateTimeFormat

        $func

        nothing
    end
end

function update()
    EarthOrientation.update()
    nothing
end

end # module

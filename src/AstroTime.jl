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

function __init__()
    for scale in TimeScales.ACRONYMS
        epoch = Symbol(scale, "Epoch")
        @eval begin
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
        end
    end
end

"""
    @timescale scale

Define a new timescale and the corresponding `Epoch` type alias.

# Example

```jldoctest
julia> @timescale Custom

julia> Custom <: TimeScale
true
julia> CustomEpoch == Epoch{Custom, T} where T <: Number
true
```
"""
macro timescale(scale::Symbol, ep::Symbol, args...)
    epoch = Expr(:escape, Symbol(scale, "Epoch"))
    sc = Expr(:escape, scale)
    ep_arg = Expr(:escape, ep)
    return quote
        struct $sc <: TimeScale end
        const $epoch = Epoch{$sc()}
        Base.show(io::IO, $sc) = print(io, string(typeof($sc)))

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

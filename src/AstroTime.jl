module AstroTime

using Reexport

import Dates
import EarthOrientation
import MacroTools

export @timescale

const ASTRO_ISO_FORMAT = Ref{Dates.DateFormat{Symbol("yyyy-mm-ddTHH:MM:SS.fff"),
                                              Tuple{Dates.DatePart{'y'},
                                                    Dates.Delim{Char, 1},
                                                    Dates.DatePart{'m'},
                                                    Dates.Delim{Char, 1},
                                                    Dates.DatePart{'d'},
                                                    Dates.Delim{Char, 1},
                                                    Dates.DatePart{'H'},
                                                    Dates.Delim{Char, 1},
                                                    Dates.DatePart{'M'},
                                                    Dates.Delim{Char, 1},
                                                    Dates.DatePart{'S'},
                                                    Dates.Delim{Char, 1},
                                                    Dates.DatePart{'f'}}}}()

const EPOCH_ISO_FORMAT = Ref{Dates.DateFormat{Symbol("yyyy-mm-ddTHH:MM:SS.fff ttt"),
                                              Tuple{Dates.DatePart{'y'},
                                                    Dates.Delim{Char, 1},
                                                    Dates.DatePart{'m'},
                                                    Dates.Delim{Char, 1},
                                                    Dates.DatePart{'d'},
                                                    Dates.Delim{Char, 1},
                                                    Dates.DatePart{'H'},
                                                    Dates.Delim{Char, 1},
                                                    Dates.DatePart{'M'},
                                                    Dates.Delim{Char, 1},
                                                    Dates.DatePart{'S'},
                                                    Dates.Delim{Char, 1},
                                                    Dates.DatePart{'f'},
                                                    Dates.Delim{Char, 1},
                                                    Dates.DatePart{'t'}}}}()

include("AccurateArithmetic.jl")
include("TimeScales.jl")
include("Periods.jl")
include("AstroDates.jl")
include(joinpath("Epochs", "Epochs.jl"))

import .AstroDates: Date, DateTime, Time

@reexport using .TimeScales
@reexport using .Periods
@reexport using .AstroDates
@reexport using .Epochs

import .Epochs: format

function __init__()
    Dates.CONVERSION_SPECIFIERS['t'] = TimeScale
    Dates.CONVERSION_SPECIFIERS['f'] = Epochs.FractionOfSecondToken
    Dates.CONVERSION_SPECIFIERS['D'] = Epochs.DayOfYearToken
    Dates.CONVERSION_DEFAULTS[TimeScale] = TimeScales.NotATimeScale()
    Dates.CONVERSION_DEFAULTS[Epochs.DayOfYearToken] = Int64(0)
    Dates.CONVERSION_DEFAULTS[Epochs.FractionOfSecondToken] = 0.0

    ASTRO_ISO_FORMAT[] = Dates.DateFormat("yyyy-mm-ddTHH:MM:SS.fff")
    EPOCH_ISO_FORMAT[] = Dates.DateFormat("yyyy-mm-ddTHH:MM:SS.fff ttt")

    Dates.CONVERSION_TRANSLATIONS[AstroDates.DateTime] = (
        Dates.Year,
        Dates.Month,
        Dates.Day,
        Epochs.DayOfYearToken,
        Dates.Hour,
        Dates.Minute,
        Dates.Second,
        Dates.Millisecond,
        Epochs.FractionOfSecondToken,
    )

    Dates.CONVERSION_TRANSLATIONS[AstroDates.DateTime{Float64}] = (
        Dates.Year,
        Dates.Month,
        Dates.Day,
        Epochs.DayOfYearToken,
        Dates.Hour,
        Dates.Minute,
        Dates.Second,
        Dates.Millisecond,
        Epochs.FractionOfSecondToken,
    )

    Dates.CONVERSION_TRANSLATIONS[Epoch] = (
        Dates.Year,
        Dates.Month,
        Dates.Day,
        Epochs.DayOfYearToken,
        Dates.Hour,
        Dates.Minute,
        Dates.Second,
        Dates.Millisecond,
        Epochs.FractionOfSecondToken,
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
        Epochs.FractionOfSecondToken,
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
        Epochs.FractionOfSecondToken,
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
        Epochs.FractionOfSecondToken,
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
        Epochs.FractionOfSecondToken,
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
        Epochs.FractionOfSecondToken,
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
        Epochs.FractionOfSecondToken,
    )
end

"""
    @timescale scale [parent[, oneway]]

Define a new time scale and the corresponding `Epoch` type alias.

### Arguments ###

- `scale`: The name of the time scale
- `parent`: The "parent" time scale to which it should be linked (optional)
- `oneway`: If `true`, only the transformation from `parent` to `scale` is
    registered (optional, default: `false`)

# Example

```jldoctest; setup = :(using AstroTime)
julia> @timescale GMT TAI

julia> GMT isa TimeScale
true

julia> GMTEpoch
Epoch{GMTScale, T} where T

julia> find_path(TT, GMT)
3-element Vector{TimeScale}:
 TT
 TAI
 GMT
```
"""
macro timescale(scale::Symbol, parent=nothing, oneway=false)
    scale_type = Symbol(scale, "Scale")
    epoch_type = Symbol(scale, "Epoch")
    name = String(scale)

    MacroTools.@esc scale scale_type epoch_type

    if parent === nothing
        reg_expr = MacroTools.@q(register_scale!($scale))
    else
        MacroTools.@esc parent
        reg_expr = MacroTools.@q(link_scales!($parent, $scale, oneway=$oneway))
    end

    return MacroTools.@q begin
        struct $scale_type <: TimeScale end
        const $scale = $scale_type()
        const $epoch_type = Epoch{$scale_type}
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

        $reg_expr

        nothing
    end
end

function load_eop(files...)
    EarthOrientation.push!(EarthOrientation.EOP_DATA, files...)
end

function load_test_eop()
    finals = joinpath(@__DIR__, "..", "test", "data", "finals.csv")
    finals2000A = joinpath(@__DIR__, "..", "test", "data", "finals2000A.csv")
    load_eop(finals, finals2000A)
end

"""
    AstroTime.update()

Download up-to-date IERS tables from the internet to enable transformations to and from
the [`UT1`](@ref) time scale.
"""
function update()
    EarthOrientation.update()
    nothing
end

end # module

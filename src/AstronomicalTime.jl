module AstronomicalTime

__precompile__()

using EarthOrientation
using Reexport

import RemoteFiles: path

export JULIAN_CENTURY, SEC_PER_DAY, SEC_PER_CENTURY, MJD, J2000, J1950,
    @timescale

const JULIAN_CENTURY = 36525.0
const SEC_PER_DAY = 86400.0
const SEC_PER_CENTURY = JULIAN_CENTURY * SEC_PER_DAY
const MJD = 2400000.5
const J2000 = Dates.datetime2julian(DateTime(2000, 1, 1, 12, 0, 0))
const J1950 = Dates.datetime2julian(DateTime(1950, 1, 1, 12, 0, 0))

include("LeapSeconds.jl")
include("TimeScales.jl")
include("Periods.jl")
include("Epochs.jl")

@reexport using .TimeScales
@reexport using .Periods
@reexport using .LeapSeconds
@reexport using .Epochs

"""
    @timescale scale

Define a new timescale and the corresponding `Epoch` type alias.

# Example

```jldoctest
julia> @timescale Custom

julia> Custom <: TimeScale
true
julia> CustomEpoch == Epoch{Custom}
true
```
"""
macro timescale(scale)
    if !(scale isa Symbol)
        error("Invalid time scale name.")
    end
    epoch = Symbol(scale, "Epoch")
    return quote
        struct $(esc(scale)) <: TimeScale end
        @convertible const $(esc(epoch)) = Epoch{$(esc(scale))}
    end
end

function update()
    EarthOrientation.update()
    download(LSK_FILE)
    push!(LSK_DATA, path(LSK_FILE))
    nothing
end

end # module

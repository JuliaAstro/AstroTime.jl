# __precompile__()

module AstronomicalTime

using EarthOrientation
using Reexport

import RemoteFiles: path, isfile

export @timescale

include("LeapSeconds.jl")
include("TimeScales.jl")
include("Periods.jl")
include("Epochs.jl")

@reexport using .TimeScales
@reexport using .Periods
@reexport using .LeapSeconds
@reexport using .Epochs

function __init__()
    isfile(LSK_FILE) && push!(LSK_DATA, path(LSK_FILE))
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
macro timescale(scale)
    if !(scale isa Symbol)
        error("Invalid time scale name.")
    end
    epoch = Symbol(scale, "Epoch")
    return quote
        struct $(esc(scale)) <: TimeScale end
        const $(esc(epoch)) = Epoch{$(esc(scale))}
    end
end

function update()
    EarthOrientation.update()
    download(LSK_FILE)
    push!(LSK_DATA, path(LSK_FILE))
    nothing
end

end # module

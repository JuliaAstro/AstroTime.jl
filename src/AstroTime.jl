__precompile__()

module AstroTime

using EarthOrientation
using Reexport
import RemoteFiles: path, isfile

export @timescale

include("TimeScales.jl")
include("Periods.jl")
#= include("Epochs.jl") =#
include("Epochs2.jl")

@reexport using .TimeScales
@reexport using .Periods
#= @reexport using .Epochs =#
@reexport using .Epochs2

#= """ =#
#=     @timescale scale =#
#=  =#
#= Define a new timescale and the corresponding `Epoch` type alias. =#
#=  =#
#= # Example =#
#=  =#
#= ```jldoctest =#
#= julia> @timescale Custom =#
#=  =#
#= julia> Custom <: TimeScale =#
#= true =#
#= julia> CustomEpoch == Epoch{Custom, T} where T <: Number =#
#= true =#
#= ``` =#
#= """ =#
#= macro timescale(scale) =#
#=     if !(scale isa Symbol) =#
#=         error("Invalid time scale name.") =#
#=     end =#
#=     epoch = Symbol(scale, "Epoch") =#
#=     return quote =#
#=         struct $(esc(scale)) <: TimeScale end =#
#=         const $(esc(epoch)) = Epoch{$(esc(scale))} =#
#=         nothing =#
#=     end =#
#= end =#

function update()
    EarthOrientation.update()
    nothing
end

end # module

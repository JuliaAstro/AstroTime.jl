module AstroTime

using EarthOrientation
using Reexport

export @timescale

include("TimeScales.jl")
include("Periods.jl")
include("AstroDates.jl")
include("Epochs.jl")

@reexport using .TimeScales
@reexport using .Periods
@reexport using .AstroDates
@reexport using .Epochs

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

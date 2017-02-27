module AstronomicalTime

using Compat
using ERFA

import Base: inv, isapprox
import Base.Dates: datetime2julian
import LightGraphs: Graph, nv, add_edge!, add_vertex!

export Timescale, Epoch, EpochPeriod

const JULIAN_CENTURY = 36525
const SEC_PER_DAY = 86400
const SEC_PER_CENTURY = SEC_PER_DAY*JULIAN_CENTURY
const TAI_TO_TT = 32.184/SEC_PER_DAY
const LG = 6.969290134e-10
const TT0 = 2443144.5003725
const MJD0 = 2400000.5
const J2000 = Dates.datetime2julian(DateTime(2000, 1, 1, 12, 0, 0))
const J1950 = Dates.datetime2julian(DateTime(1950, 1, 1, 12, 0, 0))

@compat abstract type Timescale end
Base.show{T<:Timescale}(io::IO, ::Type{T}) = print(io, T.name.name)

scales = (
    :TAI,
    :TT,
    :UTC,
    :UT1,
    :TCG,
    :TCB,
    :TDB,
)

for scale in scales
    @eval begin
        immutable $scale <: Timescale end
        export $scale
    end
end

immutable Epoch{T<:Timescale}
    jd1::Float64
    jd2::Float64
end
Epoch{T<:Timescale}(::Type{T}, jd1, jd2) = Epoch{T}(jd1, jd2)

Base.show{T<:Timescale}(io::IO, ep::Epoch{T}) = print(io, "")

function convert{T<:Timescale}(::Type{DateTime}, ep::Epoch{T})
    dt = eraD2dtf(string(T.name.name), 3, ep.jd1, ep.jd2)
    DateTime(dt...)
end
DateTime(ep::Epoch) = convert(DateTime, ep)

immutable EpochPeriod
    djd1::Float64
    djd2::Float64
end
EpochPeriod(;days=0, seconds=0) = EpochPeriod(days, seconds/SEC_PER_DAY)

#= function isapprox{T}(ep1::Epoch{T}, ep2::Epoch{T}) =#
#=     ep1.jd1 ≈ ep2.jd1 && ep1.jd2 ≈ ep2.jd2 =#
#= end =#
#=  =#
#= abstract Transformation{F<:Timescale, T<:Timescale} =#
#=  =#
#= from{F,T}(t::Transformation{F,T}) = F =#
#= to{F,T}(t::Transformation{F,T}) = T =#
#=  =#
#= immutable Offset{F,T} <: Transformation{F,T} =#
#=     v::Float64 =#
#= end =#
#= Offset{F,T}(from::F, to::T, v) = Offset{F,T}(v) =#
#=  =#
#= inv{F,T}(t::Offset{F,T}) = Offset{T,F}(-t.v) =#
#=  =#
#= @inline function (t::Offset{F,T}){F,T}(ep::Epoch{F}) =#
#=     jd1 = ep.jd1 =#
#=     jd2 = ep.jd2 =#
#=     if abs(jd1) > abs(jd2) =#
#=         jd2 += t.v =#
#=     else =#
#=         jd1 += t.v =#
#=     end =#
#=     Epoch{T}(jd1, jd2) =#
#= end =#
#=  =#
#= type Registry =#
#=     graph::Graph =#
#=     scales::Dict{DataType, Int} =#
#=     transformations::Dict{Int, Dict{Int, Transformation}} =#
#=     Registry() = new(Graph(), Dict{DataType, Int}(), Dict{Int, Dict{Int, Transformation}}()) =#
#= end =#
#=  =#
#= const registry = Registry() =#
#=  =#
#= function add_scale!(reg::Registry, scale::DataType) =#
#=     add_vertex!(reg.graph) =#
#=     merge!(reg.scales, Dict(scale => nv(reg.graph))) =#
#= end =#
#= add_scale!(scale::DataType) = add_scale!(registry, scale) =#
#=  =#
#= function add_transformation!{F,T}(reg::Registry, t::Transformation{F,T}) =#
#=     from = reg.scales[F] =#
#=     to = reg.scales[T] =#
#=  =#
#=     add_edge!(reg.graph, from, to) =#
#=     if !haskey(reg.transformations, from) =#
#=         merge!(reg.transformations, Dict(from => Dict{Int, Transformation}())) =#
#=     end =#
#=     merge!(reg.transformations[from], Dict(to => t)) =#
#=  =#
#=     add_edge!(reg.graph, to, from) =#
#=     if !haskey(reg.transformations, to) =#
#=         merge!(reg.transformations, Dict(to => Dict{Int, Transformation}())) =#
#=     end =#
#=     merge!(reg.transformations[to], Dict(from => inv(t))) =#
#= end =#
#= add_transformation!(t::Transformation) = add_transformation!(registry, t) =#
#=  =#
#=  =#
#= for scale in scales =#
#=     @eval begin =#
#=         immutable $sym <: Timescale end =#
#=         const $scale = $sym() =#
#=         Base.show(io::IO, tai::$sym) = print(io, $str) =#
#=         export $scale =#
#=         add_scale!($sym) =#
#=     end =#
#= end =#


end # module

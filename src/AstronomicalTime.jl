module AstronomicalTime

import Base.Dates: TimeType
import Base: inv, isapprox
import LightGraphs: Graph, nv, add_edge!, add_vertex!

export Timescale, Epoch, Transformation, Offset, inv, isapprox

const SECONDS_PER_DAY = 86400
const TAI_TO_TT = 32.184/SECONDS_PER_DAY
const LG = 6.969290134e-10
const TT0 = 2443144.5003725
const MJD0 = 2400000.5

abstract Timescale

type Epoch{T<:Timescale} <: TimeType
    jd1::Float64
    jd2::Float64
end
Epoch{T}(::T, jd1, jd2) = Epoch{T}(jd1, jd2)

function isapprox{T}(ep1::Epoch{T}, ep2::Epoch{T})
    ep1.jd1 ≈ ep2.jd1 && ep1.jd2 ≈ ep2.jd2
end

abstract Transformation{F<:Timescale, T<:Timescale}

from{F,T}(t::Transformation{F,T}) = F
to{F,T}(t::Transformation{F,T}) = T

immutable Offset{F,T} <: Transformation{F,T}
    v::Float64
end
Offset{F,T}(from::F, to::T, v) = Offset{F,T}(v)

inv{F,T}(t::Offset{F,T}) = Offset{T,F}(-t.v)

@inline function (t::Offset{F,T}){F,T}(ep::Epoch{F})
    jd1 = ep.jd1
    jd2 = ep.jd2
    if abs(jd1) > abs(jd2)
        jd2 += t.v
    else
        jd1 += t.v
    end
    Epoch{T}(jd1, jd2)
end

type Registry
    graph::Graph
    scales::Dict{DataType, Int}
    transformations::Dict{Int, Dict{Int, Transformation}}
    Registry() = new(Graph(), Dict{DataType, Int}(), Dict{Int, Dict{Int, Transformation}}())
end

const registry = Registry()

function add_scale!(reg::Registry, scale::DataType)
    add_vertex!(reg.graph)
    merge!(reg.scales, Dict(scale => nv(reg.graph)))
end
add_scale!(scale::DataType) = add_scale!(registry, scale)

function add_transformation!{F,T}(reg::Registry, t::Transformation{F,T})
    from = reg.scales[F]
    to = reg.scales[T]

    add_edge!(reg.graph, from, to)
    if !haskey(reg.transformations, from)
        merge!(reg.transformations, Dict(from => Dict{Int, Transformation}()))
    end
    merge!(reg.transformations[from], Dict(to => t))

    add_edge!(reg.graph, to, from)
    if !haskey(reg.transformations, to)
        merge!(reg.transformations, Dict(to => Dict{Int, Transformation}()))
    end
    merge!(reg.transformations[to], Dict(from => inv(t)))
end
add_transformation!(t::Transformation) = add_transformation!(registry, t)

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
    sym = Symbol(scale, "Scale")
    str = string(scale)
    @eval begin
        immutable $sym <: Timescale end
        const $scale = $sym()
        Base.show(io::IO, tai::$sym) = print(io, $str)
        export $scale
        add_scale!($sym)
    end
end

add_transformation!(Offset(TAI, TT, TAI_TO_TT))

immutable TTtoTCG

end # module

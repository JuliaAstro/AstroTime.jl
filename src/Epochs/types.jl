struct Epoch{S<:TimeScale, T} <: Dates.AbstractDateTime
    scale::S
    second::Int64
    fraction::T
    error::T
    function Epoch{S}(second::Int64, fraction::T, error::T=zero(T)) where {S<:TimeScale, T<:AbstractFloat}
        return new{S, T}(S(), second, fraction, error)
    end
end

Epoch{S,T}(ep::Epoch{S,T}) where {S,T} = ep

function Epoch{S}(ep::Epoch{S}, Δt) where {S<:TimeScale}
    second, fraction, error = apply_offset(ep.second, ep.fraction, ep.error, Δt)
    return Epoch{S}(second, fraction, error)
end

Base.show(io::IO, ep::Epoch) = print(io, DateTime(ep), " ", timescale(ep))

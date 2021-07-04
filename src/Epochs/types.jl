@inline function two_sum(a, b)
    hi = a + b
    a1 = hi - b
    b1 = hi - a1
    lo = (a - a1) + (b - b1)
    return hi, lo
end

@inline function two_hilo_sum(a, b)
    hi = a + b
    lo = b - (hi - a)
    return hi, lo
end

function three_sum(a, b, c)
    s, t   = two_sum(b, c)
    hi, u  = two_sum(a, s)
    md, lo = two_sum(u, t)
    hi, md = two_hilo_sum(hi, md)
    return hi, md, lo
end

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

@inline function apply_offset(second::Int64, fraction, error, offset)
    if !isfinite(fraction + offset)
        fraction′ = fraction + offset
        second′ = ifelse(fraction′ < 0, typemin(Int64), typemax(Int64))
        residual = zero(fraction)
    else
        offset_secs = floor(Int64, offset)
        sum, residual, _ = three_sum(fraction, error, offset - offset_secs)
        int_secs = floor(Int64, sum)
        second′ = second + int_secs + offset_secs
        fraction′ = sum - int_secs
    end
    return second′, fraction′, residual
end

function Epoch{S}(ep::Epoch{S}, Δt) where {S<:TimeScale}
    second, fraction, error = apply_offset(ep.second, ep.fraction, ep.error, Δt)
    return Epoch{S}(second, fraction, error)
end

Base.show(io::IO, ep::Epoch) = print(io, DateTime(ep), " ", timescale(ep))

@inline function two_sum(a, b)
    hi = a + b
    a1 = hi - b
    b1 = hi - a1
    lo = (a - a1) + (b - b1)
    hi, lo
end

struct Epoch{S<:TimeScale, T} <: Dates.AbstractDateTime
    scale::S
    second::Int64
    fraction::T
    function Epoch{S}(second::Int64, fraction::T) where {S<:TimeScale, T}
        return new{S, T}(S(), second, fraction)
    end
end

Epoch{S,T}(ep::Epoch{S,T}) where {S,T} = ep

@inline function apply_offset(second::Int64, fraction, offset)
    sum, residual = two_sum(fraction, offset)
    if !isfinite(sum)
        fraction′ = sum
        second′ = sum < 0 ? typemin(Int64) : typemax(Int64)
    else
        int_secs = floor(Int64, sum)
        fraction′ = sum - int_secs + residual
        second′ = second + int_secs
    end
    return second′, fraction′
end

function Epoch{S}(ep::Epoch{S}, Δt) where {S<:TimeScale}
    second, fraction = apply_offset(ep.second, ep.fraction, Δt)
    Epoch{S}(second, fraction)
end

show(io::IO, ep::Epoch) = print(io, DateTime(ep), " ", timescale(ep))

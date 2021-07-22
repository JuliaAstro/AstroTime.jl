function Base.isapprox(a::Epoch{S}, b::Epoch{S}; kwargs...) where S <: TimeScale
    return isapprox(a.fraction + a.second, b.fraction + b.second; kwargs...)
end

function Base.:(==)(a::Epoch, b::Epoch)
    a.second == b.second && a.fraction == b.fraction
end

Base.isless(ep1::Epoch, ep2::Epoch) = isless(value(ep1 - ep2), 0.0)

function Base.:+(ep::Epoch{S}, p::AstroPeriod) where {S}
    second, fraction, error = apply_offset(ep.second, ep.fraction, ep.error, p.second, p.fraction, p.error)
    return Epoch{S}(second, fraction, error)
end
Base.:-(ep::Epoch, p::AstroPeriod) = ep + (-p)

"""
    -(a::Epoch, b::Epoch)

Return the duration between epoch `a` and epoch `b`.

### Examples ###

```jldoctest; setup = :(using AstroTime)
julia> TAIEpoch(2018, 2, 6, 20, 45, 20.0) - TAIEpoch(2018, 2, 6, 20, 45, 0.0)
20.0 seconds
```
"""
function Base.:-(a::Epoch{S}, b::Epoch{S}) where S<:TimeScale
    second = a.second - b.second
    fraction = (a.error - b.error) + (a.fraction - b.fraction)
    return (fraction + second) * seconds
end


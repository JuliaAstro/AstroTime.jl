function Base.isapprox(a::Epoch{S}, b::Epoch{S}; kwargs...) where S <: TimeScale
    return isapprox(a.fraction + a.second, b.fraction + b.second; kwargs...)
end

function Base.:(==)(a::Epoch, b::Epoch)
    a.second == b.second && a.fraction == b.fraction
end

Base.isless(ep1::Epoch, ep2::Epoch) = isless(value(ep1 - ep2), 0.0)

Base.:+(ep::Epoch{S}, p::Period) where {S} = Epoch{S}(ep, value(seconds(p)))
Base.:-(ep::Epoch{S}, p::Period) where {S} = Epoch{S}(ep, -value(seconds(p)))

"""
    -(a::Epoch, b::Epoch)

Return the duration between epoch `a` and epoch `b`.

### Examples ###

```jldoctest; setup = :(using AstroTime)
julia> UTCEpoch(2018, 2, 6, 20, 45, 20.0) - UTCEpoch(2018, 2, 6, 20, 45, 0.0)
20.0 seconds
```
"""
function Base.:-(a::Epoch{S}, b::Epoch{S}) where S<:TimeScale
    return ((a.second - b.second) + (a.fraction - b.fraction)) * seconds
end


function isapprox(a::Epoch{S}, b::Epoch{S}; atol::Real=0, rtol::Real=atol>0 ? 0 : √eps()) where S <: TimeScale
    a.second == b.second && isapprox(a.fraction, b.fraction; atol=atol, rtol=rtol)
end

function ==(a::Epoch, b::Epoch)
    a.second == b.second && a.fraction == b.fraction
end

<(ep1::Epoch, ep2::Epoch) = value(ep1 - ep2) < 0.0
isless(ep1::Epoch, ep2::Epoch) = isless(value(ep1 - ep2), 0.0)

+(ep::Epoch{S}, p::Period) where {S} = Epoch{S}(ep, value(seconds(p)))
-(ep::Epoch{S}, p::Period) where {S} = Epoch{S}(ep, -value(seconds(p)))

"""
    -(a::Epoch, b::Epoch)

Return the duration between epoch `a` and epoch `b`.

### Examples ###

```jldoctest
julia> UTCEpoch(2018, 2, 6, 20, 45, 20.0) - UTCEpoch(2018, 2, 6, 20, 45, 0.0)
20.0 seconds
```
"""
function -(a::Epoch{S}, b::Epoch{S}) where S<:TimeScale
    return ((a.second - b.second) + (a.fraction - b.fraction)) * seconds
end

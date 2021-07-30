const J2000_TO_JULIAN = 2.451545e6days
const J2000_TO_MJD = 51544.5days

"""
    Epoch{S}(jd1::T, jd2::T=zero(T); origin=:j2000) where {S, T<:AstroPeriod}

Construct an `Epoch` with time scale `S` from a Julian date
(optionally split into `jd1` and `jd2`). `origin` determines the
variant of Julian date that is used. Possible values are:

- `:j2000`: J2000 Julian date, starts at `2000-01-01T12:00`
- `:julian`: Julian date, starts at `-4712-01-01T12:00`
- `:modified_julian`: Modified Julian date, starts at `1858-11-17T00:00`

### Examples ###

```jldoctest; setup = :(using AstroTime)
julia> Epoch{InternationalAtomicTime}(0.0days, 0.5days)
2000-01-02T00:00:00.000 TAI

julia> Epoch{InternationalAtomicTime}(2.451545e6days, origin=:julian)
2000-01-01T12:00:00.000 TAI
```
"""
function Epoch{S}(jd1::T, jd2::T=zero(T), args...; origin=:j2000) where {S, T<:AstroPeriod}
    if jd2 > jd1
        jd1, jd2 = jd2, jd1
    end

    u = unit(jd1)

    if origin == :j2000
        # pass
    elseif origin == :julian
        jd1 -= u(J2000_TO_JULIAN)
    elseif origin == :modified_julian
        jd1 -= u(J2000_TO_MJD)
    else
        throw(ArgumentError("Unknown Julian epoch: $origin"))
    end

    jd1v = jd1 |> seconds |> value
    jd2v = jd2 |> seconds |> value

    sum, residual = two_sum(jd1v, jd2v)
    epoch = floor(Int64, sum)
    offset = (sum - epoch) + residual
    return Epoch{S}(epoch, offset)
end

"""
    julian_period([T,] ep::Epoch; origin=:j2000, scale=timescale(ep), unit=days)

Return the period since Julian Epoch `origin` within the time scale `scale` expressed in
`unit` for a given epoch `ep`. The result is an [`AstroPeriod`](@ref) object by default.
If the type argument `T` is present, the result is converted to `T` instead.

### Example ###

```jldoctest; setup = :(using AstroTime)
julia> ep = TAIEpoch(2018, 2, 6, 20, 45, 0.0)
2018-02-06T20:45:00.000 TAI

julia> julian_period(ep; scale=TT)
6611.364955833334 days

julia> julian_period(ep; unit=years)
18.100929728496464 years

julia> julian_period(Float64, ep)
6611.364583333333
```
"""
function julian_period(ep::Epoch; origin=:j2000, scale=timescale(ep), unit=days)
    ep1 = Epoch(ep, scale)
    jd1 = unit(ep1.second * seconds)
    jd2 = unit(ep1.fraction * seconds)

    if origin == :j2000
        # pass
    elseif origin == :julian
        jd1 += unit(J2000_TO_JULIAN)
    elseif origin == :modified_julian
        jd1 += unit(J2000_TO_MJD)
    else
        throw(ArgumentError("Unknown Julian epoch: $origin"))
    end

    return jd2 + jd1
end

function julian_period(::Type{T}, ep::Epoch; kwargs...) where T
    jd = julian_period(ep; kwargs...)
    return T(value(jd))
end

"""
    j2000(ep)

Return the J2000 Julian Date for epoch `ep`.

### Example ###

```jldoctest; setup = :(using AstroTime)
julia> j2000(TAIEpoch(2000, 1, 1, 12))
0.0 days
```
"""
j2000(ep::Epoch) = julian_period(ep)

"""
    julian(ep)

Return the Julian Date for epoch `ep`.

### Example ###

```jldoctest; setup = :(using AstroTime)
julia> julian(TAIEpoch(2000, 1, 1, 12))
2.451545e6 days
```
"""
julian(ep::Epoch) = julian_period(ep; origin=:julian)

"""
    modified_julian(ep)

Return the Modified Julian Date for epoch `ep`.

### Example ###

```jldoctest; setup = :(using AstroTime)
julia> modified_julian(TAIEpoch(2000, 1, 1, 12))
51544.5 days
```
"""
modified_julian(ep::Epoch) = julian_period(ep; origin=:modified_julian)

"""
    julian_twopart(ep)

Return the two-part Julian Date for epoch `ep`, which is a tuple consisting
of the Julian day number and the fraction of the day.

### Example ###

```jldoctest; setup = :(using AstroTime)
julia> julian_twopart(TAIEpoch(2000, 1, 2))
(2.451545e6 days, 0.5 days)
```
"""
function julian_twopart(ep::Epoch)
    sec_in_days = ep.second / SECONDS_PER_DAY
    frac_in_days = ep.fraction / SECONDS_PER_DAY
    j2k1, j2k2 = divrem(sec_in_days, 1)
    jd1 = j2k1 * days + J2000_TO_JULIAN
    jd2 = (frac_in_days + j2k2) * days
    return jd1, jd2
end


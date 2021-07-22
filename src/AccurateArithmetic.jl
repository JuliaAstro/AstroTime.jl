module AccurateArithmetic

# Adapted from AccurateArithmetic.jl

export two_sum, apply_offset

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

function four_sum(a, b, c, d)
    t0, t1 = two_sum(a,  b)
    t2, t3 = two_sum(c,  d)
    hi, t4 = two_sum(t0, t2)
    t5, lo = two_sum(t1, t3)
    hm, ml = two_sum(t4, t5)
    ml, lo = two_hilo_sum(ml, lo)
    hm, ml = two_hilo_sum(hm, ml)
    hi, hm = two_hilo_sum(hi,hm)
    return hi, hm, ml, lo
end

function handle_infinity(fraction)
    second = ifelse(fraction < 0, typemin(Int64), typemax(Int64))
    return second, fraction, zero(fraction)
end

function apply_offset(s1::Int64, f1, e1, s2::Int64, f2, e2)
    isfinite(f1 + f2) || return handle_infinity(f1 + f2)

    sum, residual, _ = four_sum(f1, f2, e1, e2)
    int_seconds = floor(Int64, sum)
    second = s1 + s2 + int_seconds
    fraction = sum - int_seconds
    return second, fraction, residual
end

function apply_offset(s1::Int64, f1, e1, offset)
    isfinite(f1 + offset) || return handle_infinity(f1 + offset)

    s2 = floor(Int64, offset)
    f2 = offset - s2
    return apply_offset(s1, f1, e1, s2, f2, 0.0)
end

end


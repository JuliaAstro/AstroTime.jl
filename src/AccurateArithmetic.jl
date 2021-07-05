module AccurateArithmetic

# Adapted from AccurateArithmetic.jl

export two_sum, two_hilo_sum, three_sum

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

end


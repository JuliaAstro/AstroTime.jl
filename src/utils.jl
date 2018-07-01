"""
Return the sum of ``val1`` and ``val2`` as two float64s, an integer part
and the fractional remainder.  If ``factor`` is not 1.0 then multiply the
sum by ``factor``.  If ``divisor`` is not 1.0 then divide the sum by
``divisor``.
The arithmetic is all done with exact floating point operations so no
precision is lost to rounding error.  This routine assumes the sum is less
than about 1e16, otherwise the ``frac`` part will be greater than 1.0.
Returns
-------
day, frac : float64
    Integer and fractional part of val1 + val2.
"""
function sec_frac(val1, val2)
    # Add val1 and val2 exactly, returning the result as two float64s.
    # The first is the approximate sum (with some floating point error)
    # and the second is the error of the float64 sum.
    sum12, err12 = two_sum(val1, val2)

    # get integer fraction
    sec = Int64(round(sum12))
    extra, frac = two_sum(sum12, -sec)
    frac += extra + err12
    sec, frac
end


"""
Add ``a`` and ``b`` exactly, returning the result as two float64s.
The first is the approximate sum (with some floating point error)
and the second is the error of the float64 sum.
Using the procedure of Shewchuk, 1997,
Discrete & Computational Geometry 18(3):305-363
http://www.cs.berkeley.edu/~jrs/papers/robustr.pdf
Returns
-------
sum, err : float64
    Approximate sum of a + b and the exact floating point error
"""
function two_sum(a, b)
    x = a + b
    eb = x - a
    eb = b - eb
    ea = x - b
    ea = a - ea
    x, ea + eb
end


"""
Multiple ``a`` and ``b`` exactly, returning the result as two float64s.
The first is the approximate product (with some floating point error)
and the second is the error of the float64 product.
Uses the procedure of Shewchuk, 1997,
Discrete & Computational Geometry 18(3):305-363
http://www.cs.berkeley.edu/~jrs/papers/robustr.pdf
Returns
-------
prod, err : float64
    Approximate product a * b and the exact floating point error
"""
function two_product(a, b)
    x = a * b
    ah, al = split(a)
    bh, bl = split(b)
    y1 = ah * bh
    y = x - y1
    y2 = al * bh
    y -= y2
    y3 = ah * bl
    y -= y3
    y4 = al * bl
    y = y4 - y
    x, y
end


"""
Split float64 in two aligned parts.
Uses the procedure of Shewchuk, 1997,
Discrete & Computational Geometry 18(3):305-363
http://www.cs.berkeley.edu/~jrs/papers/robustr.pdf
"""
function split(a)
    c = 134217729.0 * a  # 2**27+1.
    abig = c - a
    ah = c - abig
    al = a - ah
    ah, al
end
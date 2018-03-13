module Conversionfunctions
import Convertible: findpath, haspath
include("constants.jl")
export Taitt

function Taitt(tai1::Float64, tai2::Float64)
    const dtat = TTMTAI/SECONDS_PER_DAY;

    # Result, safeguarding precision
    if tai1 > tai2
        tt1 = tai1
        tt2 = tai2 + dtat
    else
        tt1 = tai1 + dtat
        tt2 = tai2
    end

    # Status (always OK)
    return tt1, tt2
end

end

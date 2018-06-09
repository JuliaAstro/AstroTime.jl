module LeapSeconds

using ERFA
using OptionalData
using RemoteFiles


export leapseconds, LSK, LSK_FILE, LSK_DATA, fractionofday

const DRIFT_EPOCHS = ( 2.4373005e6, 2.4376655e6 , 2.4387615e6, 2.4391265e6)
const DRIFT_RATE = ( 0.0012960, 0.0011232, 0.0012960, 0.0025920)

const LS_1972 = [(2.4369345e6, 2.4373005e6, 2.4375125e6, 2.4376655e6, 2.4383345e6, 2.4383955e6, 2.4384865e6,
 2.4386395e6, 2.4387615e6, 2.4388205e6, 2.4389425e6, 2.4390045e6, 2.4391265e6, 2.4398875e6),
 (1.417818, 1.422818, 1.372818, 1.845858, 1.945858, 3.240130, 3.340130, 3.440130, 3.540130,
 3.640130, 3.740130, 3.840130, 4.313170,4.213170)]

struct LSK
    t::Vector{Float64}
    leapseconds::Vector{Float64}
end

function LSK(file)
    t = Vector{Float64}()
    leapseconds = Vector{Float64}()
    re = r"(?<dat>[0-9]{2}),\s+@(?<date>[0-9]{4}-[A-Z]{3}-[0-9])"
    lines = open(readlines, file)
    for line in lines
        s = string(line)
        if ismatch(re, s)
            m = match(re, s)
            push!(leapseconds, float(m["dat"]))
            push!(t, Dates.datetime2julian(DateTime(m["date"], "y-u-d")))
        end
    end
    LSK(t, leapseconds)
end

@RemoteFile LSK_FILE "https://naif.jpl.nasa.gov/pub/naif/generic_kernels/lsk/naif0012.tls"
@OptionalData LSK_DATA LSK "Run 'AstroTime.update()' to load it."

function fractionofday(dt)
    Dates.hour(dt)/24 + Dates.minute(dt)/(24*60) + Dates.second(dt)/86400 + Dates.millisecond(dt)/8.64e7
end

function leapseconds(lsk::LSK, jd)
    # Before 1960-01-01
    if jd < 2.4369345e6
        return 0.0
    elseif jd < lsk.t[1]
        idx = findlast(jd .>= LS_1972[1])
        a = [ abs(i) for i in jd .- DRIFT_EPOCHS]
        i_drift = find(x -> x==min(a...), a)[1]
        deltat = LS_1972[2][idx]
        deltat += (jd - DRIFT_EPOCHS[i_drift]) * DRIFT_RATE[i_drift]
        return deltat
    else
        return lsk.leapseconds[findlast(jd .>= lsk.t)]
    end
end
leapseconds(jd) = leapseconds(get(LSK_DATA), jd)
end

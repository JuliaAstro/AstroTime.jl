module Epochs

using LeapSeconds: offset_tai_utc
using EarthOrientation: getΔUT1, EOP_DATA, get
using LeapSeconds: offset_tai_utc, offset_utc_tai
using MuladdMacro

import Dates
import Dates: format

import ..AstroDates: Date, DateTime, Time
import ..AstroDates: year, day, month, hour, minute, second, millisecond
import ..AstroDates: calendar, yearmonthday, dayofyear, fractionofday, secondinday
import ..AstroDates: j2000, julian, julian_twopart

using ..TimeScales: find_path

export CCSDS_EPOCH, FIFTIES_EPOCH, FUTURE_INFINITY, GALILEO_EPOCH, GPS_EPOCH, J2000_EPOCH
export J2000_TO_JULIAN, J2000_TO_MJD, JULIAN_EPOCH, MODIFIED_JULIAN_EPOCH, PAST_INFINITY
export UNIX_EPOCH
export Date, DateTime, Time, Epoch
export NoOffsetError, NoPathError
export day, dayofyear, fractionofday, millisecond, minute, hour, month, now, second
export secondinday, timescale, year, yearmonthday
export getoffset, insideleap
export j2000, julian, julian_period, julian_twopart, modified_julian
export -

using ..TimeScales
using ..AstroDates
using ..Periods

include("types.jl")
include("julian.jl")
include("tdb_constants.jl")
include("offsets.jl")
include("accessors.jl")
include("operations.jl")
include("dates.jl")
include("aliases.jl")
include("ranges.jl")
include("epoch_constants.jl")
include("io.jl")

end

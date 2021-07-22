module Epochs

using LeapSeconds: offset_tai_utc, offset_utc_tai
using EarthOrientation: getΔUT1_TAI, EOP_DATA, get
using LeapSeconds: offset_tai_utc, offset_utc_tai
using MuladdMacro

import Dates
import Dates: format
import Dates: year, day, month, hour, minute, second
import Dates: millisecond, microsecond, nanosecond
import Dates: yearmonthday, dayofyear, now

import LeapSeconds

import ..EPOCH_ISO_FORMAT

import ..AstroDates: Date, DateTime, Time
import ..AstroDates: calendar, fractionofday, fractionofsecond, secondinday, subsecond
import ..AstroDates: j2000, julian, julian_twopart
import ..AccurateArithmetic: apply_offset, two_sum

using ..TimeScales: find_path

export CCSDS_EPOCH, FIFTIES_EPOCH, FUTURE_INFINITY, GALILEO_EPOCH, GPS_EPOCH, J2000_EPOCH
export J2000_TO_JULIAN, J2000_TO_MJD, JULIAN_EPOCH, MODIFIED_JULIAN_EPOCH, PAST_INFINITY
export UNIX_EPOCH
export Epoch
export NoOffsetError, NoPathError
export year, month, day, hour, minute, second
export millisecond, microsecond, nanosecond, subsecond
export yearmonthday, dayofyear, fractionofday, fractionofsecond, secondinday
export timescale, now
export getoffset, insideleap
export j2000, julian, julian_period, julian_twopart, modified_julian
export from_utc, to_utc
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
include("utc.jl")

end

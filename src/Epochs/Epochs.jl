module Epochs

using LeapSeconds: offset_tai_utc
using ..TimeScales: find_path
using EarthOrientation: getΔUT1, EOP_DATA, get
using LeapSeconds: offset_tai_utc, offset_utc_tai
using MuladdMacro

import Base: -, +, <, ==, isapprox, isless, show
import Dates
import Dates: format, parse

import ..AstroDates:
    Date,
    DateTime,
    Time,
    calendar,
    day,
    dayofyear,
    fractionofday,
    hour,
    j2000,
    julian,
    julian_twopart,
    millisecond,
    minute,
    month,
    second,
    secondinday,
    year,
    yearmonthday

import ..AstroDates: Date, DateTime, Time,
    year, month, day,
    hour, minute, second, millisecond,
    fractionofday, yearmonthday, dayofyear

import Base: (:)


export Epoch,
    CCSDS_EPOCH,
    FIFTIES_EPOCH,
    FUTURE_INFINITY,
    GALILEO_EPOCH,
    GPS_EPOCH,
    J2000_EPOCH,
    J2000_TO_JULIAN,
    J2000_TO_MJD,
    JULIAN_EPOCH,
    MODIFIED_JULIAN_EPOCH,
    PAST_INFINITY,
    UNIX_EPOCH,
    DateTime,
    Date,
    Time,
    day,
    dayofyear,
    fractionofday,
    hour,
    j2000,
    julian,
    julian_period,
    julian_twopart,
    millisecond,
    minute,
    modified_julian,
    month,
    now,
    second,
    secondinday,
    timescale,
    year,
    yearmonthday,
    -

export
    NoOffsetError,
    NoPathError,
    getoffset,
    insideleap

using ..TimeScales
using ..AstroDates
using ..Periods

include("types.jl")
include("julian.jl")
include("tdb_constants.jl")
include("offsets.jl")
include("accessors.jl")
include("dates.jl")
include("operations.jl")
include("aliases.jl")
include("ranges.jl")
include("epoch_constants.jl")
include("io.jl")

end

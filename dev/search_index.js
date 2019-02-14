var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#AstroTime-1",
    "page": "Home",
    "title": "AstroTime",
    "category": "section",
    "text": "Astronomical time keeping in JuliaAstroTime.jl provides a high-precision, time-scale aware, DateTime-like data type which supports all commonly used astronomical time scales."
},

{
    "location": "#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "The package can be installed through Julia\'s package manager:julia> import Pkg; Pkg.add(\"AstroTime\")"
},

{
    "location": "#Quickstart-1",
    "page": "Home",
    "title": "Quickstart",
    "category": "section",
    "text": "# Create an Epoch based on the TT (Terrestial Time) scale\ntt = TTEpoch(\"2018-01-01T12:00:00\")\n\n# Transform to UTC (Universal Time Coordinated)\nutc = UTCEpoch(tt)\n\n# Transform to TDB (Barycentric Dynamical Time)\nutc = TDBEpoch(utc)\n\n# Shift an Epoch by one day\nanother_day = tt + 1days"
},

{
    "location": "#Next-Steps-1",
    "page": "Home",
    "title": "Next Steps",
    "category": "section",
    "text": "You can either follow the Tutorial or jump straight into the API reference."
},

{
    "location": "tutorial/#",
    "page": "Tutorial",
    "title": "Tutorial",
    "category": "page",
    "text": ""
},

{
    "location": "tutorial/#Tutorial-1",
    "page": "Tutorial",
    "title": "Tutorial",
    "category": "section",
    "text": "This tutorial will walk you through the features and functionality of AstroTime.jl. Everything in this package revolves around the Epoch data type. Epochs are a high-precision, time-scale aware version of the DateTime type from Julia\'s standard library. This means that while DateTime timestamps are always assumed to be based on Universal Time (UT), Epochs can be created in several pre-defined time scales or custom user-defined time scales."
},

{
    "location": "tutorial/#Creating-Epochs-1",
    "page": "Tutorial",
    "title": "Creating Epochs",
    "category": "section",
    "text": "You construct Epoch instances similar to DateTime instance, for example by using date and time components. The main difference is that you need to supply the time scale to be used. Out of the box, the following time scales are defined:TAI: International Atomic Time\nUTC: Coordinated Universal Time\nUT1: Universal Time\nTT: Terrestrial Time\nTCG: Geocentric Coordinate Time\nTCB: Barycentric Coordinate Time\nTDB: Barycentric Dynamical Timeusing AstroTime\n\nep = Epoch{UTC}(2018, 2, 6, 20, 45, 0.0)\n\n# The following shorthand also works\nep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)\n\n# Or in another time scale\nep = TAIEpoch(2018, 2, 6, 20, 45, 0.0)You can also parse an Epoch from a string. AstroTime.jl uses the DateFormat type and specification language from the Dates module from Julia\'s standard library. For example:ep = UTCEpoch(\"2018-02-06T20:45:00.000\", \"yyyy-mm-ddTHH:MM:SS.sss\")\n\n# The format string above `yyyy-mm-ddTHH:MM:SS.sss` is also the default format.\n# Thus, this also works...\nep = UTCEpoch(\"2018-02-06T20:45:00.000\")\n\nimport Dates\n\n# You can also reuse the format string\ndf = Dates.dateformat\"dd.mm.yyyy HH:MM\"\n\nutc = UTCEpoch(\"06.02.2018 20:45\", df)\ntai = TAIEpoch(\"06.02.2018 20:45\", df)There are two additional character codes supported.t: This character code is parsed as the time scale.\nD: This character code is parsed as the day number within a year.# The time scale can be omitted from the constructor because it is already\n# defined in the input string\njulia> Epoch(\"2018-02-06T20:45:00.000 UTC\", \"yyyy-mm-ddTHH:MM:SS.sss ttt\")\n2018-02-06T20:45:00.000 UTC\n\n# February 6 is the 37th day of the year\njulia> UTCEpoch(\"2018-037T20:45:00.000\", \"yyyy-DDDTHH:MM:SS.sss\")\n2018-02-06T20:45:00.000 UTCWhen printing Epochs, you can format the output in the same way.julia> ep = UTCEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 UTC\njulia> AstroTime.format(ep, \"dd.mm.yyyy HH:MM ttt\")\n06.02.2018 20:45 UTC"
},

{
    "location": "tutorial/#Working-with-Epochs-and-Periods-1",
    "page": "Tutorial",
    "title": "Working with Epochs and Periods",
    "category": "section",
    "text": "You can shift an Epoch in time by adding or subtracting a Period to it.AstroTime.jl provides a convenient way to construct periods by multiplying a value with a time unit.julia> 23 * seconds\n23 seconds\n\njulia> 1hour # You can use Julia\'s factor juxtaposition syntax and omit the `*`\n1 hourThe following time units are available:seconds\nminutes\nhours\ndays\nyears\ncenturiesTo shift an Epoch forward in time add a Period to it.julia> ep = UTCEpoch(2000, 1, 1)\n2000-01-01T00:00:00.000 UTC\n\njulia> ep + 1days\n2000-01-02T00:00:00.000 UTCOr subtract it to shift the Epoch backwards.julia> ep = UTCEpoch(2000, 1, 1)\n2000-01-01T00:00:00.000 UTC\n\njulia> ep - 1days\n1999-12-31T00:00:00.000 UTCIf you subtract two epochs you will receive the time between them as a Period.julia> ep1 = UTCEpoch(2000, 1, 1)\n2000-01-01T00:00:00.000 UTC\n\njulia> ep2 = UTCEpoch(2000, 1, 2)\n2000-01-02T00:00:00.000 UTC\n\njulia> ep2 - ep1\n86400.0 secondsYou can also construct a Period with a different time unit from another Period.julia> dt = 86400.0seconds\n86400.0 seconds\n\njulia> days(dt)\n1.0 daysTo access the raw value of a period, i.e. without a unit, use the value function.julia> dt = 86400.0seconds\n86400.0 seconds\n\njulia> value(days(dt))\n1.0"
},

{
    "location": "tutorial/#Converting-Between-Time-Scales-1",
    "page": "Tutorial",
    "title": "Converting Between Time Scales",
    "category": "section",
    "text": "You convert an Epoch to another time scale by constructing a new Epoch with the target time scale from it.julia> utc = UTCEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 UTC\n\njulia> tai = TAIEpoch(utc) # Convert to TAI\n2018-02-06T20:45:37.000 TAIInternally, epochs are defined with respect to Internation Atomic Time (TAI). Which makes comparisons and other operations across time scales possible.# These two epoch correspond to the same point on the TAI time scale\nutc = UTCEpoch(2018, 2, 6, 20, 45, 0.0)\ntt = TTEpoch(2018, 2, 6, 20, 46, 9.184)\n\nutc == tt\n# true"
},

{
    "location": "tutorial/#High-Precision-Conversions-and-Custom-Offsets-1",
    "page": "Tutorial",
    "title": "High-Precision Conversions and Custom Offsets",
    "category": "section",
    "text": "Some time scale transformations depend on measured quantities which cannot be accurately predicted (e.g. UTC to UT1) or there are different algortihms which offer variable levels of accuracy. For the former, AstroTime.jl can download the required data automatically from the internet. You need to run AstroTime.update() periodically (weekly) to keep this data up-to-date. For the latter, AstroTime.jl will use the alogrithm which provides the best trade-off between accuracy and performance for most applications.If you cannot use the internet or want to use a different data source, e.g. a time ephemeris, to obtain the offset between time scales, you can use the following constructor for epochs which overrides the default algorithms.# AstroTime.jl provides a higher precision TDB<->TT transformation that is dependent on\n# the position of the observer on Earth\n\ntt = TTEpoch(2018, 2, 6, 20, 46, 9.184)\ndtai = tai_offset(TDB, tt, elong, u, v)\n\n# Use the custom offset for the transformation\ntdb = TDBEpoch(dtai, tt)"
},

{
    "location": "tutorial/#Working-with-Julian-Dates-1",
    "page": "Tutorial",
    "title": "Working with Julian Dates",
    "category": "section",
    "text": "Epochs can be converted to and from Julian Dates. Three different base epochs are supported:The (default) J2000 date which starts at January 1, 2000, at 12h,\nthe standard Julian date which starts at January 1, 4712BC, at 12h,\nand the Modified Julian date which starts at November 17, 1858, at midnight.You can get Julian date in days from an Epoch like this:julia> ep = TTEpoch(2000,1,2)\n2000-01-02T00:00:00.000 TT\n\njulia> j2000(ep)\n0.5 days\n\njulia> julian(ep)\n2.4515455e6 days\n\njulia> modified_julian(ep)\n51545.0 daysTo construct an Epoch from a Julian date do this:julia> TTEpoch(0.5) # J2000 is the default\n2000-01-02T00:00:00.000 TT\n\njulia> TTEpoch(0.5, origin=:j2000)\n2000-01-02T00:00:00.000 TT\n\njulia> TTEpoch(2.4515455e6, origin=:julian)\n2000-01-02T00:00:00.000 TT\n\njulia> TTEpoch(51545.0, origin=:modified_julian)\n2000-01-02T00:00:00.000 TTSome libraries (such as ERFA) expect a two-part Julian date as input. You can use julian_twopart(ep) in this case.warning: Warning\nYou should not convert an Epoch to a Julian date to do arithmetic because this will result in a loss of accuracy."
},

{
    "location": "tutorial/#Converting-to-Standard-Library-Types-1",
    "page": "Tutorial",
    "title": "Converting to Standard Library Types",
    "category": "section",
    "text": "Epoch instances satisfy the AbstractDateTime interface specified in the Dates module of Julia\'s standard library.  Thus, you should be able to pass them to other libraries which expect a standard DateTime. Please open an issue on the issue tracker if you encounter any problems with this.It is nevertheless possible to convert an Epoch to a DateTime if it should become necessary. Please note that the time scale information will be lost in the process.julia> ep = TTEpoch(2000,1,1)\n2000-01-01T00:00:00.000 TT\n\njulia> import Dates; Dates.DateTime(ep)\n2000-01-01T00:00:00"
},

{
    "location": "tutorial/#Defining-Custom-Time-Scales-1",
    "page": "Tutorial",
    "title": "Defining Custom Time Scales",
    "category": "section",
    "text": "AstroTime.jl enables you to create your own first-class time scales via the @timescale macro. The @timescale macro will define the necessary structs and a method for tai_offset that will determine the offset between atomic time and the newly defined time scale.You need to provide at least three parameters to the macro: The name of the time scale, an epoch type parameter for the offset function, and the body of the offset function.Let\'s start with a simple example and assume that you want to define GMT as an alias for UTC.@timescale GMT ep begin\n    tai_offset(UTC, ep)\nendHere GMT is the name of the new time scale and ep is the required epoch parameter that is passed to the new tai_offset method (you could actually call anything you want). The begin block at the end is the body of the new tai_offset method. Since GMT has the same offset as UTC, you can just return the value from the tai_offset method for UTC here. The resulting method will look like this:function AstroTime.Epochs.tai_offset(::typeof(GMT), ep)\n    tai_offset(UTC, ep)\nendYou can now use GMTEpoch like any other epoch type, e.g.julia> ep = UTCEpoch(2000, 1, 1)\n2000-01-01T00:00:00.000 UTC\njulia> GMTEpoch(ep)\n2000-01-01T00:00:00.000 GMTThe @timescale macro also accepts additional parameters for offset calculation. Let\'s assume that you want to define a time scale that determines the Spacecraft Event Time which takes the one-way light time into account.You can use the following definition which takes another parameter distance into account which is the distance of the spacecraft from Earth.const speed_of_light = 299792458.0 # m/s\n\n@timescale SCET ep distance begin\n    # Add the one-way light time to UTC offset\n    tai_offset(UTC, ep) + distance / speed_of_light\nendIf you want to convert another epoch to SCET, you now need to pass this additional parameter. For example, for a spacecraft that is one astronomical unit away from Earth:julia> astronomical_unit = 149597870700.0 # m\n149597870700.0\njulia> ep = UTCEpoch(2000, 1, 1)\n2000-01-01T00:00:00.000 UTC\njulia> SCETEpoch(ep, astronomical_unit)\n2000-01-01T00:08:19.005 SCETnote: Note\nAt this time, custom epochs with additional parameters cannot be parsed from strings."
},

{
    "location": "api/#",
    "page": "API",
    "title": "API",
    "category": "page",
    "text": ""
},

{
    "location": "api/#AstroTime.@timescale-Tuple{Symbol,Symbol,Vararg{Any,N} where N}",
    "page": "API",
    "title": "AstroTime.@timescale",
    "category": "macro",
    "text": "@timescale scale epoch [args...] body\n\nDefine a new time scale, the corresponding Epoch type alias, and a function that calculates the offset from TAI for the new time scale.\n\nArguments\n\nscale: The name of the time scale\nepoch: The name of the Epoch parameter that is passed to the tai_offset function\nargs: Optional additional parameters that are passed to the tai_offset function\nbody: The body of the tai_offset function\n\nExample\n\njulia> @timescale GMT ep tai_offset(UTC, ep)\n\njulia> GMT isa TimeScale\ntrue\n\njulia> GMTEpoch\nEpoch{GMT,T} where T\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.Epoch",
    "page": "API",
    "title": "AstroTime.Epochs.Epoch",
    "category": "type",
    "text": "Epoch(str[, format])\n\nConstruct an Epoch from a string str. Optionally a format definition can be passed as a DateFormat object or as a string. In addition to the character codes supported by DateFormat the character code D is supported which is parsed as \"day of year\" (see the example below) and the character code t which is parsed as the time scale.  The default format is yyyy-mm-ddTHH:MM:SS.sss ttt.\n\nNote: Please be aware that this constructor requires that the time scale is part of str, e.g. 2018-02-06T00:00 UTC. Otherwise use an explicit constructor, e.g. Epoch{UTC}.\n\nExample\n\njulia> Epoch(\"2018-02-06T20:45:00.0 UTC\")\n2018-02-06T20:45:00.000 UTC\n\njulia> Epoch(\"2018-037T00:00 UTC\", \"yyyy-DDDTHH:MM ttt\")\n2018-02-06T00:00:00.000 UTC\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.Epoch-Union{Tuple{AbstractString}, Tuple{S}, Tuple{AbstractString,DateFormat}} where S",
    "page": "API",
    "title": "AstroTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{S}(str[, format]) where S\n\nConstruct an Epoch with time scale S from a string str. Optionally a format definition can be passed as a DateFormat object or as a string. In addition to the character codes supported by DateFormat the code D can be used which is parsed as \"day of year\" (see the example below).  The default format is yyyy-mm-ddTHH:MM:SS.sss.\n\nExample\n\njulia> Epoch{UTC}(\"2018-02-06T20:45:00.0\")\n2018-02-06T20:45:00.000 UTC\n\njulia> Epoch{UTC}(\"February 6, 2018\", \"U d, y\")\n2018-02-06T00:00:00.000 UTC\n\njulia> Epoch{UTC}(\"2018-037T00:00\", \"yyyy-DDDTHH:MM\")\n2018-02-06T00:00:00.000 UTC\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.Epoch-Union{Tuple{Int64,Int64,Int64}, NTuple{4,Int64}, NTuple{5,Int64}, Tuple{S}, Tuple{Int64,Int64,Int64,Int64,Int64,Float64,Vararg{Any,N} where N}} where S",
    "page": "API",
    "title": "AstroTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{S}(year, month, day, hour=0, minute=0, second=0.0) where S\n\nConstruct an Epoch with time scale S from date and time components.\n\nExample\n\njulia> Epoch{UTC}(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 UTC\n\njulia> Epoch{UTC}(2018, 2, 6)\n2018-02-06T00:00:00.000 UTC\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.Epoch-Union{Tuple{S2}, Tuple{S1}, Tuple{Any,Epoch{S1,T} where T}} where S2 where S1",
    "page": "API",
    "title": "AstroTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{S2}(Δtai, ep::Epoch{S1}) where {S1, S2}\n\nConvert ep, an Epoch with time scale S1, to an Epoch with time scale S2 by overriding the offset between S2 and TAI with Δtai.\n\nExamples\n\njulia> ep = TAIEpoch(2000,1,1)\n2000-01-01T00:00:00.000 TAI\n\njulia> TTEpoch(32.184, ep)\n2000-01-01T00:00:32.184 TT\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.Epoch-Union{Tuple{S2}, Tuple{S1}, Tuple{Epoch{S1,T} where T,Vararg{Any,N} where N}} where S2 where S1",
    "page": "API",
    "title": "AstroTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{S2}(ep::Epoch{S1}) where {S1, S2}\n\nConvert ep, an Epoch with time scale S1, to an Epoch with time scale S2.\n\nExamples\n\njulia> ep = TTEpoch(2000,1,1)\n2000-01-01T00:00:00.000 TT\n\njulia> TAIEpoch(ep)\n1999-12-31T23:59:27.816 TAI\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.Epoch-Union{Tuple{T}, Tuple{T}, Tuple{S}, Tuple{T,T,Vararg{Any,N} where N}} where T<:Number where S",
    "page": "API",
    "title": "AstroTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{S}(jd1::T, jd2::T=zero(T); origin=:j2000) where {S, T}\n\nConstruct an Epoch with time scale S from a Julian date (optionally split into jd1 and jd2). origin determines the variant of Julian date that is used. Possible values are:\n\n:j2000: J2000 Julian date, starts at 2000-01-01T12:00\n:julian: Julian date, starts at -4712-01-01T12:00\n:modified_julian: Modified Julian date, starts at 1858-11-17T00:00\n\nExamples\n\njulia> Epoch{UTC}(0.0, 0.5)\n2000-01-02T00:00:00.000 UTC\n\njulia> Epoch{UTC}(2.451545e6, origin=:julian)\n2000-01-01T12:00:00.000 UTC\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.TAIEpoch-Tuple{AbstractString}",
    "page": "API",
    "title": "AstroTime.Epochs.TAIEpoch",
    "category": "method",
    "text": "TAIEpoch(str[, format])\n\nConstruct a TAIEpoch from a string str. Optionally a format definition can be passed as a DateFormat object or as a string. In addition to the character codes supported by DateFormat the code D is supported which is parsed as \"day of year\" (see the example below). The default format is yyyy-mm-ddTHH:MM:SS.sss.\n\nExample\n\njulia> TAIEpoch(\"2018-02-06T20:45:00.0\")\n2018-02-06T20:45:00.000 TAI\n\njulia> TAIEpoch(\"February 6, 2018\", \"U d, y\")\n2018-02-06T00:00:00.000 TAI\n\njulia> TAIEpoch(\"2018-37T00:00\", \"yyyy-DDDTHH:MM\")\n2018-02-06T00:00:00.000 TAI\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.TAIEpoch-Tuple{Int64,Int64,Int64}",
    "page": "API",
    "title": "AstroTime.Epochs.TAIEpoch",
    "category": "method",
    "text": "TAIEpoch(year, month, day, hour=0, minute=0, second=0.0)\n\nConstruct a TAIEpoch from date and time components.\n\nExample\n\njulia> TAIEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 TAI\n\njulia> TAIEpoch(2018, 2, 6)\n2018-02-06T00:00:00.000 TAI\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.TAIEpoch-Tuple{Number,Number}",
    "page": "API",
    "title": "AstroTime.Epochs.TAIEpoch",
    "category": "method",
    "text": "TAIEpoch(jd1::T, jd2::T=zero(T); origin=:j2000) where T\n\nConstruct a TAIEpoch from a Julian date (optionally split into jd1 and jd2). origin determines the variant of Julian date that is used. Possible values are:\n\n:j2000: J2000 Julian date, starts at 2000-01-01T12:00\n:julian: Julian date, starts at -4712-01-01T12:00\n:modified_julian: Modified Julian date, starts at 1858-11-17T00:00\n\nExamples\n\njulia> TAIEpoch(0.0, 0.5)\n2000-01-02T00:00:00.000 TAI\n\njulia> TAIEpoch(2.451545e6, origin=:julian)\n2000-01-01T12:00:00.000 TAI\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.TCBEpoch-Tuple{AbstractString}",
    "page": "API",
    "title": "AstroTime.Epochs.TCBEpoch",
    "category": "method",
    "text": "TCBEpoch(str[, format])\n\nConstruct a TCBEpoch from a string str. Optionally a format definition can be passed as a DateFormat object or as a string. In addition to the character codes supported by DateFormat the code D is supported which is parsed as \"day of year\" (see the example below). The default format is yyyy-mm-ddTHH:MM:SS.sss.\n\nExample\n\njulia> TCBEpoch(\"2018-02-06T20:45:00.0\")\n2018-02-06T20:45:00.000 TCB\n\njulia> TCBEpoch(\"February 6, 2018\", \"U d, y\")\n2018-02-06T00:00:00.000 TCB\n\njulia> TCBEpoch(\"2018-37T00:00\", \"yyyy-DDDTHH:MM\")\n2018-02-06T00:00:00.000 TCB\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.TCBEpoch-Tuple{Int64,Int64,Int64}",
    "page": "API",
    "title": "AstroTime.Epochs.TCBEpoch",
    "category": "method",
    "text": "TCBEpoch(year, month, day, hour=0, minute=0, second=0.0)\n\nConstruct a TCBEpoch from date and time components.\n\nExample\n\njulia> TCBEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 TCB\n\njulia> TCBEpoch(2018, 2, 6)\n2018-02-06T00:00:00.000 TCB\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.TCBEpoch-Tuple{Number,Number}",
    "page": "API",
    "title": "AstroTime.Epochs.TCBEpoch",
    "category": "method",
    "text": "TCBEpoch(jd1::T, jd2::T=zero(T); origin=:j2000) where T\n\nConstruct a TCBEpoch from a Julian date (optionally split into jd1 and jd2). origin determines the variant of Julian date that is used. Possible values are:\n\n:j2000: J2000 Julian date, starts at 2000-01-01T12:00\n:julian: Julian date, starts at -4712-01-01T12:00\n:modified_julian: Modified Julian date, starts at 1858-11-17T00:00\n\nExamples\n\njulia> TCBEpoch(0.0, 0.5)\n2000-01-02T00:00:00.000 TCB\n\njulia> TCBEpoch(2.451545e6, origin=:julian)\n2000-01-01T12:00:00.000 TCB\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.TCGEpoch-Tuple{AbstractString}",
    "page": "API",
    "title": "AstroTime.Epochs.TCGEpoch",
    "category": "method",
    "text": "TCGEpoch(str[, format])\n\nConstruct a TCGEpoch from a string str. Optionally a format definition can be passed as a DateFormat object or as a string. In addition to the character codes supported by DateFormat the code D is supported which is parsed as \"day of year\" (see the example below). The default format is yyyy-mm-ddTHH:MM:SS.sss.\n\nExample\n\njulia> TCGEpoch(\"2018-02-06T20:45:00.0\")\n2018-02-06T20:45:00.000 TCG\n\njulia> TCGEpoch(\"February 6, 2018\", \"U d, y\")\n2018-02-06T00:00:00.000 TCG\n\njulia> TCGEpoch(\"2018-37T00:00\", \"yyyy-DDDTHH:MM\")\n2018-02-06T00:00:00.000 TCG\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.TCGEpoch-Tuple{Int64,Int64,Int64}",
    "page": "API",
    "title": "AstroTime.Epochs.TCGEpoch",
    "category": "method",
    "text": "TCGEpoch(year, month, day, hour=0, minute=0, second=0.0)\n\nConstruct a TCGEpoch from date and time components.\n\nExample\n\njulia> TCGEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 TCG\n\njulia> TCGEpoch(2018, 2, 6)\n2018-02-06T00:00:00.000 TCG\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.TCGEpoch-Tuple{Number,Number}",
    "page": "API",
    "title": "AstroTime.Epochs.TCGEpoch",
    "category": "method",
    "text": "TCGEpoch(jd1::T, jd2::T=zero(T); origin=:j2000) where T\n\nConstruct a TCGEpoch from a Julian date (optionally split into jd1 and jd2). origin determines the variant of Julian date that is used. Possible values are:\n\n:j2000: J2000 Julian date, starts at 2000-01-01T12:00\n:julian: Julian date, starts at -4712-01-01T12:00\n:modified_julian: Modified Julian date, starts at 1858-11-17T00:00\n\nExamples\n\njulia> TCGEpoch(0.0, 0.5)\n2000-01-02T00:00:00.000 TCG\n\njulia> TCGEpoch(2.451545e6, origin=:julian)\n2000-01-01T12:00:00.000 TCG\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.TDBEpoch-Tuple{AbstractString}",
    "page": "API",
    "title": "AstroTime.Epochs.TDBEpoch",
    "category": "method",
    "text": "TDBEpoch(str[, format])\n\nConstruct a TDBEpoch from a string str. Optionally a format definition can be passed as a DateFormat object or as a string. In addition to the character codes supported by DateFormat the code D is supported which is parsed as \"day of year\" (see the example below). The default format is yyyy-mm-ddTHH:MM:SS.sss.\n\nExample\n\njulia> TDBEpoch(\"2018-02-06T20:45:00.0\")\n2018-02-06T20:45:00.000 TDB\n\njulia> TDBEpoch(\"February 6, 2018\", \"U d, y\")\n2018-02-06T00:00:00.000 TDB\n\njulia> TDBEpoch(\"2018-37T00:00\", \"yyyy-DDDTHH:MM\")\n2018-02-06T00:00:00.000 TDB\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.TDBEpoch-Tuple{Int64,Int64,Int64}",
    "page": "API",
    "title": "AstroTime.Epochs.TDBEpoch",
    "category": "method",
    "text": "TDBEpoch(year, month, day, hour=0, minute=0, second=0.0)\n\nConstruct a TDBEpoch from date and time components.\n\nExample\n\njulia> TDBEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 TDB\n\njulia> TDBEpoch(2018, 2, 6)\n2018-02-06T00:00:00.000 TDB\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.TDBEpoch-Tuple{Number,Number}",
    "page": "API",
    "title": "AstroTime.Epochs.TDBEpoch",
    "category": "method",
    "text": "TDBEpoch(jd1::T, jd2::T=zero(T); origin=:j2000) where T\n\nConstruct a TDBEpoch from a Julian date (optionally split into jd1 and jd2). origin determines the variant of Julian date that is used. Possible values are:\n\n:j2000: J2000 Julian date, starts at 2000-01-01T12:00\n:julian: Julian date, starts at -4712-01-01T12:00\n:modified_julian: Modified Julian date, starts at 1858-11-17T00:00\n\nExamples\n\njulia> TDBEpoch(0.0, 0.5)\n2000-01-02T00:00:00.000 TDB\n\njulia> TDBEpoch(2.451545e6, origin=:julian)\n2000-01-01T12:00:00.000 TDB\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.TTEpoch-Tuple{AbstractString}",
    "page": "API",
    "title": "AstroTime.Epochs.TTEpoch",
    "category": "method",
    "text": "TTEpoch(str[, format])\n\nConstruct a TTEpoch from a string str. Optionally a format definition can be passed as a DateFormat object or as a string. In addition to the character codes supported by DateFormat the code D is supported which is parsed as \"day of year\" (see the example below). The default format is yyyy-mm-ddTHH:MM:SS.sss.\n\nExample\n\njulia> TTEpoch(\"2018-02-06T20:45:00.0\")\n2018-02-06T20:45:00.000 TT\n\njulia> TTEpoch(\"February 6, 2018\", \"U d, y\")\n2018-02-06T00:00:00.000 TT\n\njulia> TTEpoch(\"2018-37T00:00\", \"yyyy-DDDTHH:MM\")\n2018-02-06T00:00:00.000 TT\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.TTEpoch-Tuple{Int64,Int64,Int64}",
    "page": "API",
    "title": "AstroTime.Epochs.TTEpoch",
    "category": "method",
    "text": "TTEpoch(year, month, day, hour=0, minute=0, second=0.0)\n\nConstruct a TTEpoch from date and time components.\n\nExample\n\njulia> TTEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 TT\n\njulia> TTEpoch(2018, 2, 6)\n2018-02-06T00:00:00.000 TT\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.TTEpoch-Tuple{Number,Number}",
    "page": "API",
    "title": "AstroTime.Epochs.TTEpoch",
    "category": "method",
    "text": "TTEpoch(jd1::T, jd2::T=zero(T); origin=:j2000) where T\n\nConstruct a TTEpoch from a Julian date (optionally split into jd1 and jd2). origin determines the variant of Julian date that is used. Possible values are:\n\n:j2000: J2000 Julian date, starts at 2000-01-01T12:00\n:julian: Julian date, starts at -4712-01-01T12:00\n:modified_julian: Modified Julian date, starts at 1858-11-17T00:00\n\nExamples\n\njulia> TTEpoch(0.0, 0.5)\n2000-01-02T00:00:00.000 TT\n\njulia> TTEpoch(2.451545e6, origin=:julian)\n2000-01-01T12:00:00.000 TT\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.UT1Epoch-Tuple{AbstractString}",
    "page": "API",
    "title": "AstroTime.Epochs.UT1Epoch",
    "category": "method",
    "text": "UT1Epoch(str[, format])\n\nConstruct a UT1Epoch from a string str. Optionally a format definition can be passed as a DateFormat object or as a string. In addition to the character codes supported by DateFormat the code D is supported which is parsed as \"day of year\" (see the example below). The default format is yyyy-mm-ddTHH:MM:SS.sss.\n\nExample\n\njulia> UT1Epoch(\"2018-02-06T20:45:00.0\")\n2018-02-06T20:45:00.000 UT1\n\njulia> UT1Epoch(\"February 6, 2018\", \"U d, y\")\n2018-02-06T00:00:00.000 UT1\n\njulia> UT1Epoch(\"2018-37T00:00\", \"yyyy-DDDTHH:MM\")\n2018-02-06T00:00:00.000 UT1\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.UT1Epoch-Tuple{Int64,Int64,Int64}",
    "page": "API",
    "title": "AstroTime.Epochs.UT1Epoch",
    "category": "method",
    "text": "UT1Epoch(year, month, day, hour=0, minute=0, second=0.0)\n\nConstruct a UT1Epoch from date and time components.\n\nExample\n\njulia> UT1Epoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 UT1\n\njulia> UT1Epoch(2018, 2, 6)\n2018-02-06T00:00:00.000 UT1\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.UT1Epoch-Tuple{Number,Number}",
    "page": "API",
    "title": "AstroTime.Epochs.UT1Epoch",
    "category": "method",
    "text": "UT1Epoch(jd1::T, jd2::T=zero(T); origin=:j2000) where T\n\nConstruct a UT1Epoch from a Julian date (optionally split into jd1 and jd2). origin determines the variant of Julian date that is used. Possible values are:\n\n:j2000: J2000 Julian date, starts at 2000-01-01T12:00\n:julian: Julian date, starts at -4712-01-01T12:00\n:modified_julian: Modified Julian date, starts at 1858-11-17T00:00\n\nExamples\n\njulia> UT1Epoch(0.0, 0.5)\n2000-01-02T00:00:00.000 UT1\n\njulia> UT1Epoch(2.451545e6, origin=:julian)\n2000-01-01T12:00:00.000 UT1\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.UTCEpoch-Tuple{AbstractString}",
    "page": "API",
    "title": "AstroTime.Epochs.UTCEpoch",
    "category": "method",
    "text": "UTCEpoch(str[, format])\n\nConstruct a UTCEpoch from a string str. Optionally a format definition can be passed as a DateFormat object or as a string. In addition to the character codes supported by DateFormat the code D is supported which is parsed as \"day of year\" (see the example below). The default format is yyyy-mm-ddTHH:MM:SS.sss.\n\nExample\n\njulia> UTCEpoch(\"2018-02-06T20:45:00.0\")\n2018-02-06T20:45:00.000 UTC\n\njulia> UTCEpoch(\"February 6, 2018\", \"U d, y\")\n2018-02-06T00:00:00.000 UTC\n\njulia> UTCEpoch(\"2018-37T00:00\", \"yyyy-DDDTHH:MM\")\n2018-02-06T00:00:00.000 UTC\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.UTCEpoch-Tuple{Int64,Int64,Int64}",
    "page": "API",
    "title": "AstroTime.Epochs.UTCEpoch",
    "category": "method",
    "text": "UTCEpoch(year, month, day, hour=0, minute=0, second=0.0)\n\nConstruct a UTCEpoch from date and time components.\n\nExample\n\njulia> UTCEpoch(2018, 2, 6, 20, 45, 0.0)\n2018-02-06T20:45:00.000 UTC\n\njulia> UTCEpoch(2018, 2, 6)\n2018-02-06T00:00:00.000 UTC\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.UTCEpoch-Tuple{Number,Number}",
    "page": "API",
    "title": "AstroTime.Epochs.UTCEpoch",
    "category": "method",
    "text": "UTCEpoch(jd1::T, jd2::T=zero(T); origin=:j2000) where T\n\nConstruct a UTCEpoch from a Julian date (optionally split into jd1 and jd2). origin determines the variant of Julian date that is used. Possible values are:\n\n:j2000: J2000 Julian date, starts at 2000-01-01T12:00\n:julian: Julian date, starts at -4712-01-01T12:00\n:modified_julian: Modified Julian date, starts at 1858-11-17T00:00\n\nExamples\n\njulia> UTCEpoch(0.0, 0.5)\n2000-01-02T00:00:00.000 UTC\n\njulia> UTCEpoch(2.451545e6, origin=:julian)\n2000-01-01T12:00:00.000 UTC\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.AstroDates.date-Tuple{Epoch}",
    "page": "API",
    "title": "AstroTime.AstroDates.date",
    "category": "method",
    "text": "date(ep::Epoch)\n\nGet the date of the epoch ep.\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.AstroDates.fractionofday-Tuple{Epoch}",
    "page": "API",
    "title": "AstroTime.AstroDates.fractionofday",
    "category": "method",
    "text": "fractionofday(ep::Epoch)\n\nGet the time of the day of the epoch ep as a fraction.\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.AstroDates.j2000-Tuple{Any,Epoch}",
    "page": "API",
    "title": "AstroTime.AstroDates.j2000",
    "category": "method",
    "text": "j2000(scale, ep)\n\nReturns the J2000 Julian date for epoch ep within a specific time scale.\n\nExample\n\njulia> j2000(TAI, TTEpoch(2000, 1, 1, 12, 0, 32.184))\n0.0 days\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.AstroDates.j2000-Tuple{Epoch}",
    "page": "API",
    "title": "AstroTime.AstroDates.j2000",
    "category": "method",
    "text": "j2000(ep)\n\nReturns the J2000 Julian date for epoch ep.\n\nExample\n\njulia> j2000(UTCEpoch(2000, 1, 1, 12))\n0.0 days\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.AstroDates.julian-Tuple{Any,Epoch}",
    "page": "API",
    "title": "AstroTime.AstroDates.julian",
    "category": "method",
    "text": "julian(scale, ep)\n\nReturns the Julian Date for epoch ep within a specific time scale.\n\nExample\n\njulia> julian(TAI, TTEpoch(2000, 1, 1, 12, 0, 32.184))\n2.451545e6 days\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.AstroDates.julian-Tuple{Epoch}",
    "page": "API",
    "title": "AstroTime.AstroDates.julian",
    "category": "method",
    "text": "julian(ep)\n\nReturns the Julian Date for epoch ep.\n\nExample\n\njulia> julian(UTCEpoch(2000, 1, 1, 12))\n2.451545e6 days\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.AstroDates.julian_twopart-Tuple{Any,Epoch}",
    "page": "API",
    "title": "AstroTime.AstroDates.julian_twopart",
    "category": "method",
    "text": "julian_twopart(scale, ep)\n\nReturns the two-part Julian date for epoch ep within a specific time scale, which is a tuple consisting of the Julian day number and the fraction of the day.\n\nExample\n\njulia> julian_twopart(TAI, TTEpoch(2000, 1, 1, 12, 0, 32.184))\n(2.451545e6 days, 0.0 days)\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.AstroDates.julian_twopart-Tuple{Epoch}",
    "page": "API",
    "title": "AstroTime.AstroDates.julian_twopart",
    "category": "method",
    "text": "julian_twopart(ep)\n\nReturns the two-part Julian date for epoch ep, which is a tuple consisting of the Julian day number and the fraction of the day.\n\nExample\n\njulia> julian_twopart(UTCEpoch(2000, 1, 2))\n(2.451545e6 days, 0.5 days)\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.modified_julian-Tuple{Any,Epoch}",
    "page": "API",
    "title": "AstroTime.Epochs.modified_julian",
    "category": "method",
    "text": "modified_julian(scale, ep)\n\nReturns the Modified Julian Date for epoch ep within a specific time scale.\n\nExample\n\njulia> modified_julian(TAI, TTEpoch(2000, 1, 1, 12, 0, 32.184))\n51544.5 days\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.modified_julian-Tuple{Epoch}",
    "page": "API",
    "title": "AstroTime.Epochs.modified_julian",
    "category": "method",
    "text": "modified_julian(ep)\n\nReturns the Modified Julian Date for epoch ep.\n\nExample\n\njulia> modified_julian(UTCEpoch(2000, 1, 1, 12))\n51544.5 days\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.now-Tuple{}",
    "page": "API",
    "title": "AstroTime.Epochs.now",
    "category": "method",
    "text": "now()\n\nGet the current date and time as a UTCEpoch.\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.tai_offset-Tuple{BarycentricCoordinateTime,Any}",
    "page": "API",
    "title": "AstroTime.Epochs.tai_offset",
    "category": "method",
    "text": "tai_offset(TCB, ep)\n\nReturns the difference TCB-TAI in seconds at the epoch ep.\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.tai_offset-Tuple{BarycentricDynamicalTime,Any,Any,Any,Any}",
    "page": "API",
    "title": "AstroTime.Epochs.tai_offset",
    "category": "method",
    "text": "tai_offset(TDB, ep, elong, u, v)\n\nReturns the difference TDB-TAI in seconds at the epoch ep for an observer on Earth.\n\nArguments\n\nep: Current epoch\nelong: Longitude (east positive, radians)\nu: Distance from Earth\'s spin axis (km)\nv: Distance north of equatorial plane (km)\n\nReferences\n\nERFA\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.tai_offset-Tuple{BarycentricDynamicalTime,Any}",
    "page": "API",
    "title": "AstroTime.Epochs.tai_offset",
    "category": "method",
    "text": "tai_offset(TDB, ep)\n\nReturns the difference TDB-TAI in seconds at the epoch ep.\n\nThis routine is accurate to ~40 microseconds in the interval 1900-2100.\n\nnote: Note\nAn accurate transformation between TDB and TT depends on the trajectory of the observer. For two observers fixed on Earth\'s surface the quantity TDB-TT can differ by as much as ~4 microseconds. See tai_offset(TDB, ep, elong, u, v).\n\nReferences\n\nhttps://www.cv.nrao.edu/~rfisher/Ephemerides/times.html#TDB\nIssue #26\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.tai_offset-Tuple{CoordinatedUniversalTime,Any}",
    "page": "API",
    "title": "AstroTime.Epochs.tai_offset",
    "category": "method",
    "text": "tai_offset(UTC, ep)\n\nReturns the difference UTC-TAI in seconds at the epoch ep.\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.tai_offset-Tuple{Epoch}",
    "page": "API",
    "title": "AstroTime.Epochs.tai_offset",
    "category": "method",
    "text": "tai_offset(ep)\n\nReturns the offset from TAI for the epoch ep.\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.tai_offset-Tuple{GeocentricCoordinateTime,Any}",
    "page": "API",
    "title": "AstroTime.Epochs.tai_offset",
    "category": "method",
    "text": "tai_offset(TCG, ep)\n\nReturns the difference TCG-TAI in seconds at the epoch ep.\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.tai_offset-Tuple{TerrestrialTime,Any}",
    "page": "API",
    "title": "AstroTime.Epochs.tai_offset",
    "category": "method",
    "text": "tai_offset(TT, ep)\n\nReturns the difference TT-TAI in seconds at the epoch ep.\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Epochs.tai_offset-Tuple{UniversalTime,Any}",
    "page": "API",
    "title": "AstroTime.Epochs.tai_offset",
    "category": "method",
    "text": "tai_offset(UT1, ep)\n\nReturns the difference UT1-TAI in seconds at the epoch ep.\n\n\n\n\n\n"
},

{
    "location": "api/#Base.Libc.time-Tuple{Epoch}",
    "page": "API",
    "title": "Base.Libc.time",
    "category": "method",
    "text": "time(ep::Epoch)\n\nGet the time of the epoch ep.\n\n\n\n\n\n"
},

{
    "location": "api/#Dates.day-Tuple{Epoch}",
    "page": "API",
    "title": "Dates.day",
    "category": "method",
    "text": "day(ep::Epoch)\n\nGet the day of the epoch ep.\n\n\n\n\n\n"
},

{
    "location": "api/#Dates.dayofyear-Tuple{Epoch}",
    "page": "API",
    "title": "Dates.dayofyear",
    "category": "method",
    "text": "dayofyear(ep::Epoch)\n\nGet the day of the year of the epoch ep.\n\n\n\n\n\n"
},

{
    "location": "api/#Dates.hour-Tuple{Epoch}",
    "page": "API",
    "title": "Dates.hour",
    "category": "method",
    "text": "hour(ep::Epoch)\n\nGet the hour of the epoch ep.\n\n\n\n\n\n"
},

{
    "location": "api/#Dates.millisecond-Tuple{Epoch}",
    "page": "API",
    "title": "Dates.millisecond",
    "category": "method",
    "text": "millisecond(ep::Epoch)\n\nGet the number of milliseconds of the epoch ep.\n\n\n\n\n\n"
},

{
    "location": "api/#Dates.minute-Tuple{Epoch}",
    "page": "API",
    "title": "Dates.minute",
    "category": "method",
    "text": "minute(ep::Epoch)\n\nGet the minute of the epoch ep.\n\n\n\n\n\n"
},

{
    "location": "api/#Dates.month-Tuple{Epoch}",
    "page": "API",
    "title": "Dates.month",
    "category": "method",
    "text": "month(ep::Epoch)\n\nGet the month of the epoch ep.\n\n\n\n\n\n"
},

{
    "location": "api/#Dates.second-Tuple{Any,Epoch}",
    "page": "API",
    "title": "Dates.second",
    "category": "method",
    "text": "second(type, ep::Epoch)\n\nGet the second of the epoch ep as a type.\n\n\n\n\n\n"
},

{
    "location": "api/#Dates.second-Tuple{Epoch}",
    "page": "API",
    "title": "Dates.second",
    "category": "method",
    "text": "second(ep::Epoch) -> Int\n\nGet the second of the epoch ep as an Int.\n\n\n\n\n\n"
},

{
    "location": "api/#Dates.year-Tuple{Epoch}",
    "page": "API",
    "title": "Dates.year",
    "category": "method",
    "text": "year(ep::Epoch)\n\nGet the year of the epoch ep.\n\n\n\n\n\n"
},

{
    "location": "api/#Dates.yearmonthday-Tuple{Epoch}",
    "page": "API",
    "title": "Dates.yearmonthday",
    "category": "method",
    "text": "yearmonthday(ep::Epoch)\n\nGet the year, month, and day of the epoch ep as a tuple.\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Periods.Period",
    "page": "API",
    "title": "AstroTime.Periods.Period",
    "category": "type",
    "text": "Period{U}(Δt)\n\nA Period object represents a time interval of Δt with a TimeUnit of U. Periods can be constructed via the shorthand syntax shown in the examples below.\n\nExamples\n\njulia> 3.0seconds\n3.0 seconds\n\njulia> 1.0minutes\n1.0 minutes\n\njulia> 12hours\n12 hours\n\njulia> days_per_year = 365\n365\njulia> days_per_year * days\n365 days\n\njulia> 10.0years\n10.0 years\n\njulia> 1centuries\n1 century\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.Periods.TimeUnit",
    "page": "API",
    "title": "AstroTime.Periods.TimeUnit",
    "category": "type",
    "text": "All time units are subtypes of the abstract type TimeUnit. The following time units are defined:\n\nSecond\nMinute\nHour\nDay\nYear\nCentury\n\n\n\n\n\n"
},

{
    "location": "api/#AstroTime.TimeScales.TimeScale",
    "page": "API",
    "title": "AstroTime.TimeScales.TimeScale",
    "category": "type",
    "text": "All timescales are subtypes of the abstract type TimeScale. The following timescales are defined:\n\nUTC — Coordinated Universal Time\nUT1 — Universal Time\nTAI — International Atomic Time\nTT — Terrestrial Time\nTCG — Geocentric Coordinate Time\nTCB — Barycentric Coordinate Time\nTDB — Barycentric Dynamical Time\n\n\n\n\n\n"
},

{
    "location": "api/#API-1",
    "page": "API",
    "title": "API",
    "category": "section",
    "text": "DocTestSetup = quote\n    using AstroTime\nendModules = [AstroTime, AstroTime.Epochs, AstroTime.Periods, AstroTime.TimeScales]\nPrivate = false"
},

]}

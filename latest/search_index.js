var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#AstroTime-1",
    "page": "Home",
    "title": "AstroTime",
    "category": "section",
    "text": "Astronomical time keeping in Julia"
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "The package can be installed through Julia\'s package manager:Pkg.clone(\"https://github.com/JuliaAstro/AstroTime.jl\")"
},

{
    "location": "index.html#Quickstart-1",
    "page": "Home",
    "title": "Quickstart",
    "category": "section",
    "text": "# Create an Epoch based on the TT (Terrestial Time) scale\ntt = TTEpoch(\"2018-01-01T12:00:00\")\n\n# Transform to UTC (Universal Time Coordinated)\nutc = UTCEpoch(tt)\n\n# Transform to TDB (Barycentric Dynamical Time)\nutc = TDBEpoch(utc)Read the API docs."
},

{
    "location": "api.html#",
    "page": "API",
    "title": "API",
    "category": "page",
    "text": ""
},

{
    "location": "api.html#AstroTime.@timescale-Tuple{Any}",
    "page": "API",
    "title": "AstroTime.@timescale",
    "category": "macro",
    "text": "@timescale scale\n\nDefine a new timescale and the corresponding Epoch type alias.\n\nExample\n\njulia> @timescale Custom\n\njulia> Custom <: TimeScale\ntrue\njulia> CustomEpoch == Epoch{Custom, T} where T <: Number\ntrue\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.Epoch-Union{NTuple{4,Any}, NTuple{5,Any}, NTuple{6,Any}, NTuple{7,Any}, Tuple{Any,Any,Any}, Tuple{T}} where T",
    "page": "API",
    "title": "AstroTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{T}(year, month, day,\n    hour=0, minute=0, seconds=0, milliseconds=0) where {T}\n\nConstruct an Epoch with timescale T at the given date and time.\n\nExample\n\njulia> Epoch{TT}(2017, 3, 14, 7, 18, 20, 325)\n2017-03-14T07:18:20.325 TT\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.Epoch-Union{Tuple{AbstractString,Any}, Tuple{AbstractString}, Tuple{T}} where T",
    "page": "API",
    "title": "AstroTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{T}(timestamp::AbstractString,\n    fmt::DateFormat=dateformat\"yyyy-mm-ddTHH:MM:SS.sss\") where {T}\n\nConstruct an Epoch with timescale T from a timestamp. Optionally a DateFormat object can be passed which improves performance if many date strings need to be parsed and the format is known in advance.\n\nExample\n\njulia> Epoch{TT}(\"2017-03-14T07:18:20.325\")\n2017-03-14T07:18:20.325 TT\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.Epoch-Union{Tuple{AstroTime.Epochs.Epoch{S,T} where T<:Number}, Tuple{S}, Tuple{T}} where S where T",
    "page": "API",
    "title": "AstroTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{T}(ep::Epoch{S}) where {T}, S}\n\nConvert an Epoch with timescale S to an Epoch with timescale T.\n\nExample\n\njulia> Epoch{TT}(Epoch{TAI}(2000, 1, 1))\n2000-01-01T00:00:32.184 TT\n\n\n\n"
},

{
    "location": "api.html#AstroTime.Epochs.Epoch-Union{Tuple{DateTime}, Tuple{T}} where T",
    "page": "API",
    "title": "AstroTime.Epochs.Epoch",
    "category": "method",
    "text": "Epoch{T}(dt::DateTime) where {T}\n\nConvert a DateTime object to an Epoch with timescale T.\n\nExample\n\njulia> Epoch{TT}(DateTime(2017, 3, 14, 7, 18, 20, 325))\n2017-03-14T07:18:20.325 TT\n\n\n\n"
},

{
    "location": "api.html#API-1",
    "page": "API",
    "title": "API",
    "category": "section",
    "text": "DocTestSetup = quote\n    using AstroTime\nendModules = [AstroTime, AstroTime.Epochs]\nPrivate = false"
},

]}

# Generate aliases for all defined time scales so we can use
# e.g. `TTEpoch` instead of `Epoch{TT}`
for (scale, acronym) in zip(TimeScales.NAMES, TimeScales.ACRONYMS)
    epoch = Symbol(acronym, "Epoch")
    name = string(epoch)
    @eval begin
        const $epoch = Epoch{$scale}
        export $epoch

        """
            $($name)(str[, format])

        Construct a $($name) from a string `str`. Optionally a `format` definition can be
        passed as a [`DateFormat`](https://docs.julialang.org/en/stable/stdlib/Dates/#Dates.DateFormat)
        object or as a string. In addition to the character codes supported by `DateFormat`
        the code `D` is supported which is parsed as "day of year" (see the example below).
        The default format is `yyyy-mm-ddTHH:MM:SS.sss`.

        ### Example ###

        ```jldoctest; setup = :(using AstroTime)
        julia> $($name)("2018-02-06T20:45:00.0")
        2018-02-06T20:45:00.000 $($acronym)

        julia> $($name)("February 6, 2018", "U d, y")
        2018-02-06T00:00:00.000 $($acronym)

        julia> $($name)("2018-37T00:00", "yyyy-DDDTHH:MM")
        2018-02-06T00:00:00.000 $($acronym)
        ```
        """
        $epoch(::AbstractString)

        """
            $($name)(jd1::T, jd2::T=zero(T); origin=:j2000) where T<:AstroPeriod

        Construct a $($name) from a Julian date (optionally split into
        `jd1` and `jd2`). `origin` determines the variant of Julian
        date that is used. Possible values are:

        - `:j2000`: J2000 Julian date, starts at `2000-01-01T12:00`
        - `:julian`: Julian date, starts at `-4712-01-01T12:00`
        - `:modified_julian`: Modified Julian date, starts at `1858-11-17T00:00`

        ### Examples ###

        ```jldoctest; setup = :(using AstroTime)
        julia> $($name)(0.0days, 0.5days)
        2000-01-02T00:00:00.000 $($acronym)

        julia> $($name)(2.451545e6days, origin=:julian)
        2000-01-01T12:00:00.000 $($acronym)
        ```
        """
        $epoch(::Number, ::Number)

        """
            $($name)(year, month, day, hour=0, minute=0, second=0.0)

        Construct a $($name) from date and time components.

        ### Example ###

        ```jldoctest; setup = :(using AstroTime)
        julia> $($name)(2018, 2, 6, 20, 45, 0.0)
        2018-02-06T20:45:00.000 $($acronym)

        julia> $($name)(2018, 2, 6)
        2018-02-06T00:00:00.000 $($acronym)
        ```
        """
        $epoch(::Int, ::Int, ::Int)
    end
end


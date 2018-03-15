export MJD, J2000, J1950,
    SECONDS_PER_MINUTE, SECONDS_PER_HOUR, SECONDS_PER_DAY, SECONDS_PER_YEAR, SECONDS_PER_CENTURY,
    MINUTES_PER_HOUR, MINUTES_PER_DAY, MINUTES_PER_YEAR, MINUTES_PER_CENTURY,
    HOURS_PER_DAY, HOURS_PER_YEAR, HOURS_PER_CENTURY,
    DAYS_PER_YEAR, DAYS_PER_CENTURY,
    YEARS_PER_CENTURY,
<<<<<<< aeacb6edd2919cee100e9c87a80df84ee2801bb2
<<<<<<< 56a7a738ef60532ddd337827a009c79f33aa4eeb
    OFFSET_TT_TAI
=======
    TTMTAI
>>>>>>> Ported function eraTaitt
=======
    OFFSET_TT_TAI
>>>>>>> fixing

const MJD = 2400000.5
const J2000 = Dates.datetime2julian(DateTime(2000, 1, 1, 12, 0, 0))
const J1950 = Dates.datetime2julian(DateTime(1950, 1, 1, 12, 0, 0))

const SECONDS_PER_MINUTE   = 60.0
const SECONDS_PER_HOUR     = 60.0 * 60.0
const SECONDS_PER_DAY      = 60.0 * 60.0 * 24.0
const SECONDS_PER_YEAR     = 60.0 * 60.0 * 24.0 * 365.25
const SECONDS_PER_CENTURY  = 60.0 * 60.0 * 24.0 * 365.25 * 100.0

const MINUTES_PER_HOUR     = 60.0
const MINUTES_PER_DAY      = 60.0 * 24.0
const MINUTES_PER_YEAR     = 60.0 * 24.0 * 365.25
const MINUTES_PER_CENTURY  = 60.0 * 24.0 * 365.25 * 100.0

const HOURS_PER_DAY        = 24.0
const HOURS_PER_YEAR       = 24.0 * 365.25
const HOURS_PER_CENTURY    = 24.0 * 365.25 * 100.0

const DAYS_PER_YEAR        = 365.25
const DAYS_PER_CENTURY     = 365.25 * 100.0

const YEARS_PER_CENTURY    = 100.0

<<<<<<< e7240b131e015741152ce49f3097621a420009c6
<<<<<<< cdc10b523967f6ca20cf0e65d3a45c8a322678b6
<<<<<<< 56a7a738ef60532ddd337827a009c79f33aa4eeb
const OFFSET_TT_TAI = 32.184
=======
# ============================= ERFA CONSTANTS =========================
<<<<<<< aeacb6edd2919cee100e9c87a80df84ee2801bb2
const TTMTAI = 32.184 # ERFA_TTMTAI
>>>>>>> Ported function eraTaitt
=======
=======
>>>>>>> final changes
=======
>>>>>>> port ut1tai
const OFFSET_TT_TAI = 32.184
>>>>>>> fixing

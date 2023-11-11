


# Read into data.table for quicker processing of large data
# Remove unwanted columns
# Status has only one value
# Owner,Fuel_Source_Display_Name is replicated in another column
# Start and End Serial is used to calculate num_recs
# Creation_year, date, month, year are all similar to Creation_Date
# Update names
# Set Status.1 as Status
# capitalise all column names
# remove unusable characters from name and status columns
# capitalise name columns

Sys.time()
dt_rec <-
  fread(
    paste(
      rstudioapi::getActiveProject(),
      "data/wholeRECdatabase_20230816_no_dups_withSTCs_Zone3.csv",
      sep = "/"
    ),
    drop = c(
      "Status",
      "Owner",
      "Fuel_Source_Display_Name",
      "Start_Serial",
      "End_Serial",
      "Creation_Year",
      "date",
      "month",
      "year"
    ),
    check.names = TRUE,
    encoding = "UTF-8",
    strip.white = TRUE
  ) %>%
  rename_with(toupper) %>%
  rename(STATUS = STATUS.1, CREATOR_NAME = CREATED_BY) %>%
  mutate(
    CREATOR_NAME =
      toupper(str_remove_all(CREATOR_NAME, '[^\x20-\x7E]')),
    OWNER_NAME =
      toupper(str_remove_all(OWNER_NAME, '[^\x20-\x7E]')),
    DEEMED =
      str_ends(FUEL_SOURCE_TYPE, '_DEEMED'),
    FUEL_SOURCE_TYPE =
      str_remove_all(FUEL_SOURCE_TYPE, '_DEEMED'),
    CREATION_YEAR = year(CREATION_DATE),
    CREATION_QUARTER = quarter(CREATION_DATE),
    CREATION_MONTH = month(CREATION_DATE),
    CREATION_WEEK = week(CREATION_DATE),
    # CREATION_DAY_Y = yday(CREATION_DATE),
    # CREATION_DAY_M = mday(CREATION_DATE),
    # CREATION_DAY_W = wday(CREATION_DATE)
  )
Sys.time()

# load into duckdb connection
duckdb_register(con, "rec", dt_rec)

rm("dt_rec")

# power station data
dt_acc_power_stn <-
  dbGetQuery(con,
             "SELECT OWNER_NAME,
    CREATOR_NAME,
    STATE,
    FUEL_SOURCE_TYPE,
    DEEMED,
    CREATION_YEAR,
    CREATION_QUARTER,
    CREATION_MONTH,
    CREATION_WEEK,
    SUM(NUM_RECS) AS TRADE_QUANTITY
    FROM rec
    WHERE LEN(ACCREDITATION_CODE) <= 8
    GROUP BY OWNER_NAME,
    CREATOR_NAME,
    STATE,
    FUEL_SOURCE_TYPE,
    DEEMED,
    CREATION_YEAR,
    CREATION_QUARTER,
    CREATION_MONTH,
    CREATION_WEEK")

power_stations <-
  dt_acc_power_stn %>%
  distinct(CREATOR_NAME)

# create a pattern to exclude while checking for similarity
pattern_company <-
  "[PTY]|[PRIVATE]|[LIMITED]|[LTD]|[\\.]|[T\\/A]|[\\sTA\\s]"

# Creators
Sys.time()
creators <-
  dbGetQuery(
    con,
    "SELECT CREATOR_NAME,
    STATE,
    FUEL_SOURCE_TYPE,
    DEEMED,
    CREATION_YEAR,
    CREATION_QUARTER,
    CREATION_MONTH,
    CREATION_WEEK,
    -- CREATION_DAY_Y,
    -- CREATION_DAY_M,
    -- CREATION_DAY_W,
    -- count(*) AS TRADE_COUNT,
    SUM(NUM_RECS) AS TRADE_QUANTITY FROM rec
    GROUP BY CREATOR_NAME,
    STATE,
    FUEL_SOURCE_TYPE,
    DEEMED,
    CREATION_YEAR,
    CREATION_QUARTER,
    CREATION_MONTH,
    CREATION_WEEK,
    -- CREATION_DAY_Y,
    -- CREATION_DAY_M,
    -- CREATION_DAY_W"
  )

# Buyers
Sys.time()
buyers <-
  dbGetQuery(
    con,
    "SELECT OWNER_NAME,
    STATE,
    FUEL_SOURCE_TYPE,
    DEEMED,
    CREATION_YEAR,
    CREATION_QUARTER,
    CREATION_MONTH,
    CREATION_WEEK,
    -- CREATION_DAY_Y,
    -- CREATION_DAY_M,
    -- CREATION_DAY_W,
    -- count(*) AS TRADE_COUNT,
    SUM(NUM_RECS) AS TRADE_QUANTITY FROM rec
    GROUP BY OWNER_NAME,
    STATE,
    FUEL_SOURCE_TYPE,
    DEEMED,
    CREATION_YEAR,
    CREATION_QUARTER,
    CREATION_MONTH,
    CREATION_WEEK,
    -- CREATION_DAY_Y,
    -- CREATION_DAY_M,
    -- CREATION_DAY_W"
  )

# unique creator owner combination
# only for Registered status
Sys.time()
nexuses <-
  dbGetQuery(
    con,
    "SELECT OWNER_NAME,
    CREATOR_NAME,
    STATE,
    FUEL_SOURCE_TYPE,
    DEEMED,
    CREATION_YEAR,
    CREATION_QUARTER,
    CREATION_MONTH,
    CREATION_WEEK,
    -- CREATION_DAY_Y,
    -- CREATION_DAY_M,
    -- CREATION_DAY_W,
    -- count(*) AS TRADE_COUNT,
    SUM(NUM_RECS) AS TRADE_QUANTITY  FROM rec
    -- WHERE FUEL_SOURCE_ACTIVE = TRUE
    GROUP BY OWNER_NAME,
    CREATOR_NAME,
    STATE,
    FUEL_SOURCE_TYPE,
    DEEMED,
    CREATION_YEAR,
    CREATION_QUARTER,
    CREATION_MONTH,
    CREATION_WEEK,
    -- CREATION_DAY_Y,
    -- CREATION_DAY_M,
    -- CREATION_DAY_W"
  ) %>%
  mutate(WITHIN_UMBRELLA_COMPANY =
           if_else(stringsim(
             str_remove_all(OWNER_NAME,
                            pattern_company),
             str_remove_all(CREATOR_NAME,
                            pattern_company)
           ) >= .75, TRUE, FALSE))
Sys.time()

# nexus not within one umbrella company
collaboration <-
  nexuses %>%
  select(OWNER_NAME,
         CREATOR_NAME,
         WITHIN_UMBRELLA_COMPANY) %>%
  filter(WITHIN_UMBRELLA_COMPANY != TRUE) %>%
  distinct(OWNER_NAME, CREATOR_NAME)

Sys.time()

# Shutdown DB
if (exists('drv')) duckdb_shutdown(drv)
if (exists('con')) dbDisconnect(con, shutdown=TRUE)

rm('con')
gc()

# Create shareddata for dataframes used for visualisations
sd_creators <- SharedData$new(creators)

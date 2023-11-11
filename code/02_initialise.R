

if (exists('drv'))
  duckdb_shutdown(drv)
if (exists('con'))
  dbDisconnect(con, shutdown = TRUE)

# Create / connect to database file
# drv <-
#   duckdb(dbdir = paste(rstudioapi::getActiveProject(), "assets/duck.db", sep = "/"))
# con <- dbConnect(drv)
con <- dbConnect(duckdb(), dbdir = ":memory:")

# write a table to it
# dbWriteTable(con, "iris", iris)
# duckdb_shutdown(drv)
# and disconnect
# dbDisconnect(con, shutdown=TRUE)

# initialise states and their coordinates
states <-
  data.frame(
    NAME = c(
      'Australian Capital Territory',
      'New South Wales',
      'Northern Territory',
      'Queensland',
      'South Australia',
      'Tasmania',
      'Victoria',
      'Western Australia',
      'Other Territories'
    ),
    state = c('ACT', 'NSW', 'NT', 'QLD', 'SA', 'TAS', 'VIC', 'WA','OT'),
    lat = c(
      -35.3546004,
      -33.42004148,
      -13.81617348,
      -26.67998777,
      -34.28293455,
      -40.83292234,
      -37.73119953,
      -33.58287392,
      0
    ),
    lng = c(
      149.2113468,
      151.3000048,
      131.816698,
      153.0500272,
      140.6000378,
      145.1166613,
      142.0234135,
      120.0333345,
      0
    )
  )

sf_oz <- ozmap("states")

sf_oz$state <- states[match(sf_oz$NAME, states$NAME),'state']

sd_states <- SharedData$new(states)

# initialise months datafgrame and shareddata for interaction
month_names <-
  data.frame(month = factor(month.name, levels = month.name))

sd_months <- SharedData$new(month_names)

# initialise links
link_shiny <- tags$a(icon("github"), "Shiny",
                     href = "https://github.com/rstudio/shiny",
                     target = "_blank")
link_posit <- tags$a(icon("r-project"),
                     "Posit",
                     href = "https://posit.co",
                     target = "_blank")
link_itp <- tags$a(icon("home"),
                   "ITP Development",
                   href = "https://itpd.com.au",
                   target = "_blank")

# initialise themes
light_theme <- bs_theme(bootswatch = "cosmo")

dark_theme <- bs_theme(bootswatch = 'cyborg')

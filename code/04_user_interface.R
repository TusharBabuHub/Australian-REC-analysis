

# Setup User Interface
ui <- page_navbar(
  title = card_image(
    file = paste(script_path, "assets/itpd_logo.png", sep = "/"),
    href = "https://itpd.com.au",
    height = "50%",
    width = "50%",
    fill = TRUE,
    border_radius = "all"
  ),
  window_title = "Regulatory Energy Certificates Dashboard",
  theme = dark_theme,
  id = "ITP",
  fluid = TRUE,
  nav_spacer(),
  navset_card_tab(
    nav_panel(
      title = "Creators",
      layout_columns(
        plotlyOutput("plot_creators", reportTheme = TRUE),
        tmapOutput("creator_maps")
      ),
      dataTableOutput("creators", fill = TRUE)
    ),
    nav_panel(
      title = "Buyers",
      layout_columns(
        plotlyOutput("plot_buyers", reportTheme = TRUE),
        tmapOutput("buyer_maps")
      ),
      dataTableOutput("buyers", fill = TRUE)
    ),
    nav_panel(
      title = "Sales",
      layout_columns(
        value_box(
          title = "Top Buyer",
          value = textOutput("sales_top_buyer"),
          showcase = bs_icon("gem", size = NULL),
          full_screen = TRUE,
          fill = TRUE,
          tags$style(HTML("
    #sales_top {
      font-size: 10px;
    }
  "))
        ),
  value_box(
    title = "Top Creator",
    textOutput("sales_top_creator"),
    showcase = bs_icon("coin", size = NULL),
    full_screen = TRUE,
    fill = TRUE,
    theme_color = "success",
    tags$style(HTML("
    #sales_top {
      font-size: 10px;
    }
  "))
  ),
  value_box(
    title = "Top Sale Period",
    value = textOutput("sales_top_period"),
    showcase = bs_icon("calendar", size = NULL),
    full_screen = TRUE,
    fill = TRUE,
    theme_color = "info",
    tags$style(HTML("
    #sales_top {
      font-size: 10px;
    }
  "))
  )
      )
  ,
  value_box(
    title = "Top Sale",
    value = textOutput("sales_top"),
    showcase = bs_icon("piggy-bank", size = NULL),
    full_screen = TRUE,
    fill = TRUE,
    theme_color = "dark",
    tags$style(HTML("
    #sales_top {
      font-size: 20px;
    }
  "))
  ),
  dataTableOutput("sales", fill = TRUE)
    ),
  nav_panel(
    title = "Forecasts",
    dygraphOutput("dygraph"),
    dataTableOutput("nexuses", fill = TRUE)
  ),
  nav_spacer(),
  nav_menu(
    title = icon("bars"),
    nav_item(input_switch(
      id = "light_mode",
      label = icon("circle-half-stroke"),
      value = FALSE
    )),
    nav_item(link_itp),
    nav_item(link_shiny),
    nav_item(link_posit),
    align = "right"
  )
  )
)

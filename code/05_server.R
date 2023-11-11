
# Setup the Data and other input based visuals
server <- function(input, output, session) {
  observe(session$setCurrentTheme(if (input$light_mode)
    light_theme
    else
      dark_theme))

  primary_colour <- reactive((if (input$light_mode)
    '#5a5b5a'
    else
      'cyan'))

  secondary_colour <- reactive((if (input$light_mode)
    'white'
    else
      '#5a5b5a'))

  map_theme <- reactive((if (input$light_mode)
    'natural'
    else
      'cobalt'))

  map_border <- reactive((if (input$light_mode)
    'magenta'
    else
      'cyan'))

  # Creators pane processing
  creators_agg <-
    reactive({
      if (every(input$creators_rows_all,is.na))
        sel_data <- creators
      else
        sel_data <- creators[input$creators_rows_all, , drop = FALSE]

      sel_data %>%
        select(-one_of(c(
          "CREATION_QUARTER", "CREATION_MONTH", "CREATION_WEEK"
        ))) %>%
        group_by(STATE, CREATION_YEAR) %>%
        summarise(CREATOR_COUNT = n(),
                  TRADE_QUANTITY = sum(TRADE_QUANTITY)) %>%
        ungroup()
    })

  output$creators <-
    renderDataTable(
      datatable(
        creators,
        options = list(pageLength = 3,
                       scrollY = 200),
        filter = list(
          position = 'top',
          clear = FALSE,
          plain = FALSE
        ),
        rownames = FALSE
      ),
      server = TRUE,
      future = TRUE
    )

  output$plot_creators <- renderPlotly({
    creators_agg() %>%
      plot_ly(
        x = ~ CREATOR_COUNT,
        y = ~ TRADE_QUANTITY,
        color = ~ STATE,
        frame = ~ CREATION_YEAR,
        span = ~ CREATOR_COUNT,
        hoverinfo = "text",
        type = "scatter",
        mode = "lines+markers"
      ) %>%
      layout(
        xaxis = list(type = "log"),
        yaxis = list(type = "log"),
        title = "Creators over the years",
        plot_bgcolor = secondary_colour(),
        paper_bgcolor = secondary_colour(),
        font = list(color = primary_colour()),
        xaxis = list(gridcolor = primary_colour()),
        yaxis = list(gridcolor = primary_colour())
      ) %>%
      animation_opts(1000,
                     easing = "elastic",
                     redraw = FALSE)
  })

  output$creator_maps <- renderTmap({

    coord_creators <- creators_agg() %>%
      group_by(STATE) %>%
      summarise(TRADE_QUANTITY = sum(TRADE_QUANTITY)) %>%
      filter(TRADE_QUANTITY == max(TRADE_QUANTITY,na.rm = TRUE)) %>%
      ungroup()

    sf_out <- sf_oz[sf_oz$state == coord_creators$STATE,]

    tm_shape(sf_out, name = sf_out$NAME, filter = FALSE) +
      tm_borders(col = map_border(),lwd = 5) +
      tmap_style(map_theme())
      })

  # Buyers pane processing
  buyers_agg <-
    reactive({
      if (every(input$buyers_rows_all,is.na))
        sel_data <- buyers
      else
        sel_data <- buyers[input$buyers_rows_all, , drop = FALSE]

      sel_data %>%
        select(-one_of(c(
          "CREATION_QUARTER", "CREATION_MONTH", "CREATION_WEEK"
        ))) %>%
        group_by(STATE, CREATION_YEAR) %>%
        summarise(BUYER_COUNT = n(),
                  TRADE_QUANTITY = sum(TRADE_QUANTITY)) %>%
        ungroup()
    })

  output$buyers <-
    renderDataTable(
      datatable(
        buyers,
        options = list(pageLength = 3,
                       scrollY = 200),
        filter = list(
          position = 'top',
          clear = FALSE,
          plain = FALSE
        ),
        rownames = FALSE
      ),
      server = TRUE,
      future = TRUE
    )

  output$plot_buyers <- renderPlotly({
    buyers_agg() %>%
      plot_ly(
        x = ~ BUYER_COUNT,
        y = ~ TRADE_QUANTITY,
        color = ~ STATE,
        frame = ~ CREATION_YEAR,
        span = ~ BUYER_COUNT,
        hoverinfo = "text",
        type = "scatter",
        mode = "lines+markers"
      ) %>%
      layout(
        xaxis = list(type = "log"),
        yaxis = list(type = "log"),
        title = "Buyers over the years",
        plot_bgcolor = secondary_colour(),
        paper_bgcolor = secondary_colour(),
        font = list(color = primary_colour()),
        xaxis = list(gridcolor = primary_colour()),
        yaxis = list(gridcolor = primary_colour())
      ) %>%
      animation_opts(1000,
                     easing = "elastic",
                     redraw = FALSE)
  })

  output$buyer_maps <- renderTmap({

    coord_buyers <- buyers_agg() %>%
      group_by(STATE) %>%
      summarise(TRADE_QUANTITY = sum(TRADE_QUANTITY)) %>%
      filter(TRADE_QUANTITY == max(TRADE_QUANTITY,na.rm = TRUE)) %>%
      ungroup()

    sf_out <- sf_oz[sf_oz$state == coord_buyers$STATE,]

    tm_shape(sf_out, name = sf_out$NAME, filter = FALSE) +
      tm_borders(col = map_border(),lwd = 5) +
      tmap_style(map_theme())
  })

  # Sales pane processing

  output$sales <-
    renderDataTable({
      sales <- nexuses %>%
        filter(WITHIN_UMBRELLA_COMPANY != TRUE) %>%
        select(-c(WITHIN_UMBRELLA_COMPANY,CREATION_WEEK,DEEMED))

      datatable(
        sales,
        options = list(pageLength = 3,
                       scrollY = 200),
        filter = list(
          position = 'top',
          clear = FALSE,
          plain = FALSE
        ),
        rownames = FALSE
      )
    },
    server = TRUE,
    future = TRUE)

  sel_data <- reactive({
    if (every(input$sales_rows_all,is.na))
      sel_data <- nexuses
    else
      sel_data <- nexuses[input$sales_rows_all, , drop = FALSE]})

  output$sales_top_creator <- renderText({

    sel_data <- sel_data() %>%
      select(c(
        "CREATOR_NAME", "TRADE_QUANTITY"
      )) %>%
      group_by(CREATOR_NAME) %>%
      summarise(TRADE_QUANTITY = sum(TRADE_QUANTITY)) %>%
      ungroup() %>%
      filter(TRADE_QUANTITY == max(TRADE_QUANTITY))

    sel_data$CREATOR_NAME
    })

  output$sales_top_buyer <- renderText({

    sel_data <- sel_data() %>%
      select(c(
        "OWNER_NAME", "TRADE_QUANTITY"
      )) %>%
      group_by(OWNER_NAME) %>%
      summarise(TRADE_QUANTITY = sum(TRADE_QUANTITY)) %>%
      ungroup() %>%
      filter(TRADE_QUANTITY == max(TRADE_QUANTITY))

   sel_data$OWNER_NAME
  })

  output$sales_top <- renderText({

    sel_data <- sel_data() %>%
      select(c(
        "CREATOR_NAME", "OWNER_NAME", "TRADE_QUANTITY"
      )) %>%
      group_by(CREATOR_NAME, OWNER_NAME) %>%
      summarise(TRADE_QUANTITY = sum(TRADE_QUANTITY)) %>%
      ungroup() %>%
      filter(TRADE_QUANTITY == max(TRADE_QUANTITY))

    paste('Between Buyer',sel_data$OWNER_NAME,'and Creator',sel_data$CREATOR_NAME,sep = " ")
  })

  output$sales_top_period <- renderText({

    sel_data <- sel_data() %>%
      select(c(
        "CREATION_YEAR", "CREATION_QUARTER", "CREATION_MONTH", "TRADE_QUANTITY"
      )) %>%
      group_by(CREATION_YEAR, CREATION_QUARTER, CREATION_MONTH) %>%
      summarise(TRADE_QUANTITY = sum(TRADE_QUANTITY)) %>%
      ungroup() %>%
      filter(TRADE_QUANTITY == max(TRADE_QUANTITY))

    paste(month_names$month[sel_data$CREATION_MONTH], 'of Year', sel_data$CREATION_YEAR,sep = " ")
  })

  # Forecast pane processing
  output$nexuses <-
    renderDataTable(
      datatable(
        select(nexuses,-WITHIN_UMBRELLA_COMPANY),
        options = list(pageLength = 3,
                       scrollY = 200),
        filter = list(
          position = 'top',
          clear = FALSE,
          plain = FALSE
        ),
        rownames = FALSE
      ),
      server = TRUE,
      future = TRUE
    )

  nexuses_agg <-
    reactive({
      if (every(input$nexuses_rows_all,is.na))
        sel_data <- nexuses
      else
        sel_data <- nexuses[input$nexuses_rows_all, , drop = FALSE]

      sel_data <- sel_data %>%
        select(c(
          "CREATION_YEAR", "CREATION_MONTH", "TRADE_QUANTITY"
        )) %>%
        group_by(CREATION_MONTH, CREATION_YEAR) %>%
        summarise(TRADE_QUANTITY = sum(TRADE_QUANTITY)) %>%
        ungroup() %>%
        mutate(CREATION_MONTH = month_names$month[CREATION_MONTH]) %>%
        mutate(DATE = as.Date(paste(CREATION_YEAR, CREATION_MONTH, "01", sep = "-"), "%Y-%b-%d"))

      ts_nexuses <-
        ts(sel_data$TRADE_QUANTITY,
           start = c(min(sel_data$CREATION_YEAR), 1),
           frequency = 12)
    })

  predicted <- reactive({
    hw <- HoltWinters(nexuses_agg())
    predict(
      hw,
      n.ahead = 72,
      prediction.interval = TRUE,
      level = as.numeric(.9)
    )
  })

  output$dygraph <- renderDygraph({
    dygraph(predicted(), main = "Predicted Trade Quantity") %>%
      dySeries(c("lwr", "fit", "upr"), label = "Trade Quantity") %>%
      dyOptions(
        drawGrid = TRUE,
        axisLineColor = primary_colour(),
        axisLabelColor = primary_colour(),
        colors = RColorBrewer::brewer.pal(3, "Set2")
      ) %>%
      dyHighlight(
        highlightCircleSize = 5,
        highlightSeriesBackgroundAlpha = 1,
        hideOnMouseOut = TRUE
      ) %>%
      dyRangeSelector()
  })
  }

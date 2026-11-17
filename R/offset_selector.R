#' Interactively Select an Offset Range
#'
#' Launches an interactive Plotly graph that allows users to
#' select an interval using two points or a rectangular region.
#'
#' @param data A data frame containing the data to plot.
#' @param x Character string specifying the x-axis column.
#' @param y Character string specifying the y-axis column.
#' @param title Title displayed above the selection interface.
#'
#' @return A list containing lower, upper, width, and method.
#' Returns NULL if the selection is cancelled.
#'
#' @importFrom stats as.formula
#' @export
select_offsets <- function(data, x, y,
                           viewer = c("dialog", "browser"),
                           title = "Select an offset range") {
  # Validate inputs ---------------------------------------------------

  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Shiny is required to use the `select_offsets` GUI.")
  }
  if (!requireNamespace("plotly", quietly = TRUE)) {
    stop("Plotly is required to use the `select_offsets` GUI.")
  }
  if (!requireNamespace("htmlwidgets", quietly = TRUE)) {
    stop("htmlwidgets is required to use the `select_offsets` GUI.")
  }

  if (!is.data.frame(data)) {
    stop("'data' must be a data.frame.", call. = FALSE)
  }

  if (!all(c(x, y) %in% names(data))) {
    stop("'x' and 'y' must refer to columns in 'data'.",
      call. = FALSE
    )
  }

  if (!is.numeric(data[[x]]) || !is.numeric(data[[y]])) {
    stop("Both selected columns must be numeric.",
      call. = FALSE
    )
  }

  if (length(viewer) > 1) viewer <- viewer[1]
  if (!viewer %in% c("dialog", "browser")) {
    stop("`viewer` must be one of dialog or browser")
  }

  # UI ----------------------------------------------------------------

  ui <- shiny::fluidPage(
    shiny::titlePanel(title),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::radioButtons(
          inputId = "mode",
          label = "Selection method:",
          choices = c(
            "Two points" = "points",
            "Rectangular region" = "region"
          ),
          selected = "points"
        ),
        shiny::actionButton(
          inputId = "clear",
          label = "Clear selection"
        ),
        shiny::hr(),
        shiny::verbatimTextOutput("selection"),
        shiny::actionButton(
          inputId = "finish",
          label = "Use selection",
          class = "btn-primary"
        ),
        shiny::actionButton(
          inputId = "cancel",
          label = "Cancel"
        )
      ),
      shiny::mainPanel(
        plotly::plotlyOutput(
          outputId = "plot",
          height = "600px"
        )
      )
    )
  )


  # Server ------------------------------------------------------------

  server <- function(input, output, session) {
    selected_points <- shiny::reactiveVal(numeric())
    selected_offsets <- shiny::reactiveVal(NULL)


    # Reset selection when changing modes
    shiny::observeEvent(input$mode, {
      selected_points(numeric())
      selected_offsets(NULL)
    })


    # Clear selection
    shiny::observeEvent(input$clear, {
      selected_points(numeric())
      selected_offsets(NULL)
    })


    # Interactive plot
    output$plot <- plotly::renderPlotly({
      mode <- input$mode

      p <- plotly::plot_ly(
        data = data,
        x = stats::as.formula(paste0("~", x)),
        y = stats::as.formula(paste0("~", y)),
        type = "scatter",
        mode = "lines",
        source = "selector"
        # marker = list(size = 5)
      ) |>
        plotly::layout(
          title = title,
          xaxis = list(title = x),
          yaxis = list(title = y),
          dragmode = if (mode == "region") "select" else "zoom"
        )

      # Capture rectangular selection boundaries
      if (mode == "region") {
        p <- htmlwidgets::onRender(
          p,
          "
          function(el, x) {

            el.on('plotly_selected', function(event) {

              if (event && event.range && event.range.x) {

                Shiny.setInputValue(
                  'box_range',
                  {
                    xmin: event.range.x[0],
                    xmax: event.range.x[1]
                  },
                  {priority: 'event'}
                );

              }

            });

          }
          "
        )
      }

      p
    })


    # Two-point selection
    shiny::observeEvent(
      plotly::event_data(
        "plotly_click",
        source = "selector"
      ),
      {
        if (input$mode != "points") {
          return()
        }

        click <- plotly::event_data(
          "plotly_click",
          source = "selector"
        )

        points <- c(
          selected_points(),
          click$x[1]
        )

        if (length(points) > 2) {
          points <- tail(points, 2)
        }

        selected_points(points)

        if (length(points) == 2) {
          selected_offsets(sort(points))
        }
      },
      ignoreNULL = TRUE
    )


    # Rectangular selection
    shiny::observeEvent(input$box_range, {
      if (input$mode != "region") {
        return()
      }

      selected_offsets(
        sort(c(
          input$box_range$xmin,
          input$box_range$xmax
        ))
      )
    })


    # Display selected offsets
    output$selection <- shiny::renderPrint({
      offsets <- selected_offsets()

      if (is.null(offsets)) {
        cat("No valid selection yet.")
      } else {
        cat("Lower:", offsets[1], "\n")
        cat("Upper:", offsets[2], "\n")
        cat("Width:", diff(offsets))
      }
    })


    # Return selection
    shiny::observeEvent(input$finish, {
      offsets <- selected_offsets()

      if (is.null(offsets)) {
        return()
      }

      shiny::stopApp(
        returnValue = list(
          lower = offsets[1],
          upper = offsets[2],
          width = diff(offsets),
          method = input$mode
        )
      )
    })


    # Cancel
    shiny::observeEvent(input$cancel, {
      shiny::stopApp(returnValue = NULL)
    })
  }


  # Launch application -------------------------------------------------

  app <- shiny::shinyApp(
    ui = ui,
    server = server
  )

  if (viewer == "browser") {
    viewer <- shiny::browserViewer()
  } else {
    viewer <- shiny::dialogViewer("Select offsets")
  }

  result <- shiny::runGadget(
    app,
    viewer = viewer
  )

  return(result)
}

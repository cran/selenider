## ----include = FALSE----------------------------------------------------------
available <- selenider::selenider_available()
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = available
)

## ----eval = !available, include = FALSE---------------------------------------
#  message("Selenider is not available")

## ----setup--------------------------------------------------------------------
library(selenider)
library(testthat)

## ----error = TRUE-------------------------------------------------------------
test_that("My test", {
  # session will be opened here...
  open_url("https://www.r-project.org/")

  s(".random-class") |>
    elem_expect(is_present)
}) # and closed here!

## ----setup2-------------------------------------------------------------------
library(shiny)
library(shinytest2)

## -----------------------------------------------------------------------------
shiny_app <- shinyApp(
  ui = fluidPage(
    actionButton("button", label = "Click me!"),
    conditionalPanel(
      condition = "(input.button % 2) == 1",
      p("Button has been clicked an odd number of times.")
    ) |>
      tagAppendAttributes(id = "condpanel")
  ),
  server = function(input, output) {
    even <- reactive((input$button %% 2) == 0)
    exportTestValues(even = { even() })
  }
)

## -----------------------------------------------------------------------------
test_that("App works", {
  app <- AppDriver$new(shiny_app)

  session <- selenider_session(driver = app)

  s("#condpanel") |>
    elem_expect(is_invisible)

  app$click("button")

  app$expect_values(export = "even")
  s("#condpanel") |>
    elem_expect(is_visible)

  app$click("button")

  app$expect_values(export = "even")
  s("#condpanel") |>
    elem_expect(is_invisible)
})


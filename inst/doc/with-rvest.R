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
library(rvest)
library(selenider)

## -----------------------------------------------------------------------------
open_url("https://www.r-project.org/")

## -----------------------------------------------------------------------------
s(".mt-timeline") |>
  find_element("article") |>
  elem_attr("data-location") |>
  open_url()

## -----------------------------------------------------------------------------
# First method
rvest_element <- s(".columns-area") |>
  find_element(".status__content") |>
  read_html()

rvest_element

html_text2(rvest_element)

## -----------------------------------------------------------------------------
get_page_source() |>
  html_element(".columns-area") |>
  html_element(".status__content") |>
  html_text2()


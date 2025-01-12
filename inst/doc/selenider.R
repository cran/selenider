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

## ----eval=FALSE---------------------------------------------------------------
#  session <- selenider_session(
#    "chromote",
#    timeout = 10,
#    options = chromote_options(headless = FALSE)
#  )

## ----include=FALSE------------------------------------------------------------
session <- selenider_session()

## -----------------------------------------------------------------------------
# Bad (unless you only need to use the session inside the function)
my_selenider_session <- function(...) {
  selenider_session("selenium", ...)
  # The session will be closed here
}

# Good - the session will be open in the caller environment/function
my_selenider_session <- function(..., .env = rlang::caller_env()) {
  selenider_session("selenium", ..., .env = .env)
}

## -----------------------------------------------------------------------------
open_url("https://www.r-project.org/")

open_url("https://www.tidyverse.org/")

back()

forward()

reload()

## -----------------------------------------------------------------------------
header <- s("#rStudioHeader")

header

## -----------------------------------------------------------------------------
s(xpath = "//div/a")

## -----------------------------------------------------------------------------
all_links <- ss("a")

all_links

## -----------------------------------------------------------------------------
tidyverse_title <- s("#rStudioHeader") |>
  find_element("div") |>
  find_element(".productName")

tidyverse_title

menu_items <- s("#rStudioHeader") |>
  find_element("#menu") |>
  find_elements(".menuItem")

menu_items

## -----------------------------------------------------------------------------
s("#menuItems") |>
  elem_children()

s("#menuItems") |>
  elem_ancestors()

## -----------------------------------------------------------------------------
# Find the blog item in the menu
menu_items |>
  elem_find(has_text("Blog"))

# Find the hex badges on the second row
s(".hexBadges") |>
  find_elements("img") |>
  elem_filter(
    \(x) substring(elem_attr(x, "class"), 1, 2) == "r2"
  )

## -----------------------------------------------------------------------------
s(".blurb") |>
  find_element("a") |> # List of packages
  elem_scroll_to() |>
  elem_click()

## -----------------------------------------------------------------------------
s(".packages") |>
  find_elements("a") |>
  elem_find(has_text("dplyr")) |> # Find the link to the dplyr documentation
  elem_attr("href") |> # Get the URL
  open_url()

## -----------------------------------------------------------------------------
s("input[type='search']") |>
  elem_set_value("filter")

# Go back to the main page
back()
back()

## -----------------------------------------------------------------------------
# Get the tag name
s("#appTidyverseSite") |>
  elem_name()

# Get the text inside the element
s(".tagline") |>
  elem_text()

# Get an attribute
s(".hexBadges") |>
  find_element("img") |>
  elem_attr("alt")

# Get every attribute
s(".hexBadges") |>
  find_element("img") |>
  elem_attrs()

# Get the 'value' attribute (`NULL` in this case)
s("#homeContent") |>
  elem_value()

# Get a CSS property
s(".tagline") |>
  elem_css_property("font-size")

## -----------------------------------------------------------------------------
s(".hexBadges") |>
  is_present()

## -----------------------------------------------------------------------------
s(".tagline") |>
  elem_expect(is_present) |>
  elem_expect(has_text("data science"))

s(".hexBadges") |>
  find_element("a") |>
  elem_expect(is_visible, is_enabled)

s("#menu") |>
  find_element("#menuItems") |>
  elem_children() |>
  elem_expect(has_at_least(4))

s(".productName") |>
  elem_expect(
    \(x) substring(elem_text(x), 1, 1) == "T" # Tidyverse starts with T
  )

## ----error = TRUE-------------------------------------------------------------
s(".band.first") |>
  find_element(".blurb") |>
  find_element("code") |>
  elem_expect(has_text('install.packages("selenider")'), timeout = 1)

## -----------------------------------------------------------------------------
s(".random-class") |>
  elem_expect(!is_present)

s(".innards") |>
  elem_expect(is_visible || is_enabled)

elem_1 <- s(".random-class")

elem_2 <- s("#main")

# Test that either the first or second element exists
elem_expect(is_present(elem_1) || is_present(elem_2))

## -----------------------------------------------------------------------------
elem_wait_until(is_present(elem_1) || is_present(elem_2))

## -----------------------------------------------------------------------------
s(".hexBadges") |>
  find_elements("a") |>
  elem_expect_all(is_visible)


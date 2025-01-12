## ----include = FALSE----------------------------------------------------------
available <- selenider::selenider_available()
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = available
)

## ----eval = !available, include = FALSE---------------------------------------
#  message("Selenider is not available")

## -----------------------------------------------------------------------------
library(selenider)

## ----eval=FALSE---------------------------------------------------------------
#  session <- selenider_session(
#    "chromote",
#    options = chromote_options(headless = TRUE)
#  )

## ----eval=FALSE---------------------------------------------------------------
#  session <- selenider_session(
#    "selenium",
#    options = selenium_options(
#      server_options = NULL, # Stop selenider from creating a server
#      client_options = selenium_client_options(
#        host = "localhost", # Use the host and port of your manually created server
#        port = 4444L
#      )
#    )
#  )

## ----eval=FALSE---------------------------------------------------------------
#  session <- selenider_session()
#  
#  chromote_session <- session$driver
#  
#  chromote_session$Browser$setDownloadBehavior(
#    behavior = "allow",
#    downloadPath = "<path_to_folder>"
#  )

## -----------------------------------------------------------------------------
open_url("https://www.r-project.org/")

links <- ss("a")

links

## -----------------------------------------------------------------------------
links[[1]]

links[1:2]

length(links)

## -----------------------------------------------------------------------------
names(links)

## -----------------------------------------------------------------------------
execute_js_expr("
  const link = document.createElement('a');
  link.href = 'https://ashbythorpe.github.io/selenider/';
  link.innerText = 'Selenider';
  document.body.appendChild(link);
")

## -----------------------------------------------------------------------------
links

links[[length(links)]]


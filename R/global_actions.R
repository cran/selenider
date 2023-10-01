#' Open a URL
#'
#' Navigate the browser to specified URL, waiting until the page is considered
#' open before finishing.
#'
#' @param url The URL to navigate to: a string.
#' @inheritParams back
#'
#' @returns
#' The session object, invisibly.
#'
#' @family global actions
#'
#' @examplesIf selenider::selenider_available()
#' session <- selenider_session()
#'
#' open_url("https://r-project.org")
#'
#' # Or:
#' open_url(session = session, "https://r-project.org")
#'
#' \dontshow{
#' # Clean up all connections and invalidate default chromote object
#' selenider_cleanup()
#' }
#'
#' @export
open_url <- function(url, session = NULL) {
  check_string(url)
  check_class(session, "selenider_session", allow_null = TRUE)

  if (is.null(session)) {
    session <- get_session(.env = caller_env())
  }

  driver <- session$driver

  if (uses_selenium(session$driver)) {
    driver$client$navigate(url)
  } else {
    promise <- driver$Page$loadEventFired(wait_ = FALSE)
    driver$Page$navigate(url, wait_ = FALSE)
    driver$wait_for(promise)
  }

  invisible(session)
}

#' Move back or forward in browsing history
#'
#' @description
#' `back()` navigates to the previously opened URL, or the previously opened
#' page in your browsing history.
#'
#' `forward()` reverses the action of `back()`, going to the next page in your
#' browsing history.
#'
#' @param session A `selenider_session object. If not specified, the global
#'   session object (the result of [get_session()]) is used.
#'
#' @returns
#' The session object, invisibly.
#'
#' @family global actions
#'
#' @examplesIf selenider::selenider_available()
#' session <- selenider_session()
#'
#' open_url("https://r-project.org")
#'
#' open_url("https://www.tidyverse.org/")
#'
#' back()
#'
#' forward()
#'
#' \dontshow{
#' # Clean up all connections and invalidate default chromote object
#' selenider_cleanup()
#' }
#'
#' @export
back <- function(session = NULL) {
  check_class(session, "selenider_session", allow_null = TRUE)

  if (is.null(session)) {
    session <- get_session(.env = caller_env())
  }

  driver <- session$driver

  if (uses_selenium(session$driver)) {
    driver$client$goBack()
  } else {
    navigation_history <- driver$Page$getNavigationHistory()
    index <- navigation_history$currentIndex + 1
    history <- navigation_history$entries
    if (index > 1) {
      new_id <- history[[index - 1]]$id

      promise <- driver$Page$loadEventFired(wait_ = FALSE)
      driver$Page$navigateToHistoryEntry(new_id, wait_ = FALSE)
      driver$wait_for(promise)
    } else {
      warn_history_page_not_found(next_page = FALSE)
    }
  }

  invisible(session)
}

#' @rdname back
#'
#' @export
forward <- function(session = NULL) {
  check_class(session, "selenider_session", allow_null = TRUE)

  if (is.null(session)) {
    session <- get_session(.env = caller_env())
  }

  driver <- session$driver

  if (uses_selenium(session$driver)) {
    driver$client$goForward()
  } else {
    navigation_history <- driver$Page$getNavigationHistory()
    index <- navigation_history$currentIndex + 1
    history <- navigation_history$entries
    if (index < length(history)) {
      new_id <- history[[index + 1]]$id

      promise <- driver$Page$loadEventFired(wait_ = FALSE)
      driver$Page$navigateToHistoryEntry(new_id, wait_ = FALSE)
      driver$wait_for(promise)
    } else {
      warn_history_page_not_found(next_page = TRUE)
    }
  }

  invisible(session)
}

#' Reload the current page
#'
#' `reload()` and `refresh()` both reload the current page.
#'
#' @inheritParams back
#'
#' @returns
#' The session object, invisibly.
#'
#' @family global actions
#'
#' @examplesIf selenider::selenider_available()
#' session <- selenider_session()
#'
#' open_url("https://r-project.org")
#'
#' reload()
#'
#' \dontshow{
#' # Clean up all connections and invalidate default chromote object
#' selenider_cleanup()
#' }
#'
#' @export
reload <- function(session = NULL) {
  check_class(session, "selenider_session", allow_null = TRUE)

  if (is.null(session)) {
    session <- get_session(.env = caller_env())
  }

  driver <- session$driver

  if (uses_selenium(session$driver)) {
    driver$client$refresh()
} else {
    promise <- driver$Page$loadEventFired(wait_ = FALSE)
    session$driver$Page$reload(wait_ = FALSE)
    driver$wait_for(promise)
  }

  invisible(session)
}

#' @rdname reload
#'
#' @export
refresh <- reload

#' Take a screenshot of the current page
#'
#' Take a screenshot of the current session state, saving this image to a file.
#'
#' @param file The file path to save the screenshot to.
#' @param view Whether to open the interactively view the screenshot. If this is
#'   `TRUE` and `file` is `NULL`, the screenshot will be deleted after viewing.
#' @inheritParams back
#'
#' @returns
#' `file`, if it is not `NULL`. Otherwise, the session object is returned, invisibly.
#'
#' @family global actions
#'
#' @examplesIf selenider::selenider_available()
#' session <- selenider_session()
#'
#' open_url("https://www.google.com")
#'
#' file_path <- withr::local_tempfile(fileext = "png")
#'
#' take_screenshot(file_path)
#'
#' \dontshow{
#' # Clean up all connections and invalidate default chromote object
#' selenider_cleanup()
#' }
#'
#' @export
take_screenshot <- function(file = NULL, view = FALSE, session = NULL) {
  check_string(file, allow_null = TRUE)
  check_bool(view)
  check_class(session, "selenider_session", allow_null = TRUE)

  if (view) {
    rlang::check_installed("showimage", reason = "to view the screenshot")
  }

  if (is.null(file) && !view) {
    stop_null_screenshot_file()
  }

  if (is.null(session)) {
    session <- get_session(.env = caller_env())
  }

  if (is.null(file)) {
    file <- withr::local_tempfile(fileext = "png")
  }

  if (uses_selenium(session$driver)) {
    session$driver$client$screenshot(file = file)

    if (view) {
      showimage::show_image(file)
    }
  } else {
    session$driver$screenshot(file, show = view)
  }

  if (!is.null(file)) {
    file
  } else {
    invisible(session)
  }
}

#' Read the HTML of a session
#'
#' Uses [xml2::read_html()] to read the page source of the session
#'
#' @param session Optionally, a `selenider_session` object.
#' @param ... Passed into [xml2::read_html()]
#'
#' @returns An XML document.
#'
#' @family global actions
#'
#' @examplesIf selenider::selenider_available(online = FALSE)
#' html <- "
#' <p>Example text</p>
#' "
#'
#' session <- minimal_selenider_session(html)
#'
#' get_page_source()
#'
#' \dontshow{
#' # Clean up all connections and invalidate default chromote object
#' selenider_cleanup()
#' }
#'
#' @export
get_page_source <- function(session = NULL, ...) {
  rlang::check_installed("xml2")

  if (is.null(session)) {
    session <- get_session()
  }

  driver <- session$driver

  if (uses_selenium(driver)) {
    page_source <- unpack_list(driver$client$getPageSource())

  } else {
    document <- driver$DOM$getDocument()
    root <- document$root$nodeId
    page_source <- driver$DOM$getOuterHTML(root)$outerHTML
  }

  xml2::read_html(page_source, ...)
}
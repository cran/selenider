selenider_test_session <- function(x, .env = rlang::caller_env()) {
  session <- Sys.getenv("SELENIDER_SESSION", "chromote")
  browser <- Sys.getenv("SELENIDER_BROWSER", "chrome")
  docker <- as.logical(Sys.getenv("SELENIDER_DOCKER", "FALSE"))
  port <- as.integer(Sys.getenv("SELENIDER_PORT", "4444"))

  skip_if_selenider_unavailable(session)

  if (session == "chromote") {
    headless <- as.logical(Sys.getenv("SELENIDER_HEADLESS", "TRUE"))

    chromote::set_chrome_args(c(
      # https://peter.sh/experiments/chromium-command-line-switches/#disable-crash-reporter
      "--disable-crash-reporter",
      "--no-sandbox",
      chromote::default_chrome_args()
    ))

    result <- selenider_session(
      session,
      browser = browser,
      options = chromote_options(headless = headless),
      .env = .env
    )

    withr::defer(
      {
        # Delete the Crashpad folder if it exists
        unlink(file.path(tempdir(), "Crashpad"), recursive = TRUE)
      },
      envir = .env
    )
  } else if (docker && session == "selenium") {
    result <- selenider_session(
      "selenium",
      browser = browser,
      options = selenium_options(
        server_options = NULL,
        client_options = selenium_client_options(port = port)
      ),
      .env = .env
    )
  } else if (session == "selenium") {
    result <- selenider_session(session, browser = browser, .env = .env)
  } else if (docker && session == "rselenium") {
    result <- selenider_session(
      "rselenium",
      browser = browser,
      options = selenium_options(
        server_options = NULL,
        client_options = rselenium_client_options(port = port)
      ),
      .env = .env
    )
  } else {
    result <- selenider_session(
      "rselenium",
      browser = browser,
      options = selenium_options(
        server_options = wdman_server_options()
      ),
      .env = .env
    )
  }

  result
}

#' @title Get information from yaml file
#' @description Get information from yaml file
#' @param file A character string naming a file
#' @return A list with input information from yaml file
#' @export

oauth_config <- function(file) {

  appid <- read_yaml(file, eval.expr = TRUE)

  app <- oauth_app(
    appid$name,
    key = appid$config$key,
    secret = appid$config$secret,
    redirect_uri = appid$config$redirect_uri
  )

  api <- oauth_endpoint(
    base_url = appid$config$base_url,
    authorize = appid$config$authorize,
    access = appid$config$access
  )

  scope <- appid$config$scope

  base_url <- appid$config$base_url

  return(list(app = app,
              api = api,
              scope = scope,
              base_url = base_url)
  )

}

#' @title Modified shinyApp
#' @description Modified shinyApp
#' @param ui The UI definition of the app
#' @param  server A function with three parameters: input, output, and session. The function is called once for each session ensuring that each app is independent
#' @return An object that represents the app
#' @export

shinyAppId <- function(ui, server){

  oauth_setup <- oauth_config(list.files(pattern = "appid_config.yml", full.names = TRUE))

  uiFunc <- function(req) {

    has_auth_code <- function(params) {

      return(!is.null(params$code))
    }

    if (!has_auth_code(parseQueryString(req$QUERY_STRING))) {
      url <- oauth2.0_authorize_url(oauth_setup$api, oauth_setup$app, scope = oauth_setup$scope)
      redirect <- sprintf("location.replace(\"%s\");", url)
      tags$script(HTML(redirect))

    } else {
      ui

    }
  }

  shinyApp(uiFunc, server)

}

#' @title Get user information
#' @description This is a shiny module to get user information
#' @param input Input
#' @param output Output
#' @param session Session
#' @return Name
#' @export

get_user_info <- function(input, output, session) {

  oauth_setup <- oauth_config(list.files(pattern = "appid_config.yml", full.names = TRUE))

  params <- parseQueryString(isolate(session$clientData$url_search))

  has_auth_code <- function(params) {

    return(!is.null(params$code))
  }

  if (!has_auth_code(params)) {
    return()
  }

  # get a token and get user info

  if (!file.exists("/tmp/code.RDS")) {

    code <- params$code
    saveRDS(code, "/tmp/code.RDS")

  } else {

    code <- readRDS("/tmp/code.RDS")

    if (length(code) > 5) {code %<>% .[(length(.) - 3):length(.)]}
    code %<>% append(params$code)
    saveRDS(code, "/tmp/code.RDS")

  }

  if (!(code[(length(code) - 1):length(code)] %>% duplicated() %>% any())) {

    access_token <- oauth2.0_access_token(
      oauth_setup$api,
      oauth_setup$app,
      use_basic_auth = TRUE,
      params$code
    )

    saveRDS(access_token, "/tmp/token.RDS")

    token <- oauth2.0_token(
      app = oauth_setup$app,
      endpoint = oauth_setup$api,
      credentials = access_token,
      cache = TRUE
    )

  } else {

    token <- oauth2.0_token(
      app = oauth_setup$app,
      endpoint = oauth_setup$api,
      credentials = readRDS("/tmp/token.RDS"),
      cache = TRUE
    )

  }

  user <-
    reactive({

      resp <-
        GET(glue::glue("{oauth_setup$base_url}/userinfo"),
            httr::config(token = token)) %>%
        content(., "text", encoding = "UTF-8") %>%
        fromJSON()

      glue::glue("{resp$name}")

    })

  return(user)

}

#' @title Show user information in UI
#' @description Show user information in UI
#' @param
#' @return Name
#' @export

user_info <- function() {

  tags$li(class = "dropdown",
          tags$a(href = "",
                 class = "header_class",
                 textOutput("user")))

}

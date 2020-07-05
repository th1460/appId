#' @title Generate a configuration file
#' @description Generate a configuration file
#' @param name App's name
#' @return Configuration file
#' @export

gen_appid_config <- function(name = NULL) {

  list_obj <- list(name = name,
                   config = list(key = 'Sys.getenv("APPID_KEY")',
                                 secret = 'Sys.getenv("APPID_SECRET")',
                                 redirect_uri = 'Sys.getenv("APP_URL")',
                                 base_url = 'Sys.getenv("APPID_URL")',
                                 authorize = 'authorization',
                                 access = 'token',
                                 scope = 'openid',
                                 password = 'Sys.getenv("SECRET")'
                                 ))

  attr(list_obj$config$key, "tag") <- "!expr"
  attr(list_obj$config$secret, "tag") <- "!expr"
  attr(list_obj$config$redirect_uri, "tag") <- "!expr"
  attr(list_obj$config$base_url, "tag") <- "!expr"
  attr(list_obj$config$password, "tag") <- "!expr"

  cat(list_obj %>% as.yaml(), file = "appid_config.yml")

}

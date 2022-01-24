#' Web Scraping Stock Price Data for Two or More Brands
#'
#' @description This function scrapes stock price data of
#' two or more stocks by using the loop syntax of `scrape_onefirm`.
#' With the `append` option,
#' you can select whether to obtain the data
#' combining the data of each brand in the row direction or
#' to obtain it from the list composed of the data of each brand.
#'
#' @param code numeric vector. Specify brand codes.
#' @param name character vector. Specify company name.
#' If specified, ignore `code` argument and
#' find out brand code by `code_detect`.
#' @param start_date numeric.
#' Specify the start date of the stock price data you want to acquire
#' in the format of yyyymmdd.
#' @param end_date numeric.
#' Specify the end date of the stock price data you want to acquire
#' in the format of yyyymmdd.
#' @param datatype character. Specify the type of stock price data.
#' If `datatype = "d", get daily data.
#' If `datatype = "w", get weekly data.
#' If `datatype = "m", get monthly data.
#' @param append logical.
#' Do you want to combine the stock price data of each stock
#' in the row direction? Default is `append = TRUE`.
#' @return If `append = TRUE`,
#' return a tibble object containing stock price data of multiple brands.
#' If `append = FALSE`,
#' return a list object in which
#' the stock price data of each brand is an element.
#' The name of each element is a string with "b"
#' in front of the corresponding brand code.
#' For example, if the brand code is 1000,
#' the stock price data for that brand
#' can be obtained with `(object name)$b1000`.
#'
#' @importFrom dplyr bind_rows
#' @export
#'
#' @examples
#' # Combine the 2014 monthly stock price data of
#' # Sony Group (6758) and Nintendo Co., Ltd. (7974)
#' # into one data frame
#' scrape_more2firm(
#'   c(6758, 7974),
#'   start_date = 20140101,
#'   end_date = 20141231,
#'   datatype = "m"
#' )
#'
#' # Combine the 2014 monthly stock price data of
#' # APAMAN and YU-WA Creation Holdings
#' # into one data frame
#' scrape_more2firm(
#'   name = c("APAMAN", "YU-WA Creation Holdings"),
#'   start_date = 20140101,
#'   end_date = 20141231,
#'   datatype = "m",
#' )
#'
#' # Save the 2014 monthly stock price data of
#' # Sony Group (6758) and Nintendo Co., Ltd. (7974)
#' # a list named dt
#' dt <- scrape_more2firm(
#'   c(6758, 7974),
#'   start_date = 20140101,
#'   end_date = 20141231,
#'   datatype = "m",
#'   append = FALSE
#' )
#' dt$b6758 #extract Sony Group
#' dt$b7974 #extract Nintendo
#'
scrape_more2firm <- function(
  code, name = NULL, start_date, end_date, datatype,
  append = TRUE
) {
  if (!is.null(name)) {
    find <- code_detect(name)
    code <- find$code
  }
  if (append) {
    dt <- NULL
    for (i in code) {
      newdt <- scrape_onefirm(
        i,
        start_date = start_date,
        end_date = end_date,
        datatype = datatype
      )
      dt <- bind_rows(dt, newdt)
    }
    return(dt)
  } else {
    dt <- vector("list", length(code))
    for (i in seq_len(length(code))) {
      dt[[i]] <- scrape_onefirm(
        code[i],
        start_date = start_date,
        end_date = end_date,
        datatype = datatype
      )
    }
    names(dt) <- paste0("b", code)
    return(dt)
  }
}
